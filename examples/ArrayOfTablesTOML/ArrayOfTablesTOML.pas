program ArrayOfTablesTOML;

{$mode objfpc}{$H+}{$J-}

uses
  SysUtils, Classes, TOML, TOML.Types;

procedure DumpTOMLTableContents(const Table: TTOMLTable; const Indent: string = '');
var
  Pair: TTOMLKeyValuePair;
  i: Integer;
  ItemTable: TTOMLTable;
begin
  for Pair in Table do  // visits keys in document order
  begin
    Write(Indent, Pair.Key, ' = ');
    
    case Pair.Value.ValueType of
      tvtString:
        WriteLn('"', Pair.Value.AsString, '"');
        
      tvtInteger:
        WriteLn(Pair.Value.AsInteger);
        
      tvtFloat:
        WriteLn(Pair.Value.AsFloat:0:2);
        
      tvtBoolean:
        if Pair.Value.AsBoolean then
          WriteLn('true')
        else
          WriteLn('false');
          
      tvtDateTime:
        WriteLn(FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', Pair.Value.AsDateTime));
        
      tvtArray:
        begin
          WriteLn('(array with ', Pair.Value.AsArray.Count, ' items)');
          for i := 0 to Pair.Value.AsArray.Count - 1 do
          begin
            Write(Indent, '  [', i, '] ');
            if Pair.Value.AsArray.Items[i].ValueType = tvtTable then
            begin
              WriteLn('(table)');
              DumpTOMLTableContents(Pair.Value.AsArray.Items[i].AsTable, Indent + '    ');
            end
            else
              WriteLn(Pair.Value.AsArray.Items[i].AsString);
          end;
        end;
        
      tvtTable, tvtInlineTable:
        begin
          WriteLn('(table)');
          DumpTOMLTableContents(Pair.Value.AsTable, Indent + '  ');
        end;
    end;
  end;
end;

procedure TestArrayOfTablesSerialization;
var
  Doc: TTOMLTable;
  Products: TTOMLArray;
  Product1, Product2: TTOMLTable;
  TOML: string;
  DocFromFile: TTOMLTable;
  TomlFilename: string;
begin
  WriteLn('===== Testing Serialization of Arrays of Tables =====');
  WriteLn;
  
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
    
    // Serialize the document to string
    TOML := SerializeTOML(Doc);
    
    WriteLn('Serialized TOML (should use [[products]] format):');
    WriteLn('----------------------------------------------');
    WriteLn(TOML);
    WriteLn('----------------------------------------------');
    WriteLn;
    
    // Save to a file
    TomlFilename := 'products.toml';
    if SerializeTOMLToFile(Doc, TomlFilename) then
      WriteLn('Successfully wrote to file: ', TomlFilename)
    else
      WriteLn('Failed to write to file: ', TomlFilename);
    WriteLn;
    
    // Read from the file
    DocFromFile := ParseTOMLFromFile(TomlFilename);
    try
      WriteLn('Content read from file:');
      WriteLn;
      DumpTOMLTableContents(DocFromFile);
    finally
      DocFromFile.Free;
    end;
    WriteLn;
    
    // Verify by parsing the serialized output
    WriteLn('Re-parsing the serialized string:');
    WriteLn;
    
    Doc.Free; // Free the original document
    Doc := ParseTOML(TOML);
    DumpTOMLTableContents(Doc);
  finally
    Doc.Free;
  end;
  
  WriteLn;
end;

procedure TestParsingArrayWithInlineTables;
var
  TOML: string;
  Doc, DocFromFile: TTOMLTable;
  TomlFilename: string;
begin
  WriteLn('===== Testing Parsing of Array with Inline Tables =====');
  WriteLn;
  
  // TOML string with an array of inline tables including newlines
  TOML := 'fruits = [' + LineEnding +
          '    { name = "apple", color = "red" },' + LineEnding +
          '    { name = "banana", color = "yellow" }' + LineEnding +
          ']';
          
  WriteLn('TOML input with array of inline tables and newlines:');
  WriteLn('--------------------------------------------------');
  WriteLn(TOML);
  WriteLn('--------------------------------------------------');
  WriteLn;
  
  // Parse the TOML string
  Doc := ParseTOML(TOML);
  try
    WriteLn('Successfully parsed from string. Contents:');
    WriteLn;
    DumpTOMLTableContents(Doc);
    
    // Save to a file
    TomlFilename := 'fruits.toml';
    if SerializeTOMLToFile(Doc, TomlFilename) then
      WriteLn('Successfully wrote to file: ', TomlFilename)
    else
      WriteLn('Failed to write to file: ', TomlFilename);
    WriteLn;
    
    // Read from the file
    DocFromFile := ParseTOMLFromFile(TomlFilename);
    try
      WriteLn('Content read from file:');
      WriteLn;
      DumpTOMLTableContents(DocFromFile);
    finally
      DocFromFile.Free;
    end;
  finally
    Doc.Free;
  end;
  
  WriteLn;
end;

begin
  try
    TestArrayOfTablesSerialization;
    TestParsingArrayWithInlineTables;
    
    WriteLn('Both tests completed successfully!');
    WriteLn('Press Enter to exit...');
    ReadLn;
  except
    on E: Exception do
    begin
      WriteLn('Error: ', E.Message);
      ReadLn;
    end;
  end;
end. 
