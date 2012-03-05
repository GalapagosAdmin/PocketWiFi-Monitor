unit frmPrefsUnit;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ComCtrls, ActnList, CheckLst;

type

  { TfrmPreferences }

  TfrmPreferences = class(TForm)
    acFormTranslate: TAction;
    ActionList1: TActionList;
    CheckListBox1: TCheckListBox;
    lblNotifications: TLabel;
    lblUpdateFreq: TLabel;
    tbUpdateFrequency: TTrackBar;
    procedure acFormTranslateExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tbUpdateFrequencyChange(Sender: TObject);
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

procedure TfrmPreferences.tbUpdateFrequencyChange(Sender: TObject);
begin
  DataModule1.IdleTimer1.interval := tbUpdateFrequency.Frequency*1000;
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

