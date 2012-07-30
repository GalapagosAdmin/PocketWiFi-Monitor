unit inetcheck;
// Test Internet Connectivity
// 2012.07.30 Noah Silva  + First version

{$mode objfpc}

interface

uses
  Classes, SysUtils;


// Returns true if there is internet connectivity.
// Specifically, not just that a connection is active, but that we can request
// a ping and/or HTTP request to a public IP address or DNS name.
Function InternetConnected:boolean;
Function InternetConnectedStr:UTF8String;

implementation

uses httpsend; // synapse

Const
  http_timeout = 500;



Function InternetConnected:boolean;
 var
   Success:Boolean;
   url:UTF8String;
   data:TStringList;
 begin
    // one possible option, Apple and Google have their own
    URL := 'http://www.msftncsi.com/ncsi.txt';
    //URL := 'http://www.apple.com/library/test/success.html';
    try
      Data := TStringList.Create;
      Success := httpgettext(URL, data, http_timeout);
      // for now we only check one host, so the result is always equal to that
      // result.
      Result := Success;
    finally
      data.free;
    end;
 end; // of Function

Function InternetConnectedStr:UTF8String;
  begin
    Case InternetConnected of
      True:Result := 'Connected';
      False: Result := 'Not Connected';
    end;
  end; // of Function

end.

