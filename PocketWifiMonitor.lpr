program PocketWifiMonitor;

// TO DO
// 1. Background mode/thread for TCP/IP Requests
// 2. New icons (GP01 not detected, etc.)
// 3. Graphs for bandwidth, etc.
// 4. Status Notifications - f.e. battery dropping/raising, client
//                                             connection/disconnection, etc.

//@000 2011.03.24 Noah Silva Project Started
//@001 2011.03.29 Fixed to compile on Windows with Lazarus 0.9.30
//@002 2011.03.30 Hide the main form here. Convert to use resource String
// v0.0.3 Release

{$mode objfpc}{$H+}


uses
  {$IFDEF UNIX}
  cthreads,
 {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, tachartlazaruspkg, FrmMainUnit, PWMLib2, EMConst,
  frmAboutUnit, dmUnit, PWFMonGlobals,
  bwchart_unit,                                                                 //@003+
  sigchart_unit, frmPrefsUnit, blcksock, httpsend, inetcheck, WiFiClients,
  objrouter,
frmhostinfounit                                               //@003+
  { you can add units after this };

{$R *.res}

begin
  //  Application.Title:='Pocket WiFi Monitor';                                 //@002+
  Application.Title:='Pocket WiFi Monitor';
                                                                                //@002+
  {$IFDEF DARWIN} // not really mac OS related, but not supported on the        //@001+
  // Lazarus 0.9.30 I have on Windows                                           //@001+
  RequireDerivedFormResource := True;                                           //@001+
  {$ENDIF}                                                                      //@001+
  Application.Initialize;
  Application.CreateForm(TfrmPocketWifiMon, frmPocketWifiMon);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TFrmBWChart, FrmBWChart);
  Application.CreateForm(TfrmUTMSChart, frmUTMSChart);
  Application.CreateForm(TfrmPreferences, frmPreferences);
  Application.CreateForm(TfrmHostInfo, frmHostInfo);
  Application.Run;
end.

