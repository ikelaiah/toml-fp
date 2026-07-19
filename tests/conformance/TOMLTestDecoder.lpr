program TOMLTestDecoder;

{$mode objfpc}{$H+}{$J-}

uses
  SysUtils, Classes, Math, Generics.Collections, fpjson, TOML, TOML.Types;

type
  TTOMLPair = specialize TPair<string, TTOMLValue>;

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

function TaggedValue(const AType, AValue: string): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.Add('type', AType);
  Result.Add('value', AValue);
end;

function FloatValueToString(const AValue: Double): string;
var
  FormatSettings: TFormatSettings;
begin
  if IsNan(AValue) then
    Exit('nan');
  if IsInfinite(AValue) then
  begin
    if AValue < 0 then
      Exit('-inf');
    Exit('inf');
  end;

  if (AValue = 0.0) and (PInt64(@AValue)^ < 0) then
    Exit('-0.0');

  FormatSettings := DefaultFormatSettings;
  FormatSettings.DecimalSeparator := '.';
  Result := Format('%.17g', [AValue], FormatSettings);
  if (Pos('.', Result) = 0) and (Pos('E', UpperCase(Result)) = 0) then
    Result := Result + '.0';
end;

function DateTimeValueToString(const AValue: TTOMLDateTime): string;
var
  DotPosition, FractionEnd, FractionLength: Integer;
  Fraction: string;
begin
  if AValue.RawValue = '' then
  begin
    case AValue.Kind of
      tdtOffsetDateTime:
        Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz"Z"', AValue.Value);
      tdtLocalDateTime:
        Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz', AValue.Value);
      tdtLocalDate:
        Result := FormatDateTime('yyyy-mm-dd', AValue.Value);
      tdtLocalTime:
        Result := FormatDateTime('hh:nn:ss.zzz', AValue.Value);
    end;
    Exit;
  end;

  Result := AValue.RawValue;
  if (Length(Result) >= 11) and (Result[11] in [' ', 't']) then
    Result[11] := 'T';
  if (Result <> '') and (Result[Length(Result)] = 'z') then
    Result[Length(Result)] := 'Z';

  DotPosition := Pos('.', Result);
  if DotPosition > 0 then
  begin
    FractionEnd := DotPosition + 1;
    while (FractionEnd <= Length(Result)) and (Result[FractionEnd] in ['0'..'9']) do
      Inc(FractionEnd);
    FractionLength := FractionEnd - DotPosition - 1;
    Fraction := Copy(Result, DotPosition + 1, FractionLength);
    Fraction := Copy(Fraction + '000', 1, 3);
    Delete(Result, DotPosition + 1, FractionLength);
    Insert(Fraction, Result, DotPosition + 1);
  end;
end;

function DateTimeTypeName(const AValue: TTOMLDateTime): string;
begin
  case AValue.Kind of
    tdtOffsetDateTime: Result := 'datetime';
    tdtLocalDateTime: Result := 'datetime-local';
    tdtLocalDate: Result := 'date-local';
    tdtLocalTime: Result := 'time-local';
  end;
end;

function EncodeValue(const AValue: TTOMLValue): TJSONData; forward;

function EncodeArray(const AArray: TTOMLArray): TJSONArray;
var
  Index: Integer;
begin
  Result := TJSONArray.Create;
  for Index := 0 to AArray.Count - 1 do
    Result.Add(EncodeValue(AArray.GetItem(Index)));
end;

function EncodeTable(const ATable: TTOMLTable): TJSONObject;
var
  Pair: TTOMLPair;
begin
  Result := TJSONObject.Create;
  for Pair in ATable.Items do
    Result.Add(Pair.Key, EncodeValue(Pair.Value));
end;

function EncodeValue(const AValue: TTOMLValue): TJSONData;
begin
  case AValue.ValueType of
    tvtString:
      Result := TaggedValue('string', AValue.AsString);
    tvtInteger:
      Result := TaggedValue('integer', IntToStr(AValue.AsInteger));
    tvtFloat:
      Result := TaggedValue('float', FloatValueToString(AValue.AsFloat));
    tvtBoolean:
      if AValue.AsBoolean then
        Result := TaggedValue('bool', 'true')
      else
        Result := TaggedValue('bool', 'false');
    tvtDateTime:
      Result := TaggedValue(DateTimeTypeName(TTOMLDateTime(AValue)),
        DateTimeValueToString(TTOMLDateTime(AValue)));
    tvtArray:
      Result := EncodeArray(AValue.AsArray);
    tvtTable, tvtInlineTable:
      Result := EncodeTable(AValue.AsTable);
  else
    raise ETOMLException.Create('Unsupported TOML value type');
  end;
end;

var
  Parsed: TTOMLTable;
  Encoded: TJSONData;
begin
  Parsed := nil;
  Encoded := nil;
  try
    try
      Parsed := ParseTOML(ReadStandardInput);
      Encoded := EncodeTable(Parsed);
      Write(Encoded.AsJSON);
    except
      on E: Exception do
      begin
        WriteLn(StdErr, E.Message);
        Halt(1);
      end;
    end;
  finally
    Encoded.Free;
    Parsed.Free;
  end;
end.
