unit PWFMonGlobals;
//@000 2011.03.24 Noah SILVA Project started
//@001 2011.03.30 1. Incremented version number to 0.0.3 for GP01 Support
//                2. Add Icon constants
// v0.0.3 Release
//@002 2011.05.22 Noah SILVA Changed Version Number
//@003 2011.08.01 Noah SILVA Preliminary Support for GP02 version 0.0.5
//@004 2011.08.02 Noah SILVA Fixed data traffic chart for GP02
//@005 2011.08.04 Noah SILVA Japanese Translations
//@006 2011.08.05 Noah SILVA Further Internationalization of GUI
//@007 2011.08.13 Noah SILVA Version Update - Prepare for MacOS release,
//                           add Settings dialog
//@008 2012.02.23 Noah SILVA Minor Defect Corrections
//@009 2012.03.04 Noah SILVA Update version number, etc. (GP02r2 Support)
//@010 2012.03.15 Noah SILVA Updates for GL01P (LTE) Support version
//@011 2012.07.30 Noah SILVA Update for internet detection
{$mode objfpc}

interface

uses
  Classes, SysUtils;
ResourceString     // English version of Resource Strings
  StrVersion='Version 0.0.8'; //%0:s';         //@001=@002=@003=@004=@006=@007+@009@010
 // StrVersionNum = '0.0.3';                                            //@001+-
 {$DEFINE LANG_EN}
 {$IFDEF LANG_EN}
  StrNetworkType= 'Network Type: ';
  StrSimCardStatus = 'SIM Card Status';
  StrCarrier = 'Carrier: ';
  StrSignal = 'Signal: ';
  StrAppTitle = 'Pocket WiFi Monitor';                                          //@001+
  StrModel = 'Model: ';                                                         //@001+
  StrBatterylevel = 'Battery Level: ';                                          //@001+
  StrBattery = 'Battery';                                                       //@005+
  StrSDCard = 'SD Card';                                                        //@005+
  StrMobile = 'Mobile';                                                         //@005+
  StrData = 'Data';                                                             //@005+
  StrChartElip = 'Chart...';                                                    //@005+
  StrCarrierName = 'Carrier Name:';                                             //@005+
  StrRoamingStatus = 'Roaming Status:';                                         //@005+
  StrUpload = 'Sent:';   // as in Sent                                          //@006+
  StrDownload = 'Received:'; // as in Received                                  //@006+
  StrCurrTP = 'Current Throughput';                                             //@006+
  StrAvgTP = 'Average Throughput';                                              //@006+
  StrSDCardStatus = 'SD Card Status:';                                          //@006+
  StrTotalSize = 'Total Size:';                                                 //@006+
  StrWANIP = 'WAN IP Address:';                                                 //@006+
  StrDNS1 = 'Primary DNS:';                                                     //@006+
  StrDNS2 = 'Secondary DNS:';                                                   //@006+
  StrFrmBWChartCaption = 'Bandwidth Utilization';                               //@006+
  StrCrtBAndwidthTitle = 'Network Bandwidth Utilization (KBps)';                //@006+
  StrAppAbout = 'About Pocket WiFi Monitor';                                    //@006+
  StrmiAbout = 'About...' ;                                                     //@006+
  StrmiQuit = 'Quit' ;                                                          //@006+
  StrmiStatus = 'Status...' ;                                                   //@006+
  StrmiSettings = 'Preferences...' ;                                            //@007+
  StrFrmSettings = 'Preferences' ;                                              //@007+
  StrlblUpdateFreq = 'Update Frequency' ;                                       //@007+
  StrWifiClientCount = 'Current WiFi Clients:';                                 //@009+
  StrWifiClientMax = 'Maximum WiFi Clients:';                                   //@009+
  StrInternetConnectivity = 'Internet Connectivity:';                           //@011+
  {$ELSE}   // Japanese                                                         //@005+
  StrNetworkType= 'ネットワーク種類：';
  StrSimCardStatus = 'SIMカード状況：';
  StrCarrier = 'キャリア：';
  StrSignal = '電波状況：';
  StrAppTitle = 'ポケットワイファイ監視ツール';
  StrModel = '製品モデル：';
  StrBatterylevel = '充電レベル：';
  StrBattery = '電池';                                                          //@005+
  StrSDCard = 'SDカード';                                                       //@005+
  StrMobile = 'モーバイル';                                                     //@005+
  StrData = 'データ伝送';                                                       //@005+
  StrChartElip = 'グラフ…';                                                     //@005+
  StrCarrierName = 'キャリア名：';                                              //@005+
  StrRoamingStatus = 'ローミング状況：' ;                                       //@005+
  StrUpload = '送信：';   // as in Sent                                         //@006+
  StrDownload = '受信：'; // as in Received                                     //@006+
  StrCurrTP = '現在のスループット';                                             //@006+
  StrAvgTP = '平均スループット';                                                //@006+
  StrSDCardStatus = 'SDカードの状況：';                                         //@006+
  StrTotalSize = '合計サイズ';                                                  //@006+
  StrWANIP = 'WANのIPアドレス：';                                               //@006+
  StrDNS1 = 'プライマリDNS：';                                                  //@006+
  StrDNS2 = 'セカンダリDNS：';                                                  //@006+
  StrFrmBWChartCaption = '帯域幅利用';                                          //@006+
  StrCrtBAndwidthTitle = 'ネットワーク帯域幅利用(KBps)';                        //@006+
  StrAppAbout = 'ポケットワイファイ監視ツールについて';                         //@006+
  StrmiAbout = 'バーション情報…' ;                                              //@006+
  StrmiQuit = '終了' ;                                                          //@006+
  StrmiStatus = '状況…' ;                                                       //@006+
  StrmiSettings = '設定…' ;                                                     //@007+
  StrFrmSettings = '設定' ;                                                     //@007+
  StrlblUpdateFreq = '更新頻度' ;                                               //@007+
  StrWifiClientCount = '無線LAN接続数:';                                        //@009+
  StrWifiClientMax = 'WiFiクライエント接続可能台数:';                           //@009+@011=
  StrInternetConnectivity = 'インターネット接続済:';                            //@011+
  {$ENDIF}

Const
  ICON_RED_DOT   = 6;                                                           //@001+
  ICON_GREEN_DOT = 7;                                                           //@001+
  ICON_RADAR_MIN = 8;                                                           //@008+
  ICON_RADAR_MAX = 15;                                                          //@008+

Var
  NetworkType:String;
  ShowMainForm:Boolean=False;

implementation
// 0 = isrv_status     Service Status
//        MACRO_NETWORK_SERVICE_AVAILABILITY
// 1 =
// 2 = roam_status
// 3 =
// 4 = icardstate      SIM Card Status
//        MACRO_INVALID_SIM_CARD
//        MACRO_NO_SIM_CARD
//        MACRO_PS_CS_INVALID_SIM_CARD
//        MACRO_INVALID_DATA
// 5 =
// 6 = network_type    Type of Network we are connected to
//        MACRO_NETWORKTYPE_GSM
//        MACRO_NETWORKTYPE_GPRS
//        MACRO_NETWORKTYPE_EDGE
//        MACRO_NETWORKTYPE_WCDMA
//        MACRO_NETWORKTYPE_HSDPA
//        MACRO_NETWORKTYPE_HSUPA
//        MACRO_NETWORKTYPE_HSPA
//        MACRO_INVALID_DATA
//        MACRO_NETWORKTYPE_NO_SERVICE

end.

