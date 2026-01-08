#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stddef.h>
#include <math.h>
#include <string.h>
#include "esp_wifi.h"
#include "esp_mac.h"
#include "esp_system.h"
#include "nvs_flash.h"
#include "esp_event.h"
#include "esp_timer.h"
#include "esp_bt.h"
#include "esp_gap_ble_api.h"
#include "esp_gatts_api.h"
#include "esp_bt_main.h"
#include "esp_gatt_common_api.h"
#include "esp_netif.h"
#include "protocol_examples_common.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/semphr.h"
#include "freertos/queue.h"
#include "lwip/sockets.h"
#include "lwip/dns.h"
#include "lwip/netdb.h"
#include "esp_log.h"
#include "mqtt_client.h"
#include "esp_adc/adc_oneshot.h"
#include "esp_adc/adc_cali.h"
#include "esp_adc/adc_cali_scheme.h"
#include "driver/gpio.h"
static const char *TAG = "SMART_PLUG";
#define GATTS_SERVICE_UUID      0x00FF
#define GATTS_CHAR_UUID_RX      0xFF01  // Nhận từ Flutter
#define GATTS_CHAR_UUID_TX      0xFF02  // Gửi cho Flutter
#define GATTS_NUM_HANDLE        8       // Tăng từ 4 lên 8
#define PROFILE_NUM      1
#define PROFILE_APP_IDX  0
#define ADC_UNIT            ADC_UNIT_1
#define ADC_CHANNEL         ADC_CHANNEL_2       // GPIO 2
#define ADC_ATTEN           ADC_ATTEN_DB_12
#define SENSITIVITY         185.0               // Do nhay cho ACS712-5A (185 mV/A)
#define CALIB_FACTOR        1.0                 // He so hieu chinh (1.0 = khong hieu chinh)
#define ZERO_CURRENT_MV     2500                // Dien ap OUT khi I=0A (2.5V)
#define RELAY_PIN 4
#define PREPARE_BUF_MAX_SIZE    1024
#define ESP_BROKER_IP "mqtt://broker.emqx.io:1883" 
static uint8_t adv_config_done = 0;
uint32_t MQTT_CONNECTED = 0;
const int msDelay =350;
static int currentState = 0;
#define ADV_CONFIG_FLAG      (1 << 0)
static uint16_t gatts_if_store;
static uint16_t conn_id_store = 0xFFFF;
static uint16_t char_handle_tx = 0;
char ssid[256];
char password[256];
static char received_data[PREPARE_BUF_MAX_SIZE];
// Advertising data
static uint8_t adv_service_uuid[16] = {
    0xfb, 0x34, 0x9b, 0x5f, 0x80, 0x00, 0x00, 0x80,
    0x00, 0x10, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00,
};
static void mqtt_app_start(void);
static void mqtt_app_disconnect(void);
static void gatts_profile_event_handler(esp_gatts_cb_event_t event,
                                       esp_gatt_if_t gatts_if,
                                       esp_ble_gatts_cb_param_t *param);
char *get_device_name_from_mac(void)
{
    static char device_name[16];
    uint8_t mac[6];

    esp_read_mac(mac, ESP_MAC_WIFI_STA);

    snprintf(device_name, sizeof(device_name),
             "89_%02X%02X%02X%02X%02X%02X",
             mac[0], mac[1], mac[2],
             mac[3], mac[4], mac[5]);
    return device_name;
}
char *get_topic_relay_from_mac(void){
    static char topicSub[64];
    snprintf(topicSub, sizeof(topicSub),
         "/relay/%s", get_device_name_from_mac());
    return topicSub;
}
char *get_topic_data_from_mac(void){
    static char topicSub[64];
    snprintf(topicSub, sizeof(topicSub),
         "/data/%s", get_device_name_from_mac());
    return topicSub;
}
const char * device_name;
const char *topicPub;
const char *topicSubRelay;                  
static esp_ble_adv_data_t adv_data = {
    .set_scan_rsp = false,
    .include_name = true,
    .include_txpower = true,
    .min_interval = 0x0006,
    .max_interval = 0x0010,
    .appearance = 0x00,
    .manufacturer_len = 0,
    .p_manufacturer_data = NULL,
    .service_data_len = 0,
    .p_service_data = NULL,
    .service_uuid_len = sizeof(adv_service_uuid),
    .p_service_uuid = adv_service_uuid,
    .flag = (ESP_BLE_ADV_FLAG_GEN_DISC | ESP_BLE_ADV_FLAG_BREDR_NOT_SPT),
};

static esp_ble_adv_params_t adv_params = {
    .adv_int_min = 0x20,
    .adv_int_max = 0x40,
    .adv_type = ADV_TYPE_IND,
    .own_addr_type = BLE_ADDR_TYPE_PUBLIC,
    .channel_map = ADV_CHNL_ALL,
    .adv_filter_policy = ADV_FILTER_ALLOW_SCAN_ANY_CON_ANY,
};

struct gatts_profile_inst {
    esp_gatts_cb_t gatts_cb;
    uint16_t gatts_if;
    uint16_t app_id;
    uint16_t conn_id;
    uint16_t service_handle;
    esp_gatt_srvc_id_t service_id;
    uint16_t char_handle_rx;
    uint16_t char_handle_tx;
    uint16_t descr_handle;
    esp_bt_uuid_t char_uuid;
    esp_gatt_perm_t perm;
    esp_gatt_char_prop_t property;
    uint16_t descr_uuid;
};
static struct gatts_profile_inst heart_rate_profile_tab[PROFILE_NUM] = {
    [PROFILE_APP_IDX] = {
        .gatts_cb = gatts_profile_event_handler,
        .gatts_if = ESP_GATT_IF_NONE,
    },
};
void send_response(const char *message) {
    if (conn_id_store != 0xFFFF && char_handle_tx != 0) {
        // Gửi response
        esp_err_t ret = esp_ble_gatts_send_indicate(
            gatts_if_store, 
            conn_id_store, 
            char_handle_tx, 
            strlen(message), 
            (uint8_t *)message, 
            false
        );
        
        if (ret == ESP_OK) {
            ESP_LOGI(TAG, "✓ Đã gửi: %s", message);
        } else {
            ESP_LOGE(TAG, "✗ Lỗi gửi: %d", ret);
        }
    }
}
bool wifi_is_connected(void)
{
    wifi_ap_record_t ap_info;
    return esp_wifi_sta_get_ap_info(&ap_info) == ESP_OK;
}
void wifi_disconnect_if_needed(void)
{
    if (wifi_is_connected())
    {
        ESP_LOGI("WIFI", "WiFi is connected → disconnecting...");
        send_response("WiFi is connected → disconnecting...");
        esp_wifi_disconnect();
        vTaskDelay(pdMS_TO_TICKS(250)); // chờ ngắt hoàn toàn
    }
}
// call when bluetooth receive ssid and pass
void wifi_connect_from_bt(void)
{
    wifi_disconnect_if_needed();
    wifi_config_t wifi_config = {0};

    strcpy((char *)wifi_config.sta.ssid, ssid);
    strcpy((char *)wifi_config.sta.password, password);

    wifi_config.sta.threshold.authmode = WIFI_AUTH_WPA2_PSK;

    esp_wifi_set_config(WIFI_IF_STA, &wifi_config);
    esp_wifi_connect();
}
// Hiển thị thông tin QR Code
void print_qr_code() {
    uint8_t mac[6];
    esp_read_mac(mac, ESP_MAC_WIFI_STA);
    
    ESP_LOGI(TAG, "\n");
    ESP_LOGI(TAG, "╔════════════════════════════════╗");
    ESP_LOGI(TAG, "║   QUÉT QR ĐỂ KẾT NỐI BLE      ║");
    ESP_LOGI(TAG, "╠════════════════════════════════╣");
    ESP_LOGI(TAG, "║                                ║");
    ESP_LOGI(TAG, "║  Device: %-21s ║", device_name);
    ESP_LOGI(TAG, "║  MAC: %02X:%02X:%02X:%02X:%02X:%02X        ║",
             mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
    ESP_LOGI(TAG, "║                                ║");
    ESP_LOGI(TAG, "║  [█████████ QR CODE █████████] ║");
    ESP_LOGI(TAG, "║                                ║");
    ESP_LOGI(TAG, "║  Nội dung: %-19s ║", device_name);
    ESP_LOGI(TAG, "║                                ║");
    ESP_LOGI(TAG, "╚════════════════════════════════╝");
    ESP_LOGI(TAG, "\n");
}
// Xử lý tin nhắn và tạo response
void process_message(const char *msg, char *response, size_t response_size) {
    
    // Chuyển sang lowercase để so sánh (chỉ với ASCII)
    char lower_msg[512];
    strncpy(lower_msg, msg, sizeof(lower_msg) - 1);
    lower_msg[sizeof(lower_msg) - 1] = '\0';
    
    // Chuyển thành lowercase (chỉ với ký tự ASCII)
    for (int i = 0; lower_msg[i]; i++) {
        if (lower_msg[i] >= 'A' && lower_msg[i] <= 'Z') {
            lower_msg[i] = lower_msg[i] + 32;
        }
    }
    // Xử lý các lệnh - kiểm tra cả UTF-8 và ASCII
    if (strstr(lower_msg, "ping")) {
        snprintf(response, response_size, "ESP32-C3: Pong!");
    }
    else if(strstr(lower_msg,"info")){
        snprintf(response, response_size,
                    "{"
                        "\"name\": %s,"
                        "\"tpRelay\": \"%s\","
                        "\"tpData\": %s"
                    "}",
                    device_name,
                    topicPub,
                    topicSubRelay
        );
    }
    else if(sscanf(msg,"ssid=%256[^,],pass=%256[^\n]", ssid, password) == 2) {
        snprintf(response, response_size, "ESP32-C3: Nhận SSID: %s và Pass: %s", ssid, password);
        mqtt_app_disconnect();
        wifi_connect_from_bt();
    }
    else {
        snprintf(response, response_size, "ESP32-C3: Lệnh không xác định.");
    }
}
static void gap_event_handler(esp_gap_ble_cb_event_t event, esp_ble_gap_cb_param_t *param) {
    switch (event) {
    case ESP_GAP_BLE_ADV_DATA_SET_COMPLETE_EVT:
        adv_config_done &= (~ADV_CONFIG_FLAG);
        if (adv_config_done == 0) {
            esp_ble_gap_start_advertising(&adv_params);
        }
        break;
    case ESP_GAP_BLE_ADV_START_COMPLETE_EVT:
        if (param->adv_start_cmpl.status != ESP_BT_STATUS_SUCCESS) {
            ESP_LOGE(TAG, "Advertising start failed");
        } else {
            ESP_LOGI(TAG, "✓ Advertising started");
        }
        break;
    default:
        break;
    }
}
static void gatts_profile_event_handler(esp_gatts_cb_event_t event,
                                       esp_gatt_if_t gatts_if,
                                       esp_ble_gatts_cb_param_t *param) {
    switch (event) {
    case ESP_GATTS_REG_EVT: {
        ESP_LOGI(TAG, "REGISTER_APP_EVT, status %d, app_id %d",
                 param->reg.status, param->reg.app_id);
        
        heart_rate_profile_tab[PROFILE_APP_IDX].service_id.is_primary = true;
        heart_rate_profile_tab[PROFILE_APP_IDX].service_id.id.inst_id = 0x00;
        heart_rate_profile_tab[PROFILE_APP_IDX].service_id.id.uuid.len = ESP_UUID_LEN_16;
        heart_rate_profile_tab[PROFILE_APP_IDX].service_id.id.uuid.uuid.uuid16 = GATTS_SERVICE_UUID;

        esp_err_t set_dev_name_ret = esp_ble_gap_set_device_name(device_name);
        if (set_dev_name_ret) {
            ESP_LOGE(TAG, "set device name failed, error code = %x", set_dev_name_ret);
        }

        esp_err_t ret = esp_ble_gap_config_adv_data(&adv_data);
        if (ret) {
            ESP_LOGE(TAG, "config adv data failed, error code = %x", ret);
        }
        adv_config_done |= ADV_CONFIG_FLAG;

        esp_ble_gatts_create_service(gatts_if, &heart_rate_profile_tab[PROFILE_APP_IDX].service_id, GATTS_NUM_HANDLE);
        break;
    }
    case ESP_GATTS_READ_EVT:
        ESP_LOGI(TAG, "ESP_GATTS_READ_EVT");
        break;
    case ESP_GATTS_WRITE_EVT: {
        if (!param->write.is_prep) {
            ESP_LOGI(TAG, "✓ Nhận được data, len = %d", param->write.len);
            
            memset(received_data, 0, sizeof(received_data));
            
            // Giới hạn độ dài để tránh overflow
            int copy_len = (param->write.len < sizeof(received_data) - 1) 
                          ? param->write.len 
                          : sizeof(received_data) - 1;
            
            memcpy(received_data, param->write.value, copy_len);
            received_data[copy_len] = '\0';
            
            ESP_LOGI(TAG, "📨 Tin nhắn: %s", received_data);
            
            // Gửi response confirmation
            if (param->write.need_rsp) {
                esp_ble_gatts_send_response(
                    gatts_if,
                    param->write.conn_id,
                    param->write.trans_id,
                    ESP_GATT_OK,
                    NULL
                );
            }
            
            // Đợi 100ms trước khi gửi notification
            vTaskDelay(100 / portTICK_PERIOD_MS);
            
            // Xử lý tin nhắn và tạo response
            char response[512];
            process_message(received_data, response, sizeof(response));
            
            ESP_LOGI(TAG, "📤 Phản hồi: %s", response);
            
            // Gửi lại Flutter
            send_response(response);
        }
        break;
    }
    case ESP_GATTS_EXEC_WRITE_EVT:
        ESP_LOGI(TAG, "ESP_GATTS_EXEC_WRITE_EVT");
        break;
    case ESP_GATTS_MTU_EVT:
        ESP_LOGI(TAG, "ESP_GATTS_MTU_EVT, MTU %d", param->mtu.mtu);
        break;
    case ESP_GATTS_CONF_EVT:
        break;
    case ESP_GATTS_START_EVT:
        ESP_LOGI(TAG, "SERVICE_START_EVT, status %d, service_handle %d",
                 param->start.status, param->start.service_handle);
        break;
    case ESP_GATTS_CONNECT_EVT: {
        ESP_LOGI(TAG, "✓ Thiết bị đã kết nối!");
        ESP_LOGI(TAG, "   conn_id = %d", param->connect.conn_id);
        
        conn_id_store = param->connect.conn_id;
        gatts_if_store = gatts_if;
        
        esp_ble_conn_update_params_t conn_params = {0};
        memcpy(conn_params.bda, param->connect.remote_bda, sizeof(esp_bd_addr_t));
        conn_params.latency = 0;
        conn_params.max_int = 0x20;
        conn_params.min_int = 0x10;
        conn_params.timeout = 400;
        
        esp_ble_gap_update_conn_params(&conn_params);
        
        // Test gửi tin nhắn chào mừng
        vTaskDelay(1000 / portTICK_PERIOD_MS);
        send_response("ESP32-C3: Ket noi thanh cong!");
        
        break;
    }
    case ESP_GATTS_DISCONNECT_EVT:
        ESP_LOGI(TAG, "✗ Thiết bị ngắt kết nối, reason = 0x%x", param->disconnect.reason);
        esp_ble_gap_start_advertising(&adv_params);
        conn_id_store = 0xFFFF;
        break;
    case ESP_GATTS_CREAT_ATTR_TAB_EVT: {
        if (param->add_attr_tab.status != ESP_GATT_OK) {
            ESP_LOGE(TAG, "create attribute table failed, error code=0x%x", param->add_attr_tab.status);
        } else if (param->add_attr_tab.num_handle != GATTS_NUM_HANDLE) {
            ESP_LOGE(TAG, "create attribute table abnormally, num_handle (%d) doesn't equal to GATTS_NUM_HANDLE(%d)",
                     param->add_attr_tab.num_handle, GATTS_NUM_HANDLE);
        } else {
            ESP_LOGI(TAG, "✓ Attribute table created, num_handle = %d", param->add_attr_tab.num_handle);
        }
        break;
    }
    case ESP_GATTS_CREATE_EVT:
        ESP_LOGI(TAG, "CREATE_SERVICE_EVT, status %d, service_handle %d",
                 param->create.status, param->create.service_handle);
        
        heart_rate_profile_tab[PROFILE_APP_IDX].service_handle = param->create.service_handle;
        heart_rate_profile_tab[PROFILE_APP_IDX].char_uuid.len = ESP_UUID_LEN_16;
        heart_rate_profile_tab[PROFILE_APP_IDX].char_uuid.uuid.uuid16 = GATTS_CHAR_UUID_RX;

        esp_ble_gatts_start_service(heart_rate_profile_tab[PROFILE_APP_IDX].service_handle);

        esp_err_t add_char_ret = esp_ble_gatts_add_char(
            heart_rate_profile_tab[PROFILE_APP_IDX].service_handle,
            &heart_rate_profile_tab[PROFILE_APP_IDX].char_uuid,
            ESP_GATT_PERM_READ | ESP_GATT_PERM_WRITE,
            ESP_GATT_CHAR_PROP_BIT_READ | ESP_GATT_CHAR_PROP_BIT_WRITE | ESP_GATT_CHAR_PROP_BIT_NOTIFY,
            NULL, NULL);
        
        if (add_char_ret) {
            ESP_LOGE(TAG, "add char failed, error code =%x", add_char_ret);
        }
        break;
    case ESP_GATTS_ADD_CHAR_EVT: {
        ESP_LOGI(TAG, "ADD_CHAR_EVT, status %d, attr_handle %d, service_handle %d",
                 param->add_char.status, param->add_char.attr_handle, param->add_char.service_handle);
        
        if (param->add_char.status != ESP_GATT_OK) {
            ESP_LOGE(TAG, "Add characteristic failed, status = %d", param->add_char.status);
            break;
        }
        
        if (heart_rate_profile_tab[PROFILE_APP_IDX].char_handle_rx == 0) {
            // Đây là RX characteristic
            heart_rate_profile_tab[PROFILE_APP_IDX].char_handle_rx = param->add_char.attr_handle;
            
            ESP_LOGI(TAG, "✓ RX Characteristic added, handle = %d", param->add_char.attr_handle);
            
            // Thêm TX characteristic
            esp_bt_uuid_t char_uuid_tx;
            char_uuid_tx.len = ESP_UUID_LEN_16;
            char_uuid_tx.uuid.uuid16 = GATTS_CHAR_UUID_TX;
            
            esp_err_t add_char_ret = esp_ble_gatts_add_char(
                heart_rate_profile_tab[PROFILE_APP_IDX].service_handle,
                &char_uuid_tx,
                ESP_GATT_PERM_READ,
                ESP_GATT_CHAR_PROP_BIT_READ | ESP_GATT_CHAR_PROP_BIT_NOTIFY,
                NULL, NULL);
                
            if (add_char_ret) {
                ESP_LOGE(TAG, "Add TX char failed, error = %x", add_char_ret);
            }
        } else {
            // Đây là TX characteristic
            heart_rate_profile_tab[PROFILE_APP_IDX].char_handle_tx = param->add_char.attr_handle;
            char_handle_tx = param->add_char.attr_handle;
            
            ESP_LOGI(TAG, "✓ TX Characteristic added, handle = %d", param->add_char.attr_handle);
            
            // Thêm Client Characteristic Configuration Descriptor (CCCD)
            esp_bt_uuid_t descr_uuid;
            descr_uuid.len = ESP_UUID_LEN_16;
            descr_uuid.uuid.uuid16 = ESP_GATT_UUID_CHAR_CLIENT_CONFIG;
            
            esp_err_t add_descr_ret = esp_ble_gatts_add_char_descr(
                heart_rate_profile_tab[PROFILE_APP_IDX].service_handle,
                &descr_uuid,
                ESP_GATT_PERM_READ | ESP_GATT_PERM_WRITE,
                NULL, NULL);
                
            if (add_descr_ret) {
                ESP_LOGE(TAG, "Add descriptor failed, error = %x", add_descr_ret);
            } else {
                ESP_LOGI(TAG, "✓ CCCD Descriptor added");
            }
        }
        break;
    }
    default:
        break;
    }
}
static void gatts_event_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param) {
    if (event == ESP_GATTS_REG_EVT) {
        if (param->reg.status == ESP_GATT_OK) {
            heart_rate_profile_tab[PROFILE_APP_IDX].gatts_if = gatts_if;
        } else {
            ESP_LOGI(TAG, "reg app failed, app_id %04x, status %d",
                     param->reg.app_id,
                     param->reg.status);
            return;
        }
    }

    do {
        int idx;
        for (idx = 0; idx < PROFILE_NUM; idx++) {
            if (gatts_if == ESP_GATT_IF_NONE ||
                gatts_if == heart_rate_profile_tab[idx].gatts_if) {
                if (heart_rate_profile_tab[idx].gatts_cb) {
                    heart_rate_profile_tab[idx].gatts_cb(event, gatts_if, param);
                }
            }
        }
    } while (0);
}
static void wifi_event_handler(void* arg,
                               esp_event_base_t event_base,
                               int32_t event_id,
                               void* event_data)
{
    if (event_base == WIFI_EVENT)
    {
        switch (event_id)
        {
            case WIFI_EVENT_STA_START:
                printf("WiFi started\n");
                send_response("{\"code\" : 1, \"message\" : \"WiFi started\"}");
                break;
            case WIFI_EVENT_STA_CONNECTED:
                printf("WiFi connected to AP\n");
                send_response("{\"code\" : 2, \"message\" : \"WiFi connected to AP\"}");
                break;

            case WIFI_EVENT_STA_DISCONNECTED:
                printf("WiFi disconnected\n");
                send_response("{\"code\" : -1, \"message\" : \"WiFi disconnected or error\"}");
                break;
        }
    }

    if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP)
    {
        ip_event_got_ip_t* event = (ip_event_got_ip_t*) event_data;
        printf("Got IP: " IPSTR "\n", IP2STR(&event->ip_info.ip));
        // ==> KẾT NỐI WIFI THÀNH CÔNG
        send_response("{\"code\" : 0, \"message\" : \"Connected to WiFi\"}");
        mqtt_app_start();
    }
}
void wifi_init_sta(void)
{
    esp_netif_init();
    esp_event_loop_create_default();
    esp_netif_create_default_wifi_sta();

    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    esp_wifi_init(&cfg);

    esp_event_handler_instance_t instance_any_id;
    esp_event_handler_instance_t instance_got_ip;

    esp_event_handler_instance_register(
        WIFI_EVENT,
        ESP_EVENT_ANY_ID,
        &wifi_event_handler,
        NULL,
        &instance_any_id);

    esp_event_handler_instance_register(
        IP_EVENT,
        IP_EVENT_STA_GOT_IP,
        &wifi_event_handler,
        NULL,
        &instance_got_ip);

    esp_wifi_set_mode(WIFI_MODE_STA);
    esp_wifi_start();
}
adc_oneshot_unit_handle_t adc_handle = NULL;
adc_cali_handle_t adc_cali_handle = NULL;
bool do_calibration = false;
static bool adc_calibration_init(adc_unit_t unit, adc_channel_t channel, adc_atten_t atten, adc_cali_handle_t *out_handle) {
    adc_cali_handle_t handle = NULL;
    esp_err_t ret = ESP_FAIL;
    bool calibrated = false;
    adc_cali_curve_fitting_config_t cali_config = {
        .unit_id = unit, 
        .chan = channel, 
        .atten = atten, 
        .bitwidth = ADC_BITWIDTH_DEFAULT,
    };
    ret = adc_cali_create_scheme_curve_fitting(&cali_config, &handle);
    if (ret == ESP_OK) {
        calibrated = true;
        *out_handle = handle;
    }
    return calibrated;
}
/**
 * @brief Do dong dien RMS voi ACS712 - TRU OFFSET 2.5V
 * @param raw_out: Tra ve gia tri ADC raw trung binh
 * @param voltage_out: Tra ve dien ap (mV) trung binh
 * @param vmax_out: Tra ve dien ap MAX (mV)
 * @param vmin_out: Tra ve dien ap MIN (mV)
 * @return Dong dien RMS (Ampere)
 */
float get_current_rms(int *raw_out, int *voltage_out, int *vmax_out, int *vmin_out) {
    int voltage_raw = 0;
    int voltage_mv = 0;
    int max_mv = 0;
    int min_mv = 5000; // Khoi tao lon de dam bao cap nhat
    
    int sum_raw = 0;
    int sum_mv = 0;
    int count = 0;
    
    uint32_t start_tick = xTaskGetTickCount();
    
    // Do trong 100ms (khoang 5 chu ky AC 50Hz)
    while ((xTaskGetTickCount() - start_tick) < pdMS_TO_TICKS(100)) {
        ESP_ERROR_CHECK(adc_oneshot_read(adc_handle, ADC_CHANNEL, &voltage_raw));
        
        if (do_calibration) {
            ESP_ERROR_CHECK(adc_cali_raw_to_voltage(adc_cali_handle, voltage_raw, &voltage_mv));
        } else {
            voltage_mv = voltage_raw * 3300 / 4095;
        }

        // Cap nhat min/max
        if (voltage_mv > max_mv) max_mv = voltage_mv;
        if (voltage_mv < min_mv) min_mv = voltage_mv;
        
        // Tinh trung binh
        sum_raw += voltage_raw;
        sum_mv += voltage_mv;
        count++;
        
        vTaskDelay(pdMS_TO_TICKS(1));
    }

    // Gia tri trung binh
    *raw_out = (count > 0) ? (sum_raw / count) : 0;
    *voltage_out = (count > 0) ? (sum_mv / count) : 0;
    *vmax_out = max_mv;
    *vmin_out = min_mv;

    // Kiem tra loi doc ADC
    if (count == 0 || max_mv == 0) {
        return 0.0;
    }

    // *** PHAN QUAN TRONG: TRU OFFSET 2.5V ***
    // Tinh V_peak-to-peak (mV) - DA TRU OFFSET
    float v_pp = (float)(max_mv - min_mv);
    
    // Tinh V_peak (mV)
    float v_peak = v_pp / 2.0;
    
    // Tinh V_rms (mV)
    float v_rms = v_peak * 0.707; // 1/sqrt(2)
    
    // Tinh I_rms (A)
    float current = v_rms / SENSITIVITY;
    
    // Ap dung he so hieu chinh
    current = current * CALIB_FACTOR;
    
    // Loc nhieu - bo qua gia tri qua nho
    // Nguong 0.25A de tranh nhieu ESP32 ADC
    if (current < 0.25) {
        current = 0.0;
    }

    return current;
}
/**
 * @brief Lay dong dien RMS co loc trung binh de giam nhieu
 * @param raw_out: Tra ve gia tri ADC raw
 * @param voltage_out: Tra ve dien ap (mV)
 * @param vmax_out: Tra ve dien ap MAX (mV)
* @param vmin_out: Tra ve dien ap MIN (mV)
 * @return Dong dien RMS trung binh (Ampere)
 */
float get_filtered_current(int *raw_out, int *voltage_out, int *vmax_out, int *vmin_out) {
    float sum = 0.0;
    int samples = 3; // Lay 3 mau va tinh trung binh
    
    for (int i = 0; i < samples; i++) {
        sum += get_current_rms(raw_out, voltage_out, vmax_out, vmin_out);
        if (i < samples - 1) {
            vTaskDelay(pdMS_TO_TICKS(50)); // Delay 50ms giua cac mau
        }
    }
    
    return sum / samples;
}



void handle_mqtt_message(const char *topic, int topic_len,
                         const char *data, int data_len)
{
    char topic_buf[256];
    char data_buf[512];
    memcpy(topic_buf, topic, topic_len);
    topic_buf[topic_len] = '\0';
    memcpy(data_buf, data, data_len);
    data_buf[data_len] = '\0';
    printf("🚀 Received MQTT Message\n");
    printf("Topic: %s\n", topic_buf);
    printf("Data : %s\n", data_buf);
    if (strcmp(topic_buf, topicSubRelay) == 0)
    {
        if (strcmp(data_buf, "1") == 0) {
            currentState =1;
            gpio_set_level(RELAY_PIN, currentState);
            printf("BẬT\n");
        } 
        else if (strcmp(data_buf, "0") == 0) {
            currentState =0;
            gpio_set_level(RELAY_PIN, currentState);  // tắt đèn
            printf("TẮT\n");
        }
    }
}
static void mqtt_event_handler(void *handler_args, esp_event_base_t base, int32_t event_id, void *event_data)
{
    ESP_LOGD(TAG, "Event dispatched from event loop base=%s, event_id=%ld", base, (long)event_id);
    esp_mqtt_event_handle_t event = event_data;
    esp_mqtt_client_handle_t client = event->client;
    int msg_id;
    switch ((esp_mqtt_event_id_t)event_id)
    {
        case MQTT_EVENT_CONNECTED:
            ESP_LOGI(TAG, "MQTT_EVENT_CONNECTED");
            MQTT_CONNECTED = 1;
            msg_id = esp_mqtt_client_subscribe(client, topicSubRelay, 0);
            ESP_LOGI(TAG, "Subscribed, msg_id=%d", msg_id);
        break;
        case MQTT_EVENT_DISCONNECTED:
            ESP_LOGI(TAG, "MQTT_EVENT_DISCONNECTED");
            MQTT_CONNECTED = 0;
        break;
        case MQTT_EVENT_DATA:
            ESP_LOGI(TAG, "MQTT_EVENT_DATA");
            handle_mqtt_message(event->topic, event->topic_len,
                        event->data, event->data_len);
        break;
        default:
            ESP_LOGI(TAG, "Other event id:%ld", (long)event->event_id);
        break;
    }
}
esp_mqtt_client_handle_t client = NULL;
static void mqtt_app_disconnect(void)
{
    if (client == NULL) {
        ESP_LOGW(TAG, "MQTT client is NULL");
        return;
    }
    ESP_LOGI(TAG, "Disconnecting MQTT...");
    // Ngắt kết nối broker
    esp_mqtt_client_disconnect(client);
    // Dừng task MQTT
    esp_mqtt_client_stop(client);
    // Giải phóng tài nguyên
    esp_mqtt_client_destroy(client);
    client = NULL;
    MQTT_CONNECTED  = 0;
    ESP_LOGI(TAG, "MQTT disconnected");
}
static void mqtt_app_start(void)
{
    ESP_LOGI(TAG, "STARTING MQTT");
    esp_mqtt_client_config_t mqttConfig = {
        .broker.address.hostname = "broker.emqx.io",
        .broker.address.port = 1883,
        .broker.address.transport = MQTT_TRANSPORT_OVER_TCP,
    };
    client = esp_mqtt_client_init(&mqttConfig);
    esp_mqtt_client_register_event(client, ESP_EVENT_ANY_ID, mqtt_event_handler, client);
    esp_mqtt_client_start(client);
}
void DataTask(void*pvParameter)
{
    while(1)
    {
        if(MQTT_CONNECTED){
            int raw = 0;
            int voltage = 0;
            int vmax = 0;
            int vmin = 0;
            int power = 0;
            // Su dung ham loc trung binh de giam nhieu
            float I = get_filtered_current(&raw, &voltage, &vmax, &vmin);
            
            // Tinh Vpp va cong suat
            int vpp = vmax - vmin;
            float P = I * 220.0; // Cong suat (W)
            
            // In log chi tiet
            if (I == 0.0 || currentState ==0) {
                power = 0;
                ESP_LOGI(TAG, "raw=%d, V=%d mV (Vpp=%d mV) | I=%.3f A | P=0 W", 
                        raw, voltage, vpp, I);
            } else {
                power = P;
                ESP_LOGI(TAG, "raw=%d, V=%d mV (max=%d, min=%d, Vpp=%d mV) | I=%.3f A | P=%.1f W", 
                        raw, voltage, vmax, vmin, vpp, I, P);
            }
            char payload[150];
            int64_t ts = esp_timer_get_time() / 1000ULL; // epoch ms
            snprintf(payload, sizeof(payload),
                    "{"
                        "\"stateRelay\": %s,"
                        "\"power\": \"%u\","
                        "\"ts\": %lld"
                    "}",
                    currentState == 1 ? "true" : "false",
                    power,
                    ts
            );
            esp_mqtt_client_publish(client,topicPub,payload,0,0,0);
        }
        vTaskDelay(msDelay/ portTICK_PERIOD_MS);
    }
    if (do_calibration) {
        adc_cali_delete_scheme_curve_fitting(adc_cali_handle);
    }
    adc_oneshot_del_unit(adc_handle);
} 
void app_main(void)
{
    device_name =get_device_name_from_mac();
    topicPub = get_topic_data_from_mac();
    topicSubRelay = get_topic_relay_from_mac(); 
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND)
    {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);
    ESP_LOGI(TAG, "╔═══════════════════════════════════════╗");
    ESP_LOGI(TAG, "║   ESP32-C3 BLE SERVER STARTING...    ║");
    ESP_LOGI(TAG, "╚═══════════════════════════════════════╝");
     // Khởi tạo Bluetooth (chỉ BLE cho ESP32-C3)
    ESP_ERROR_CHECK(esp_bt_controller_mem_release(ESP_BT_MODE_CLASSIC_BT));
    esp_bt_controller_config_t bt_cfg = BT_CONTROLLER_INIT_CONFIG_DEFAULT();
    ret = esp_bt_controller_init(&bt_cfg);
    if (ret) {
        ESP_LOGE(TAG, "%s enable controller failed: %s", __func__, esp_err_to_name(ret));
        return;
    }
    ret = esp_bt_controller_enable(ESP_BT_MODE_BLE);
    if (ret) {
        ESP_LOGE(TAG, "%s enable controller failed: %s", __func__, esp_err_to_name(ret));
        return;
    }

    ret = esp_bluedroid_init();
    if (ret) {
        ESP_LOGE(TAG, "%s init bluetooth failed: %s", __func__, esp_err_to_name(ret));
        return;
    }

    ret = esp_bluedroid_enable();
    if (ret) {
        ESP_LOGE(TAG, "%s enable bluetooth failed: %s", __func__, esp_err_to_name(ret));
        return;
    }

    ret = esp_ble_gatts_register_callback(gatts_event_handler);
    if (ret) {
        ESP_LOGE(TAG, "gatts register error, error code = %x", ret);
        return;
    }

    ret = esp_ble_gap_register_callback(gap_event_handler);
    if (ret) {
        ESP_LOGE(TAG, "gap register error, error code = %x", ret);
        return;
    }

    ret = esp_ble_gatts_app_register(PROFILE_APP_IDX);
    if (ret) {
        ESP_LOGE(TAG, "gatts app register error, error code = %x", ret);
        return;
    }

    esp_err_t local_mtu_ret = esp_ble_gatt_set_local_mtu(500);
    if (local_mtu_ret) {
        ESP_LOGE(TAG, "set local MTU failed, error code = %x", local_mtu_ret);
    }
    wifi_init_sta();
    print_qr_code();
    ESP_LOGI(TAG, "✓ ESP32-C3 BLE Server sẵn sàng!");
    ESP_LOGI(TAG, "✓ Đang chờ kết nối...");
    gpio_config_t io_conf = {
        .mode = GPIO_MODE_OUTPUT,
        .pin_bit_mask = (1ULL << RELAY_PIN),
    };
    gpio_config(&io_conf);
    gpio_set_level(RELAY_PIN, currentState); // Khởi đầu tắt đèn
    adc_oneshot_unit_init_cfg_t init_config = { .unit_id = ADC_UNIT };
    ESP_ERROR_CHECK(adc_oneshot_new_unit(&init_config, &adc_handle));
    adc_oneshot_chan_cfg_t config = { 
        .bitwidth = ADC_BITWIDTH_DEFAULT, 
        .atten = ADC_ATTEN 
    };
    ESP_ERROR_CHECK(adc_oneshot_config_channel(adc_handle, ADC_CHANNEL, &config));
    do_calibration = adc_calibration_init(ADC_UNIT, ADC_CHANNEL, ADC_ATTEN, &adc_cali_handle);
    ESP_LOGI(TAG, "System Init OK. Calibration: %s", do_calibration ? "YES" : "NO");
    xTaskCreate(&DataTask, "DataTask", 4096, NULL, 5, NULL);
}