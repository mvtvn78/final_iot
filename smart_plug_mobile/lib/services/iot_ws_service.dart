import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class IotWsMessage {
  final bool? stateRelay;
  final String? power;
  final int? ts;

  IotWsMessage({this.stateRelay, this.power, this.ts});

  factory IotWsMessage.fromJson(Map<String, dynamic> j) => IotWsMessage(
        stateRelay: j["stateRelay"] is bool ? j["stateRelay"] as bool : null,
        power: j["power"]?.toString(),
        ts: j["ts"] is num
            ? (j["ts"] as num).toInt()
            : int.tryParse(j["ts"]?.toString() ?? ""),
      );
}

enum WsState { disconnected, connecting, connected }

class IotWsService {
  final String wsBase; // e.g. ws://10.198.26.62:8080
  IotWsService({required this.wsBase});

  WebSocketChannel? _channel;
  StreamSubscription? _sub;

  final _msgCtrl = StreamController<IotWsMessage>.broadcast();
  Stream<IotWsMessage> get stream => _msgCtrl.stream;

  final _stateCtrl = StreamController<WsState>.broadcast();
  Stream<WsState> get stateStream => _stateCtrl.stream;
  WsState _state = WsState.disconnected;
  WsState get state => _state;

  Timer? _reconnectTimer;
  int _retry = 0;

  int? _deviceId;
  String? _token;

  bool _manualDisconnect = false;

  void connect({required int deviceId, required String token}) {
    _deviceId = deviceId;
    _token = token;
    _manualDisconnect = false;

    _open();
  }

  void _setState(WsState s) {
    _state = s;
    _stateCtrl.add(s);
  }

  void _open() {
    if (_deviceId == null || _token == null) return;

    disconnect(); // close any existing, but keep saved params

    _setState(WsState.connecting);

    final safeToken = Uri.encodeComponent(_token!);
    final uri = Uri.parse("$wsBase/iot?deviceId=$_deviceId&token=$safeToken");

    try {
      _channel = WebSocketChannel.connect(uri);

      _sub = _channel!.stream.listen(
        (event) {
          final s = event.toString().trim();
          if (s.isEmpty) return;

          // nếu server có “hello/connected” message thì set connected tại đây
          // hoặc set connected ngay khi nhận được bất kỳ frame nào:
          if (_state != WsState.connected) _setState(WsState.connected);
          _retry = 0;

          final map = _extractMap(s);
          if (map == null) return;

          _msgCtrl.add(IotWsMessage.fromJson(map));
        },
        onError: (_) {
          if (_manualDisconnect) return;
          _setState(WsState.disconnected);
          _scheduleReconnect();
        },
        onDone: () {
          if (_manualDisconnect) return;
          _setState(WsState.disconnected);
          _scheduleReconnect();
        },
        cancelOnError: false,
      );
    } catch (_) {
      _setState(WsState.disconnected);
      _scheduleReconnect();
    }
  }

  Map<String, dynamic>? _extractMap(String s) {
    try {
      final obj = json.decode(s);

      // case 1: trực tiếp là Map
      if (obj is Map) {
        return obj.map((k, v) => MapEntry(k.toString(), v));
      }

      // case 2: dạng {payload:{...}}
      if (obj is Map<String, dynamic> && obj["payload"] is Map) {
        final p = obj["payload"] as Map;
        return p.map((k, v) => MapEntry(k.toString(), v));
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();

    // exponential backoff: 1,2,4,8,16,30 (max 30s)
    final sec = (1 << _retry).clamp(1, 30);
    _retry = (_retry + 1).clamp(0, 10);

    _reconnectTimer = Timer(Duration(seconds: sec), () {
      if (_manualDisconnect) return;
      _open();
    });
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _sub?.cancel();
    _sub = null;

    // close socket
    try {
      _channel?.sink.close();
    } catch (_) {}

    _channel = null;
    _setState(WsState.disconnected);
  }

  void manualDisconnect() {
    _manualDisconnect = true;
    disconnect();
  }

  void dispose() {
    manualDisconnect();
    _msgCtrl.close();
    _stateCtrl.close();
  }
}
