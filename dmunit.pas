unit dmUnit;
// @000 2011.03.24 Noah SILVA - Started Project
// @001 2011.03.30 1. Added AutoDetect for GP01, hide non-working features
//                 2. Factored out Icon setting code
// @002            Added Roaming feature
// @003 2011.03.31 Added SD Card Information, data throughput data
// @004 2011.03.31 Logic to allow main form to be shown, when hidden at startup
// v0.0.3 Release
// @005 2011.03.31 Updated for changes in PWMLib2
// @006 2011.04.05 Added Network data (WAN IP Address and DNS Server addresses)
// @007 2011.05.23 Added Bandwidth Chart, signal strength charts
// @008 2011.05.24 Added Bandwidth Chart, CellInfoSignalLevel
// @009 2011.08.01 Added Support for GP02
// @010 2011.08.02 Debugging
// @011 2011.08.03 Added TrayIcon Popup Output on Changes  (Battery/Signal)
// @012 2011.08.04 Collect multiple popup-messages into one
//                 Added Network Type notification
//                 Moving System Information into PWMLib
// @013 2011.08.04 Convert Roaming Status from Code to Text
//                 Fix Pop-up Position in Mac OS
// @014 2011.08.05 Further Internationalization (Popup Menu, etc.)
// @015 2011.08.07 Device Info (Model Number), prefs dialog, quit code
// @016 2012.02.23 Add Radar display for when router can't be contacted.
// @017 2012.03.04 Added WiFi Client Change detection / Notification
// @018 2012.03.05 Added WiFi Info Tab, client count.
// @019 2012.03.05 Added Support for GP01 Software Update v3
// @020 2012.03.15 Added Support for GL01P (LTE)
// @021 2012.03.16 Maximum WiFi Client Count Support
// @022 2012.07.30 Check Internet Connectivity
{$mode objfpc}

interface

uses
  Classes,
  sysutils,
  FileUtil, LResources, ActnList, ExtCtrls, Menus, Controls,
  PopupNotifier, TASources, Forms;

type

  { TDataModule1 }

  TDataModule1 = class(TDataModule)
    acQuit: TAction;
    acRefreshStatus: TAction;
    acCarrierNameUpdate: TAction;
    acSystemInformationUpdate: TAction;
    acSignalStrengthUpdate: TAction;
    acBatteryLevelUpdate: TAction;
    acSDCardUpdate: TAction;
    acDataUpdate: TAction;
    acNetworkUpdate: TAction;
    acStateChange: TAction;
    acDoTranslate: TAction;
    acShowPrefs: TAction;
    acCheckInternet: TAction;
    ActionList1: TActionList;
    IdleTimer1: TIdleTimer;
    ImageList1: TImageList;
    lcsCellInfoSigLev: TListChartSource;
    lcsCellInfoRSCP: TListChartSource;
    lcsCellInfoRSSI: TListChartSource;
    lcsCellInfoEcIo: TListChartSource;
    lcsUL: TListChartSource;
    lcsDL: TListChartSource;
    lcsSignal: TListChartSource;
    miSettings: TMenuItem;
    miStatusWindow: TMenuItem;
    miBatteryLevel: TMenuItem;
    miRoamingStatus: TMenuItem;
    miDevice: TMenuItem;
    miSignal: TMenuItem;
    miCarrierName: TMenuItem;
    miSIMCardStatus: TMenuItem;
    miNetworkType: TMenuItem;
    miAbout: TMenuItem;
    miQuit: TMenuItem;
    PopupMenu1: TPopupMenu;
    PopupNotifier1: TPopupNotifier;
    tmrInternetCheck: TTimer;
    TrayIcon1: TTrayIcon;
    procedure acBatteryLevelUpdateExecute(Sender: TObject);
    procedure acCarrierNameUpdateExecute(Sender: TObject);
    procedure acCheckInternetExecute(Sender: TObject);
    procedure acDataUpdateExecute(Sender: TObject);
    procedure acDoTranslateExecute(Sender: TObject);
    procedure acNetworkUpdateExecute(Sender: TObject);
    procedure acQuitExecute(Sender: TObject);
    procedure acRefreshStatusExecute(Sender: TObject);
    procedure acSDCardUpdateExecute(Sender: TObject);
    procedure acSignalStrengthUpdateExecute(Sender: TObject);
    procedure acStateChangeExecute(Sender: TObject);
    procedure acSystemInformationUpdateExecute(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miQuitClick(Sender: TObject);
    procedure miSettingsClick(Sender: TObject);
    procedure miStatusWindowClick(Sender: TObject);
    procedure PopupNotifier1Close(Sender: TObject; var CloseAction: TCloseAction);
    procedure tmrInternetCheckTimer(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
    procedure SetIcon(const Index: integer);                              //@001+
    procedure TrayIcon1DblClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  DataModule1: TDataModule1;

implementation


uses
  //forms,                                                                      //@011-
  FrmMainUnit,
  emconst,         // eMobile D25HW/GP01/GP02 Constants
  Graphics,
  pwmlib2,         // Utilities to decode the D25HW responses
  frmAboutUnit,    // About Box
  PWFMonGlobals,   // Global variables
  bwchart_unit,    // Bancwidth Chart                                           //@007+
  dbugintf,        // Debug Server Output                                       //@010+
  Math,            // Floor()                                                   //@010+
  frmPrefsUnit,                                                                 //@015+
  inetcheck;       // Internet Connectivity                                     //@022+
{ TDataModule1 }

var
  BandwithDataPoints_CurMax: integer = 0;
  SignalDataPoints_CurMax: integer = 0;
  Radar_Stage:Integer = ICON_RADAR_MIN;                                         //@016+


procedure TDataModule1.SetIcon(const Index: integer);
var
  TempBitmap: TBitmap;
begin
  try
    try
      TempBitmap := TBitmap.Create;
      ImageList1.GetBitmap(Index, TempBitmap);
      TrayIcon1.Icon.Assign(TempBitmap);
      TrayIcon1.Show;
    finally
      TempBitmap.Free;
    end;

  except
    //  DebugLn('Problem in SetIcon');
  end;
end;

procedure TDataModule1.TrayIcon1DblClick(Sender: TObject);
begin
  IdleTimer1.Interval := 2000;
  ShowMainForm := True;                                                         //@004+
  FrmPocketWiFiMon.Show;
  acRefreshStatus.Execute;
end;

procedure TDataModule1.acQuitExecute(Sender: TObject);
begin
  frmPocketWifiMon.Close;
  Application.terminate;
end;

// Update Carrier (Operator) name in the GUI
procedure TDataModule1.acCarrierNameUpdateExecute(Sender: TObject);
var
  VCarrierInfo: TCarrierInfo;
begin
  //  Case GetEquipmentModel of                                                 //@001+
  //   EM_GP01: miCarrierName.Visible:=False;                                   //@001+
  //   Else                                                                     //@001+
  begin                                                                         //@001+
    // Carrier Info
    //VCarrierInfo := DecodeCarrierInfo(mmdata.Lines.Strings[operator_info_line]);
    //               VCarrierInfo := DecodeCarrierInfo(mmdata.Text);            //@005-
    VCarrierInfo := DecodeCarrierInfo;                                          //@005+
    miCarrierName.Caption := StrCarrier + VCarrierInfo.CarrierName;
    with FrmPocketWiFiMon do
      if Visible then
        leCarrierName.Text := VCarrierInfo.CarrierName;
  end;                                                                          //@001-
  //  end; // of CASE GetEquipmentModel                                         //@001-

end;

procedure TDataModule1.acCheckInternetExecute(Sender: TObject);                 //@022+
begin
  with FrmPocketWiFiMon do
    if visible then
      leX.Text := InternetConnectedStr;
  If InternetConnected = False then
    begin
      tmrInternetCheck.Interval := 5000; // 5 seconds
      SendDebug('Internet down');
      beep;
    end
  else
   with tmrInternetCheck do
     if not (interval = 30000) then     // 30 seconds
       Interval := 30000;
end;

procedure TDataModule1.acDataUpdateExecute(Sender: TObject);
const
  MaxPoints = 50;                                                               //@007+
var
  NewDataPoint: string;                                                         //@007+
  DownK: real;                                                                  //@007+
  UpK: real;                                                                    //@007+
begin
  case GetEquipmentModelCode of                                                 //@005=
    EM_GP01,
    EM_GP01r3,                                                                  //@019+
    EM_GL01P,                                                                   //@020+
    EM_GP02:
    begin                                                                       //@009=
      with FrmPocketWiFiMon do
        if Visible then
        begin
          leCurrUploadT.Text := GetCurrentUploadThroughput;
          leCurrDownloadT.Text := GetCurrentDownloadThroughput;
          leAvgUploadT.Text := GetAverageUploadThroughput;
          leAvgDownloadT.Text := GetAverageDownloadThroughput;
//          leX.Text := InternetConnectedStr;                                   //@022+-
        end;
      //Begin of code insertion @007+
      begin  // Code to update graph data source
        Inc(BandwithDataPoints_CurMax);
        // Adjust the X Output if required to accomodate new data
        //              If CurMax > FrmBWChart.Chart1.Extent.XMax Then
        //                FrmBWChart.Chart1.Extent.XMax := CurMax;
        // We can start dropping old data from the graph as well if we want
        // The output string has KBPS or BPS
        // Process Download
        DownK := ExtractKBps(GetCurrentDownloadThroughput);
        //              SendDebug(Format('Download KBps "%s" ',
        //                                     [FloatToStr(DownK)]));
        //              NewDataPoint := IntToStr(BandwithDataPoints_CurMax)
        //                   + '|' + FloatToStr(random()) + '|?|';
        lcsDL.Add(BandwithDataPoints_CurMax, DownK, '?');
        if BandwithDataPoints_CurMax > MaxPoints then
          lcsDL.Delete(0);
        // Process Upload
        UpK := ExtractKBps(GetCurrentUploadThroughput);
        lcsUL.Add(BandwithDataPoints_CurMax, UpK, '?');
        if BandwithDataPoints_CurMax > MaxPoints then
          lcsUL.Delete(0);
        //              lcsDL.DataPoints.Append(NewDataPoint);
      end;   // of code to update graph
      // End of Code Insertion @007+
    end // of CASE EM_GP01
    // else
    // not GP01
  end;

end;

procedure TDataModule1.acDoTranslateExecute(Sender: TObject);
begin

end;

procedure TDataModule1.acNetworkUpdateExecute(Sender: TObject);                 //@006+
begin
  with FrmPocketwiFiMon do
    if Visible then
    begin
      leWanIP.Text := GetWANIP;
      leDNS1.Text := GetDNS1;
      leDNS2.Text := GetDNS2;
    end;
end;

procedure TDataModule1.acBatteryLevelUpdateExecute(Sender: TObject);
begin
  case GetEquipmentModelCode of                                                 //@005=
    EM_GP01,
    EM_GP01r3,                                                                  //@019+
    EM_GL01P,                                                                   //@020+
    EM_GP02:
    begin                                                                       //@009=
      // Update the pop-up menu
      miBatteryLevel.Caption :=
        StrBatteryLevel + IntToStr(GetBatteryLevelCode)+'/4';
  //    SendDebug( StrBatteryLevel + IntToStr(GetBatteryLevelCode)) ;
      //@005=
      // Update the Infor Dialog, if visible
      with FrmPocketwiFiMon do
        if Visible then
        begin
          pbBatteryLevel.Position := GetBatteryLevelCode;                       //@005=
          with sBattLev1.Brush do
            if GetBatteryLevelCode > 0 then                                     //@005=
              Color := clLime
            else
              Color := clGray;
          with sBattLev2.Brush do
            if GetBatteryLevelCode > 1 then                                     //@005=
              Color := clLime
            else
              Color := clGray;
          with sBattLev3.Brush do
            if GetBatteryLevelCode > 2 then                                     //@005=
              Color := clLime
            else
              Color := clGray;
          with sBattLev4.Brush do
            if GetBatteryLevelCode > 3 then                                     //@005=
              Color := clLime
            else
              Color := clGray;
          leBatteryStatus.Text := GetBatteryStatusText;
        end;
    end
    else
      miBatteryLevel.Visible := False;
  end;
end;

procedure TDataModule1.acRefreshStatusExecute(Sender: TObject);
var
  Success: boolean;
  //  IP_ADDR:String;
  //   VEVDOStatus:TEVDOStatus;                                                 //@001-
  //   TempBitmap: TBitmap;                                                     //@001-
  //   mmData:TStringList;                                                      //@001-
begin
  // Success := RefreshStatusData(mmdata);                                      //@005-
  try
    Success := RefreshStatusData;                                               //@005+
    if Success = False then
    begin
      // Show Red Dot Error Icon
//      SetIcon(ICON_RED_DOT);                                                  //@016-
      SetIcon(Radar_Stage);                                                     //@016+
      Inc(Radar_Stage);                                                         //@016+
      If Radar_Stage > ICON_RADAR_MAX then                                      //@016+
        Radar_Stage := ICON_RADAR_MIN;                                          //@016+
      exit;
    end; // of IF/BEGIN

    miDevice.Caption := StrModel + GetEquipmentModelText;                       //@015+
    acSystemInformationUpdate.Execute;

    acCarrierNameUpdate.Execute;

    acSignalStrengthUpdate.Execute;
    acBatteryLevelUpdate.Execute;                                               //@002+
    acSDCardUpdate.Execute;                                                     //@003+
    acDataUpdate.Execute;                                                       //@003+
    //   mmData.Free;
    acNetworkUpdate.Execute;                                                    //@009+
    // ex 2,2,0,5,1,0,7
    // process status changes
    acStateChange.Execute
  except
    SendDebug('dmUnit.TDataModule1.acRefreshStatusExecute: Error in timer loop'); //@009+
  end;  // of try
end;

procedure TDataModule1.acSDCardUpdateExecute(Sender: TObject);
begin
  with FrmPocketWiFiMon do
    if Visible then
    begin
      leSDCardStatus.Text := GetSDCardStatusText;
      leSDCardTotalVolume.Text := GetSDCardTotalVolume;
    end;
end;

procedure TDataModule1.acSignalStrengthUpdateExecute(Sender: TObject);          //@001+
const                                                                           //@007+
  MaxPoints = 50;                                                               //@007+@008=
var
  VEVDOStatus: TEVDOStatus;
  VEVDOStatusNew: TEVDOStatus;                                                  //@021+

  Procedure UpdateSignalPanel;                                                  //@021+
    begin
      with FrmPocketWiFiMon do
        begin
      with sSignalSeg1.Brush do
        if VEVDOStatus > 0 then
          Color := clLime
        else
          Color := clGray;
      with sSignalSeg2.Brush do
        if VEVDOStatus > 1 then
          Color := clLime
        else
          Color := clGray;
      with sSignalSeg3.Brush do
        if VEVDOStatus > 2 then
          Color := clLime
        else
          Color := clGray;
      with sSignalSeg4.Brush do
        if VEVDOStatus > 3 then
          Color := clLime
        else
          Color := clGray;
      with sSignalSeg5.Brush do
        if VEVDOStatus > 4 then
          Color := clLime
        else
          Color := clGray;

        end;  // of WITH
    end;  // of PROCEDURE

begin
  try
  //   leCarrierService.Text := IntToStr(VCarrierInfo.CarrierStatus);
  // EVDO Signal Status (Signal Strength)
  //VEVDOStatus := DecodeEVDOStatus(mmdata.Lines.Strings[EVDO_STATUS_LINE]);
  //  VEVDOStatus := DecodeEVDOStatus(mmdata.Text);                             //@005-
  VEVDOStatus := GetEVDOStatusCode;                                             //@005+
  VEVDOStatusNew := GetEVDOStatusCodeNew;                                       //@021+
  //  leSignalStrength.Text:= IntToStr(VEVDOStatus);
  miSignal.Caption := StrSignal + IntToStr(VEVDOStatus) + '/5';
  SetIcon(VEvdoStatus);
  with FrmPocketWiFiMon do
    if Visible then
    begin                                                                       //@021+
      If GetEquipmentModelCode = EM_GL01P then                                  //@021+
       begin                                                                    //@021+
         // These should really only be checked and hidden/shown once per
         // equipment change, but there is no such notification/event as of now.
         pbSignalStrength.Visible := True;                                      //@021+
         pnlSignal.Visible:= False;                                             //@021+
         pbSignalStrength.position := VEVDOStatusNew;                           //@021+
       end                                                                      //@021+
      else                                                                      //@021+
       UpdateSignalPanel;

      leCellInfoRSCP.Text := IntToStr(CellInfoRSCP);                            //@007+
      leCellInfoRSSI.Text := IntToStr(CellInfoRSSI);                            //@007+
  // Show the type of device we have detected
  miDevice.Caption := StrModel + GetEquipmentModelText;                         //@001+
  // Update Signal Strength Chart
  // Begin of Code Insertion @007+ Beg
  Inc(SignalDataPoints_CurMax);
  // Update Basic Signal Strength (EVDO Status) Graph
  lcsSignal.Add(SignalDataPoints_CurMax, VEVDOStatusNew, '?');                  //@021=
  lcsCellInfoSigLev.Add(SignalDataPoints_CurMax, CellInfoSignalLevel, '?');     //@008+
  lcsCellInfoRscp.Add(SignalDataPoints_CurMax, CellInfoRscp, '?');
  lcsCellInfoRssi.Add(SignalDataPoints_CurMax, CellInfoRssi, '?');
  lcsCellInfoEcIo.Add(SignalDataPoints_CurMax, CellInfoEcIo, '?');              //@008+
  if SignalDataPoints_CurMax > MaxPoints then
    begin                                                                       //@008+
      lcsSignal.Delete(0);         //EVDO Status Signal
      lcsCellInfoSigLev.Delete(0);                                              //@008+
      lcsCellInfoRscp.Delete(0);                                                //@008+
      lcsCellInfoRssi.Delete(0);                                                //@008+
      lcsCellInfoEcIo.Delete(0);                                                //@008+
    end;
  end;      // of WITH
  // End of Code Insertion @007+ End
 except
   SendDebug('Error in dmUnit.TDataModule1.acSignalStrengthUpdateExecute');
 end;
end;

procedure TDataModule1.acStateChangeExecute(Sender: TObject);

  Procedure DoNotify(Const Msg:String);
  var                                                                           //@013+
    x:integer;                                                                  //@013+
  begin
    {$IFDEF Darwin}  // This thing is ugly, but we can use it if needed on MacOS
        with PopupNotifier1 do
          begin
            Text := msg;
            Title := StrAppTitle;
            x:= screen.Width-popupnotifier1.vNotifierForm.Width;                //@013+
            ShowAtPos(x, 23);//x,y                                              //@013+
            popupnotifier1.vNotifierForm.AutoHide:=true;

          end;
        {$ELSE}    // At least in Windows the TrayIcon baloon thing works
        // but I don't think so in Mac OS.  (Not sure on Linux)
         With TrayIcon1 do
          begin
            BalloonHint:= msg;
            BalloonTitle := StrAppTitle;
            ShowBalloonHint;
           end;
         {$ENDIF}

  end;


var
  NotifyString:UTF8String;

  Procedure AddNotify(Msg:UTF8String);                                          //@012+
   begin
     If NotifyString = '' then
      NotifyString := Msg
     else
       NotifyString := NotifyString + #10#13 + Msg;
   end;


begin
  Try
      // Clear the notifications for this round
      NotifyString := '';                                                       //@012=
      // Check EVDO Status
      If GetStateChange_EVDOStatusCode then
        AddNotify(StrSignalStrength//'Signal Strength: '                        //@012=@016+
            + IntToStr(GetEVDOStatusCode) + '/5');
      // Check Battery Level
      If GetStateChange_BatteryLevelCode then
      begin
        AddNotify(StrBatteryLevel //'Battery Level: '                           //@016=
            + IntToStr(GetBatteryLevelCode)+'/4');                              //@012=
//        SendDebug('BatteryLevel: '+IntToStr(GetBatteryLevelCode)+'/4');
      end;
      // Check Battery Status (Charging/Not charging)
      if GetStateChange_Battery then
        AddNotify(StrBatteryStatus                                              //@012=
            + GetBatteryStatusText{(GetBatteryStatusCode)});                    //@016=
      // Network Type                                                           //@012+
//      if GetStateChange_NetworkType then                                        //@012+
//        AddNotify(StrNetworkType + NetworkTypeGetText);                         //@012+@016=
      // Connected WiFi Clients
      case GetEquipmentModelCode of                                             //@017+
       EM_GP01r3,                                                               //@019+
       EM_GL01P,                                                                //@020+
       EM_GP02: begin                                                           //@017+
        if GetStateChange_WiFiClientCount then                                  //@017+
          AddNotify(StrWiFiClientCount                                          //@017+
              +  IntToStr(GetWiFiClients) + '/'                                 //@017+
              + IntToStr(GetWiFiClientMax));                                    //@017+
       end; // of GP02                                                          //@017+
      end;  // of CASE                                                          //@017+
      // Show the messages
      If Length(NotifyString) > 0 then                                          //@012+
      begin                                                                     //@012+
        DoNotify(NotifyString);                                                 //@012+
        SendDebug(NotifyString);                                                //@012+
      end;                                                                      //@012+
  Except
    SendDebug('Error in dmUnit.TDataModule1.acStateChangeExecute');
  end;
end; // of PROCEDURE

procedure TDataModule1.acSystemInformationUpdateExecute(Sender: TObject);       //@001+
//var                                                                           //@012-
//  VSysInfo: TSysInfo;                                                         //@012-
begin
  try
  //  edit1.Text := mmdata.Lines.Strings[sysinfo_line];
  // Basic system Info
  //  VSysInfo := DecodeSysInfo(mmdata.Lines.Strings[sysinfo_line]);
 // VSysInfo := DecodeSysInfo;//(mmdata.Text);                                  //@005=@012-
  //   leServiceStatus.text := SrvStatusGetText(VSysInfo.srv_status);
//  Case GetEquipmentModel of                                                   //@001+@016+
    // GP02 is giving CS Invalid SIM on valid SIM cards
//   EM_GP02: begin                                                             //@016=
  //        miNetworkType.Visible:=False;                                       //@001+
//              miSIMCardStatus.Visible := False;                               //@001+@016+
//            end                                                               //@016+
//    Else                                                                      //@001+@016+
  //   begin                                                                    //@001+
//  miSIMCardStatus.Caption := SIMCardStatusGetText(VSysInfo.card_state);       //@012-
  miSIMCardStatus.Caption := SIMCardStatusGetText;                              //@012+
//  end;                                                                        //@016+
  //  miRoamingStatus.Caption := 'Roaming: ' + IntToStr(VSysInfo.roam_status);  //@002+@012-
//miRoamingStatus.Caption := 'Roaming: ' + IntToStr(roam_statusGetCode);        //@012+014-
  miRoamingStatus.Caption := StrRoamingStatus + GetRoamingStatusText;             //@014+
  with FrmPocketWiFiMon do
    if Visible then
//    leRoamingStatus.Text := IntToStr(VSysInfo.roam_status);                   //@012-
//      leRoamingStatus.Text := IntToStr(roam_statusGetCode);                   //@012+@13-
          leRoamingStatus.Text := GetRoamingStatusText;                         //@013+
  // Network Type
  // end;                                                                       //@001+
  // end; // of Case                                                            //@001+
//  PWFMonGlobals.NetworkType := NetworkTypeGetText(VSysInfo.Network_Type);     //@012-
  PWFMonGlobals.NetworkType := NetworkTypeGetText;                              //@012+
  //  leNetworkType.Text := NetworkType;
  miNetworkType.Caption := StrNetworkType + PWFMonGlobals.NetworkType;
  with FrmPocketWiFiMon do
    if Visible then
    begin
      leNetworkType.Text := PWFMonGlobals.NetworkType;
//        if VSysInfo.Network_Type >= MACRO_NETWORKTYPE_HSPA then               //@012-
      if Network_TypeGetCode = MACRO_NETWORKTYPE_LTE then                       //@020+
        leNetworkType.Color := clBlue                                           //@020+
      else                                                                      //@020+
      if Network_TypeGetCode >= MACRO_NETWORKTYPE_HSPA then                     //@012+
        leNetworkType.Color := clLime
      else
        leNetworkType.Color := clDefault;
    end;

  with FrmPocketWiFiMon do                                                      //@018+
   begin                                                                        //@018+
    leWiFiClientCount.Caption := IntToStr(GetWiFiClients);                      //@018+
    leWiFiClientMax.Caption := IntToStr(GetWiFiClientMax);                      //@021+
   end;                                                                         //@018+
//  SendDebug(IntToStr(GetWiFiClients) + ' WiFi Clients'+ '/' +                 //@017+
//           IntToStr(GetWiFiClientMax) + ' Maximum');                          //@017+
  except
    SendDebug('Error in dmUnit.TDataModule1.acSystemInformationUpdateExecute');
  end; // of TRY..EXCEPT
 end; // of PROCEDURE

procedure TDataModule1.DataModuleCreate(Sender: TObject);
begin
  acRefreshStatus.Execute;
   miAbout.Caption:=StrMiAbout;                                                 //@014+
   miSettings.Caption := StrmiSettings;                                         //@015+
   miQuit.Caption := StrMiQuit;                                                 //@014+
   miStatusWindow.Caption:= StrMiStatus;                                        //@014+
end;

procedure TDataModule1.miAboutClick(Sender: TObject);
begin
  frmAbout.Show;
end;

procedure TDataModule1.miQuitClick(Sender: TObject);
begin
  application.Terminate;                                                        //@015+
end;

procedure TDataModule1.miSettingsClick(Sender: TObject);
begin
  frmPreferences.Show;
end;

procedure TDataModule1.miStatusWindowClick(Sender: TObject);
begin

end;

procedure TDataModule1.PopupNotifier1Close(Sender: TObject;
  var CloseAction: TCloseAction);
begin

end;

procedure TDataModule1.tmrInternetCheckTimer(Sender: TObject);
begin

end;

procedure TDataModule1.TrayIcon1Click(Sender: TObject);
begin
  PopupMenu1.PopUp;
  // showmessage('Click');
end;



initialization
  {$I dmunit.lrs}

end.
