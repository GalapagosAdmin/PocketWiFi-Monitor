unit frmPrefsUnit;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ComCtrls, ActnList;

type

  { TfrmPreferences }

  TfrmPreferences = class(TForm)
    acFormTranslate: TAction;
    ActionList1: TActionList;
    lblUpdateFreq: TLabel;
    TrackBar1: TTrackBar;
    procedure acFormTranslateExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmPreferences: TfrmPreferences;

implementation

uses
   dmUnit, PWFMonGlobals;

{ TfrmPreferences }

procedure TfrmPreferences.TrackBar1Change(Sender: TObject);
begin
  DataModule1.IdleTimer1.interval := TrackBar1.Frequency*1000;
end;

procedure TfrmPreferences.acFormTranslateExecute(Sender: TObject);
begin
 frmPreferences.Caption:= StrFrmSettings;
 lblUpdateFreq.Caption:= StrlblUpdateFreq;
end;

procedure TfrmPreferences.FormShow(Sender: TObject);
begin
  acFormTranslate.Execute;
end;

initialization
  {$I frmprefsunit.lrs}

end.

