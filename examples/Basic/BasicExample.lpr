program BasicExample;

{$mode objfpc}{$H+}{$J-}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,
  SimpleJSON;

var
  Json: IJSONValue;
  Person: IJSONObject;
begin
  // Parse JSON with ease
  Json := TJSON.Parse('{"name":"Pascal","age":50}');
  WriteLn('Name: ', Json.AsObject['name'].AsString);

  // Build JSON programmatically
  Person := TJSON.Obj;
  Person.Add('name', 'Alice');
  Person.Add('age', 30);
  Person.Add('isActive', True);

  // No need to worry about freeing - automatic memory management!
  WriteLn(Person.ToString(True));  // Pretty-printed JSON

  // Pause console
  WriteLn('Press enter key to quit ...');
  ReadLn;
end.

