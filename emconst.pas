unit EMConst;
// @000 2011.03.24 Noah Silva Started project
// @001 2011.03.31 Added Battery Level information
// @002 2011.03.31 Added Resource Strings
// @003 2011.03.31 Modified Typed: Word->Integer;
// v0.0.3 Release
// @004 2011.04.05 Added new resource strings
// @005 2011.08.01 Support for GP02
// @006 2011.08.04 Additional Resource Strings, Japanese Translation
// @007 2012.02.23 Added new routers, network types
// @008 2012.03.04 Added new constants for GP02 Software Update 2.0
// @009 2012.03.05 Adjustments for GP01 Software Update 3.0
// @010 2012.03.15 Added network type for GL01P (LTE)
// @011 2012.08.30 New Constants for Internet connectivity
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

ResourceString
   {.$.DEFINE LANG_EN}
   {$IFDEF LANG_EN}
  StrCharging = 'Charging';                                              //@002+
  StrNotCharging = 'Not Charging';                                       //@002+
  StrSDCardNone = 'Not Inserted';                                        //@002+
  StrSDCardInserted = 'Inserted';                                        //@002+
  StrNotSupported = 'Not Supported';                                     //@002+
  StrNoNetService = 'No Network Service';                                //@004+
  StrYesNetworkService = 'Network Service Available';                    //@004+
  StrUnknownNetworkType = 'Unknown Network Type: ';                      //@004+
  StrNoService = 'No Service';  // used for no network type              //@004+
  // Status Update Notification Strings
  StrNetworkType = 'Network Type: ';                                            //@006+
  StrBatteryStatus = 'Battery Status is now '; // Sharging Status               //@006+
  StrBatteryLevel = 'Battery Level: ';                                          //@006+
  StrSignalStrength = 'Signal Strength: ';                                      //@006+
  StrRoamStatusFalse = 'No';                                                    //@006+
  StrRoamStatusTrue = 'Yes';                                                    //@006+
  StrRoamStatusUnknown = 'Unknown';                                             //@006+
  StrConnected = 'Connected';                                                   //@011+
  StrNotConnected = 'Not Connected';                                            //@011+
   {$ELSE} // 日本語
   StrCharging = '充電中';
   StrNotCharging = '充電してない';
   StrSDCardNone = '導入されてない';
   StrSDCardInserted = '導入済';
//   StrNotSupported = 'サポートされてない';                                    //@006-
   StrNotSupported = '非対応';                                                  //@006+
   StrNoNetService = 'サービスがありません ';
   StrYesNetworkService = 'サービスががあります';
   StrUnknownNetworkType = 'ネットワーク種類不明: ';
   StrNoService = '電波が届けない';  // used for no network type
   // Status Update Notification Strings
    StrNetworkType = 'ネットワーク種類: ';
   StrBatteryStatus = '電池状態: '; // Sharging Status
   StrBatteryLevel = '充電レベル： ';
//   StrSignalStrength = '電波強さ：';                                          //@006-
   StrSignalStrength = '信号の品質：';                                          //@006+
    StrRoamStatusFalse = '無効';                                                //@006+
    StrRoamStatusTrue = '有効';                                                 //@006+
    StrRoamStatusUnknown = '状況不明';                                          //@006+
    StrConnected = '接続済';                                                    //@011+
    StrNotConnected = '接続されてない';                                         //@011+
    {$ENDIF}

CONST          // Line numbers in the conn.asp file
  OPERATOR_INFO_LINE=8;
  PPPINFO_LINE=10;
  SYSINFO_LINE=11;
  PPP_STATE_LINE = 18;  // iWanState = PPP_State =
  // MACRO_INVALID_DATA
  // MACRO_PPP_DISCONECTED
  // MACRO_PPP_CONNECTING
  // MACRO_PPP_CONNECTED

  WIFI_CLIENTS_line=26;
  SD_CARD_STATUS_LINE=27;
  EVDO_STATUS_LINE=28;     // Signal 0-5
  // MACRO_EVDO_LEVEL_ONE
  // MACRO_EVDO_LEVEL_FIVE

  // total time 29
  // total volume 30 (in, out)
  // DIAL_MODE_LINE 33
  // WLAN_ADV_SETTING 34


CONST
  IP_ADDR = '192.168.1.1';   // Normally the pocket WiFi is at this address


  MACRO_INVALID_DATA = -11111;
// System: Network Type
  MACRO_NETWORKTYPE_NO_SERVICE = 0;
  MACRO_NETWORKTYPE_GSM        = 1;
  MACRO_NETWORKTYPE_GPRS       = 2;
  MACRO_NETWORKTYPE_EDGE       = 3;
  MACRO_NETWORKTYPE_WCDMA      = 4;
  MACRO_NETWORKTYPE_HSDPA      = 5;
  MACRO_NETWORKTYPE_HSUPA      = 6;
  MACRO_NETWORKTYPE_HSPA       = 7;
  // Values below this comment are not returned by routers, but invented for    //@007+
  // this library                                                               //@007+
//  MACRO_NETWORKTYPE_HSPA_PLUS  = 8;                                             //@007+@009-
// Update HSPA+ for GP01 Firmware Update 3
  MACRO_NETWORKTYPE_HSPA_PLUS  = 9;                                             //@007+@009=
  // following is produced by GP02 according to some people
  MACRO_NETWORKTYPE_DCHSPA     = 9;                                             //@007+
  MACRO_NETWORKTYPE_LTE        = 19;                                            //@010+
  // Seems GP02 always returns one of these.
  //I can only assume 46 is better than 41
  MACRO_NETWORKTYPE_41         = 41;  // returned by GP02 rev 2                 //@008+
  MACRO_NETWORKTYPE_46         = 46;  // returned by GP02 rev 2                 //@008+

// Carrier Info
  MACRO_NETWORK_SERVICE_AVAILABILITY = 2;
// System: SIM Card Status
    MACRO_INVALID_SIM_CARD             = 0;
    MACRO_VALID_SIM_CARD               = 1;
    MACRO_CS_INVALID_SIM_CARD          = 2;
    MACRO_PS_INVALID_SIM_CARD          = 3;
    MACRO_PS_CS_INVALID_SIM_CARD       = 4;
    MACRO_ROMSIM_SIM_CARD              = 240;
    MACRO_NO_SIM_CARD                  = 255;
// Other SIM Card related stuff
    MACRO_SIM_LOCK_ENABLE              = 1;
    MACRO_CPIN_FAIL                    = 256;
    MACRO_PIN_READY                    = 257;
    MACRO_PIN_DISABLE                  = 258;
    MACRO_PIN_VALIDATE                 = 259;
    MACRO_PIN_REQ                      = 260;
    MACRO_PUK_REQ                      = 261;
    MACRO_SAVE_PIN_ENABLED = 1;
    MACRO_SAVE_PIN_DISABLED = 0;

// PPP Status                      // in case of GL01P
  MACRO_PPP_CONNECTING      =   0; //900
  MACRO_PPP_CONNECTED       =   1; //901
  MACRO_PPP_DISCONNECTED    =   2; //902
  // GL01P-only entries
  MACRO_PPP_DISCONNECTING   = 903;
  MACRO_PPP_DISCONNECT_FAIL = 904;
  MACRO_PPP_ROAM_FORBID     = 113;
// Signal Level
  MACRO_EVDO_LEVEL_ZERO   = 0;
  MACRO_EVDO_LEVEL_ONE    = 1;
  MACRO_EVDO_LEVEL_TWO    = 2;
  MACRO_EVDO_LEVEL_THREE  = 3;
  MACRO_EVDO_LEVEL_FOUR   = 4;
  MACRO_EVDO_LEVEL_FIVE   = 5;
// Equipment Model Type       機種種類
  EM_UNKNOWN              = 0;
  EM_D25HW                = 1; //7.2Mbps E560?
  EM_GP01                 = 2; //21Mbps  E586?
  EM_GP02                 = 3; //42Mbps  E587?                                  //@005+
  EM_GD03W                = 4; // Stick WiFi                                    //@007+
  EM_GL01P                = 5; // Huawei LTE 75Mbit                             //@007+
  EM_GL02P                = 6; // Anydata LTE 75Mbit                            //@007+
  EM_GP01r3               = 7; // GP01 Firmware Update #3 (acts like GP02)      //@009+
  //EM_GL04                 = ?;
  //Battery Status              電池状況
  EM_UNSUPPORTED          = -100;// I added for D25HW                           //@001+
  EM_BATTERY_NOT_CHARGING = 0;   // this is a guess                             //@001+
  EM_BATTERY_CHARGING     = 1;                                                  //@001+
  EM_SDCARD_INSERTED      = 0;       //determined experimentally                //@001+
  EM_SDCARD_NONE          = -1;      //determined experimentally                //@001+
  // Seems GP02 uses 0 for no card, 1 for card.

CONST
  http_timeout            = 500;                                                //@007+

TYPE TSrvStatus=Word;
TYPE TNetWorkType=Word;
TYPE TRawSIMCardStatus=Word;
TYPE TSysinfo = Record     // var sysinfo =
        srv_status:TSrvStatus;   // Service Status
        Dummy1:word;
        roam_status:Word;  // Roaming Status
        Dummy2:Word;
        card_state:TRawSimCardStatus;   // SIM Card State
        SIM_Lock:Word;
        Network_Type:TNetworkType; // Network Type (Edge, HSPA, etc.)
      end;
TYPE TCarrierInfo = Record
        CarrierStatus:Integer; // available, or...                              //@003=
        CarrierName:String; // 'EMOBILE', or...
      end;
TYPE TEVDOStatus=Integer;                                                       //@003+


implementation


end.

