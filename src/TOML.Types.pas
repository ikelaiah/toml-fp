{ TOML.Types.pas
  Core data model: one class per TOML value type.

    TTOMLValue (abstract)
      TTOMLString, TTOMLInteger, TTOMLFloat, TTOMLBoolean, TTOMLDateTime
      TTOMLArray   ordered list of values
      TTOMLTable   key/value pairs, kept in insertion order

  Ownership: arrays and tables own their values. Free only the root.
  Conversions: AsString, AsInteger, ... raise ETOMLException on a type
  mismatch (an integer may be read AsFloat).
}
unit TOML.Types;

{$mode objfpc}{$H+}{$J-}
{$modeswitch typehelpers}
{$modeswitch advancedrecords}

interface

uses
  SysUtils, Generics.Collections;

type
  { TOML value types - one per TOML specification type }
  TTOMLValueType = (
    tvtString,      // Basic and literal strings
    tvtInteger,     // Decimal, hex, octal, binary
    tvtFloat,       // Including inf and nan
    tvtBoolean,     // true / false
    tvtDateTime,    // RFC 3339; see TTOMLDateTimeKind
    tvtArray,       // Ordered list of values
    tvtTable,       // Key/value pairs (standard and inline tables)
    tvtInlineTable  // Reserved; the parser reports inline tables as tvtTable
  );

  { The four date/time types defined by TOML 1.0 and 1.1 }
  TTOMLDateTimeKind = (
    tdtOffsetDateTime,  // 1979-05-27T07:32:00Z
    tdtLocalDateTime,   // 1979-05-27T07:32:00
    tdtLocalDate,       // 1979-05-27
    tdtLocalTime        // 07:32:00
  );

  { Forward declarations for interdependent types }
  TTOMLValue = class;
  TTOMLArray = class;
  TTOMLTable = class;
  TTOMLTableEnumerator = class;

  { Base exception type for all TOML-related errors }
  ETOMLException = class(Exception);

  { Raised for invalid TOML input and duplicate keys }
  ETOMLParserException = class(ETOMLException);

  { Raised when a value cannot be serialized }
  ETOMLSerializerException = class(ETOMLException);

  { Key lookup for TOML tables (case-sensitive) }
  TTOMLTableDict = specialize TDictionary<string, TTOMLValue>;

  { Storage for TOML arrays }
  TTOMLValueList = specialize TList<TTOMLValue>;

  { A key and its value, as yielded by `for Pair in Table do` }
  TTOMLKeyValuePair = specialize TPair<string, TTOMLValue>;

  { Base TOML value class - abstract base class for all TOML value types }
  TTOMLValue = class
  private
    FValueType: TTOMLValueType;
  protected
    { Each raises ETOMLException unless the derived class supports it }
    function GetAsString: string; virtual;
    function GetAsInteger: Int64; virtual;
    function GetAsFloat: Double; virtual;
    function GetAsBoolean: Boolean; virtual;
    function GetAsDateTime: TDateTime; virtual;
    function GetAsArray: TTOMLArray; virtual;
    function GetAsTable: TTOMLTable; virtual;
  public
    { Creates a new TOML value with the specified type
      @param AType The type of TOML value to create }
    constructor Create(AType: TTOMLValueType);

    { Typed accessors. Each raises ETOMLException on a type mismatch }
    property ValueType: TTOMLValueType read FValueType;
    property AsString: string read GetAsString;
    property AsInteger: Int64 read GetAsInteger;
    property AsFloat: Double read GetAsFloat;
    property AsBoolean: Boolean read GetAsBoolean;
    property AsDateTime: TDateTime read GetAsDateTime;
    property AsArray: TTOMLArray read GetAsArray;
    property AsTable: TTOMLTable read GetAsTable;
  end;

  { String value - represents a TOML string (basic or literal) }
  TTOMLString = class(TTOMLValue)
  private
    FValue: string;
  protected
    function GetAsString: string; override;
  public
    constructor Create(const AValue: string);
    property Value: string read FValue write FValue;
  end;

  { Integer value - a signed 64-bit TOML integer }
  TTOMLInteger = class(TTOMLValue)
  private
    FValue: Int64;
  protected
    function GetAsInteger: Int64; override;
    function GetAsFloat: Double; override;  // Integers widen to float
  public
    constructor Create(const AValue: Int64);
    property Value: Int64 read FValue write FValue;
  end;

  { Float value - an IEEE 754 double, including inf and nan }
  TTOMLFloat = class(TTOMLValue)
  private
    FValue: Double;
  protected
    function GetAsFloat: Double; override;
  public
    constructor Create(const AValue: Double);
    property Value: Double read FValue write FValue;
  end;

  { Boolean value - represents a TOML boolean (true/false) }
  TTOMLBoolean = class(TTOMLValue)
  private
    FValue: Boolean;
  protected
    function GetAsBoolean: Boolean; override;
  public
    constructor Create(const AValue: Boolean);
    property Value: Boolean read FValue write FValue;
  end;

  { DateTime value - one of the four TOML date/time kinds.
    Parsed values keep their source text in RawValue, so offsets and
    sub-millisecond digits survive a round trip. }
  TTOMLDateTime = class(TTOMLValue)
  private
    FValue: TDateTime;
    FKind: TTOMLDateTimeKind;
    FRawValue: string;
  protected
    function GetAsDateTime: TDateTime; override;
  public
    { Creates a local date-time value. TDateTime carries no time zone, so
      it serializes without an offset, e.g. 2026-11-17T09:30:00
      @param AValue The TDateTime value to store }
    constructor Create(const AValue: TDateTime); overload;
    constructor Create(const AValue: TDateTime;
      const AKind: TTOMLDateTimeKind; const ARawValue: string); overload;
    property Value: TDateTime read FValue write FValue;
    property Kind: TTOMLDateTimeKind read FKind;
    { Returns the value as RFC 3339 text for serialization. Source text is
      kept but normalized: a space or lowercase t becomes T, a lowercase z
      becomes Z, and omitted seconds (TOML 1.1) are written as :00 so that
      TOML 1.0 readers accept the result }
    function CanonicalText: string;
    property RawValue: string read FRawValue;
  end;

  { Array value - an ordered list of values of any type }
  TTOMLArray = class(TTOMLValue)
  private
    FItems: TTOMLValueList;
  protected
    function GetAsArray: TTOMLArray; override;
  public
    constructor Create;
    destructor Destroy; override;

    { Appends a value. The array takes ownership of it }
    procedure Add(AValue: TTOMLValue);

    { @returns The value at a zero-based index
      @raises EListError if the index is out of bounds }
    function GetItem(Index: Integer): TTOMLValue;

    { @returns The number of items }
    function GetCount: Integer;

    { Enables `for Value in Arr do` }
    function GetEnumerator: TTOMLValueList.TEnumerator;

    property Items: TTOMLValueList read FItems;
    property Count: Integer read GetCount;
  end;

  { Table value - key/value pairs. Keys keep the order in which they were
    added, so documents serialize in the order they were written or built. }
  TTOMLTable = class(TTOMLValue)
  private
    FItems: TTOMLTableDict;              // Key lookup
    FKeys: specialize TList<string>;    // Insertion order
    procedure SyncKeys;
    function GetCount: Integer;
    function GetKey(Index: Integer): string;
    function GetValue(Index: Integer): TTOMLValue;
  protected
    function GetAsTable: TTOMLTable; override;
  public
    constructor Create;
    destructor Destroy; override;

    { Adds a key-value pair. The table takes ownership of the value
      @raises ETOMLParserException if the key already exists }
    procedure Add(const AKey: string; AValue: TTOMLValue);

    { Removes a key and frees its value
      @returns True if the key existed }
    function Remove(const AKey: string): Boolean;

    { @returns True and the value if the key exists }
    function TryGetValue(const AKey: string; out AValue: TTOMLValue): Boolean;

    { @returns True if the key exists }
    function Contains(const AKey: string): Boolean;

    { @returns The value for AKey, or nil if the key does not exist }
    function Find(const AKey: string): TTOMLValue;

    { Walks nested tables, one key per path element
      @param APath Keys, outermost first, e.g. ['server', 'http', 'port']
      @returns The value, or nil if a key is missing or a parent is not a table }
    function FindPath(const APath: array of string): TTOMLValue;

    { Typed lookups by path. They return ADefault when the path does not
      exist, and raise ETOMLException when it exists with another type.
      Example: Port := Config.GetInteger(['server', 'port'], 8080); }
    function GetString(const APath: array of string; const ADefault: string = ''): string;
    function GetInteger(const APath: array of string; const ADefault: Int64 = 0): Int64;
    function GetFloat(const APath: array of string; const ADefault: Double = 0): Double;
    function GetBoolean(const APath: array of string; const ADefault: Boolean = False): Boolean;

    { @returns The table at APath, or nil if missing or not a table }
    function GetTable(const APath: array of string): TTOMLTable;

    { @returns The array at APath, or nil if missing or not an array }
    function GetArray(const APath: array of string): TTOMLArray;

    { Enables `for Pair in Table do`, visiting keys in insertion order }
    function GetEnumerator: TTOMLTableEnumerator;

    { Number of keys }
    property Count: Integer read GetCount;
    { Key at a zero-based position, in insertion order }
    property Keys[Index: Integer]: string read GetKey;
    { Value at a zero-based position, in insertion order }
    property Values[Index: Integer]: TTOMLValue read GetValue;

    { Underlying dictionary. Its enumeration order is unspecified; use
      `for Pair in Table`, Keys or Values for document order. Add and remove
      entries through the table so the order stays correct. }
    property Items: TTOMLTableDict read FItems;
  end;

  { Ordered key/value enumerator returned by TTOMLTable.GetEnumerator }
  TTOMLTableEnumerator = class
  private
    FTable: TTOMLTable;
    FIndex: Integer;
    function GetCurrent: TTOMLKeyValuePair;
  public
    constructor Create(ATable: TTOMLTable);
    function MoveNext: Boolean;
    property Current: TTOMLKeyValuePair read GetCurrent;
  end;

implementation

{ TTOMLValue }

constructor TTOMLValue.Create(AType: TTOMLValueType);
begin
  inherited Create;
  FValueType := AType;
end;

function TTOMLValue.GetAsString: string;
begin
  Result := '';
  raise ETOMLException.Create('Cannot convert this TOML value to string');
end;

function TTOMLValue.GetAsInteger: Int64;
begin
  Result := 0;
  raise ETOMLException.Create('Cannot convert this TOML value to integer');
end;

function TTOMLValue.GetAsFloat: Double;
begin
  Result := 0.0;
  raise ETOMLException.Create('Cannot convert this TOML value to float');
end;

function TTOMLValue.GetAsBoolean: Boolean;
begin
  Result := False;
  raise ETOMLException.Create('Cannot convert this TOML value to boolean');
end;

function TTOMLValue.GetAsDateTime: TDateTime;
begin
  Result := 0;
  raise ETOMLException.Create('Cannot convert this TOML value to datetime');
end;

function TTOMLValue.GetAsArray: TTOMLArray;
begin
  Result := nil;
  raise ETOMLException.Create('Cannot convert this TOML value to array');
end;

function TTOMLValue.GetAsTable: TTOMLTable;
begin
  Result := nil;
  raise ETOMLException.Create('Cannot convert this TOML value to table');
end;

{ TTOMLString }

constructor TTOMLString.Create(const AValue: string);
begin
  inherited Create(tvtString);
  FValue := AValue;
end;

function TTOMLString.GetAsString: string;
begin
  Result := FValue;
end;

{ TTOMLInteger }

constructor TTOMLInteger.Create(const AValue: Int64);
begin
  inherited Create(tvtInteger);
  FValue := AValue;
end;

function TTOMLInteger.GetAsInteger: Int64;
begin
  Result := FValue;
end;

function TTOMLInteger.GetAsFloat: Double;
begin
  Result := FValue;
end;

{ TTOMLFloat }

constructor TTOMLFloat.Create(const AValue: Double);
begin
  inherited Create(tvtFloat);
  FValue := AValue;
end;

function TTOMLFloat.GetAsFloat: Double;
begin
  Result := FValue;
end;

{ TTOMLBoolean }

constructor TTOMLBoolean.Create(const AValue: Boolean);
begin
  inherited Create(tvtBoolean);
  FValue := AValue;
end;

function TTOMLBoolean.GetAsBoolean: Boolean;
begin
  Result := FValue;
end;

{ TTOMLDateTime }

constructor TTOMLDateTime.Create(const AValue: TDateTime);
begin
  Create(AValue, tdtLocalDateTime, '');
end;

constructor TTOMLDateTime.Create(const AValue: TDateTime;
  const AKind: TTOMLDateTimeKind; const ARawValue: string);
begin
  inherited Create(tvtDateTime);
  FValue := AValue;
  FKind := AKind;
  FRawValue := ARawValue;
end;

function TTOMLDateTime.CanonicalText: string;
const
  DatePart = 'yyyy-mm-dd';
  TimePart = 'hh:nn:ss';
var
  TimeStart: Integer;
  Time: string;
  Hour, Minute, Second, MilliSecond: Word;
begin
  if FRawValue = '' then
  begin
    // Milliseconds are written only when present.
    Time := TimePart;
    DecodeTime(FValue, Hour, Minute, Second, MilliSecond);
    if MilliSecond > 0 then
      Time := Time + '.zzz';
    case FKind of
      tdtOffsetDateTime:
        Result := FormatDateTime(DatePart + '"T"' + Time + '"Z"', FValue);
      tdtLocalDateTime:
        Result := FormatDateTime(DatePart + '"T"' + Time, FValue);
      tdtLocalDate:
        Result := FormatDateTime(DatePart, FValue);
      tdtLocalTime:
        Result := FormatDateTime(Time, FValue);
    end;
    Exit;
  end;

  Result := FRawValue;
  if (Length(Result) >= 11) and (Result[11] in [' ', 't']) then
    Result[11] := 'T';
  if (Result <> '') and (Result[Length(Result)] = 'z') then
    Result[Length(Result)] := 'Z';

  if FKind = tdtLocalDate then
    Exit;
  if FKind = tdtLocalTime then
    TimeStart := 1
  else
    TimeStart := 12;
  if (Length(Result) < TimeStart + 5) or (Result[TimeStart + 5] <> ':') then
    Insert(':00', Result, TimeStart + 5);
end;

function TTOMLDateTime.GetAsDateTime: TDateTime;
begin
  Result := FValue;
end;

{ TTOMLArray }

constructor TTOMLArray.Create;
begin
  inherited Create(tvtArray);
  FItems := TTOMLValueList.Create;
end;

destructor TTOMLArray.Destroy;
var
  Item: TTOMLValue;
begin
  for Item in FItems do
    Item.Free;
  FItems.Free;
  inherited Destroy;
end;

procedure TTOMLArray.Add(AValue: TTOMLValue);
begin
  FItems.Add(AValue);
end;

function TTOMLArray.GetItem(Index: Integer): TTOMLValue;
begin
  Result := FItems[Index];
end;

function TTOMLArray.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TTOMLArray.GetEnumerator: TTOMLValueList.TEnumerator;
begin
  Result := FItems.GetEnumerator;
end;

function TTOMLArray.GetAsArray: TTOMLArray;
begin
  Result := Self;
end;

{ TTOMLTable }

constructor TTOMLTable.Create;
begin
  inherited Create(tvtTable);
  FItems := TTOMLTableDict.Create;
  FKeys := specialize TList<string>.Create;
end;

destructor TTOMLTable.Destroy;
var
  Item: TTOMLValue;
begin
  // The table owns its values, including nested tables and arrays.
  for Item in FItems.Values do
    Item.Free;
  FItems.Free;
  FKeys.Free;
  inherited Destroy;
end;

procedure TTOMLTable.SyncKeys;
var
  i: Integer;
  Key: string;
  Seen: specialize TDictionary<string, Boolean>;
begin
  // Recovers the key order if Items was changed directly.
  if FKeys.Count = FItems.Count then
    Exit;
  Seen := specialize TDictionary<string, Boolean>.Create;
  try
    for i := FKeys.Count - 1 downto 0 do
      if (not FItems.ContainsKey(FKeys[i])) or Seen.ContainsKey(FKeys[i]) then
        FKeys.Delete(i)
      else
        Seen.Add(FKeys[i], True);
    for Key in FItems.Keys do
      if not Seen.ContainsKey(Key) then
        FKeys.Add(Key);
  finally
    Seen.Free;
  end;
end;

function TTOMLTable.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TTOMLTable.GetKey(Index: Integer): string;
begin
  SyncKeys;
  Result := FKeys[Index];
end;

function TTOMLTable.GetValue(Index: Integer): TTOMLValue;
begin
  Result := FItems[GetKey(Index)];
end;

procedure TTOMLTable.Add(const AKey: string; AValue: TTOMLValue);
begin
  if FItems.ContainsKey(AKey) then
    raise ETOMLParserException.CreateFmt('Duplicate key "%s" found', [AKey]);
  SyncKeys;
  FItems.Add(AKey, AValue);
  FKeys.Add(AKey);
end;

function TTOMLTable.Remove(const AKey: string): Boolean;
var
  Value: TTOMLValue;
begin
  Result := FItems.TryGetValue(AKey, Value);
  if not Result then
    Exit;
  FItems.Remove(AKey);
  FKeys.Remove(AKey);
  Value.Free;
end;

function TTOMLTable.TryGetValue(const AKey: string; out AValue: TTOMLValue): Boolean;
begin
  Result := FItems.TryGetValue(AKey, AValue);
end;

function TTOMLTable.Contains(const AKey: string): Boolean;
begin
  Result := FItems.ContainsKey(AKey);
end;

function TTOMLTable.Find(const AKey: string): TTOMLValue;
begin
  if not FItems.TryGetValue(AKey, Result) then
    Result := nil;
end;

function TTOMLTable.FindPath(const APath: array of string): TTOMLValue;
var
  i: Integer;
begin
  Result := Self;
  for i := Low(APath) to High(APath) do
  begin
    if not (Result is TTOMLTable) then
      Exit(nil);
    Result := TTOMLTable(Result).Find(APath[i]);
    if Result = nil then
      Exit;
  end;
end;

function TTOMLTable.GetString(const APath: array of string; const ADefault: string): string;
var
  Value: TTOMLValue;
begin
  Value := FindPath(APath);
  if Value = nil then
    Result := ADefault
  else
    Result := Value.AsString;
end;

function TTOMLTable.GetInteger(const APath: array of string; const ADefault: Int64): Int64;
var
  Value: TTOMLValue;
begin
  Value := FindPath(APath);
  if Value = nil then
    Result := ADefault
  else
    Result := Value.AsInteger;
end;

function TTOMLTable.GetFloat(const APath: array of string; const ADefault: Double): Double;
var
  Value: TTOMLValue;
begin
  Value := FindPath(APath);
  if Value = nil then
    Result := ADefault
  else
    Result := Value.AsFloat;
end;

function TTOMLTable.GetBoolean(const APath: array of string; const ADefault: Boolean): Boolean;
var
  Value: TTOMLValue;
begin
  Value := FindPath(APath);
  if Value = nil then
    Result := ADefault
  else
    Result := Value.AsBoolean;
end;

function TTOMLTable.GetTable(const APath: array of string): TTOMLTable;
var
  Value: TTOMLValue;
begin
  Value := FindPath(APath);
  if Value is TTOMLTable then
    Result := TTOMLTable(Value)
  else
    Result := nil;
end;

function TTOMLTable.GetArray(const APath: array of string): TTOMLArray;
var
  Value: TTOMLValue;
begin
  Value := FindPath(APath);
  if Value is TTOMLArray then
    Result := TTOMLArray(Value)
  else
    Result := nil;
end;

function TTOMLTable.GetEnumerator: TTOMLTableEnumerator;
begin
  Result := TTOMLTableEnumerator.Create(Self);
end;

function TTOMLTable.GetAsTable: TTOMLTable;
begin
  Result := Self;
end;

{ TTOMLTableEnumerator }

constructor TTOMLTableEnumerator.Create(ATable: TTOMLTable);
begin
  inherited Create;
  FTable := ATable;
  FIndex := -1;
end;

function TTOMLTableEnumerator.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < FTable.Count;
end;

function TTOMLTableEnumerator.GetCurrent: TTOMLKeyValuePair;
begin
  Result := TTOMLKeyValuePair.Create(FTable.Keys[FIndex], FTable.Values[FIndex]);
end;

end.
