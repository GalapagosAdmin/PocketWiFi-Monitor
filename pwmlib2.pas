Unit PWMLib2;
// eMobile D25HW/GP01/GP02 Pocket WiFi Access Library
// Harware is made by Huawei and sold as E5 elsewhere.
//@000 2011.03.24 Noah SILVA First Version.
//@001 2011.03.29 Modifications for a more dynamic approach.
//@002 2011.03.28 Error Checking, grab whole carrier name.
//@003 2011.03.30 Add autodetection of GP01 model
//@005 2011.03.30 CGI Post and XML Functions GP01 model
//                Switched GetJSVar to GetWebVar which can handle XML as well
//@006 2011.03.30 Battery Status Functions for GP01
//@007 2011.03.31 1. Battery Status Text for GP01
//                2. SD-Card related functions
// --- PocketWiFiMonitor v0.0.3 Release
//@008 2011.03.31 Unit Clean-Up:
//                 1. Function Name Normalization
//                 2. Remove Data paramaters for functions in INTERFACE
//@009 2011.04.05 Added NetworkType number to message for unknown type
//                Moved some hardcoded strings into EMConst ResourceStrings
//                Created function to build CGI URLs
//                Added WAN IP and DNS Server IP address functions
//                Added additional error checking to GP01 sysinfo routines
//@010 2011.05.23 Added CellInfoRSCP, CellInfoRSSI
//@011 2011.05.24 Added CellInfoEcIo, CellInfoSignalLevel, ExtractKbps
//                Added Last Refreshed Timestamp, moved ExtractKBps here
// --- PocketWiFiMonitor v0.0.4 Release
//@012 2011.04.26 Converted most StrToInt calls to SafeStrToInt
//@013 2011.08.01 Changes to support GP02
//@014 2011.08.02 Further GP02 Support (Download throughput),
//@015 2011.08.03 Battery state, Signal Strength tracking
//@016 2011.08.04 Network Type Change Tracking
//                Addition of various functions/overloads to move SysInfo to
//                private
//@017 2012.02.23 Re-Enable SIM Card Status
//                Additional debug code
//                Special case D25HW in some routines
//                Fall back to autodetect when router is unreachable
//@018 2012.03.04 GetWiFiClients, related state tracking logic
//@019 2012.03.05 Improve Reset logic on error (Reset primed status to false).
//                Adjustments for GP01 Software Update #3
//@020 2012.03.15 Support for GL01P (LTE)
{$mode objfpc}{$H+}

// To Do:
// * Automatic Lazy Data Refresh (Based on last refresh timestamp),
//     Caching of results within 1000 ms, refresh if older
// * Comparison of previous results (to report changes) - In Progress
// * HTTP calls in the background (Thread) to keep the GUI responsive
// * Consider where Object Orientation might be beneficial
// * Add fields available on newer models (i.e. Connected WiFi Clients, etc.)

interface

uses
  Classes, SysUtils,
  httpsend,// Synapse HTTP libraries
  EMConst, // eMobile/Huawei D25HW/GP01/GP02 Constants
  WebVar;  // Javascript/XML Variable extraction

Type
  TSimCardStatus = set of (INVALID_SIM_CARD, VALID_SIM_CARD,
           CS_INVALID_SIM_CARD,  PS_INVALID_SIM_CARD, PS_CS_INVALID_SIM_CARD,
           ROMSIM_SIM_CARD, NO_SIM_CARD, SIM_STATUS_UNKNOWN);
  //  TEquipmentModel = set of (MODEL_UNKNOWN, D25HW, GP01);
  TEquipmentModel = Integer;


  Function DecodeSysinfo:TSysInfo;                                              //@001=//@008=
//  Function DecodeCarrierInfo(const RAWdata:AnsiString):TCarrierInfo;          //@001=@008-
  Function DecodeCarrierInfo:TCarrierInfo;                                      //@008+
//  Function DecodeEVDOStatus(const RAWdata:AnsiString):TEVDOStatus;            //@001=
//Function DecodeEVDOStatus(const RAWdata:AnsiString):TEVDOStatus;              //@001=@008-
  Function GetEVDOStatusCode:TEVDOStatus;                                       //@008+
  Function SrvStatusGetText(Status:TSrvStatus):String;                          //Service Status
//  Function NetworkTypeGetText(NetworkType:TNetworkType):String;               //@016-
  Function NetworkTypeGetText:String; Overload;                                 //@016+
//  Function SIMCardStatusGetText(Const                                         //@016-
//                               SIMCardStatusCode:TRawSIMCardStatus):String;   //@016-
  Function SIMCardStatusGetText:String; Overload;                               //@016+
  Function SIMCardStatusGet(Const SIMCardStatusCode:TRawSIMCardStatus):TSimCardStatus;
  // Returns an integer code representing the model we are accessing
  Function GetEquipmentModelCode:TEquipmentModel;                               //@003+//@008=
  Function GetEquipmentModelText:String;                                        //@003+
  // Refresh the Status Data by polling the unit
  // Returns true if successful, and modifies the passed mmdata Stringlist
//  Function RefreshStatusData(Var StatusData:TStringList):Boolean;             //@004+@008-
  Function RefreshStatusData:Boolean;                                           //@008-
  // temporary, for debugging
 // function HttpPostText(const URL, URLData: string; const Response: TStrings): Boolean;
  Function GetBatteryLevelCode:Integer;                                         //@006+/@008=
  Function GetBatteryStatusCode:Integer;                                        //@006+@007=
  Function GetBatteryStatusText:String;                                         //@007+
//  Function GetBatteryStatusText(const code:Integer):String;overload;          //@014+@016-
  Function GetSDCardStatusCode:Integer;                                         //@007+
  Function GetSDCardStatusText:String;                                          //@007+
  Function GetSDCardTotalVolume:String;                                         //@007+
  Function GetCurrentDownloadThroughput:String;                                 //@007+
  Function GetCurrentUploadThroughput:String;                                   //@007+
  Function GetAverageDownloadThroughput:String;                                 //@007+
  Function GetAverageUploadThroughput:String;                                   //@007+
  Function GetWANIP:String;                                                     //@009+
  Function GetDNS1:String;                                                      //@009+
  Function GetDNS2:String;                                                      //@009+
  // UTMS/WCDMA Received Signal Code Power
  Function CellInfoRSCP:Integer;                                                //@010+
  // UMTS/WCDMA Received Signal Strength Indicator
  Function CellInfoRSSI:Integer;                                                //@010+
  Function CellInfoEcIo:Integer;                                                //@011+
  Function CellInfoSignalLevel:Integer;                                         //@011+
  Function ExtractKBps(Str:String):Real;                                        //@011+
  Function GetStateChange_Battery:Boolean;                                      //@015+
  Function GetStateChange_EVDOStatusCode:Boolean;                               //@015+
  Function GetStateChange_BatteryLevelCode:Boolean;                             //@015+
  Function GetStateChange_NetworkType:Boolean;                                  //@016+
  Function GetStateChange_WiFiClientCount:Boolean;                              //@018+
  Function roam_statusGetCode:Word; // VSysInfo.roam_status                     //@016+
  Function Network_TypeGetCode:TNetWorkType;                                    //@016+
  Function GetRoamingStatusText:UTF8String;                                     //@016+
  // Current Connected WiFi Client Count
  Function GetWiFiClients:Integer;                                              //@018+
  // Maximum WiFi Client Count
  Function GetWiFiClientMax:Integer;                                            //@018+

implementation

uses
  math,                                                                         //@013+
  dbugintf; // For debug server                                                 //@014+

Type                                                                            //@015+
  TState=record                                                                 //@015+
    BatteryStatusCode:Integer;                                                  //@015+
    EVDOStatusCode:TEVDOStatus;                                                 //@015+
    BatteryLevelCode:Integer;
    WiFiClientCount:Integer;                                                    //@018+
    NetworkType:TNetworkType;                                                   //@016+
  end;                                                                          //@015+

Var
  EquipmentModel:TEquipmentModel=EM_UNKNOWN;                                    //@003+
  mmData:TStringList; // temporary - for holding Raw HTML/XML results
  LastRefreshTimeStamp:TDateTime;
 // LastBatteryState:Integer;                                                   //@014+@015-
 _LastState:TState;                                                             //@015+
 // The following should be turned into an array or record...
 _StateChange_BatteryStatusCode:Boolean;                                        //@015+
 _StateChange_WiFiClientCount:Boolean;                                          //@018+
 _StateChange_EVDOStatusCode:Boolean;                                           //@015+
 _StateChange_BatteryLevelCode:Boolean;                                         //@015+
 _StateChange_NetworkType:Boolean;                                              //@016+
 _Primed:Boolean=false; //This is to let us know we got data at least once      //@015+
 _SysInfo:TSysInfo;                                                             //@016+

 Function SafeStrToInt(const str:String; Const Default:Integer):Integer; //@012+
   begin
    try
     result := StrToInt(Str);
    except
      result := Default;
    end;
   end;


  Function SafeStrToInt(const str:String):Integer;                       //@010+
   begin
 //   try                                                                //@012-
//    result := StrToInt(Str);                                           //@012-
    result := SafeStrToInt(Str, 0);                                      //@012+
//    except                                                             //@012-
//      result := 0;                                                     //@012-
//    end;                                                               //@012-
   end;

  // Begin of Insertion @011+
  // Converts Bps into KBps if necessary, and returns a numeric result
  // Used for GetCurrentUploadThroughput, etc.
  Function ExtractKBps(Str:String):Real;                                //@011+
   var
      loc:Integer;
   begin
          Try
               Loc := POS(' KBps', Str);
               // If it's in KBps, then just extract the numeric portion
                If  Loc > 0 then
                 begin
                   Result := StrToFloat(Copy(Str, 1, Loc-1));
                 end;
                Loc := POS(' Bps',Str);
               // If it's in Bps then divide by 1000 to get KBps
                If Loc > 0 then
                 begin
                   Result := StrToFloat(Copy(Str, 1, Loc-1)) / 1000;
                 end;
               // Otherwise we can't read it, just return zero
                except  // invalid data
                  Result := 0;
                end;
   end;  // of ExtractKBPS
  // End of Insertion @011+


  // Private internal use only, since it should only be called once, at start-up
  Function ModelDetect:TEquipmentModel;                                         //@003+
   var
     url:UTF8String;                                                            //@017=
     data:TStringList;
     Success:Boolean;
     DeviceName:UTF8String;                                                     //@019+
   begin
    Result := EM_UNKNOWN;                                                       //@013+
    // The next URL exists only on the GP02, GP01r3, and GL01P                  //@013+@020=
    URL := 'http://' + ip_addr + '/html/indexfs.htm';                           //@013+
    try                                                                         //@013+
      Data := TStringList.Create;                                               //@013+
      Success := httpgettext(URL, data, http_timeout);                           //@013+//@017=
  //    writeln(data.Text);                                                     //@013+
      CASE Success of                                                           //@013+
        TRUE:Result  := EM_GP02;                                                //@013+
        FALSE:Result := EM_UNKNOWN;                                             //@013+
      end;                                                                      //@013+
    finally                                                                     //@013+
      data.free;                                                                //@013+
    end;                                                                        //@013+

    // Right now we know it looks like a GP02, but it could be a GP01 Rev 3, or
    // GL01P, so we test that
//@019+ Begin of Insertion
     If Result = EM_GP02 THEN                                                    //@019+
      begin
        URL := 'http://' + ip_addr + '/api/device/information';
        try
          Data := TStringList.Create;
          Success := httpgettext(URL, data, http_timeout);
      //    writeln(data.Text);
          CASE Success of
            TRUE:begin
                   DeviceName := GetXMLVar(Data.text, 'DeviceName');
                   If DeviceName = 'GP01' then
                     Result := EM_GP01r3
                   else if DeviceName = 'GL01P' then                            //@020+
                     Result := EM_GL01P                                         //@020+
                   else
//                    If DeviceName = 'GP02' then
                     Result  := EM_GP02;
//                   else
//                     Result := EM_UNKNOWN;
                 end;
            FALSE:Result := EM_UNKNOWN;
          end;
        finally
          data.free;
        end;  // of TRY..FINALLY
      end;  // of RESULT = EM_GP02
//@019+ End of Insertion

     IF NOT (Result = EM_UNKNOWN) THEN EXIT;                                    //@013+

    // The next URL exists on the GP01 and GP02  (Test for GP01)
    URL := 'http://' + ip_addr + '/html/indexf.htm';
    try
      Data := TStringList.Create;
      Success := httpgettext(URL, data, http_timeout);                          //@017=
//      writeln(data.Text);
      CASE Success of
        TRUE:Result  := EM_GP01;
        FALSE:Result := EM_UNKNOWN; // or it could be no router at all          //@017=
      end;
    finally
      data.free;
    end;
    IF NOT (Result = EM_UNKNOWN) THEN EXIT;                                     //@017+
    // Test for D25HW
    URL := 'http://' + ip_addr + '/en/conn.asp';                                //@017+
    try                                                                         //@017+
       Data := TStringList.Create;                                              //@017+
       Success := httpgettext(URL, data, http_timeout);                         //@017+
   //    writeln(data.Text);                                                    //@017+
       If Success then Result := EM_D25HW;                                      //@017+
     finally                                                                    //@017+
       data.free;                                                               //@017+
     end;                                                                       //@017+

   end; // of Procedure


Function GetEquipmentModelCode:TEquipmentModel;                                 //@003+@008=
  begin
   // If it's still unknown, try to figure it out
   // (Otherwise don't waste time trying every single time)
   If EquipmentModel = EM_UNKNOWN then
     begin
       EquipmentModel := ModelDetect;
       SendDebug('Model Detected:' + GetEquipmentModelText);
     end;
   // Pass the result.
   Result := EquipmentModel;
  end;



Function GetBatteryStatusCode:Integer;                                          //@006+@007=
  begin
   Case GetEquipmentModelCode of                                                //@008=
     EM_GP01,
     EM_GP01r3,                                                                 //@019+
     EM_GL01P,                                                                  //@020+
     EM_GP02:
       Result := SafeStrToInt(GetXMLVar(mmdata.text, 'BatteryStatus'));         //@012=
       // there is no way to get this from D25HW so far as I know
       else result := EM_UNSUPPORTED;
   end;
  end;



Function GetBatteryStatusText(Const Code:Integer):String;                       //@007+
 begin
//  Case GetBatteryStatusCode of                                                //@014-
   Case Code of                                                                 //@014+
    EM_BATTERY_CHARGING:Result := StrCharging;
    EM_BATTERY_NOT_CHARGING: Result := StrNotCharging;
    EM_UNSUPPORTED:Result := StrNotSupported;
    else
      Result := 'Unknown Status' + IntToStr(GetBatteryStatusCode);
  end;
 end;

Function GetBatteryStatusText:String;                                           //@014+
  begin
    Result := GetBatteryStatusText(GetBatteryStatusCode);
  end;

Function GetSDCardStatusCode:Integer;                                           //@007+
  begin
   Case GetEquipmentModelCode of                                                //@008=
    EM_GP01: Result :=
                   SafeStrToInt(GetXMLVar(mmdata.text, 'SdCardStatus'));        //@012=
    EM_GP01r3,                                                                  //@019+
    EM_GL01P,                                                                   //@020+
    EM_GP02: Result :=                                                          //@013+
                   SafeStrToInt(GetXMLVar(mmdata.text, 'SdCardStatus'))-1;      //@013+
//    IF GetEquipmentModelCode = EM_GP02 then
//      If result = EM_SDCARD_INSERTED then result := EM_SDCARD_NONE;
       // there is no way to get this from D25HW so far as I know
       else result := EM_UNSUPPORTED;
   end;

  end;

Function GetSDCardStatusText:String;                                     //@007+
 begin
  Case GetSDCardStatusCode of
   EM_SDCARD_INSERTED: Result := StrSDCardInserted;
   EM_SDCARD_NONE:     Result := StrSDCardNone;
   EM_UNSUPPORTED:     Result := StrNotsupported;
    else
      Result := 'Unknown Status' + IntToStr(GetSDCardStatusCode);
  end;
 end;


Function GetBatteryLevelCode:Integer;                                           //@006+@008=
  begin
   Case GetEquipmentModelCode of                                                //@008=
     EM_GP01,
     EM_GP01r3,                                                                 //@019+
     EM_GL01P,                                                                  //@020+
     EM_GP02: Result :=                                                         //@013=
                   SafeStrToInt(GetXMLVar(mmdata.text, 'BatteryLevel'));        //@012=
       // there is no way to get this from D25HW so far as I know
//       else result := -1;                                                     //@012-
        else result := EM_UNSUPPORTED;                                          //@012+
   end;
  end;

Function GetSDCardTotalVolume:String;                                           //@007+
  begin
   Case GetEquipmentModelCode of                                                //@008=
     EM_GP01: Result := GetXMLVar(mmdata.text, 'SdCardTotalVolume');
       // there is no way to get this from D25HW so far as I know
       else result := StrNotSupported;
   end;
  end;

// Converts GP02 style BPS (just a number) into GP01 style
// (annotated with Bps or KBps)
Function RawBPStoGP01(const GP02BPS:String):String;                             //@014+
  Begin
   try
     If StrToFloat(GP02BPS) > 1000 then
      Result := FloatToStr(StrToFloat(GP02BPS)/1000) + ' KBps'
     else
      Result := GP02BPS + ' Bps';
   except
     SendDebug('Error in PWMLib2.RawBPStoGP01: GP02BPS='+ GP02BPS);
     Result := '0';
   end;
  end;

Function GetCurrentDownloadThroughput:String;                                   //@007+
  begin
   Case GetEquipmentModelCode of                                                //@008=
     EM_GP01: Result := GetXMLVar(mmdata.text, 'CurrentDownloadThroughput');
     EM_GP01r3,                                                                 //@019+
     EM_GL01P,                                                                  //@020+
     EM_GP02: begin                                                             //@013+
                  Result := RawBPStoGP01(                                       //@014+
                    GetXMLVar(mmdata.text, 'CurrentDownloadRate'));             //@013+
              end;
       // there is no way to get this from D25HW so far as I know
       else result := StrNotSupported;
   end;
  end;

Function GetCurrentUploadThroughput:String;                                     //@007+
  begin
   Case GetEquipmentModelCode of                                                //@008=
     EM_GP01: Result := GetXMLVar(mmdata.text, 'CurrentUploadThroughput');
     EM_GP01r3,                                                                 //@019+
     EM_GL01P,                                                                  //@020+
     EM_GP02: Result := RawBPStoGP01(                                           //@014+
                        GetXMLVar(mmdata.text, 'CurrentUploadRate'));           //@013+
       // there is no way to get this from D25HW so far as I know
       else result := StrNotSupported;
   end;
  end;


Function GetAverageDownloadThroughput:String;                                   //@007+
  begin
   Case GetEquipmentModelCode of                                                //@008=
     EM_GP01:
           Result := GetXMLVar(mmdata.text, 'CurrentAverageDownloadThroughput');
       // there is no way to get this from D25HW so far as I know
       else result := StrNotSupported;
   end;
  end;

Function GetAverageUploadThroughput:String;                                     //@007+
  begin
   Case GetEquipmentModelCode of                                                //@008=
     EM_GP01:
          Result := GetXMLVar(mmdata.text, 'CurrentAverageUploadThroughput');
       // there is no way to get this from D25HW so far as I know
       else result := StrNotSupported;
   end;
  end;

Function GetWANIP:String;                                                       //@009+
  begin
   Case GetEquipmentModelCode of
     EM_GP01,
     EM_GP01r3,                                                                 //@019+
     EM_GL01P,                                                                  //@020+
     EM_GP02: Result := GetXMLVar(mmdata.text, 'WanIPAddress');                 //@013+
       // there is no way to get this from D25HW so far as I know
       else result := StrNotSupported;
   end;
  end;

Function GetDNS1:String;                                                        //@009+
  begin
   Case GetEquipmentModelCode of
     EM_GP01,
     EM_GP01r3,                                                                 //@019+
     EM_GL01P,                                                                  //@020+
     EM_GP02: Result := GetXMLVar(mmdata.text, 'PrimaryDns');                   //@013+
       // there is no way to get this from D25HW so far as I know
       else result := StrNotSupported;
   end;
  end;

Function GetDNS2:String;                                                        //@009+
  begin
   Case GetEquipmentModelCode of
     EM_GP01,
     EM_GP01r3,                                                                 //@019+
     EM_GL01P,                                                                  //@020+
     EM_GP02: Result := GetXMLVar(mmdata.text, 'SecondaryDns');                 //@013+
       // there is no way to get this from D25HW so far as I know
       else result := StrNotSupported;
   end;
  end;
// UTMS/WCDMA Received Signal Code Power
Function CellInfoRSCP:Integer;                                                  //@010+
Begin
 Case GetEquipmentModelCode of
  EM_GP01: Result := SafeStrToInt(GetXMLVar(mmdata.text, 'CellinfoRscp'));
    // there is no way to get this from D25HW so far as I know
    else result := EM_UNSUPPORTED;                                              //@012=
 end;
end;

// UMTS/WCDMA Received Signal Strength Indicator
Function CellInfoRSSI:Integer;                                                  //@010+
 begin
  Case GetEquipmentModelCode of
   EM_GP01:begin
            Result := SafeStrToInt(GetXMLVar(mmdata.text, 'CellinfoRssi'));
           end;
   // there is no way to get this from D25HW so far as I know
     else result := EM_UNSUPPORTED;                                             //@012=
  end;
 end;


// UMTS/WCDMA Ec/Io
Function CellInfoEcIo:Integer;                                           //@011+
 begin
  Case GetEquipmentModelCode of
   EM_GP01:begin
             Result := SafeStrToInt(GetXMLVar(mmdata.text, 'CellinfoEcio'));
           end;
   // there is no way to get this from D25HW so far as I know
     else result := EM_UNSUPPORTED;                                             //@012=
  end;
 end;

// UMTS/WCDMA Signal Level of the tower we are connected to?
Function CellInfoSignalLevel:Integer;                                           //@011+
 begin
  Case GetEquipmentModelCode of
   EM_GP01:begin
             Result :=
               SafeStrToInt(GetXMLVar(mmdata.text, 'CellinfoSignalLevel'));
           end;
   // there is no way to get this from D25HW so far as I know
     else result := EM_UNSUPPORTED; //0;                                        //@012=
  end;
 end;


Function DecodeSysinfoD25HW(const RAWdata:AnsiString):TSysInfo;                 //@001=
 var                                                                            //@001+
   RawSysInfo:AnsiString; // Contents of Variable                               //@001+
 begin
  RawSysInfo := GetJSVar(RAWData, 'sysinfo');                                   //@001+//@005+
//   if pos('sysinfo', RAWData) = 0 then                                        //@001-
   If Length(RawSysInfo) = 0 then                                               //@001+
   begin
     // report error
     exit;
   end;
 //  [1,2,3,4,5,6,7]
 //  [2,2,0,5,1,0,7]
 //  123456789012345
   Result.srv_status := SafeStrToInt(RawSysInfo[2]);                            //@001=@012=
   // 17 is comma                    3
   // 18 is Dummy1                   4
   // 19 is comma                    5
   // 20 is Roaming Status           6
   Result.roam_status:=SafeStrToInt(RawsysInfo[6]);                             //@001=@012=
   // 21 is comma                    7
   // 22 is Dummy 2                  8
   // 23 is comma                    9
   // 24 is SIM Card State           10
   Result.Card_State := SafeStrToInt(RawSysInfo[10]);                           //@001=@012=
   // 25 is comma                    11
   // 26 is Dummy 3                  12
   // 27 is comma                    13
   // 28 is Network Type             14
   Result.Network_Type := SafeStrToInt(RawSysInfo[14]);                         //@001=@012=
 end;

Function DecodeSysinfoGP01(const RAWdata:AnsiString):TSysInfo;                  //@001=
  begin
//   try                                                                        //@012-
//    Result.srv_status := StrToInt(GetXMLVar(RawData, 'CurrentServiceStatus'));
//   Except                                                                     //@012-
//     Result.srv_status := MACRO_INVALID_DATA;                                 //@012-
//   end;                                                                       //@012-
   Result.srv_status := SafeStrToInt(
                                     GetXMLVar(RawData, 'CurrentServiceStatus'),
                                     MACRO_INVALID_DATA                         //@012+
                                    );
//   try                                                                        //@012-
//     Result.roam_status :=  StrToInt(GetXMLVar(RawData, 'RoamingStatus'));
//   Except                                                                     //@012-
//     Result.srv_status := MACRO_INVALID_DATA;                                 //@012-
//   end;                                                                       //@012-
Result.roam_status :=  SafeStrToInt(                                            //@012+
                                     GetXMLVar(RawData, 'RoamingStatus'),       //@012+
                                     MACRO_INVALID_DATA                         //@012+
                                    );                                          //@012+

//   try                                                                        //@012-
//     Result.Card_State := StrToInt(GetXMLVar(RawData, 'SysinfoSIMState'));
//   Except                                                                     //@012-
//     Result.srv_status := MACRO_INVALID_DATA;                                 //@012-
//   end;                                                                       //@012-
Result.Card_State := SafeStrToInt(GetXMLVar(RawData, 'SysinfoSIMState'),        //@012+
                                  MACRO_INVALID_DATA);                          //@012+

//   try                                                                        //@012-
//     Result.Network_Type := StrToInt(GetXMLVar(RawData, 'CurrentNetworkType'));
//   Except                                                                     //@012-
//     Result.srv_status := MACRO_INVALID_DATA;                                 //@012-
//   end;                                                                       //@012-
    Result.Network_Type := SafeStrToInt(                                        //@012+
                     GetXMLVar(RawData, 'CurrentNetworkType'),                  //@012+
                     MACRO_INVALID_DATA);                                       //@012+

  end;

Function DecodeSysinfoGP02(const RAWdata:AnsiString):TSysInfo;                  //@013+
  begin
   // not sure if this is the same
   Result.srv_status := SafeStrToInt(
                                     GetXMLVar(RawData, 'ConnectionStatus'),
                                     MACRO_INVALID_DATA
                                    );
   // Same as GP01
   Result.roam_status :=  SafeStrToInt(
                                     GetXMLVar(RawData, 'RoamingStatus'),
                                     MACRO_INVALID_DATA
                                    );
   Result.Card_State := SafeStrToInt(GetXMLVar(RawData, 'SimStatus'),
                                  MACRO_INVALID_DATA);

   Result.Network_Type := SafeStrToInt(
                     GetXMLVar(RawData, 'CurrentNetworkType'),
                     MACRO_INVALID_DATA);

  end;


//Function DecodeSysinfo(const RAWdata:AnsiString):TSysInfo;                    //@001=
Function DecodeSysinfo:TSysInfo;                                                //@008+
 begin
  Case GetEquipmentModelCode of                                                 //@008=
    EM_GP01 :Result := DecodeSysinfoGP01(mmData.Text);//RAWData);               //@008=
    EM_GP01r3,                                                                  //@019+
    EM_GL01P,   // same as GP02 until we know different                         //@020+
    EM_GP02 :Result := DecodeSysinfoGP02(mmData.Text);                          //@013+
    EM_D25HW:Result := DecodeSysinfoD25HW(mmData.Text);//RAWData);              //@008=@017=
  end;
 end;

Function SrvStatusGetText(Status:TSrvStatus):String;
  begin
   CASE Status OF
     MACRO_NETWORK_SERVICE_AVAILABILITY : Result := StrYesNetworkService;       //@009=
     else
       Result := StrNoNetService;                                               //@009=
   end;
  end;

// This version should be private
Function NetworkTypeGetText(NetworkType:TNetworkType):String;
  begin
   // GP01 and GP02 seem to always return WCDMA, even if connected to abetter
   // network.
   // GP02 occasionally returns HSPA or HSDPA
   CASE NetworkType OF
       MACRO_NETWORKTYPE_NO_SERVICE : Result := StrNoService;                   //@009=
       MACRO_NETWORKTYPE_GSM        : Result := 'GSM';
       MACRO_NETWORKTYPE_GPRS       : Result := 'GPRS';
       MACRO_NETWORKTYPE_EDGE       : Result := 'EDGE';
       MACRO_NETWORKTYPE_WCDMA      : Result := 'WCDMA';
       MACRO_NETWORKTYPE_HSDPA      : Result := 'HSDPA';
       MACRO_NETWORKTYPE_HSUPA      : Result := 'HSUPA';
       MACRO_NETWORKTYPE_HSPA       : Result := 'HSPA';      // and HSPA + ?
       MACRO_NETWORKTYPE_HSPA_PLUS  : Result := 'HSPA+';                        //@019+
       // The following are guesses - all that is known is these two are
       // returned by GP02 rev 2.
       MACRO_NETWORKTYPE_41       : Result := 'DC-HSPA';      // GP02 Rev 2     //@018+
       MACRO_NETWORKTYPE_46       : Result := 'DC-HSPA+';     // GP02 Rev 2     //@018+
       MACRO_NETWORKTYPE_LTE      : Result := 'LTE';          // GL01P          //@020+
     else
       Result := StrUnknownNetworkType + inttostr(NetworkType);                 //@009=
   end;
  end;

Function NetworkTypeGetText:String;                                             //@016+
  begin
   Result := NetworkTypeGetText(_SysInfo.Network_Type);
  end;

Function SIMCardStatusGetText(Const SIMCardStatusCode:TRawSIMCardStatus):String;
begin
 CASE SIMCardStatusCode OF
     MACRO_INVALID_SIM_CARD          : Result := 'Invalid SIM Card';
     MACRO_VALID_SIM_CARD            : Result := 'Valid SIM Card';
     MACRO_CS_INVALID_SIM_CARD       : Result := 'CS Invalid SIM Card';
     MACRO_PS_INVALID_SIM_CARD       : Result := 'PS Invalid SIM Card';
     MACRO_PS_CS_INVALID_SIM_CARD    : Result := 'PS CS Invalid SIM Card';
     MACRO_ROMSIM_SIM_CARD           : Result := 'ROMSIM SIM Card';
     MACRO_NO_SIM_CARD               : Result := 'No SIM card!';
   else
     Result := 'Unknown SIM Card Status';
 end;
end;

Function SIMCardStatusGetText:String;                                           //@016+
 begin
  Result := SIMCardStatusGetText(_SysInfo.card_state);
 end;

Function SIMCardStatusGet(Const SIMCardStatusCode:TRawSIMCardStatus):TSimCardStatus;
begin
 CASE SIMCardStatusCode OF
     MACRO_INVALID_SIM_CARD          : Result := [INVALID_SIM_CARD];            //@017=
     MACRO_VALID_SIM_CARD            : Result := [VALID_SIM_CARD];              //@017=
     MACRO_CS_INVALID_SIM_CARD       : Result := [CS_INVALID_SIM_CARD];         //@017=
     MACRO_PS_INVALID_SIM_CARD       : Result := [PS_INVALID_SIM_CARD];         //@017=
     MACRO_PS_CS_INVALID_SIM_CARD    : Result := [PS_CS_INVALID_SIM_CARD];      //@017=
     MACRO_ROMSIM_SIM_CARD           : Result := [ROMSIM_SIM_CARD];             //@017=
     MACRO_NO_SIM_CARD               : Result := [NO_SIM_CARD];                 //@017=
   else
     Result := [SIM_STATUS_UNKNOWN];                                            //@017=
 end;
end;


//Function DecodeCarrierInfoGP01(const RAWdata:AnsiString):TCarrierInfo         //@005+@008-
Function DecodeCarrierInfoGP01:TCarrierInfo;                                    //@008+
 begin  //
//  Result.CarrierName := GetXMLVar(RAWData, 'CurrentProvider');                //@008-
  Result.CarrierName := GetXMLVar(mmData.Text, 'CurrentProvider');              //@008+
//  Result.CarrierStatus := StrToInt(GetWebVar(RAWData, 'CurrentServiceStatus')); //@008-
  Result.CarrierStatus :=
                SafeStrToInt(GetWebVar(mmData.text, 'CurrentServiceStatus'));   //@008+
 end;

Function DecodeCarrierInfoGP02:TCarrierInfo;                                    //@013+
 begin  //
  Result.CarrierName := GetXMLVar(mmData.Text, 'FullName');
  Result.CarrierStatus :=
                SafeStrToInt(GetWebVar(mmData.text, 'State'));
 end;


Function DecodeCarrierInfoD25HW(Const RAWdata:AnsiString):TCarrierInfo;         //@005=
  var                                                                           //@001+
    RawCarrierInfo:AnsiString;                                                  //@001+
    RawCarrierStatus:Char;                                                      //@001+
    p:integer;
  begin
    RawCarrierInfo := GetJSVar(RAWData, 'operator_rat');          //@001+//@005=
//    if pos('operator_rat', RAWData) = 0 then                           //@001-
    If Length(RawCarrierInfo) = 0 then                                   //@001+
        // report error
        exit;
    TRY
      RawCarrierStatus := RawCarrierInfo[3];                             //@001=
      Result.CarrierStatus:=
        SafeStrToInt(RawCarrierStatus, MACRO_INVALID_DATA);         //@001=@012=
      p := 8; // 27; // CarrierNameStartPos                              //@002+
      Result.CarrierName:= '';                                           //@002+
      While (RawCarrierInfo[p] <> '''')                           //@002+//@001=
        and (p < Length(RawCarrierInfo)) do                       //@002+//@001=
       begin                                                             //@002+
        Result.CarrierName                                        //@002+//@001=
            := Result.CarrierName + RawCarrierInfo[p];            //@002+//@001=
        inc(p);                                                          //@002+
       end;                                                              //@002+
   EXCEPT
     Result.CarrierStatus:= MACRO_INVALID_DATA;
     Result.CarrierName := '';
   end;    // of TRY..EXCEPT
  end;    // of FUNCTION

//Function DecodeCarrierInfo(const RAWdata:AnsiString):TCarrierInfo;            //@005+@008-
Function DecodeCarrierInfo:TCarrierInfo;                                        //@008+
  begin
    Case GetEquipmentModelCode of   //@008=
//     EM_GP01:Result := DecodeCarrierInfoGP01(RAWData);                        //@008-
     EM_GP01 : Result := DecodeCarrierInfoGP01;                                 //@008+
     EM_GP01r3,                                                                 //@019+
     EM_GL01P,                                                                  //@020+
     EM_GP02 : Result := DecodeCarrierInfoGP02;                                 //@013+
//     else Result := DecodeCarrierInfoD25HW(RAWData);                          //@008-
     EM_D25HW : Result := DecodeCarrierInfoD25HW(mmData.Text);                  //@008+@017+
      else
        with result do                                                          //@017+
         begin                                                                  //@017+
           CarrierName:='Unknown';                                              //@017+
           CarrierStatus:=0;  // is Zero right? //fixme                         //@017+
         end;                                                                   //@017+
    end;
  end;


//Function DecodeEVDOStatus(Const RAWdata:AnsiString):TEVDOStatus;              //@001-@008-
Function GetEVDOStatusCode:TEVDOStatus;                                         //@001+
var                                                                             //@001+
  RawEVDOStatus:AnsiString; // Contents of Variable                             //@001+
begin
 //writeln(mmdata.Text);
 Case GetEquipmentModelCode of                                                  //@008=
  // There is also a "CellinfoSignalLevel" available...
   // one of the few places that GP01r3 behaves more like GP01r1 than GP02
   EM_GP01, EM_GP01r3:                                                          //@019=
            RawEVDOStatus := GetXMLVar(mmData.Text, 'SignalStrength');          //@005+
   // GP02 gives this as a percentage
   EM_GL01P,                                                                    //@020+
   EM_GP02: RawEVDOStatus :=
        IntToStr(Floor(StrToInt(GetXMLVar(mmData.Text, 'SignalStrength'))/20)); //@013+
//   else RawEVDOStatus := GetJSVar(RAWData, 'ievdoState');                     //@001+@005=@008-
   EM_D25HW: RawEVDOStatus := GetJSVar(mmData.Text, 'ievdoState');              //@008+@017=
   else                                                                         //@017+
     // We haven't detected a known model yet
    RawEVDOStatus := '';                                                        //@017+
 end;
 //  if pos('ievdoState', RAWData) = 0 then                                     //@001-
 If Length(RawEVDOStatus) = 0 then                                              //@001+
  begin
      // report error
      SendDebug('PWMLib2.GetEVDOStatusCode: Invalid EVDO Status! (empty)');     //@014=
      exit;
    end;
// Try                                                                          //@001+@012-
  Result:=SafeStrToInt(RawEVDOStatus[1], MACRO_INVALID_DATA);                   //@001=@012=
// Except                                                                       //@001+@012-
//   Result := MACRO_INVALID_DATA;                                              //@001+@012-
// end;// of TRY                                                                //@001+@012-
end;

Function URLDownload(const URL:String; const FullPath:String):Boolean;
// Downloads the specified URL to the complete path given.
// Returns true if no problems, false if it couldn't download.
    Var
      FileStream:TMemoryStream;
    Begin
      FileStream := TMemoryStream.Create;
        Try
          If not HttpGetBinary(URL, FileStream) then
            Result := False
          Else
             Begin
            //   filestream.
               FileStream.SaveToFile(FullPath);
               result := True;
             end;
         finally
           FileStream.Free;
         end;   // of TRY..FINALLY
    end;  // of FUNCTION

// for D25HW, at least first formware revision.
Function RefreshStatusDataJS(Var StatusData:TStringList):Boolean;               //@004+
  Var
    url:String;
  begin
// for D25HW  EM_D25HW
    URL := 'http://' + ip_addr + '/en/conn.asp';
    Result := httpgettext(URL, StatusData, http_timeout);                       //@004=@017=
    _primed := Result;                                                          //@018+
    LastRefreshTimeStamp := Now();                                              //@011+
  end;

Function GetCGI_URL(const cgi_name:String):String;                       //@009+
 begin
   Result := 'http://' + ip_addr + '/'+ cgi_name+ '.cgi';
 end;

// Relies on custom function HttpPostText added to Synapse
// For GP01 (Pocket WiFi G4) rev 1 and 2
Function RefreshStatusDataXML(Var StatusData:TStringList):Boolean;       //@005+
 var
   url, urldata:String;
   Response:TStringList;
begin
//  URL := 'http://192.168.1.1/language.cgi';
  URL := GetCGI_URL('status');                                           //@009-
//  URL := 'http://' + ip_addr + '/status.cgi';                          //@009+
  URLData := 'operation_type=get&pname=' ;
  Response := TStringList.create;
// Following line is custom Synapse modification
  result := HttpPostText(URL, URLData, Response);
  _primed := Result;                                                           //@018+
  StatusData.Text:=Response.Text;
 // case result of
 //   true:ShowMessage('Ok');
 //   false:ShowMEssage('Error');
 // end;
  Response.free;
  LastRefreshTimeStamp := Now();                                                //@011+
end;

// Used for GP02 and GP01 Rev3
Function RefreshStatusDataGP02(Var StatusData:TStringList):Boolean;             //@013+
var
  url, urldata:String;
  Response:TStringList;
  begin
   Response := TStringList.create;
   try                                                                          //@018+
   // Signal strength, battery, etc.
   Case GetEquipmentModelCode of                                                //@020+
     EM_GL01P:URL := 'http://' + ip_addr + '/api/monitoring/status';            //@020+
   else                                                                         //@020+
     URL := 'http://' + ip_addr + '/api/monitoring';
   end;                                                                         //@020+
   result := HttpGetText(URL, Response);
   _primed := Result;                                                           //@018+
   if not result then exit;                                                     //@018+
   StatusData.Text:=Response.Text;
   // Traffic Info
   URL := 'http://' + ip_addr + '/api/monitoring/traffic-statistics';
   result := HttpGetText(URL, Response);
   _primed := Result;                                                           //@018+
   if not result then exit;                                                     //@018+
   StatusData.Add(Response.Text);

   // Carrier Info
   URL := 'http://' + ip_addr + '/api/net/current-plmn';
   result := HttpGetText(URL, Response);
   _primed := Result;                                                           //@018+
   if not result then exit;                                                     //@018+
   StatusData.Add(Response.Text);

   If Not GetEquipmentModelCode = EM_GL01P then                                 //@020+
    begin                                                                       //@020+
      // SD-Card Info
      URL := 'http://' + ip_addr + '/api/sdcard/sdcard';
      result := HttpGetText(URL, Response);
      _primed := Result;                                                        //@018+
      StatusData.Add(Response.Text);
    end;                                                                        //@020+

   finally                                                                      //@018+
     Response.free;
   end;                                                                         //@018+
   LastRefreshTimeStamp := Now();
//   writeln(StatusData.Text);

   // http://pocketwifi.home/api
   // 2 EMOBILE JP EMOBILE 44000 2
   // http://pocketwifi.home/api/monitoring
   // 901 80 4 2 0 1 4 0 1.112.87.109 60.254.193.158 117.55.64.152 3 5 2 2 1
   // /api/monitoring/status
   // /api/pin/status
   // /api/net/current-plmn
   // /api/monitoring/checknews
   // /api/language/current-language

{

/api/gp02/private
n
     *
/api/dhcp/settings
/api/dialup/connection
/api/dialup/profiles
/api/monitoring/clear-traffic
/api/monitoring/status
/api/monitoring/traffic-statistics
/api/net/network  *
/api/net/register
/api/security/firewall-switch
/api/sdcard/getpath
/api/sdcard/sdcard
/api/sdcard/sdfile   (for uploading)
/api/sdcard/sdcapacity
/api/sdcard/createdir
/api/sdcard/deletefile
/api/sdcard/sdfilestate
/api/submit/checksum
/api/user/logout
/api/user/password
/api/user/state-login
<?xml version="1.0" encoding="UTF-8"?>
<response>
<Hosts>
<Host>
<ID>1</ID>
<MacAddress>10:93:e9:08:a1:42</MacAddress>
<IpAddress>192.168.1.101</IpAddress>
<HostName></HostName>
<AssociatedTime>4580</AssociatedTime>
<AssociatedSsid>ssid1</AssociatedSsid>
</Host>
</Hosts>
</response>
/api/wlan/multi-basic-settings
/api/wlan/multi-security-settings
}
  end;

// Generic routine auto-selects as appropriate
//Function RefreshStatusData(Var StatusData:TStringList):Boolean;               //@004+@008+
Function RefreshStatusData:Boolean;                                             //@008+
  Begin
   try

   // Save current Status
  try
   If _Primed then                                                              //@018+
   With _LastState do                                                           //@015+
    begin                                                                       //@015+
      BatteryStatusCode := GetBatteryStatusCode;                                //@014+@015=
      EVDOStatusCode := GetEVDOStatusCode;                                      //@015+
      BatteryLevelCode := GetBatteryLevelCode;                                  //@015+
      NetworkType := _SysInfo.Network_Type;                                     //@016+
      WiFiClientCount := GetWiFiClients;                                        //@018+
    end;                                                                        //@015+
  except                                                                        //@018+
     SendDebug('Error while saving status. in RefreshStatusData');
    // just trap the exception                                                                             //@018+
  end;
// Do the actual data refresh
   Case GetEquipmentModelCode of                                                //@001+@008=
//    EM_GP01: Result := RefreshStatusDataXML(StatusData);                      //@001+@008-
    EM_GP01: Result := RefreshStatusDataXML(mmData);                            //@008+
    EM_GL01P,                                                                   //@020+
    EM_GP01r3, EM_GP02: Result := RefreshStatusDataGP02(mmdata);                //@013+@019=
//        Result := RefreshStatusDataJS(StatusData);                            //@001+@008-
    EM_D25HW:Result := RefreshStatusDataJS(mmData);                             //@008+@017+
    Else   //Unknown Router
      Result := False;                            // We have nothing to give    //@017+
   end;
   if not result then SendDebug ('Data download failed.');
   _Primed := Result;                                                           //@015+
   if not _primed then exit;                                                    //@018+
//    If _Primed then                                                              //@016+
     _SysInfo := DecodeSysinfo;                                                 //@016+
// process state differences
//   If _Primed then                                                              //@015+
//     begin
// This should work for all models currently supported
   if _LastState.EVDOStatusCode <> GetEVDOStatusCode then                       //@015=
     _StateChange_EVDOStatusCode := True;                                       //@015+
   if _LastState.NetworkType <> _SysInfo.Network_Type then                      //@016=
     _StateChange_NetworkType := True;                                          //@016+
// G4 only features
   Case GetEquipmentModelCode of                                                 //@014+
    EM_GP01,
    EM_GP01r3,                                                                  //@019+
    EM_GL01P,                                                                   //@020+
    EM_GP02:begin                                                               //@014+
              if _LastState.BatteryStatusCode <> GetBatteryStatusCode then      //@014+@015=
                _StateChange_BatteryStatusCode := True;                         //@015=
              if _LastState.BatteryLevelCode <> GetBatteryLevelCode then        //@014+@015=
                _StateChange_BatteryLevelCode := True;                          //@015=
              if _LastState.WiFiClientCount <> GetWiFiClients then              //@018+
                _StateChange_WiFiClientCount := True;                           //@018=
            end;                                                                //@014+
   end; // of CASE
// end; // of IF PRIMED

 except
   on E : Exception do                                                          //@017+
     begin
       SendDebug('Error in PWMLib2.RefreshStatusData:' + E.Message);            //@017=
       // Could be they switched to a different router we support.
       EquipmentModel := EM_UNKNOWN;                                            //@017+
       _primed := False;                                                        //@019+
     end;
 end;
end; // of PROCEDURE

(*
// synapse didn't include this, but it's useful for AJAX
   *)
Function GetEquipmentModelText:String;                                          //@003+
 begin
      Case GetEquipmentModelCode of                                             //@001+//@008=
       EM_GP01: Result := 'GP01';
       EM_GP01r3: Result := 'GP01 rev.3';                                       //@019+
       EM_GP02: Result := 'GP02';                                               //@013+
       EM_GL01P: Result := 'GL01P';                                             //@020+
// for D25HW  EM_D25HW
       EM_D25HW: Result := 'D25HW';                                             //@017=
         Else                                                                   //@001+
           Result := 'Unknown';                                                 //@017+
    end; // of CASE                                                             //@001+
 end;

Function GetStateChange_Battery:Boolean;                                        //@015+
  begin
   // Has it changed since last time?
   Result := _StateChange_BatteryStatusCode;
    if _StateChange_BatteryStatusCode then
      _StateChange_BatteryStatusCode := False;
  end;

Function GetStateChange_WiFiClientCount:Boolean;                                //@018+
  begin
   // Has it changed since last time?
   Result := _StateChange_WiFiClientCount;
    if _StateChange_WiFiClientCount then
      _StateChange_WiFiClientCount := False;
  end;


Function GetStateChange_BatteryLevelCode:Boolean;                               //@015+
  begin
   // Has it changed since last time?
   Result := _StateChange_BatteryLevelCode;
    if _StateChange_BatteryLevelCode then
      _StateChange_BatteryLevelCode := False;
  end;

Function GetStateChange_EVDOStatusCode:Boolean;                                 //@015+
  begin
   // Has it changed since last time?
   Result := _StateChange_EVDOStatusCode;
    if _StateChange_EVDOStatusCode then
      _StateChange_EVDOStatusCode := False;
  end;

Function GetStateChange_NetworkType:Boolean;                                    //@016+
  begin
   // Has it changed since last time?
   Result := _StateChange_NetworkType;
    if _StateChange_NetworkType then
      _StateChange_NetworkType := False;
  end;

Function roam_statusGetCode:Word;                                               //@016+
  begin
   Result := _SysInfo.roam_status;
  end;

Function Network_TypeGetCode:TNetWorkType;                                      //@016+
  begin
   Result := _SysInfo.Network_Type;
  end;

Function GetRoamingStatusText:UTF8String;                                       //@016+
  begin
   Case roam_StatusGetCode of
    0:Result := StrRoamStatusFalse;
    1:Result := StrRoamStatusTrue;
    else
      Result := StrRoamStatusUnknown;
   end;
  end;

Function GetWiFiClients:Integer;                                                //@018+
  begin
   Case GetEquipmentModelCode of
     {EM_GP01, }        // need to check if it's support
     EM_GP01r3,                                                                 //@019+
     EM_GL01P,                                                                  //@020+
     EM_GP02: Result :=
                   SafeStrToInt(GetXMLVar(mmdata.text, 'CurrentWifiUser'))

        else result := EM_UNSUPPORTED;
   end;
  end;

Function GetWiFiClientMax:Integer;                                              //@018+
  begin
   Case GetEquipmentModelCode of
     {EM_GP01, }        // need to check if it's support
     EM_GP01r3,                                                                 //@019+
     EM_GL01P,                                                                  //@020+
     EM_GP02: Result :=
                   SafeStrToInt(GetXMLVar(mmdata.text, 'TotalWifiUser'))
        else result := EM_UNSUPPORTED;
   end;
  end;


initialization
  mmData := TStringList.Create;
  _StateChange_BatteryStatusCode := False;                                      //@015+

finalization
  mmData.free;


end.

