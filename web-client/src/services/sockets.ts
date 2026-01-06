

// Api web socket
const deviceId = localStorage.getItem('deviceId');
const token = localStorage.getItem('token');

const ws = new WebSocket(
    `ws://localhost:8080/iot?deviceId=${deviceId}&token=${token}`
  );

  ws.onopen = () => {
    console.log('Connected to the server');
  };

  ws.onmessage = (event) => {
    console.log('Message from server', event.data);
  };
  