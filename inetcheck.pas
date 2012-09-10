unit inetcheck;
// Test Internet Connectivity
// @000 2012.07.30 Noah Silva  + First version
// @001 2012.08.02 Noah Silva  + OOPification
// @002 2012.08.30 Noah Silva  + Convert Strings into translatable String Constants
// @003 2012.09.10 Noah SILVA  + Auto-refresh

{$mode objfpc}

interface

uses
  Classes, SysUtils;

Type
  TInetCheck=class(TObject)
    Private
      var
        _LastResult : Boolean;
        _http_timeout : integer;
        _test_url:UTF8String;
        _cache_timeout_ms:integer;
        _last_check:TDateTime;
      Function _StateChanged:Boolean;
      // internal function to perform HTTP GET request
      Function _DoCheck:boolean;
      Function IsConnected(const Wait:Boolean):Boolean;
      Function IsConnectedStr(const Wait:Boolean):UTF8String;
    Public
      Constructor Create;
      // Returns true if there is internet connectivity.
      // Specifically, not just that a connection is active, but that we can request
      // a ping and/or HTTP request to a public IP address or DNS name.
      // Set wait to true if you want to recheck, false to give last result.
      Function IsConnected:Boolean;                                             //@003+
      Function IsConnectedStr:UTF8String;                                       //@003+
//      Property Connected:Boolean read _IsConnected;
      Property StateChanged:Boolean read _StateChanged;
  end;

var
  Internet : TInetCheck;

//Function InternetConnected:boolean;
//Function InternetConnectedStr:UTF8String;

implementation

uses
  httpsend, // Synapse
  emconst,  // StrConnected, StrNotConnected                                    //@002+
  dateutils; // TimeOf()                                                        //@003+
//Var
//  Last_State : Boolean;

Constructor TInetCheck.Create;
  begin
    _http_timeout := 500;
    _cache_timeout_ms := 5000;
    {$IFDEF WINDOWS}
     _test_URL := 'http://www.msftncsi.com/ncsi.txt'; // Microsoft NCSI
    {$ELSE}
     _test_URL := 'http://www.apple.com/library/test/success.html';
    {$ENDIF}
    _last_check := TimeOf(now);                                                 //@003+
    // Google - Should return code 204
    // http://clients3.google.com/generate_204
  end;

Function TInetCheck._DoCheck:boolean;
 var
   Success:Boolean;
   data:TStringList;
 begin
    // One possible option, Google also has their own
    try
      Data := TStringList.Create;
      Success := httpgettext(_test_URL, data, _http_timeout);
      // The following is for unmodified Synapse Library
//      Success := httpgettext(_test_URL, data);
      // for now we only check one host, so the result is always equal to that
      // result.

      // In case of failure, try one more time just to be sure.
      If not Success then
        Success := httpgettext(_test_URL, data, _http_timeout);
     // 3rd time is a charm? (Perhaps we should be trying another provider in this case)
     If not Success then
        Success := httpgettext(_test_URL, data, _http_timeout);


      Result := Success;
      _last_check := TimeOf(now);                                               //@003=
    finally
      data.free;
    end;
 end; // of Function


Function TInetCheck.IsConnected:Boolean;
  begin
    // check is cache has expired (is data stale?)
    If (MilliSecondSpan(_last_check, TimeOf(Now)) > _cache_timeout_ms) then
                _LastResult := _DoCheck;
    Result := _LastResult;
  end;

Function TInetCheck.IsConnected(Const Wait:boolean):Boolean;
  begin
    case wait of
      true:begin
            Result := _DoCheck;
            _LastResult := Result;
      end;
      false:begin
        Result := _LastResult;
      end;
    end; // of CASE
  end;

Function TInetCheck._StateChanged:Boolean;
  var
    tmp:Boolean;
  begin
    tmp := _DoCheck;

    Result := (_LastResult <> tmp);
    _LastResult := tmp;
  end;


Function TInetCheck.IsConnectedStr(Const Wait:Boolean):UTF8String;
  begin
    Case IsConnected(Wait) of
//      True: Result := 'Connected';                                            //@002-
      True: Result := StrConnected;                                             //@002+
//      False: Result := 'Not Connected';                                       //@002-
      False: Result := StrNotConnected;                                         //@002+
    end;
  end; // of Function

Function TInetCheck.IsConnectedStr:UTF8String;                                  //@003+
  begin
    Case IsConnected of
      True: Result := StrConnected;
      False: Result := StrNotConnected;
    end;
  end; // of Function


Initialization
  Internet := TInetCheck.create;
Finalization
  Internet.Destroy;
end.

