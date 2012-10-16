unit frmhostinfounit;

// 2012.10.16 Noah Silva + Started
{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons;

type

  { TfrmHostInfo }

  TfrmHostInfo = class(TForm)
    bbOk: TBitBtn;
    leDescription: TLabeledEdit;
    leHostName: TLabeledEdit;
    leIPAddress: TLabeledEdit;
    leMAC: TLabeledEdit;
    procedure bbOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure leDescriptionChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmHostInfo: TfrmHostInfo;

implementation

Uses
  WiFiClients;

{ TfrmHostInfo }

procedure TfrmHostInfo.FormShow(Sender: TObject);
begin
  with WiFiClientList.Nodes[WiFiClientList.CurrentID] do
    begin
      leMac.Text := MacAddress;
      leIPAddress.Text:=IPAddress;
      leHostName.Text:=HostName;
      leDescription.Text:=NickName;
    end;
end;

procedure TfrmHostInfo.leDescriptionChange(Sender: TObject);
begin

end;

procedure TfrmHostInfo.bbOkClick(Sender: TObject);
begin
  with WiFiClientList do
    begin
      SetNickName(leMac.Text, leDescription.Text);
      HardRefresh;
    end;
  self.close;
end;

procedure TfrmHostInfo.FormCreate(Sender: TObject);
begin

end;

initialization
  {$I frmhostinfounit.lrs}

end.

