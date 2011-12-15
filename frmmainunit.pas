unit FrmMainUnit;

{$mode objfpc}{$H+}

//@000 2011.03.24 Noah Silva Started Project
//@001 2011.03.31 Converted this form into an Information Dialog
// v0.0.3 Release
//@002 2011.04.05 Added Network Tab
//@003 2011.05.23 Added Chart Function
//@004 2011.08.04 Added Translation Action, hide unsupported data
//@005 2011.08.05 Further Internationalization Support
interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus, ComCtrls, Buttons, ActnList, types; // for testing

type

  { TfrmPocketWifiMon }

  TfrmPocketWifiMon = class(TForm)
    acTranslateForm: TAction;
    alFrmMain: TActionList;
    btnSigchart: TBitBtn;
    btnChartShow: TButton;
    leCellInfoRssi: TLabeledEdit;
    leCellInfoRscp: TLabeledEdit;
    leDNS2: TLabeledEdit;
    leDNS1: TLabeledEdit;
    leWANIP: TLabeledEdit;
    leAvgDownloadT: TLabeledEdit;
    leAvgUploadT: TLabeledEdit;
    leCurrDownloadT: TLabeledEdit;
    leCurrUploadT: TLabeledEdit;
    leSDCardTotalVolume: TLabeledEdit;
    leSDCardStatus: TLabeledEdit;
    leBatteryStatus: TLabeledEdit;
    lblBatteryLevel: TLabel;
    lblSignalStrength: TLabel;
    leRoamingStatus: TLabeledEdit;
    leNetworkType: TLabeledEdit;
    leCarrierName: TLabeledEdit;
    PageControl1: TPageControl;
    pnlSignal: TPanel;
    pbBatteryLevel: TProgressBar;
    pbSignalStrength: TProgressBar;
    sBattLev3: TShape;
    sSignalSeg1: TShape;
    sSignalSeg2: TShape;
    sSignalSeg3: TShape;
    sSignalSeg4: TShape;
    sSignalSeg5: TShape;
    sBattLev1: TShape;
    sBattLev2: TShape;
    sBattLev4: TShape;
    stCurrentTP: TStaticText;
    stAverageTP: TStaticText;
    tsData: TTabSheet;
    tsMobile: TTabSheet;
    tsTCP: TTabSheet;
    tsSDCard: TTabSheet;
    tsBattery: TTabSheet;
  //  mmData: TMemo;
 //   procedure btnGetClick(Sender: TObject);
//    procedure Button1Click(Sender: TObject);
 //   procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure acTranslateFormExecute(Sender: TObject);
    procedure btnChartShowClick(Sender: TObject);
    procedure btnSigchartClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure IdleTimer1StartTimer(Sender: TObject);
    procedure IdleTimer1Timer(Sender: TObject);
    procedure lblSignalStrengthClick(Sender: TObject);
    procedure leCellInfoRscpChange(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miQuitClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure tsBatteryShow(Sender: TObject);
    procedure tsDataContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure tsDataShow(Sender: TObject);
    procedure tsMobileContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure tsMobileShow(Sender: TObject);
    procedure tsSDCardShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmPocketWifiMon: TfrmPocketWifiMon;

implementation


uses
   frmAboutUnit, dmunit
   , pwmlib2, PWFMonGlobals                                                       //@001+
 ,  bwchart_unit, sigchart_unit, EMConst; //@003+                               //@004=
{$R *.lfm}

{ TfrmPocketWifiMon }





procedure TfrmPocketWifiMon.FormCreate(Sender: TObject);
begin

end;

procedure TfrmPocketWifiMon.btnChartShowClick(Sender: TObject);
begin
  FrmBWChart.Show;     //@003+
//  ShowMessage();
end;

procedure TfrmPocketWifiMon.acTranslateFormExecute(Sender: TObject);            //@004+
begin
  frmPocketWifiMon.Caption := StrAppTitle;
  // Tab Sheets
  tsBattery.Caption := StrBattery;
    leBatteryStatus.EditLabel.Caption:=StrBatteryStatus;
    lblBatteryLevel.Caption := StrBatteryLevel;
  tsSDCard.Caption :=  StrSDCard;
    leSDCardStatus.EditLabel.Caption := StrSDCardStatus;                        //@005+
    leSDCardTotalVolume.EditLabel.Caption:=StrTotalSize;                        //@005+
//  tcTCP.Caption :=
    leWANIP.EditLabel.Caption:=StrWANIP;                                        //@005+
    leDNS1.EditLabel.Caption:=StrDNS1;                                          //@005+
    leDNS2.EditLabel.Caption:=StrDNS2;                                          //@005+
  tsMobile.Caption := StrMobile;
    leCarrierName.EditLabel.Caption := StrCarrierName ;
    leNetworkType.EditLabel.Caption := StrNetworkType ;
    leRoamingstatus.EditLabel.Caption := StrRoamingStatus;
    lblSignalStrength.Caption := StrSignalStrength ;
    BtnSigChart.Caption := StrChartElip;
  tsData.Caption := StrData;
    btnChartShow.Caption:= StrChartElip;
    stCurrentTP.Caption:=StrCurrTP;                                             //@005+
    leCurrUploadT.EditLabel.Caption:= StrUpload;                                //@005+
    leCurrDownloadT.EditLabel.Caption:= StrDownload;                            //@005+
    stAverageTP.Caption:=StrAvgTP;                                              //@005+
    leAvgUploadT.EditLabel.Caption:= StrUpload;                                 //@005+
    leAvgDownloadT.EditLabel.Caption:= StrDownload;                             //@005+

end;

procedure TfrmPocketWifiMon.btnSigchartClick(Sender: TObject);
begin
  FrmUTMSChart.show;   //@003+
end;

procedure TfrmPocketWifiMon.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
 // IdleTimer1.Interval := 15000;
// If we let it actually close, then the application will exit.
  frmPocketWiFiMon.Hide;
  CanClose := False;
end;

procedure TfrmPocketWifiMon.FormShow(Sender: TObject);
begin
  If not ShowMainForm then
  // MacOS TTrayIcon bug fixed, always hide window to start.
    frmPocketWiFiMon.Hide;
  acTranslateFormExecute(Self);
  // Idletimer1.
end;

procedure TfrmPocketWifiMon.IdleTimer1StartTimer(Sender: TObject);
begin

end;

procedure TfrmPocketWifiMon.IdleTimer1Timer(Sender: TObject);
begin

end;

procedure TfrmPocketWifiMon.lblSignalStrengthClick(Sender: TObject);
begin

end;

procedure TfrmPocketWifiMon.leCellInfoRscpChange(Sender: TObject);
begin

end;

procedure TfrmPocketWifiMon.miAboutClick(Sender: TObject);
begin
  FrmAbout.Show;
end;

procedure TfrmPocketWifiMon.miQuitClick(Sender: TObject);
begin
application.Terminate;
end;

procedure TfrmPocketWifiMon.PageControl1Change(Sender: TObject);
begin

end;

procedure TfrmPocketWifiMon.tsBatteryShow(Sender: TObject);
begin
 // FrmPocketWiFiMon.Height := PageControl1.Top +sBattLev1.top + sBattLev1.Height + 20;
   //:= PageControl1.Top + PageControl1.Height + 20;
end;

procedure TfrmPocketWifiMon.tsDataContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TfrmPocketWifiMon.tsDataShow(Sender: TObject);
begin
end;

procedure TfrmPocketWifiMon.tsMobileContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
end;

procedure TfrmPocketWifiMon.tsMobileShow(Sender: TObject);
begin
  If CellInfoRSCP <> EM_UNSUPPORTED then                                         //@004+
    leCellInfoRscp.Visible:=true;                                              //@004+
  If CellInfoRSSI <> EM_UNSUPPORTED then                                         //@004+
    leCellInfoRSSI.Visible:=true;                                              //@004+
  //PageControl1.Bottom := pnlSignal.Bottom + 20;
  //FrmPocketWiFiMon.Bottom := PageControl1.Bottom + 20;

end;

procedure TfrmPocketWifiMon.tsSDCardShow(Sender: TObject);
begin
end;

end.
