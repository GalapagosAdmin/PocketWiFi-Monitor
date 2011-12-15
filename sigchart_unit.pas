unit sigchart_unit;
//@001 2011.08.04 Added feature to hide unavailable functionality.

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, TAGraph, TASeries;

type

  { TfrmUTMSChart }

  TfrmUTMSChart = class(TForm)
    crtCellInfoRssi: TChart;
    crtCellInfoRscpLineSeries1: TLineSeries;
    crtCellInfoRssiLineSeries1: TLineSeries;
    crtSignal: TChart;
    crtCellInfoRscp: TChart;
    crtCellInfoEcIo: TChart;
    crtSignalLineSeriesEVDOStatus: TLineSeries;
    crtCellInfoEcIoLineSeries1: TLineSeries;
    crtSignalLineSeriesCellSigLev: TLineSeries;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmUTMSChart: TfrmUTMSChart;

implementation

Uses                                                                            //@001+
  PWMLib2, EMConst;                                                             //@001+

Var
  Adjusted:Boolean;                                                             //@001+
{ TfrmUTMSChart }


{ TfrmUTMSChart }

procedure TfrmUTMSChart.FormShow(Sender: TObject);
begin
   If Adjusted then Exit;                                                       //@001+
   // Hide the graphs we can't get data for
   If CellInfoECIO = EM_UNSUPPORTED then                                        //@001+
     begin                                                                      //@001+
       crtCellInfoECIO.Visible:=False;                                          //@001+
       frmUTMSChart.Height:=frmUTMSChart.Height-crtCellInfoECIO.Height;         //@001+
 // technically we should subtract the size of the splitters too...
       splitter1.Visible:=False;                                                //@001+
       crtSignal.Align:=alClient;
     end;                                                                       //@001+
   If CellInfoRSCP = EM_UNSUPPORTED then                                        //@001+
     begin                                                                      //@001+
       crtCellInfoRSCP.Visible:=False;                                          //@001+
       frmUTMSChart.Height:=frmUTMSChart.Height-crtCellInfoRSCP.Height;         //@001+
       splitter2.Visible:=False;                                                //@001+
     end;                                                                       //@001+
   If CellInfoRSSI = EM_UNSUPPORTED then                                        //@001+
     begin                                                                      //@001+
       crtCellInfoRSSI.Visible:=False;                                          //@001+
       frmUTMSChart.Height:=frmUTMSChart.Height-crtCellInfoRSSI.Height;         //@001+
       splitter3.Visible:=False;                                                //@001+
     end;                                                                       //@001+
   //Only Adjust Size Once
   Adjusted := True;                                                            //@001+
end;

initialization
  {$I sigchart_unit.lrs}
  Adjusted := False;
end.
