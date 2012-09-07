unit objrouter;
// Router Object
// Copyright (C) 2012 Noah SILVA - ALL RIGHTS RESERVED
// @001 2012.09.07 Noah SILVA Started

{$mode objfpc}

interface

uses
  Classes, SysUtils, PWMLib2;


Type
  TRouter=Class(TObject)
    Private
      var
       _RouterDetected:Boolean;
      Function GetEquipmentModelCode:TEquipmentModel;
    Public
      Constructor Create;
      Property RouterDetected:Boolean read _RouterDetected;
      Property EquipmentModelCode:TEquipmentModel read GetEquipmentModelCode;
      Function Refresh:Boolean;
  end;

Var
  Router:TRouter;  // Global object

Implementation


  Constructor TRouter.Create;
    begin
      _RouterDetected := False;
    end;

  Function TRouter.Refresh:Boolean;
    begin
      Result := RefreshStatusData;
      _RouterDetected := Result;
    end;

  Function TRouter.GetEquipmentModelCode:TEquipmentModel;
    begin
      Result := GetEquipmentModelCode;
    end;

Initialization
  Router := TRouter.create;

Finalization
  Router.Destroy

end.

