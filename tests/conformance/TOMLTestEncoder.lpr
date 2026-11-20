program TOMLTestEncoder;

{ toml-test encoder adapter: reads tagged JSON on stdin, writes TOML on stdout.
  Exits with code 1 and a message on stderr when the input cannot be encoded. }

{$mode objfpc}{$H+}{$J-}

uses
  {$IFDEF UNIX}
  cwstring,  // fpjson converts strings through UnicodeString; without a
             // widestring manager Unix turns every non-ASCII character into '?'
  {$ENDIF}
  SysUtils, Classes, Math, fpjson, jsonparser, TOML, TOML.Types;

var
  InvariantFormat: TFormatSettings;

function ReadStandardInput: string;
var
  InputStream: THandleStream;
  Buffer: TStringStream;
begin
  InputStream := THandleStream.Create(TTextRec(Input).Handle);
  Buffer := TStringStream.Create('');
  try
    Buffer.CopyFrom(InputStream, 0);
    Result := Buffer.DataString;
  finally
    Buffer.Free;
    InputStream.Free;
  end;
end;

const
  { fpjson reads strings as PChar and truncates them at U+0000, so escaped
    NULs travel through it as this noncharacter and are restored afterwards }
  NulStandIn = #$EF#$B7#$90; // U+FDD0

{ Replaces each JSON escape \u0000 (but not an escaped backslash followed by
  u0000) with the stand-in escape ﷐ }
function ProtectNul(const AJSON: string): string;
var
  i, Backslashes: Integer;
begin
  Result := '';
  i := 1;
  Backslashes := 0;
  while i <= Length(AJSON) do
  begin
    if (AJSON[i] = '\') and not Odd(Backslashes) and
       (Copy(AJSON, i, 6) = '\u0000') then
    begin
      Result := Result + '﷐';
      Inc(i, 6);
      Backslashes := 0;
      Continue;
    end;
    if AJSON[i] = '\' then
      Inc(Backslashes)
    else
      Backslashes := 0;
    Result := Result + AJSON[i];
    Inc(i);
  end;
end;

function RestoreNul(const AText: string): string;
begin
  Result := StringReplace(AText, NulStandIn, #0, [rfReplaceAll]);
end;

{ A tagged value is an object with exactly the string members type and value }
function IsTaggedValue(const AObject: TJSONObject): Boolean;
begin
  Result := (AObject.Count = 2) and
    (AObject.IndexOfName('type') >= 0) and (AObject.IndexOfName('value') >= 0) and
    (AObject.Items[AObject.IndexOfName('type')].JSONType = jtString) and
    (AObject.Items[AObject.IndexOfName('value')].JSONType = jtString);
end;

function DecodeFloat(const AText: string): Double;
var
  Text: string;
begin
  Text := LowerCase(AText);
  if (Text = 'nan') or (Text = '+nan') or (Text = '-nan') then
    Exit(NaN);
  if (Text = 'inf') or (Text = '+inf') then
    Exit(Infinity);
  if Text = '-inf' then
    Exit(NegInfinity);
  Result := StrToFloat(StringReplace(Text, '_', '', [rfReplaceAll]), InvariantFormat);
end;

function DecodeTagged(const AType, AValue: string): TTOMLValue;
begin
  if AType = 'string' then
    Result := TTOMLString.Create(RestoreNul(AValue))
  else if AType = 'integer' then
    Result := TTOMLInteger.Create(StrToInt64(AValue))
  else if AType = 'float' then
    Result := TTOMLFloat.Create(DecodeFloat(AValue))
  else if AType = 'bool' then
    Result := TTOMLBoolean.Create(AValue = 'true')
  else if AType = 'datetime' then
    Result := TTOMLDateTime.Create(0, tdtOffsetDateTime, AValue)
  else if AType = 'datetime-local' then
    Result := TTOMLDateTime.Create(0, tdtLocalDateTime, AValue)
  else if AType = 'date-local' then
    Result := TTOMLDateTime.Create(0, tdtLocalDate, AValue)
  else if AType = 'time-local' then
    Result := TTOMLDateTime.Create(0, tdtLocalTime, AValue)
  else
    raise ETOMLException.CreateFmt('Unknown value type "%s"', [AType]);
end;

function DecodeValue(const AData: TJSONData): TTOMLValue; forward;

function DecodeTable(const AObject: TJSONObject): TTOMLTable;
var
  i: Integer;
begin
  Result := TTOMLTable.Create;
  try
    for i := 0 to AObject.Count - 1 do
      Result.Add(RestoreNul(AObject.Names[i]), DecodeValue(AObject.Items[i]));
  except
    Result.Free;
    raise;
  end;
end;

function DecodeArray(const AArray: TJSONArray): TTOMLArray;
var
  i: Integer;
begin
  Result := TTOMLArray.Create;
  try
    for i := 0 to AArray.Count - 1 do
      Result.Add(DecodeValue(AArray.Items[i]));
  except
    Result.Free;
    raise;
  end;
end;

function DecodeValue(const AData: TJSONData): TTOMLValue;
var
  JSONObject: TJSONObject;
begin
  case AData.JSONType of
    jtArray:
      Result := DecodeArray(TJSONArray(AData));
    jtObject:
    begin
      JSONObject := TJSONObject(AData);
      if IsTaggedValue(JSONObject) then
        Result := DecodeTagged(JSONObject.Strings['type'], JSONObject.Strings['value'])
      else
        Result := DecodeTable(JSONObject);
    end;
  else
    raise ETOMLException.Create('Expected a JSON object or array');
  end;
end;

var
  JSON: TJSONData;
  Document: TTOMLValue;
  Output: string;
begin
  // Treat strings as UTF-8 whatever the runner's locale is.
  DefaultSystemCodePage := CP_UTF8;
  InvariantFormat := DefaultFormatSettings;
  InvariantFormat.DecimalSeparator := '.';
  JSON := nil;
  Document := nil;
  try
    try
      JSON := GetJSON(ProtectNul(ReadStandardInput));
      if JSON.JSONType <> jtObject then
        raise ETOMLException.Create('Expected a JSON object at the top level');
      Document := DecodeTable(TJSONObject(JSON));
      Output := SerializeTOML(Document);
      Write(Output);
    except
      on E: Exception do
      begin
        WriteLn(StdErr, E.Message);
        Halt(1);
      end;
    end;
  finally
    Document.Free;
    JSON.Free;
  end;
end.
