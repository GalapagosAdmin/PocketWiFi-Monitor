unit bwchart_unit;
//Network Bandwidth Chart
//@000 2011.05.23 Noah Silva - Created Unit
//@001 2011.08.05 Internationalization
{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ActnList, TAGraph, TASources, TASeries;

type

  { TFrmBWChart }

  TFrmBWChart = class(TForm)
    acFormTranslate: TAction;
    alBandwidth: TActionList;
    crtBandwidth: TChart;
    ULSeries: TLineSeries;
    DLSeries: TLineSeries;
    procedure acFormTranslateExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  FrmBWChart: TFrmBWChart;

implementation

Uses
  PWFMonGLobals; //Translations                                                 //@001+

{ TFrmBWChart }

procedure TFrmBWChart.FormShow(Sender: TObject);
begin
  acFormTranslate.Execute;                                                      //@001+
end;

procedure TFrmBWChart.FormCreate(Sender: TObject);
begin

end;

procedure TFrmBWChart.acFormTranslateExecute(Sender: TObject);
begin
  frmBWChart.Caption := StrFrmBWChartCaption;                                   //@001+
  crtBandwidth.Title.Text.Text:=StrCrtBAndwidthTitle;                           //@001+
end;

initialization
  {$I bwchart_unit.lrs}

end.

