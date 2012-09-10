unit objrouter;
// Router Object
// Copyright (C) 2012 Noah SILVA - ALL RIGHTS RESERVED
// @001 2012.09.07 Noah SILVA Started unit
// @002 2012.09.10 Noah SILVA Start of caching/auto-refresh

{$mode objfpc}

interface

uses
  Classes, SysUtils, PWMLib2;

Type
  TRouter=Class(TObject)
    Private
      const
        _cache_timeout_ms = 1000;                                               //@002+
      var
       _RouterDetected:Boolean; // True if we think we have a router
       _last_check:TDateTime;  // Last time the data was updated.               //@002+
      Function GetEquipmentModelCode:TEquipmentModel;
      Function HardRefresh:Boolean;                                             //@002=
      Procedure SoftRefresh; // refresh if needed                               //@002+
      Function GetRouterDetected:Boolean;                                       //@002+
    Public
      Constructor Create;
      Property RouterDetected:Boolean read GetRouterDetected;
      Property EquipmentModelCode:TEquipmentModel read GetEquipmentModelCode;
  end;

Var
  Router:TRouter;  // Global object

Implementation

  Uses
    DateUtils; // TimeOf()                                                      //@002+

  Constructor TRouter.Create;
    begin
      _RouterDetected := False;
      _last_check := TimeOf(now);                                               //@002+
    end;

  Function TRouter.HardRefresh:Boolean;
    begin
      _last_check := TimeOf(Now);                                               //@002+
      Result := RefreshStatusData;
      _RouterDetected := Result;
    end;

  Procedure TRouter.SoftRefresh;                                                //@002+
    begin
      If (MilliSecondSpan(_last_check, TimeOf(Now)) > _cache_timeout_ms) then
        HardRefresh;
    end;

  Function TRouter.GetEquipmentModelCode:TEquipmentModel;
    begin
      SoftRefresh;                                                              //@002+
      Result := GetEquipmentModelCode;
    end;

  Function TRouter.GetRouterDetected:Boolean;                                   //@002+
    begin
      SoftRefresh;
      Result := _RouterDetected;
    end;


Initialization
  Router := TRouter.create;

Finalization
  Router.Destroy

end.   // of Unit

