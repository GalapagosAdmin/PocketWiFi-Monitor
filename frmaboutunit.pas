unit frmAboutUnit;

//@001 2011.03.28 Noah Silva - Remove Title Caption when in Mac OS X
// v0.0.3 Release
//@002 2011.08.05 Internationalization

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    Image1: TImage;
    lblVersion: TLabel;
    lblCopyright: TLabel;
    lblCopyright2: TLabel;
    lblProduct: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lblCopyright2Click(Sender: TObject);
    procedure lblCopyrightClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmAbout: TfrmAbout;

implementation

uses
   PWFMonGlobals;

{ TfrmAbout }

procedure TfrmAbout.lblCopyright2Click(Sender: TObject);
begin

end;

procedure TfrmAbout.lblCopyrightClick(Sender: TObject);
begin

end;

procedure TfrmAbout.FormShow(Sender: TObject);
begin

    lblVersion.Caption := StrVersion;
    //format(StrVersion, [StrVersionNum]);
    {$IFDEF darwin}
    frmAbout.Caption := ''; // Not supposed to have Caption in About box in Mac OS X?
    {$ELSE}                                                                     //@002+
    FrmAbout.Caption := StrAppAbout;                                            //@002+
    {$ENDIF}
    lblProduct.Caption:= StrAppTitle;                                           //@002+
end;

procedure TfrmAbout.FormCreate(Sender: TObject);
begin

end;

initialization
  {$I frmaboutunit.lrs}

end.

