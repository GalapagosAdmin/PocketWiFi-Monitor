unit WebVar;
// Given a string representing an HTML file (with Javascript),
// return the value of a given variable.
// @000 2011.03.28 Noah silva started Unit
// @001 2011.03.30 Added XML Functionality
// v0.0.3 Release
// @002 2011.03.31 Updated for changes in PWMLib2

{$mode objfpc}

// should use LONG strings
interface

uses
  Classes, SysUtils; 

// Case sensitive for now,  retrievs in flat/raw format
Function GetWebVar(const text:AnsiString; const varname:string):UTF8String;         //@001+
Function GetJSVar(const jstext:AnsiString; const varname:string):UTF8String;   //@001-
Function GetXMLVar(const xmltext:AnsiString; const varname:string):UTF8String; //@001-

implementation

uses PWMLib2, EMConst;                                                   //@001+


Function GetXMLVar(const xmltext:AnsiString; const varname:string):UTF8String; //@001+
 Const
   MaxResultLength = 128; // just as a sanity check to prevent run-aways
 var
   StatementBeg:Integer;
   SubStr:AnsiString;
 begin
       result := '';
    // format should be like
    // VAR varname = something;
 //   l := Length(XMLtext);
    // build the XML tag
    SubStr := '<' + varname + '>';
    // Find it in the source text
    StatementBeg := pos(SubStr, XMLtext);
   If StatementBeg = 0 then exit;
   // Position ourselves after the opening XML tag
   StatementBeg := StatementBeg + Length(SubStr);
   // we don't handle the case of escapes < symbols here
   While (XMLtext[StatementBeg] <> '<')
     and (Length(Result) < MaxResultLength)
     and (StatementBeg < Length(XMLtext)) do
    begin
     Result := Result + XMLtext[StatementBeg];
     Inc(StatementBeg);
    end;
    // we ran up against a space limitation, clear the result and exit
    if (Length(Result) >= MaxResultLength)
      or (StatementBeg >= Length(XMLtext)) then
       begin
         result := '';
         exit;
       end;
    // Still ok, so continue
    Result := Trim(Result);
 end;


Function GetJSVar(const jstext:AnsiString; const varname:string):UTF8String;
  Const
    VarConst='var ';
    MaxResultLength = 128; // just as a sanity check to prevent run-aways
                  // in case of mal-formed JS input.
  var
    StatementBeg:Integer;
    SubStr:AnsiString;
    l:Integer;       // for debugging
    EqualPos:Integer;
  begin
    result := '';
    // format should be like
    // VAR varname = something;
    l := Length(jstext);
    SubStr := VarConst + varname;
    StatementBeg := pos(SubStr, jstext);
    If StatementBeg = 0 then exit;
    StatementBeg := StatementBeg + Length(VarConst) + Length(VarName);
    // Go until we find the semicolon at the end of the assignment
    // We don't handle escaped semicolons here
    While (jstext[StatementBeg] <> ';')
      and (Length(Result) < MaxResultLength)
      and (StatementBeg < Length(jstext)) do
     begin
      Result := Result + jstext[StatementBeg];
      Inc(StatementBeg);
     end;
    // we ran up against a space limitation, clear the result and exit
    if (Length(Result) >= MaxResultLength)
      or (StatementBeg >= Length(jstext)) then
       begin
         result := '';
         exit;
       end;
    // Still ok, so continue
    EqualPos := Pos('=', Result);
    // if there is no equals sign for assignment, something is wrong;
    if EqualPos = 0 then
       begin
         Result := '';
         exit;
       end;
    // Some Sanity checks
    Assert(EqualPos > 0);
    Assert(EqualPos < Length(jsText));
    // Remove the Equal Sign
    Delete(Result, EqualPos, 1);
    Result := Trim(Result);
  end; // of FUNCTION

Function GetWebVar(const text:AnsiString; const varname:string):UTF8String;//@001+
 begin
   Case GetEquipmentModelCode of                                         //@002=
     EM_GP01: Result := GetXMLVar(text, varname)
       else
         Result := GetJSVar(text, varname);
   end;
 end;


end. // of UNIT

