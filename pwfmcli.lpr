program pwfmcli;
// Pocket WiFi Monitor CLI
// @000 2012.09.24 Noah SILVA : Started
// @001 2012.10.16 Noah Silva + Updates
{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp,
  { you can add units after this }
  objrouter, inetcheck, dbugfake,
  WiFiClients;                                                                  //@001

type

  { TPocketWiFiMonitorCLI }

  TPocketWiFiMonitorCLI = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ TPocketWiFiMonitorCLI }

procedure TPocketWiFiMonitorCLI.DoRun;
var
  ErrorMsg: String;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h','help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h','help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  { add your program here }
  // Show router Status
  Case Router.RouterDetected of
    True: Writeln('Router Detected: ' + Router.EquipmentModelText);
    False: Writeln('No Compatible Router Detected.');
  end;
  // Show internet connectivity status
  Case Internet.IsConnected of
    True: Writeln('Internet connection detected.');
    False: Writeln('Internet connection not detected.');
  end;
  If not Router.RouterDetected then exit;                                       //@001+
  WiFiClientList.HardRefresh;
  Writeln('WiFi Nodes: ' + IntToStr(WiFiClientList.Nodes.Count));

  // stop program loop
  Terminate;
end;

constructor TPocketWiFiMonitorCLI.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TPocketWiFiMonitorCLI.Destroy;
begin
  inherited Destroy;
end;

procedure TPocketWiFiMonitorCLI.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ',ExeName,' -h');
end;

var
  Application: TPocketWiFiMonitorCLI;
begin
  Application:=TPocketWiFiMonitorCLI.Create(nil);
  Application.Title:='Pocket WiFi Monitor CLI';
  Application.Run;
  Application.Free;
end.

