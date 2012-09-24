unit dbugfake;
// @000 2012.09.24 Noah Silva : Fake debug unit that just uses WRITELN

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

Procedure SendDebug(Const Str:UTF8String);

implementation

Procedure SendDebug(Const Str:UTF8String);
  begin
    Writeln('>' + Str);
  end;

end.

