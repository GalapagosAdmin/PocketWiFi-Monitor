unit WiFiClients;
// eMobile D25HW/GP01/GP02 Pocket WiFi Access Object - Client List
//@000 2012.08.07 Noah SILVA + First Version.
//@001 2012.08.13 Noah SILVA + Added node change detection
//@002 2012.09.10 Noah SILVA + Added Nickname function
//@003 2012.09.10 Noah SILVA + Started work on auto-refresh/caching
//@004 2012.10.16 Noah SILVA + SetNickName
{$mode objfpc}

interface

uses
  Classes, SysUtils, EMConst, genericstructlist,
  inifiles; // INI files.                                                       //@002+

Type
  TMacAddress=String;
  TNodeEntry=record
    ID:Integer;
    MacAddress:TMacAddress;
    HostName:UTF8String;
    IPAddress:String;
    NickName:UTF8String;                                                        //@002+
    Dirty:Boolean;  // record has been updated in memory?                       //@004+
  end;
  TChangeType=Char;  // N = New D = Deleted
  TNodeChangeEntry=record
    ChangeType:TChangeType;
    ID:Integer;
    MacAddress:String;
    HostName:UTF8String;
    IPAddress:String;
    NickName:String;                                                            //@002+
  end;
  TNodeList = specialize TGenericStructList<TNodeEntry>;
  TNodeChangeList = specialize TGenericStructList<TNodeChangeEntry>;

  TWiFiClientList=class(TObject)
    Private
      const
        _url:UTF8String='http://' + ip_addr + '/api/wlan/host-list';
      var
        _LastResult : String;
        _http_timeout : integer;
        _cache_timeout_ms:integer;
        _last_check:TDateTime;
        // This is the raw XML data retrieved from the HTTP Request
        _xml_data:TStringList;
        _string_data:TStringList;
        _Nodes:TNodeList;         // WiFi nodes
        _NodesOld:TNodeList;      // Old list before the last refresh
        _Changes:TNodeChangeList; // List of changes since the last refresh
        INI:TINIFile;             // To store Nicknames                         //@002+
        _CurrentID:Integer;       // Store Current Entry being processed        //@004+
      Function _StateChanged:Boolean;
      // internal function to perform HTTP GET request
      Function _DoCheck:boolean;       // HTTP GET
      // Parse the raw XML into more useful structure
      Procedure _DoParse;
      // Generate the Delta between the last refresh and now
      Procedure _DoCompare;
      Function GetNickName(Const MacAddress:String):UTF8String;
      Procedure SoftRefresh;                                                    //@003+
    Public
      Constructor Create;
      Destructor Destroy;
      // Returns true if there is internet connectivity.
      // Specifically, not just that a connection is active, but that we can request
      // a ping and/or HTTP request to a public IP address or DNS name.
      // Set wait to true if you want to recheck, false to give last result.
//      Property Connected:Boolean read _IsConnected;
      Procedure Update;
      Property StateChanged:Boolean read _StateChanged;
      Property XMLData:TStringList read _xml_data;
      Property StringData:TStringList read _string_data;
      Property Nodes:TNodeList read _Nodes;                                     //@001+
      Property Changes:TNodeChangeList read _Changes;                           //@001+
      Procedure SetNickName(Const MacAddress:String; Const NickName:UTF8String);//@004+
      Property CurrentID:Integer read _CurrentID write _CurrentID;              //@004+
      Procedure HardRefresh;                                                    //@009+
  end;

// global Instance
Var
  WiFiClientList:TWiFiClientList;

implementation

uses
  httpsend, // Synapse
  md5,      // MD5Print
  webvar,   // GetXMLVar
  strutils, // NPos
  DateUtils, // TimeOf
  dbugintf; // or use real debug unit

Constructor TWiFiClientList.Create;
  begin
    inherited;
    _http_timeout := 500;
    _cache_timeout_ms := 5000;
    _xml_data := TStringList.Create;
    _string_data := TStringList.Create;
    _Nodes := TNodeList.Create;
    _NodesOld := TNodeList.Create;
    _Changes := TNodeChangeList.Create;
    INI := TINIFile.Create('pwfm.ini');                                         //@002+
    _last_check := TimeOf(Now);                                                 //@003+
  end;

Destructor TWiFiClientList.Destroy;
  begin
    Ini.UpdateFile;
    Ini.Free;                                                                   //@002+
    _xml_data.free;
    _string_data.free;
    _Nodes.Free;
    _NodesOld.Free;
    _Changes.Free;
    inherited;
  end;

Function TWiFiClientList.GetNickName(Const MacAddress:String):UTF8String;       //@002+
  begin
    // This could use SQLLite or an INI properties file...
    Result := INI.ReadString('WiFi', MacAddress, '');
  end;

Procedure TWiFiClientList.SetNickName(Const MacAddress:String; Const NickName:UTF8String);      //@004+
  begin
    // Write to INI file;
    INI.WriteString('WiFi', MacAddress, Nickname);
    // Right now, we assume that the caller has updated the list themselves.
    // If not, it will be updated at the next refresh anyway.
  end;

Function TWiFiClientList._StateChanged:Boolean;
  var
    tmp:Boolean;
    NewHash:String;
  begin
    NewHash := MD5Print(MD5String(_xml_data.text));
    Result := (NewHash <> _LastResult);
    _LastResult := NewHash;
  end;

Function TWiFiClientList._DoCheck:boolean;
 var
   Success:Boolean;
 begin
    try
      Success := httpgettext(_URL, _xml_data, _http_timeout);
      // The following is for unmodified Synapse Library
//      Success := httpgettext(_test_URL, data);
      // for now we only check one host, so the result is always equal to that
      // result.

      Result := Success;
      If not Success then SendDebug('_DoCheck: Error in HTTP request.');
      _last_check := TimeOf(Now);
    finally
    end;
 end; // of Function

Procedure TWiFiClientList.SoftRefresh;
  begin
    If (MilliSecondSpan(_last_check, TimeOf(Now)) > _cache_timeout_ms) then
      _DoCheck;
  end;

// Force a Refresh
Procedure TWiFiClientList.HardRefresh;
  begin
      _DoCheck;
      _DoParse;
  end;

Procedure TWiFiClientList.Update;
  begin
//    _DoCheck;                                                                 //@003-
    SoftRefresh;                                                                //@003+
    if _statechanged then
      begin
        _DoParse;
//        _DoCompare;
      end;
  end;

Procedure TWiFiClientList._DoCompare;                                            //@001+

  // Finds the first entry with a given MAC Address in the given NodeList
  Function FindMAC(Const MacAddress:TMacAddress; Const NodeList:TNodeList):Boolean;
    Var
      Ever : Integer;
    begin
      Result := False;
      If (NodeList.Count = 0) then Exit;
      // The list isn't sorted by Mac Address, so we just do a linear search
      For Ever := 0 to NodeList.Count-1 do
        begin
          If (NodeList[Ever].MacAddress = MacAddress) then
            Exit(True);
        end;
      // If we made it here, we didn't find a match.
    end;  // of FindMAC

  // Adds and entry to the Node Change List
  Procedure AddChangeEntry(Const ChangeType:TChangeType; Const Node:TNodeEntry);
    var
      ThisChange:TNodeChangeEntry;
    begin
      // Record the entry type
      ThisChange.ChangeType:= ChangeType;
      // Copy the data from the node
      ThisChange.MacAddress:= Node.MacAddress;
      ThisChange.HostName:=Node.HostName;
      ThisChange.ID:=Node.ID;
      ThisChange.IPAddress:=Node.IPAddress;
      // Add the item
      _Changes.Add(ThisChange);
    end;

  var
    OldEntries, NewEntries, ThisEntry:Integer;
  begin
    _Changes.Clear;
    OldEntries := _NodesOld.Count;
    NewEntries := _Nodes.Count;
    If NewEntries = 0 then exit;
    // Detect new entries (Connections)
    For ThisEntry := 0 to (NewEntries - 1) do
      begin
        // See if we can find this entry in the old list
        If not FindMac(_Nodes[ThisEntry].MacAddress, _NodesOld) then
          begin
            // No? Then it must be new!
            AddChangeEntry('N', _Nodes[ThisEntry]);
          end;
      end; // of for
    If OldEntries = 0 then exit;
    // Detect Disconnections
    For ThisEntry := 0 to (OldEntries - 1) do
      begin
        // See if we can find this entry in the old list
        If not FindMac(_NodesOld[ThisEntry].MacAddress, _Nodes) then
          begin
            // No? Then it must be gone!
            AddChangeEntry('D', _NodesOld[ThisEntry]);
          end;
      end; // of for

  end;  // of PROCEDURE



Procedure TWiFiClientList._DoParse;
  Var
    _ID, _MacAddress, _HostName, _IPAddress :UTF8String;
//    Remainder,
    Scope:UTF8String;
    Start, Stop, L:Integer;  // String Copy Paramaters
    N:Integer;
    TempNode:TNodeEntry;
  begin
    N := 1;
    _String_Data.clear;
//    Remainder := _xml_data.text;
//    Start := Pos('<Host>', Remainder);
//    Stop := Pos('</Host>', Remainder);
    // Find each "Host" entry.  Another option would be to use the XML DOM unit
    // and scan the tree properly

    // keep the old list for comparison
    // this way doesn't work because it just uses the reference
    // When we change items in the new list, items in the old list will change too,
    // (Since they are actually the same list) defeating its purpose.
    //   _NodesOld := _Nodes;
(*
// This code causes really strange bugs!
    _NodesOld.Clear;
    If _Nodes.Count > 0 then
      for N := 0 to _Nodes.Count-1 do
        _NodesOld.Add(_Nodes[N]);
    Assert(_Nodes.Count = _NodesOld.Count);
*)
 // Try Manual Deep Copy
 (*
    _NodesOld.Clear;
    If _Nodes.Count > 0 then
      for N := 0 to _Nodes.Count-1 do
       begin
         TempNode.ID:= _Nodes[N].ID;
         TempNode.HostName:= _Nodes[N].HostName;
         TempNode.MacAddress:=_Nodes[N].MacAddress;
         TempNode.IPAddress:=_Nodes[N].IPAddress;
         _NodesOld.Add(TempNode);
       end;
  *)

    _Nodes.Clear;
    While (NPos('<Host>', _xml_data.text, N) > 0) do
//    If Start > 0 then                                                         //@001+
      begin
        Start := NPos('<Host>', _xml_data.text, N);
        Stop := NPos('</Host>', _xml_data.text, N);
        L := Stop - Start;
        Scope := Copy(_xml_data.text, Start, L);
        with TempNode do
          begin
            ID:= StrToInt(GetXMLVar(Scope, 'ID'));
            MacAddress := GetXMLVar(Scope, 'MacAddress');
            HostName := GetXMLVar(Scope, 'HostName');
            IPAddress := GetXMLVar(Scope, 'IpAddress');
            NickName := GetNickName(MacAddress);                                //@002+
            _nodes.Add(TempNode);
            _String_data.add(IntToStr(ID) + ' ' + HostName
                         + ' ' + IPAddress + ' ' + MacAddress);
        end;
        Inc(N);
      end;
    // parse the XML data to populate internal structures
  end;

Initialization
  WiFiClientList := TWiFiClientList.create;
Finalization
  WiFiClientList.Destroy;
end.

