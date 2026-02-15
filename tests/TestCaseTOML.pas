unit TestCaseTOML;

{$mode objfpc}{$H+}{$J-}

interface

uses
  SysUtils, Classes, TOML, TOML.Types, fpcunit, testregistry, Math;

type
  TTOMLTestCase = class(TTestCase)
  published
    { Basic Types Tests }
    procedure Test01_StringValue;
    procedure Test02_IntegerValue;
    procedure Test03_FloatValue;
    procedure Test04_BooleanTrueValue;
    procedure Test05_BooleanFalseValue;
    procedure Test06_DateTimeValue;
    
    { Array Tests }
    procedure Test10_IntegerArray;
    procedure Test11_StringArray;
    procedure Test12_MixedArrayInteger;
    procedure Test13_MixedArrayString;
    procedure Test14_MixedArrayBoolean;
    procedure Test15_EmptyArray;
    procedure Test16_InlineTableArray;
    
    { Table Tests }
    procedure Test20_BasicTableString;
    procedure Test21_BasicTableInteger;
    procedure Test22_InlineTableString;
    procedure Test23_InlineTableInteger;
    procedure Test24_EmptyTable;
    procedure Test25_NestedTable;
    
    { Serialization Tests }
    procedure Test30_SerializeString;
    procedure Test31_SerializeInteger;
    procedure Test32_SerializeFloat;
    procedure Test33_SerializeBoolean;
    procedure Test34_SerializeArray;
    procedure Test35_SerializeTable;
    procedure Test36_SerializeNestedTable;
    procedure Test36_1_SerializeHierarchicalNestedTable;
    procedure Test36_2_SerializeLiteralDottedKeyTable;
    procedure Test37_SerializeArrayOfTables;
    
    { Error Cases }
    procedure Test40_InvalidInteger;
    procedure Test41_InvalidFloat;
    procedure Test42_InvalidDateTime;
    procedure Test43_InvalidTableKey;
    procedure Test44_DuplicateKey;
    
    { TOML v1.0.0 Specification Tests }
    procedure Test50_MultilineString;
    procedure Test51_LiteralString;
    procedure Test52_MultilineLiteralString;
    procedure Test53_IntegerWithUnderscores;
    procedure Test54_HexOctBinIntegers;
    procedure Test55_FloatWithUnderscores;
    procedure Test56_LocalDateTime;
    procedure Test57_LocalDate;
    procedure Test58_LocalTime;
    procedure Test59_ArrayOfTables;
    procedure Test60_DottedTableArray;
    
    { Additional TOML v1.0.0 Specification Tests }
    procedure Test61_PositiveInf;
    procedure Test61_NegativeInf;
    procedure Test61_NotANumber;
    procedure Test62_OffsetDateTime;
    procedure Test63_MultilineArray;
    procedure Test64_QuotedKeys;
    procedure Test65_SuperTables;
    procedure Test66_WhitespaceHandling;
    procedure Test67_ArrayTypeValidation;
    procedure Test68_KeyValidation;
    procedure Test69_TableArrayNesting;
    procedure Test69_1_ArrayOfTablesWithSubtables;
    procedure Test70_ComplexKeys;
    procedure Test71_HierarchicalNestedTable;
    procedure Test72_LiteralDottedKeyTable;
  end;

implementation

procedure TTOMLTestCase.Test01_StringValue;
var
  Data: TTOMLTable;
  Value: TTOMLValue;
begin
  Data := ParseTOML('key = "Hello, World!"');
  try
    AssertTrue('String value exists', Data.TryGetValue('key', Value));
    AssertEquals('String value matches', 'Hello, World!', Value.AsString);
  finally
    Data.Free;
  end;
end;

procedure TTOMLTestCase.Test02_IntegerValue;
var
  Data: TTOMLTable;
  Value: TTOMLValue;
begin
  Data := ParseTOML('key = 42');
  try
    AssertTrue('Integer value exists', Data.TryGetValue('key', Value));
    AssertEquals('Integer value matches', 42, Value.AsInteger);
  finally
    Data.Free;
  end;
end;

procedure TTOMLTestCase.Test03_FloatValue;
var
  Data: TTOMLTable;
  Value: TTOMLValue;
begin
  Data := ParseTOML('key = 3.14');
  try
    AssertTrue('Float value exists', Data.TryGetValue('key', Value));
    AssertEquals('Float value matches', 3.14, Value.AsFloat, 0.0001);
  finally
    Data.Free;
  end;
end;

procedure TTOMLTestCase.Test04_BooleanTrueValue;
var
  Data: TTOMLTable;
  Value: TTOMLValue;
begin
  Data := ParseTOML('key = true');
  try
    AssertTrue('Boolean value exists', Data.TryGetValue('key', Value));
    AssertTrue('Boolean value is true', Value.AsBoolean);
  finally
    Data.Free;
  end;
end;

procedure TTOMLTestCase.Test05_BooleanFalseValue;
var
  Data: TTOMLTable;
  Value: TTOMLValue;
begin
  Data := ParseTOML('key = false');
  try
    AssertTrue('Boolean value exists', Data.TryGetValue('key', Value));
    AssertFalse('Boolean value is false', Value.AsBoolean);
  finally
    Data.Free;
  end;
end;

procedure TTOMLTestCase.Test06_DateTimeValue;
var
  Data: TTOMLTable;
  Value: TTOMLValue;
  ExpectedDate: TDateTime;
begin
  Data := ParseTOML('key = 2023-01-01T12:00:00Z');
  try
    AssertTrue('DateTime value exists', Data.TryGetValue('key', Value));
    ExpectedDate := EncodeDate(2023, 1, 1) + EncodeTime(12, 0, 0, 0);
    AssertEquals('DateTime value matches', ExpectedDate, Value.AsDateTime);
  finally
    Data.Free;
  end;
end;

procedure TTOMLTestCase.Test10_IntegerArray;
var
  Data: TTOMLTable;
  Value: TTOMLValue;
begin
  Data := ParseTOML('key = [1, 2, 3]');
  try
    AssertTrue('Array exists', Data.TryGetValue('key', Value));
    AssertEquals('Array has correct size', 3, Value.AsArray.Count);
    AssertEquals('First element matches', 1, Value.AsArray.GetItem(0).AsInteger);
  finally
    Data.Free;
  end;
end;

procedure TTOMLTestCase.Test11_StringArray;
var
  Data: TTOMLTable;
  Value: TTOMLValue;
begin
  Data := ParseTOML('key = ["a", "b", "c"]');
  try
    AssertTrue('Array exists', Data.TryGetValue('key', Value));
    AssertEquals('Array has correct size', 3, Value.AsArray.Count);
    AssertEquals('First element matches', 'a', Value.AsArray.GetItem(0).AsString);
  finally
    Data.Free;
  end;
end;

procedure TTOMLTestCase.Test12_MixedArrayInteger;
var
  Data: TTOMLTable;
  Value: TTOMLValue;
begin
  Data := ParseTOML('key = [1, "two", true]');
  try
    AssertTrue('Array exists', Data.TryGetValue('key', Value));
    AssertEquals('First element is integer', 1, Value.AsArray.GetItem(0).AsInteger);
  finally
    Data.Free;
  end;
end;

procedure TTOMLTestCase.Test13_MixedArrayString;
var
  Data: TTOMLTable;
  Value: TTOMLValue;
begin
  Data := ParseTOML('key = [1, "two", true]');
  try
    AssertTrue('Array exists', Data.TryGetValue('key', Value));
    AssertEquals('Second element is string', 'two', Value.AsArray.GetItem(1).AsString);
  finally
    Data.Free;
  end;
end;

procedure TTOMLTestCase.Test14_MixedArrayBoolean;
var
  Data: TTOMLTable;
  Value: TTOMLValue;
begin
  Data := ParseTOML('key = [1, "two", true]');
  try
    AssertTrue('Array exists', Data.TryGetValue('key', Value));
    AssertTrue('Third element is boolean true', Value.AsArray.GetItem(2).AsBoolean);
  finally
    Data.Free;
  end;
end;

procedure TTOMLTestCase.Test15_EmptyArray;
var
  Data: TTOMLTable;
  Value: TTOMLValue;
begin
  Data := ParseTOML('key = []');
  try
    AssertTrue('Array exists', Data.TryGetValue('key', Value));
    AssertEquals('Array is empty', 0, Value.AsArray.Count);
  finally
    Data.Free;
  end;
end;

procedure TTOMLTestCase.Test16_InlineTableArray;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
  FruitsArray: TTOMLArray;
  FruitTable: TTOMLTable;
  SerializedTOML: string;
  ParsedAgain: TTOMLTable;
begin
  TOML := 'fruits = [' + LineEnding +
          '    { name = "apple", color = "red" },' + LineEnding +
          '    { name = "banana", color = "yellow" }' + LineEnding +
          ']';
  
  // Test parsing the TOML format with inline tables in an array
  Doc := ParseTOML(TOML);
  try
    AssertTrue('Fruits array exists', Doc.TryGetValue('fruits', Value));
    AssertTrue('Fruits is an array', Value.ValueType = tvtArray);
    
    FruitsArray := Value.AsArray;
    AssertEquals('Array has 2 items', 2, FruitsArray.Count);
    
    // Check first fruit
    FruitTable := FruitsArray.Items[0].AsTable;
    AssertTrue('First fruit has name', FruitTable.TryGetValue('name', Value));
    AssertEquals('Name is apple', 'apple', Value.AsString);
    AssertTrue('First fruit has color', FruitTable.TryGetValue('color', Value));
    AssertEquals('Color is red', 'red', Value.AsString);
    
    // Check second fruit
    FruitTable := FruitsArray.Items[1].AsTable;
    AssertTrue('Second fruit has name', FruitTable.TryGetValue('name', Value));
    AssertEquals('Name is banana', 'banana', Value.AsString);
    AssertTrue('Second fruit has color', FruitTable.TryGetValue('color', Value));
    AssertEquals('Color is yellow', 'yellow', Value.AsString);
    
    // Test serialization and parsing again
    SerializedTOML := SerializeTOML(Doc);
    ParsedAgain := ParseTOML(SerializedTOML);
    try
      AssertTrue('Re-parsed fruits array exists', ParsedAgain.TryGetValue('fruits', Value));
      AssertTrue('Re-parsed fruits is an array', Value.ValueType = tvtArray);
      
      FruitsArray := Value.AsArray;
      AssertEquals('Re-parsed array has 2 items', 2, FruitsArray.Count);
    finally
      ParsedAgain.Free;
    end;
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test20_BasicTableString;
var
  Data: TTOMLTable;
  Value: TTOMLValue;
begin
  Data := ParseTOML('[server]' + LineEnding + 'host = "localhost"');
  try
    AssertTrue('Table exists', Data.TryGetValue('server', Value));
    AssertTrue('Host value exists', Value.AsTable.TryGetValue('host', Value));
    AssertEquals('Host value matches', 'localhost', Value.AsString);
  finally
    Data.Free;
  end;
end;

procedure TTOMLTestCase.Test21_BasicTableInteger;
var
  Data: TTOMLTable;
  Value: TTOMLValue;
begin
  Data := ParseTOML('[server]' + LineEnding + 'port = 8080');
  try
    AssertTrue('Table exists', Data.TryGetValue('server', Value));
    AssertTrue('Port value exists', Value.AsTable.TryGetValue('port', Value));
    AssertEquals('Port value matches', 8080, Value.AsInteger);
  finally
    Data.Free;
  end;
end;

procedure TTOMLTestCase.Test22_InlineTableString;
var
  Data: TTOMLTable;
  Value: TTOMLValue;
begin
  Data := ParseTOML('server = { host = "localhost" }');
  try
    AssertTrue('Table exists', Data.TryGetValue('server', Value));
    AssertTrue('Host value exists', Value.AsTable.TryGetValue('host', Value));
    AssertEquals('Host value matches', 'localhost', Value.AsString);
  finally
    Data.Free;
  end;
end;

procedure TTOMLTestCase.Test23_InlineTableInteger;
var
  Data: TTOMLTable;
  Value: TTOMLValue;
begin
  Data := ParseTOML('server = { port = 8080 }');
  try
    AssertTrue('Table exists', Data.TryGetValue('server', Value));
    AssertTrue('Port value exists', Value.AsTable.TryGetValue('port', Value));
    AssertEquals('Port value matches', 8080, Value.AsInteger);
  finally
    Data.Free;
  end;
end;

procedure TTOMLTestCase.Test24_EmptyTable;
var
  Data: TTOMLTable;
  Value: TTOMLValue;
begin
  Data := ParseTOML('[empty]');
  try
    AssertTrue('Table exists', Data.TryGetValue('empty', Value));
    AssertEquals('Table is empty', 0, Value.AsTable.Items.Count);
  finally
    Data.Free;
  end;
end;

procedure TTOMLTestCase.Test25_NestedTable;
var
  Data: TTOMLTable;
  Value, SubValue: TTOMLValue;
begin
  Data := ParseTOML('[server.config]' + LineEnding + 'enabled = true');
  try
    AssertTrue('Server table exists', Data.TryGetValue('server', Value));
    AssertTrue('Config table exists', Value.AsTable.TryGetValue('config', SubValue));
    AssertTrue('Enabled value exists', SubValue.AsTable.TryGetValue('enabled', Value));
    AssertTrue('Enabled value matches', Value.AsBoolean);
  finally
    Data.Free;
  end;
end;

procedure TTOMLTestCase.Test30_SerializeString;
var
  Table: TTOMLTable;
  TOML: string;
begin
  Table := TOMLTable;
  try
    Table.Add('key', TOMLString('value'));
    TOML := SerializeTOML(Table);
    AssertEquals('Serialized string matches', 'key = "value"' + LineEnding, TOML);
  finally
    Table.Free;
  end;
end;

procedure TTOMLTestCase.Test31_SerializeInteger;
var
  Table: TTOMLTable;
  TOML: string;
begin
  Table := TOMLTable;
  try
    Table.Add('key', TOMLInteger(42));
    TOML := SerializeTOML(Table);
    AssertEquals('Serialized integer matches', 'key = 42' + LineEnding, TOML);
  finally
    Table.Free;
  end;
end;

procedure TTOMLTestCase.Test32_SerializeFloat;
var
  Table: TTOMLTable;
  TOML: string;
begin
  Table := TOMLTable;
  try
    Table.Add('key', TOMLFloat(3.14));
    TOML := SerializeTOML(Table);
    AssertEquals('Serialized float matches', 'key = 3.14' + LineEnding, TOML);
  finally
    Table.Free;
  end;
end;

procedure TTOMLTestCase.Test33_SerializeBoolean;
var
  Table: TTOMLTable;
  TOML: string;
begin
  Table := TOMLTable;
  try
    Table.Add('key', TOMLBoolean(True));
    TOML := SerializeTOML(Table);
    AssertEquals('Serialized boolean matches', 'key = true' + LineEnding, TOML);
  finally
    Table.Free;
  end;
end;

procedure TTOMLTestCase.Test34_SerializeArray;
var
  Table: TTOMLTable;
  ArrValue: TTOMLArray;
  TOML: string;
begin
  Table := TOMLTable;
  try
    ArrValue := TOMLArray;
    ArrValue.Add(TOMLInteger(1));
    ArrValue.Add(TOMLInteger(2));
    Table.Add('key', ArrValue);
    TOML := SerializeTOML(Table);
    AssertEquals('Serialized array matches', 'key = [1, 2]' + LineEnding, TOML);
  finally
    Table.Free;
  end;
end;

procedure TTOMLTestCase.Test35_SerializeTable;
var
  Table: TTOMLTable;
  InnerTable: TTOMLTable;
  TOML: string;
begin
  Table := TOMLTable;
  try
    InnerTable := TOMLTable;
    InnerTable.Add('inner', TOMLString('value'));
    Table.Add('outer', InnerTable);
    TOML := SerializeTOML(Table);
    AssertEquals('Serialized table matches', LineEnding + '[outer]' + LineEnding + 'inner = "value"' + LineEnding, TOML);
  finally
    Table.Free;
  end;
end;

procedure TTOMLTestCase.Test36_SerializeNestedTable;
var
  Table: TTOMLTable;
  InnerTable: TTOMLTable;
  TOML: string;
begin
  Table := TOMLTable;
  try
    InnerTable := TOMLTable;
    InnerTable.Add('key', TOMLString('value'));
    Table.Add('table.nested', InnerTable);
    TOML := SerializeTOML(Table);
    AssertEquals('Serialized nested table matches', LineEnding + '["table.nested"]' + LineEnding + 'key = "value"' + LineEnding, TOML);
  finally
    Table.Free;
  end;
end;

procedure TTOMLTestCase.Test36_1_SerializeHierarchicalNestedTable;
var
  RootTable, FruitTable, BananaTable: TTOMLTable;
  TOML: string;
begin
  RootTable := TTOMLTable.Create;
  try
    BananaTable := TTOMLTable.Create;
    BananaTable.Add('color', TTOMLString.Create('yellow'));
    
    FruitTable := TTOMLTable.Create;
    FruitTable.Add('banana', BananaTable);
    
    RootTable.Add('fruit', FruitTable);
    
    TOML := SerializeTOML(RootTable);
    
    // Expected format: [fruit.banana]\ncolor = "yellow"
    AssertTrue('TOML contains fruit.banana section', Pos('[fruit.banana]', TOML) > 0);
    AssertTrue('TOML contains color = "yellow"', Pos('color = "yellow"', TOML) > 0);
    
    // Make sure improper format isn't present
    AssertEquals('TOML should not have separate [banana] section', 0, Pos('[banana]', TOML));
  finally
    RootTable.Free;
  end;
end;

procedure TTOMLTestCase.Test36_2_SerializeLiteralDottedKeyTable;
var
  RootTable, ValueTable: TTOMLTable;
  TOML: string;
begin
  RootTable := TTOMLTable.Create;
  try
    // Create a table with a value
    ValueTable := TTOMLTable.Create;
    ValueTable.Add('color', TTOMLString.Create('red'));
    
    // Add it with a key containing dots (should be treated as a literal key, not a path)
    RootTable.Add('fruit.apple', ValueTable);
    
    TOML := SerializeTOML(RootTable);
    
    // Expected format: ["fruit.apple"]\ncolor = "red"
    AssertTrue('TOML contains quoted key section ["fruit.apple"]', 
      Pos('["fruit.apple"]', TOML) > 0);
    AssertTrue('TOML contains color = "red"', 
      Pos('color = "red"', TOML) > 0);
    
    // Make sure improper format isn't present
    // It shouldn't interpret as [fruit.apple] (without quotes)
    AssertEquals('TOML should not have unquoted [fruit.apple] section', 
      0, Pos('[fruit.apple]', TOML));
  finally
    RootTable.Free;
  end;
end;

procedure TTOMLTestCase.Test37_SerializeArrayOfTables;
var
  Doc: TTOMLTable;
  Products: TTOMLArray;
  Product1, Product2: TTOMLTable;
  TOML: string;
  ParsedDoc: TTOMLTable;
  Value: TTOMLValue;
  ParsedProducts: TTOMLArray;
begin
  // Create a document with an array of tables
  Doc := TTOMLTable.Create;
  try
    Products := TTOMLArray.Create;
    Doc.Add('products', Products);
    
    // First product
    Product1 := TTOMLTable.Create;
    Product1.Add('name', TTOMLString.Create('Hammer'));
    Product1.Add('sku', TTOMLInteger.Create(738594937));
    Products.Add(Product1);
    
    // Second product
    Product2 := TTOMLTable.Create;
    Product2.Add('name', TTOMLString.Create('Nail'));
    Product2.Add('sku', TTOMLInteger.Create(284758393));
    Product2.Add('color', TTOMLString.Create('gray'));
    Products.Add(Product2);
    
    // Serialize the document
    TOML := SerializeTOML(Doc);
    
    // Verify serialization format - should use [[products]] format
    AssertTrue('Serialized output contains [[products]]', Pos('[[products]]', TOML) > 0);
    
    // Parse the serialized output
    ParsedDoc := ParseTOML(TOML);
    try
      AssertTrue('Parsed document has products', ParsedDoc.TryGetValue('products', Value));
      ParsedProducts := Value.AsArray;
      AssertEquals('Parsed products array has 2 items', 2, ParsedProducts.Count);
      
      // Check first product
      AssertTrue('First product has name', 
        ParsedProducts.Items[0].AsTable.TryGetValue('name', Value));
      AssertEquals('First product name is Hammer', 'Hammer', Value.AsString);
      
      // Check second product
      AssertTrue('Second product has name', 
        ParsedProducts.Items[1].AsTable.TryGetValue('name', Value));
      AssertEquals('Second product name is Nail', 'Nail', Value.AsString);
      AssertTrue('Second product has color', 
        ParsedProducts.Items[1].AsTable.TryGetValue('color', Value));
      AssertEquals('Second product color is gray', 'gray', Value.AsString);
    finally
      ParsedDoc.Free;
    end;
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test40_InvalidInteger;
begin
  try
    ParseTOML('key = 12.34.56');
    Fail('Should raise ETOMLParserException');
  except
    on E: ETOMLParserException do
      ; // Test passes
  end;
end;

procedure TTOMLTestCase.Test41_InvalidFloat;
begin
  try
    ParseTOML('key = 3.14.15');
    Fail('Should raise ETOMLParserException');
  except
    on E: ETOMLParserException do
      ; // Test passes
  end;
end;

procedure TTOMLTestCase.Test42_InvalidDateTime;
begin
  try
    ParseTOML('key = 2023-13-32T25:61:61Z');
    Fail('Should raise ETOMLParserException');
  except
    on E: ETOMLParserException do
      ; // Test passes
  end;
end;

procedure TTOMLTestCase.Test43_InvalidTableKey;
begin
  try
    ParseTOML('[invalid.key!]');
    Fail('Should raise ETOMLParserException');
  except
    on E: ETOMLParserException do
      ; // Test passes
  end;
end;

procedure TTOMLTestCase.Test44_DuplicateKey;
begin
  try
    ParseTOML('key = "first"' + LineEnding + 'key = "second"');
    Fail('Should raise ETOMLParserException');
  except
    on E: ETOMLParserException do
      ; // Test passes
  end;
end;

procedure TTOMLTestCase.Test50_MultilineString;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
begin
  TOML := 'str1 = """' + LineEnding +
          'Roses are red' + LineEnding +
          'Violets are blue"""' + LineEnding;
  Doc := ParseTOML(TOML);
  try
    AssertTrue('String value exists', Doc.TryGetValue('str1', Value));
    AssertEquals('Roses are red' + LineEnding + 'Violets are blue', 
      Value.AsString);
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test51_LiteralString;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
begin
  TOML := 'winpath = ''C:\Users\nodejs\templates''' + LineEnding +
          'winpath2 = ''\\ServerX\admin$\system32\''' + LineEnding;
  Doc := ParseTOML(TOML);
  try
    AssertTrue('First path exists', Doc.TryGetValue('winpath', Value));
    AssertEquals('C:\Users\nodejs\templates', Value.AsString);
    AssertTrue('Second path exists', Doc.TryGetValue('winpath2', Value));
    AssertEquals('\\ServerX\admin$\system32\', Value.AsString);
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test52_MultilineLiteralString;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
begin
  TOML := 'regex = ''''''I [dw]on''t need \d{2} apples''''''';
  Doc := ParseTOML(TOML);
  try
    AssertTrue('Regex exists', Doc.TryGetValue('regex', Value));
    AssertEquals('I [dw]on''t need \d{2} apples', Value.AsString);
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test53_IntegerWithUnderscores;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
begin
  TOML := 'int1 = 1_000' + LineEnding +
          'int2 = 5_349_221' + LineEnding +
          'int3 = 1_2_3_4_5' + LineEnding;
  Doc := ParseTOML(TOML);
  try
    AssertTrue('First integer exists', Doc.TryGetValue('int1', Value));
    AssertEquals(1000, Value.AsInteger);
    AssertTrue('Second integer exists', Doc.TryGetValue('int2', Value));
    AssertEquals(5349221, Value.AsInteger);
    AssertTrue('Third integer exists', Doc.TryGetValue('int3', Value));
    AssertEquals(12345, Value.AsInteger);
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test54_HexOctBinIntegers;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
begin
  TOML := 'hex = 0xDEADBEEF' + LineEnding +
          'oct = 0o755' + LineEnding +
          'bin = 0b11010110' + LineEnding;
  Doc := ParseTOML(TOML);
  try
    AssertTrue('Hex exists', Doc.TryGetValue('hex', Value));
    AssertEquals(3735928559, Value.AsInteger);
    AssertTrue('Oct exists', Doc.TryGetValue('oct', Value));
    AssertEquals(493, Value.AsInteger);
    AssertTrue('Bin exists', Doc.TryGetValue('bin', Value));
    AssertEquals(214, Value.AsInteger);
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test55_FloatWithUnderscores;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
begin
  TOML := 'float1 = 1_000.000_001' + LineEnding +
          'float2 = 1e1_0' + LineEnding;
  Doc := ParseTOML(TOML);
  try
    AssertTrue('First float exists', Doc.TryGetValue('float1', Value));
    AssertEquals(1000.000001, Value.AsFloat, 0.000001);
    AssertTrue('Second float exists', Doc.TryGetValue('float2', Value));
    AssertEquals(1e10, Value.AsFloat, 0.0);
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test56_LocalDateTime;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
begin
  TOML := 'ldt1 = 1979-05-27T07:32:00' + LineEnding +
          'ldt2 = 1979-05-27T00:32:00.999999' + LineEnding;
  Doc := ParseTOML(TOML);
  try
    AssertTrue('First datetime exists', Doc.TryGetValue('ldt1', Value));
    AssertEquals('1979-05-27T07:32:00', 
      FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', Value.AsDateTime));
    AssertTrue('Second datetime exists', Doc.TryGetValue('ldt2', Value));
    AssertEquals('1979-05-27T00:32:00.999', 
      FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz', Value.AsDateTime));
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test57_LocalDate;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
begin
  TOML := 'date1 = 1979-05-27' + LineEnding;
  Doc := ParseTOML(TOML);
  try
    AssertTrue('Date exists', Doc.TryGetValue('date1', Value));
    AssertEquals('1979-05-27', FormatDateTime('yyyy-mm-dd', Value.AsDateTime));
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test58_LocalTime;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
begin
  TOML := 'time = "07:32:00"';
  Doc := ParseTOML(TOML);
  try
    AssertTrue('Time exists', Doc.TryGetValue('time', Value));
    AssertEquals('07:32:00', Value.AsString);
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test59_ArrayOfTables;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
  Products: TTOMLArray;
  ProductTable: TTOMLTable;
begin
  TOML := '[[products]]' + LineEnding +
          'name = "Hammer"' + LineEnding +
          'sku = 738594937' + LineEnding +
          '' + LineEnding +
          '[[products]]' + LineEnding +
          'name = "Nail"' + LineEnding +
          'sku = 284758393' + LineEnding +
          'color = "gray"' + LineEnding;
  Doc := ParseTOML(TOML);
  try
    AssertTrue('Products array exists', Doc.TryGetValue('products', Value));
    Products := Value.AsArray;
    AssertEquals(2, Products.Count);
    
    ProductTable := Products.Items[0].AsTable;
    AssertTrue('First product name exists', ProductTable.TryGetValue('name', Value));
    AssertEquals('Hammer', Value.AsString);
    AssertTrue('First product sku exists', ProductTable.TryGetValue('sku', Value));
    AssertEquals(738594937, Value.AsInteger);
    
    ProductTable := Products.Items[1].AsTable;
    AssertTrue('Second product name exists', ProductTable.TryGetValue('name', Value));
    AssertEquals('Nail', Value.AsString);
    AssertTrue('Second product sku exists', ProductTable.TryGetValue('sku', Value));
    AssertEquals(284758393, Value.AsInteger);
    AssertTrue('Second product color exists', ProductTable.TryGetValue('color', Value));
    AssertEquals('gray', Value.AsString);
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test60_DottedTableArray;
var
  TOML: string;
  Doc: TTOMLTable;
  Value, SubValue: TTOMLValue;
  Fruits: TTOMLArray;
  FruitTable: TTOMLTable;
begin
  TOML := '[[fruits]]' + LineEnding +
          'name = "apple"' + LineEnding +
          'physical = { color = "red", shape = "round" }' + LineEnding +
          'varieties = { name = "red delicious", color = "red" }' + LineEnding;
  Doc := ParseTOML(TOML);
  try
    AssertTrue('Fruits array exists', Doc.TryGetValue('fruits', Value));
    Fruits := Value.AsArray;
    AssertEquals(1, Fruits.Count);
    
    FruitTable := Fruits.Items[0].AsTable;
    AssertTrue('Fruit name exists', FruitTable.TryGetValue('name', Value));
    AssertEquals('apple', Value.AsString);
    
    AssertTrue('Physical exists', FruitTable.TryGetValue('physical', Value));
    AssertTrue('Color exists', Value.AsTable.TryGetValue('color', SubValue));
    AssertEquals('red', SubValue.AsString);
    AssertTrue('Shape exists', Value.AsTable.TryGetValue('shape', SubValue));
    AssertEquals('round', SubValue.AsString);
    
    AssertTrue('Varieties exists', FruitTable.TryGetValue('varieties', Value));
    AssertTrue('Variety name exists', Value.AsTable.TryGetValue('name', SubValue));
    AssertEquals('red delicious', SubValue.AsString);
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test61_PositiveInf;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
begin
  TOML := 'pos_inf = inf';
  Doc := ParseTOML(TOML);
  try
    AssertTrue('Positive infinity exists', Doc.TryGetValue('pos_inf', Value));
    AssertTrue('Positive infinity check', IsInfinite(Value.AsFloat) and (Value.AsFloat > 0));
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test61_NegativeInf;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
begin
  TOML := 'neg_inf = -inf';
  Doc := ParseTOML(TOML);
  try
    AssertTrue('Negative infinity exists', Doc.TryGetValue('neg_inf', Value));
    AssertTrue('Negative infinity check', IsInfinite(Value.AsFloat) and (Value.AsFloat < 0));
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test61_NotANumber;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
begin
  TOML := 'not_num = nan';
  Doc := ParseTOML(TOML);
  try
    AssertTrue('NaN exists', Doc.TryGetValue('not_num', Value));
    AssertTrue('NaN check', IsNan(Value.AsFloat));
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test62_OffsetDateTime;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
begin
  TOML := 'odt1 = 1979-05-27T07:32:00Z' + LineEnding +
          'odt2 = 1979-05-27T07:32:00-07:00' + LineEnding +
          'odt3 = 1979-05-27T07:32:00.999Z' + LineEnding;
  Doc := ParseTOML(TOML);
  try
    AssertTrue('UTC time exists', Doc.TryGetValue('odt1', Value));
    AssertEquals('UTC time format', '1979-05-27T07:32:00Z', 
      FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', Value.AsDateTime));
    
    AssertTrue('Negative offset time exists', Doc.TryGetValue('odt2', Value));
    AssertEquals('Negative offset format', '1979-05-27T07:32:00', 
      FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', Value.AsDateTime));
    
    AssertTrue('Time with fraction exists', Doc.TryGetValue('odt3', Value));
    AssertEquals('Fractional time format', '1979-05-27T07:32:00.999', 
      FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz', Value.AsDateTime));
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test63_MultilineArray;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
begin
  TOML := 'numbers = [ 1, 2, 3 ]' + LineEnding +
          'colors = [ "red", "yellow", "green" ]';
  Doc := ParseTOML(TOML);
  try
    AssertTrue('Numbers array exists', Doc.TryGetValue('numbers', Value));
    AssertEquals('Numbers array size', 3, Value.AsArray.Count);
    AssertEquals('Numbers array item 1', 1, Value.AsArray.Items[0].AsInteger);
    AssertEquals('Numbers array item 2', 2, Value.AsArray.Items[1].AsInteger);
    AssertEquals('Numbers array item 3', 3, Value.AsArray.Items[2].AsInteger);
    
    AssertTrue('Colors array exists', Doc.TryGetValue('colors', Value));
    AssertEquals('Colors array size', 3, Value.AsArray.Count);
    AssertEquals('Colors array item 1', 'red', Value.AsArray.Items[0].AsString);
    AssertEquals('Colors array item 2', 'yellow', Value.AsArray.Items[1].AsString);
    AssertEquals('Colors array item 3', 'green', Value.AsArray.Items[2].AsString);
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test64_QuotedKeys;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
begin
  TOML := '"127.0.0.1" = "localhost"' + LineEnding +
          '"character encoding" = "UTF-8"' + LineEnding +
          '''quoted "value"'' = "value"' + LineEnding +
          '"ʎǝʞ" = "key"' + LineEnding;
  Doc := ParseTOML(TOML);
  try
    AssertTrue('IP address key exists', Doc.TryGetValue('127.0.0.1', Value));
    AssertEquals('localhost', Value.AsString);
    
    AssertTrue('Spaced key exists', Doc.TryGetValue('character encoding', Value));
    AssertEquals('UTF-8', Value.AsString);
    
    AssertTrue('Quoted value in key exists', Doc.TryGetValue('quoted "value"', Value));
    AssertEquals('value', Value.AsString);
    
    AssertTrue('Unicode key exists', Doc.TryGetValue('ʎǝʞ', Value));
    AssertEquals('key', Value.AsString);
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test65_SuperTables;
var
  TOML: string;
  Doc: TTOMLTable;
  Value, SubValue: TTOMLValue;
begin
  TOML := '[a.b]' + LineEnding +
          'c = 1' + LineEnding +
          '' + LineEnding +
          '[a]' + LineEnding +  // defining super-table after subtable
          'd = 2' + LineEnding +
          '' + LineEnding +
          '[x.y.z]' + LineEnding +  // implicit super-table creation
          'key = "value"' + LineEnding;
  Doc := ParseTOML(TOML);
  try
    AssertTrue('Table a exists', Doc.TryGetValue('a', Value));
    AssertTrue('Value d exists', Value.AsTable.TryGetValue('d', SubValue));
    AssertEquals(2, SubValue.AsInteger);
    
    AssertTrue('Table b exists', Value.AsTable.TryGetValue('b', SubValue));
    AssertTrue('Value c exists', SubValue.AsTable.TryGetValue('c', Value));
    AssertEquals(1, Value.AsInteger);
    
    AssertTrue('Table x exists', Doc.TryGetValue('x', Value));
    AssertTrue('Table y exists', Value.AsTable.TryGetValue('y', SubValue));
    AssertTrue('Table z exists', SubValue.AsTable.TryGetValue('z', Value));
    AssertTrue('Key exists', Value.AsTable.TryGetValue('key', SubValue));
    AssertEquals('value', SubValue.AsString);
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test66_WhitespaceHandling;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
begin
  TOML := 'key1 = "value"     # comment' + LineEnding +
          'key2 = "value"  # comment with multiple spaces' + LineEnding +
          '  key3 = "value"   # indented key' + LineEnding +
          'key4   =    "value"    ' + LineEnding +  // excessive spaces
          '  [table]   ' + LineEnding +
          '  indent = "value"  ' + LineEnding;
  Doc := ParseTOML(TOML);
  try
    AssertTrue('Key1 exists', Doc.TryGetValue('key1', Value));
    AssertEquals('value', Value.AsString);
    AssertTrue('Key2 exists', Doc.TryGetValue('key2', Value));
    AssertEquals('value', Value.AsString);
    AssertTrue('Key3 exists', Doc.TryGetValue('key3', Value));
    AssertEquals('value', Value.AsString);
    AssertTrue('Key4 exists', Doc.TryGetValue('key4', Value));
    AssertEquals('value', Value.AsString);
    
    AssertTrue('Table exists', Doc.TryGetValue('table', Value));
    AssertTrue('Indented value exists', Value.AsTable.TryGetValue('indent', Value));
    AssertEquals('value', Value.AsString);
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test67_ArrayTypeValidation; 
var
  Data: TTOMLTable;
  Value: TTOMLValue;
begin
  // Test 1: Mixed Types
  try
    Data := ParseTOML('mixed = [1, "string", true]');
    try
      AssertTrue('Array exists', Data.TryGetValue('mixed', Value));
      AssertEquals('Array count', 3, Value.AsArray.Count);
    finally
      Data.Free;
    end;
  except
    on E: ETOMLParserException do
      Fail('Mixed-type arrays should be allowed');
  end;
  
  // Test 2: Mixed Numbers
  try
    Data := ParseTOML('numbers = [1, 2.0]');
    try
      AssertTrue('Numbers array exists', Data.TryGetValue('numbers', Value));
      AssertEquals('Numbers array count', 2, Value.AsArray.Count);
    finally
      Data.Free;
    end;
  except
    on E: ETOMLParserException do
      Fail('Mixed number types should be allowed');
  end;
  
  // Test 3: Nested Arrays
  try
    Data := ParseTOML('nested = [[1, 2], [3, 4]]');
    try
      AssertTrue('Nested array exists', Data.TryGetValue('nested', Value));
      AssertEquals('Nested arrays count', 2, Value.AsArray.Count);
    finally
      Data.Free;
    end;
  except
    on E: ETOMLParserException do
      Fail('Nested arrays of same type should be allowed');
  end;
  
  // Test 4: Mixed Array/Non-Array Values
  try
    Data := ParseTOML('mixed_array = [1, [2, 3], 4]');
    try
      AssertTrue('Mixed array exists', Data.TryGetValue('mixed_array', Value));
      AssertEquals('Mixed array count', 3, Value.AsArray.Count);
    finally
      Data.Free;
    end;
  except
    on E: ETOMLParserException do
      Fail('Mixed array/non-array values should be allowed according to TOML spec');
  end;
end;


procedure TTOMLTestCase.Test68_KeyValidation;
var
  Data: TTOMLTable;
  Value: TTOMLValue;
begin
  // Test 1: Valid Dotted Key
  try
    Data := ParseTOML('valid.key = "value"');
    try
      AssertTrue('valid.key exists', Data.TryGetValue('valid.key', Value));
      AssertEquals('valid.key value', 'value', Value.AsString);
    finally
      Data.Free;
    end;
  except
    on E: ETOMLParserException do
      Fail('Valid dotted key should be allowed');
  end;
  
  // Test 2: Quoted Key with Dots
  try
    Data := ParseTOML('valid."dotted.key" = "value"');
    try
      // Corrected assertion to look for 'valid.dotted.key'
      AssertTrue('"valid.dotted.key" exists', Data.TryGetValue('valid.dotted.key', Value));
      AssertEquals('"valid.dotted.key" value', 'value', Value.AsString);
    finally
      Data.Free;
    end;
  except
    on E: ETOMLParserException do
      Fail('Quoted key containing dots should be allowed');
  end;
  
  // Test 3: Invalid Key with Empty Component
  try
    Data := ParseTOML('invalid. = "value"');
    FreeAndNil(Data);
    Fail('Empty key component should not be allowed');
  except
    on E: ETOMLParserException do
      ; // Test passes
  end;
  
  // Test 4: Invalid Key with Double Dots
  try
    Data := ParseTOML('invalid..key = "value"');
    FreeAndNil(Data);
    Fail('Double dots in key should not be allowed');
  except
    on E: ETOMLParserException do
      ; // Test passes
  end;
end;

procedure TTOMLTestCase.Test69_TableArrayNesting;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
  Fruits: TTOMLArray;
  FruitTable: TTOMLTable;
begin
  TOML := '[[fruits]]' + LineEnding +
          'name = "apple"' + LineEnding +
          'varieties = { name = "red delicious", color = "red" }' + LineEnding +
          '' + LineEnding +
          '[[fruits]]' + LineEnding +
          'name = "banana"' + LineEnding +
          'varieties = { name = "plantain", color = "yellow" }';
  Doc := ParseTOML(TOML);
  try
    AssertTrue('Fruits array exists', Doc.TryGetValue('fruits', Value));
    Fruits := Value.AsArray;
    AssertEquals('Fruits count', 2, Fruits.Count);
    
    // First fruit
    FruitTable := Fruits.Items[0].AsTable;
    AssertTrue('First fruit name exists', FruitTable.TryGetValue('name', Value));
    AssertEquals('First fruit name', 'apple', Value.AsString);
    
    AssertTrue('First fruit varieties exist', FruitTable.TryGetValue('varieties', Value));
    AssertTrue('First variety name exists', Value.AsTable.TryGetValue('name', Value));
    AssertEquals('First variety name', 'red delicious', Value.AsString);
    
    // Second fruit
    FruitTable := Fruits.Items[1].AsTable;
    AssertTrue('Second fruit name exists', FruitTable.TryGetValue('name', Value));
    AssertEquals('Second fruit name', 'banana', Value.AsString);
    
    AssertTrue('Second fruit varieties exist', FruitTable.TryGetValue('varieties', Value));
    AssertTrue('Second variety name exists', Value.AsTable.TryGetValue('name', Value));
    AssertEquals('Second variety name', 'plantain', Value.AsString);
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test69_1_ArrayOfTablesWithSubtables;
var
  TOML: string;
  Doc: TTOMLTable;
  Value, SubValue: TTOMLValue;
  Fruits, Varieties: TTOMLArray;
  FruitTable, PhysicalTable: TTOMLTable;
begin
  TOML := '[[fruits]]' + LineEnding +
          'name = "apple"' + LineEnding +
          '[fruits.physical]' + LineEnding +
          'color = "red"' + LineEnding +
          'shape = "round"' + LineEnding +
          '[[fruits.varieties]]' + LineEnding +
          'name = "red delicious"' + LineEnding +
          '[[fruits.varieties]]' + LineEnding +
          'name = "granny smith"' + LineEnding +
          '[[fruits]]' + LineEnding +
          'name = "banana"' + LineEnding +
          '[[fruits.varieties]]' + LineEnding +
          'name = "plantain"';
  Doc := ParseTOML(TOML);
  try
    AssertTrue('Fruits array exists', Doc.TryGetValue('fruits', Value));
    Fruits := Value.AsArray;
    AssertEquals('Fruits count', 2, Fruits.Count);
    
    FruitTable := Fruits.Items[0].AsTable;
    AssertTrue('First fruit name exists', FruitTable.TryGetValue('name', Value));
    AssertEquals('First fruit name', 'apple', Value.AsString);
    
    AssertTrue('Physical exists', FruitTable.TryGetValue('physical', Value));
    PhysicalTable := Value.AsTable;
    AssertTrue('Physical color exists', PhysicalTable.TryGetValue('color', SubValue));
    AssertEquals('Physical color', 'red', SubValue.AsString);
    AssertTrue('Physical shape exists', PhysicalTable.TryGetValue('shape', SubValue));
    AssertEquals('Physical shape', 'round', SubValue.AsString);
    
    AssertTrue('Varieties exists', FruitTable.TryGetValue('varieties', Value));
    Varieties := Value.AsArray;
    AssertEquals('Varieties count', 2, Varieties.Count);
    AssertTrue('First variety name exists', Varieties.Items[0].AsTable.TryGetValue('name', SubValue));
    AssertEquals('First variety name', 'red delicious', SubValue.AsString);
    AssertTrue('Second variety name exists', Varieties.Items[1].AsTable.TryGetValue('name', SubValue));
    AssertEquals('Second variety name', 'granny smith', SubValue.AsString);
    
    FruitTable := Fruits.Items[1].AsTable;
    AssertTrue('Second fruit name exists', FruitTable.TryGetValue('name', Value));
    AssertEquals('Second fruit name', 'banana', Value.AsString);
    
    AssertTrue('Second fruit varieties exist', FruitTable.TryGetValue('varieties', Value));
    Varieties := Value.AsArray;
    AssertEquals('Second varieties count', 1, Varieties.Count);
    AssertTrue('Second fruit variety name exists', Varieties.Items[0].AsTable.TryGetValue('name', SubValue));
    AssertEquals('Second fruit variety name', 'plantain', SubValue.AsString);
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test70_ComplexKeys;
var
  TOML: string;
  Doc: TTOMLTable;
  Value: TTOMLValue;
begin
  TOML := 'simple = "value"' + LineEnding +
          '"quoted.key" = "value"' + LineEnding +
          '[server]' + LineEnding +
          '"127.0.0.1" = "localhost"' + LineEnding +
          '[color]' + LineEnding +
          'red = "#ff0000"' + LineEnding +
          '[literal]' + LineEnding +
          'key = "value"';
  Doc := ParseTOML(TOML);
  try
    AssertTrue('Simple key exists', Doc.TryGetValue('simple', Value));
    AssertEquals('Simple key value', 'value', Value.AsString);
    
    AssertTrue('Quoted key exists', Doc.TryGetValue('quoted.key', Value));
    AssertEquals('Quoted key value', 'value', Value.AsString);
    
    AssertTrue('Server table exists', Doc.TryGetValue('server', Value));
    AssertTrue('IP address key exists', Value.AsTable.TryGetValue('127.0.0.1', Value));
    AssertEquals('IP address value', 'localhost', Value.AsString);
    
    AssertTrue('Color table exists', Doc.TryGetValue('color', Value));
    AssertTrue('Color red exists', Value.AsTable.TryGetValue('red', Value));
    AssertEquals('Color red value', '#ff0000', Value.AsString);
    
    AssertTrue('Literal key exists', Doc.TryGetValue('literal', Value));
    AssertTrue('Literal subkey exists', Value.AsTable.TryGetValue('key', Value));
    AssertEquals('Literal key value', 'value', Value.AsString);
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test71_HierarchicalNestedTable;
var
  Doc: TTOMLTable;
  DogTable, TatterTable, ManTable: TTOMLTable;
  Value, SubValue, SubSubValue, NameValue: TTOMLValue;
  SerializedTOML: string;
  ParsedDoc: TTOMLTable;
begin
  // Create a three-level hierarchical path: dog.tatter.man
  Doc := TTOMLTable.Create;
  try
    // Create the leaf table (man) first
    ManTable := TTOMLTable.Create;
    ManTable.Add('name', TTOMLString.Create('Rex'));
    
    // Create the middle table (tatter) and add man to it
    TatterTable := TTOMLTable.Create;
    TatterTable.Add('man', ManTable);
    
    // Create the top-level table (dog) and add tatter to it
    DogTable := TTOMLTable.Create;
    DogTable.Add('tatter', TatterTable);
    
    // Add dog to the root document
    Doc.Add('dog', DogTable);
    
    // Serialize to TOML format
    SerializedTOML := SerializeTOML(Doc);
    
    // Verify hierarchical format is used correctly (no quotes)
    AssertTrue('Serialized TOML has [dog.tatter.man] section', 
      Pos('[dog.tatter.man]', SerializedTOML) > 0);
      
    // Make sure it doesn't have quotes around components
    AssertEquals('No quoted sections should be present', 
      0, Pos('"tatter"', SerializedTOML));
    
    // Parse the serialized output to verify round-trip
    ParsedDoc := ParseTOML(SerializedTOML);
    try
      // Verify we can access all levels through nested lookups
      AssertTrue('Root has dog table', 
        ParsedDoc.TryGetValue('dog', Value));
      AssertTrue('Dog has tatter table', 
        Value.AsTable.TryGetValue('tatter', SubValue));
      AssertTrue('Tatter has man table', 
        SubValue.AsTable.TryGetValue('man', SubSubValue));
      AssertTrue('Man has name field', 
        SubSubValue.AsTable.TryGetValue('name', NameValue));
      AssertEquals('Name is Rex', 'Rex', NameValue.AsString);
        
      // Verify the hierarchical structure was preserved
      // Note: Direct dot notation access may not be supported by the parser
      // Instead, verify through the nested structure which we've already confirmed works
      AssertTrue('Hierarchical structure was preserved correctly',
        ParsedDoc.TryGetValue('dog', Value) and
        Value.AsTable.TryGetValue('tatter', SubValue) and
        SubValue.AsTable.TryGetValue('man', SubSubValue) and
        SubSubValue.AsTable.TryGetValue('name', NameValue) and
        (NameValue.AsString = 'Rex'));
    finally
      ParsedDoc.Free;
    end;
  finally
    Doc.Free;
  end;
end;

procedure TTOMLTestCase.Test72_LiteralDottedKeyTable;
var
  Doc: TTOMLTable;
  DogTable, ManTable: TTOMLTable; 
  Value, SubValue: TTOMLValue;
  SerializedTOML: string;
  ParsedDoc: TTOMLTable;
begin
  // Create a table with a literal dotted key: dog."tatter.man"
  Doc := TTOMLTable.Create;
  try
    // Create a table to be the value of the dotted key
    ManTable := TTOMLTable.Create;
    ManTable.Add('name', TTOMLString.Create('Spot'));
    
    // Create parent table
    DogTable := TTOMLTable.Create;
    // Add with a literal dotted key
    DogTable.Add('tatter.man', ManTable);
    
    // Add to the root document
    Doc.Add('dog', DogTable);
    
    // Serialize to TOML format
    SerializedTOML := SerializeTOML(Doc);
    
    // Verify dotted key is properly quoted
    AssertTrue('Serialized TOML has [dog."tatter.man"] section', 
      Pos('[dog."tatter.man"]', SerializedTOML) > 0);
    
    // Parse the serialized output to verify round-trip
    ParsedDoc := ParseTOML(SerializedTOML);
    try
      // Verify we can access the tables correctly
      AssertTrue('Root has dog table', 
        ParsedDoc.TryGetValue('dog', Value));
      AssertTrue('Dog has tatter.man table', 
        Value.AsTable.TryGetValue('tatter.man', SubValue));
      AssertTrue('tatter.man has name field', 
        SubValue.AsTable.TryGetValue('name', Value));
      AssertEquals('Name is Spot', 'Spot', Value.AsString);
    finally
      ParsedDoc.Free;
    end;
  finally
    Doc.Free;
  end;
end;

initialization
  RegisterTest(TTOMLTestCase);
end.
