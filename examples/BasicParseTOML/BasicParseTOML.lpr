program BasicParseTOML;

{$mode objfpc}{$H+}{$J-}

{ Reads config.toml and prints a few values.

  Shows:
  - Typed lookups by path, with defaults for missing keys
  - Walking a table in document order
  - Freeing only the root table }

uses
  TOML;

var
  Config, Project: TTOMLTable;
  Pair: TTOMLKeyValuePair;
begin
  Config := ParseTOMLFromFile('config.toml');
  try
    // Path lookups: the default is returned when the key is missing.
    WriteLn('Revision: ', Config.GetString(['revision']));
    WriteLn('Project:  ', Config.GetString(['project', 'name']));
    WriteLn('License:  ', Config.GetString(['project', 'license'], '(not set)'));

    // GetTable returns nil when the table does not exist.
    Project := Config.GetTable(['project']);
    if Project <> nil then
    begin
      WriteLn;
      WriteLn('[project] has ', Project.Count, ' keys:');
      for Pair in Project do
        WriteLn('  ', Pair.Key, ' = ', Pair.Value.AsString);
    end;
  finally
    Config.Free;  // frees every nested table and value
  end;
end.
