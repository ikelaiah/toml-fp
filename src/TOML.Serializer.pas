{ TOML.Serializer.pas
  Turns a TTOMLValue tree back into TOML text.

  Output rules:
  - Keys appear in table insertion order. Within a table, plain key/value
    pairs come first, then [sub.tables] and [[arrays.of.tables]].
  - A table that holds only sub-tables gets no header of its own; its
    children's headers define it (e.g. [server.http] without [server]).
  - Arrays whose items are all tables become [[headers]]; any other table
    nested in a value is written as an inline table.
  - Arrays stay on one line up to MaxLineWidth, then wrap one item per line.
  - Floats round-trip exactly and always look like floats (1.0, not 1);
    output never depends on the locale.
  - Strings use basic quotes with escapes; times always carry seconds, so
    output stays readable by TOML 1.0 parsers.
}
unit TOML.Serializer;

{$mode objfpc}{$H+}{$J-}

interface

uses
  SysUtils, Classes, TOML.Types;

type
  { Key-Value pair type for TOML tables (alias of the TOML.Types type) }
  TTOMLKeyValuePair = TOML.Types.TTOMLKeyValuePair;

  { Converts TOML values to text. One instance can serialize many values }
  TTOMLSerializer = class
  private
    FBuilder: TStringBuilder;

    { Writes the key/value pairs and sections of a document-level table
      @param ATable Table to write
      @param APath Already-formatted dotted path of ATable ('' for root) }
    procedure WriteTableBody(const ATable: TTOMLTable; const APath: string);

    { Writes a [header] or [[header]] line, preceded by a blank line
      unless it is the first line of output }
    procedure WriteHeader(const AHeader: string);

    { Formats a value for use after "key = "
      @param AValue Value to format
      @param AIndent Indentation level, for wrapped arrays
      @param AColumn Column where the value starts, for line-width checks
      @param AAllowWrap False inside inline tables, which must stay on one line }
    function FormatValue(const AValue: TTOMLValue; AIndent, AColumn: Integer;
      AAllowWrap: Boolean): string;
    function FormatArray(const AArray: TTOMLArray; AIndent, AColumn: Integer;
      AAllowWrap: Boolean): string;
    function FormatInlineTable(const ATable: TTOMLTable): string;
  public
    constructor Create;
    destructor Destroy; override;

    { Serializes a value. A table becomes a whole TOML document; any other
      value becomes its inline TOML representation
      @raises ETOMLSerializerException if the value cannot be serialized }
    function Serialize(const AValue: TTOMLValue): string;
  end;

const
  { Arrays longer than this, measured from the start of the line, wrap }
  MaxLineWidth = 80;

{ Serializes a TOML value to string format
  @param AValue The value to serialize (usually the root table)
  @returns The serialized TOML string
  @raises ETOMLSerializerException if value cannot be serialized }
function SerializeTOML(const AValue: TTOMLValue): string;

{ Serializes a TOML value to a UTF-8 file, replacing any existing file
  @param AValue The value to serialize
  @param AFileName The output file path
  @returns True if the file was written, False on any error }
function SerializeTOMLToFile(const AValue: TTOMLValue; const AFileName: string): Boolean;

{ Formats a key, quoting it only when it is not a valid bare key }
function FormatTOMLKey(const AKey: string): string;

{ Formats a string as a TOML basic string, with escapes }
function FormatTOMLString(const AValue: string): string;

{ Formats a float so it parses back to the same Double, using TOML
  spellings for special values (inf, -inf, nan) }
function FormatTOMLFloat(const AValue: Double): string;

implementation

uses
  Math;

var
  InvariantFormat: TFormatSettings;

{ High-level functions }

function SerializeTOML(const AValue: TTOMLValue): string;
var
  Serializer: TTOMLSerializer;
begin
  Serializer := TTOMLSerializer.Create;
  try
    Result := Serializer.Serialize(AValue);
  finally
    Serializer.Free;
  end;
end;

function SerializeTOMLToFile(const AValue: TTOMLValue; const AFileName: string): Boolean;
var
  Text: string;
  Stream: TFileStream;
begin
  Result := False;
  try
    Text := SerializeTOML(AValue);
    Stream := TFileStream.Create(AFileName, fmCreate);
    try
      if Text <> '' then
        Stream.WriteBuffer(Text[1], Length(Text));
      Result := True;
    finally
      Stream.Free;
    end;
  except
    // The documented contract is a Boolean result, not an exception.
  end;
end;

{ Formatting helpers }

function IsBareKey(const AKey: string): Boolean;
var
  C: Char;
begin
  if AKey = '' then
    Exit(False);
  for C in AKey do
    if not (C in ['A'..'Z', 'a'..'z', '0'..'9', '_', '-']) then
      Exit(False);
  Result := True;
end;

function FormatTOMLString(const AValue: string): string;
var
  Builder: TStringBuilder;
  C: Char;
begin
  Builder := TStringBuilder.Create(Length(AValue) + 2);
  try
    Builder.Append('"');
    for C in AValue do
      case C of
        #8:  Builder.Append('\b');
        #9:  Builder.Append('\t');
        #10: Builder.Append('\n');
        #12: Builder.Append('\f');
        #13: Builder.Append('\r');
        '"': Builder.Append('\"');
        '\': Builder.Append('\\');
        #0..#7, #11, #14..#31, #127:
          Builder.Append(Format('\u%.4X', [Ord(C)]));
      else
        // Bytes >= $80 are UTF-8 sequences and pass through unchanged.
        Builder.Append(C);
      end;
    Builder.Append('"');
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

function FormatTOMLKey(const AKey: string): string;
begin
  if IsBareKey(AKey) then
    Result := AKey
  else
    Result := FormatTOMLString(AKey);
end;

{ Lays out significant digits as positional or scientific notation.
  The value is 0.<ADigits> * 10^AExponent }
function LayOutFloat(const ADigits: string; AExponent: Integer;
  ANegative: Boolean): string;
var
  Count: Integer;
begin
  Count := Length(ADigits);
  if (AExponent > 17) or (AExponent < -4) then
  begin
    // Scientific: 1.5e-7, 6.02214076e23
    Result := ADigits[1];
    if Count > 1 then
      Result := Result + '.' + Copy(ADigits, 2, MaxInt);
    Result := Result + 'e' + IntToStr(AExponent - 1);
  end
  else if AExponent <= 0 then
    Result := '0.' + StringOfChar('0', -AExponent) + ADigits
  else if AExponent >= Count then
    Result := ADigits + StringOfChar('0', AExponent - Count) + '.0'
  else
    Result := Copy(ADigits, 1, AExponent) + '.' + Copy(ADigits, AExponent + 1, MaxInt);
  if ANegative then
    Result := '-' + Result;
end;

function FormatTOMLFloat(const AValue: Double): string;
var
  Decimal: TFloatRec;
  Digits: string;
  Precision: Integer;
begin
  if IsNan(AValue) then
    Exit('nan');
  if IsInfinite(AValue) then
    if AValue > 0 then
      Exit('inf')
    else
      Exit('-inf');
  if AValue = 0 then
    if PInt64(@AValue)^ < 0 then
      Exit('-0.0')
    else
      Exit('0.0');

  // Fewest significant digits (at most 17) that read back exactly.
  // (FloatToStrF caps Double precision at 15 digits, so it cannot be used.)
  for Precision := 1 to 17 do
  begin
    FloatToDecimal(Decimal, AValue, fvDouble, Precision, 9999);
    Digits := StrPas(@Decimal.Digits[0]);
    while (Length(Digits) > 1) and (Digits[Length(Digits)] = '0') do
      SetLength(Digits, Length(Digits) - 1);
    Result := LayOutFloat(Digits, Decimal.Exponent, Decimal.Negative);
    if StrToFloat(Result, InvariantFormat) = AValue then
      Exit;
  end;
end;

function IsArrayOfTables(const AValue: TTOMLValue): Boolean;
var
  Item: TTOMLValue;
begin
  Result := (AValue.ValueType = tvtArray) and (AValue.AsArray.Count > 0);
  if Result then
    for Item in AValue.AsArray do
      if Item.ValueType <> tvtTable then
        Exit(False);
end;

{ A value that gets its own [header] or [[header]] section }
function IsSection(const AValue: TTOMLValue): Boolean;
begin
  Result := (AValue.ValueType = tvtTable) or IsArrayOfTables(AValue);
end;

{ True when a table's headers can be left out because its children define it }
function IsImplicitTable(const ATable: TTOMLTable): Boolean;
var
  Pair: TTOMLKeyValuePair;
begin
  if ATable.Count = 0 then
    Exit(False);
  for Pair in ATable do
    if not IsSection(Pair.Value) then
      Exit(False);
  Result := True;
end;

function JoinPath(const APath, AKey: string): string;
begin
  if APath = '' then
    Result := FormatTOMLKey(AKey)
  else
    Result := APath + '.' + FormatTOMLKey(AKey);
end;

{ TTOMLSerializer }

constructor TTOMLSerializer.Create;
begin
  inherited Create;
  FBuilder := TStringBuilder.Create;
end;

destructor TTOMLSerializer.Destroy;
begin
  FBuilder.Free;
  inherited Destroy;
end;

procedure TTOMLSerializer.WriteHeader(const AHeader: string);
begin
  if FBuilder.Length > 0 then
    FBuilder.Append(LineEnding);
  FBuilder.Append(AHeader);
  FBuilder.Append(LineEnding);
end;

function TTOMLSerializer.FormatInlineTable(const ATable: TTOMLTable): string;
var
  Pair: TTOMLKeyValuePair;
begin
  if ATable.Count = 0 then
    Exit('{}');
  Result := '';
  for Pair in ATable do
  begin
    if Result <> '' then
      Result := Result + ', ';
    Result := Result + FormatTOMLKey(Pair.Key) + ' = ' +
      FormatValue(Pair.Value, 0, 0, False);
  end;
  Result := '{ ' + Result + ' }';
end;

function TTOMLSerializer.FormatArray(const AArray: TTOMLArray;
  AIndent, AColumn: Integer; AAllowWrap: Boolean): string;
var
  Items: array of string;
  i, Width: Integer;
  Wrap: Boolean;
  Pad: string;
begin
  if AArray.Count = 0 then
    Exit('[]');

  SetLength(Items, AArray.Count);
  Width := AColumn + 2;
  Wrap := False;
  Pad := StringOfChar(' ', (AIndent + 1) * 2);
  for i := 0 to AArray.Count - 1 do
  begin
    Items[i] := FormatValue(AArray.GetItem(i), AIndent + 1, Length(Pad),
      AAllowWrap);
    Inc(Width, Length(Items[i]) + 2);
    if Pos(LineEnding, Items[i]) > 0 then
      Wrap := True;
  end;
  Wrap := AAllowWrap and (Wrap or (Width > MaxLineWidth));

  if not Wrap then
  begin
    Result := '[' + Items[0];
    for i := 1 to High(Items) do
      Result := Result + ', ' + Items[i];
    Exit(Result + ']');
  end;

  // One item per line, with a trailing comma for clean diffs.
  Result := '[' + LineEnding;
  for i := 0 to High(Items) do
    Result := Result + Pad + Items[i] + ',' + LineEnding;
  Result := Result + StringOfChar(' ', AIndent * 2) + ']';
end;

function TTOMLSerializer.FormatValue(const AValue: TTOMLValue;
  AIndent, AColumn: Integer; AAllowWrap: Boolean): string;
begin
  if AValue = nil then
    raise ETOMLSerializerException.Create('Cannot serialize a nil value');

  case AValue.ValueType of
    tvtString:
      Result := FormatTOMLString(AValue.AsString);
    tvtInteger:
      Result := IntToStr(AValue.AsInteger);
    tvtFloat:
      Result := FormatTOMLFloat(AValue.AsFloat);
    tvtBoolean:
      Result := BoolToStr(AValue.AsBoolean, 'true', 'false');
    tvtDateTime:
      Result := (AValue as TTOMLDateTime).CanonicalText;
    tvtArray:
      Result := FormatArray(AValue.AsArray, AIndent, AColumn, AAllowWrap);
    tvtTable, tvtInlineTable:
      Result := FormatInlineTable(AValue.AsTable);
  else
    raise ETOMLSerializerException.Create('Unsupported TOML value type');
  end;
end;

procedure TTOMLSerializer.WriteTableBody(const ATable: TTOMLTable;
  const APath: string);
var
  Pair: TTOMLKeyValuePair;
  Item: TTOMLValue;
  Key, Path: string;
begin
  // 1. Plain key/value pairs belong to the current section.
  for Pair in ATable do
    if not IsSection(Pair.Value) then
    begin
      Key := FormatTOMLKey(Pair.Key);
      FBuilder.Append(Key);
      FBuilder.Append(' = ');
      FBuilder.Append(FormatValue(Pair.Value, 0, Length(Key) + 3, True));
      FBuilder.Append(LineEnding);
    end;

  // 2. Sub-tables and arrays of tables, in insertion order.
  for Pair in ATable do
  begin
    if not IsSection(Pair.Value) then
      Continue;
    Path := JoinPath(APath, Pair.Key);

    if Pair.Value.ValueType = tvtTable then
    begin
      if not IsImplicitTable(Pair.Value.AsTable) then
        WriteHeader('[' + Path + ']');
      WriteTableBody(Pair.Value.AsTable, Path);
    end
    else
      for Item in Pair.Value.AsArray do
      begin
        WriteHeader('[[' + Path + ']]');
        WriteTableBody(Item.AsTable, Path);
      end;
  end;
end;

function TTOMLSerializer.Serialize(const AValue: TTOMLValue): string;
begin
  FBuilder.Clear;
  if AValue is TTOMLTable then
    WriteTableBody(TTOMLTable(AValue), '')
  else
    FBuilder.Append(FormatValue(AValue, 0, 0, True));
  Result := FBuilder.ToString;
end;

initialization
  InvariantFormat := DefaultFormatSettings;
  InvariantFormat.DecimalSeparator := '.';
  InvariantFormat.ThousandSeparator := #0;

end.
