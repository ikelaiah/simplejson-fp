program SystemJSONExample;

{$mode objfpc}{$H+}

(* System.JSON Compatibility Example
   
   This example demonstrates how to use the Delphi System.JSON-compatible API
   in Free Pascal/Lazarus. Code written for Delphi's System.JSON can be 
   easily ported using this unit with minimal changes.
   
   To compile:
     fpc -Mobjfpc SystemJSONExample.lpr
   
   Or open in Lazarus IDE and build. *)

uses
  SysUtils, System.JSON;

procedure DemoParseJSON;
var
  Obj: TJSONObject;
  JSONStr: string;
begin
  WriteLn('=== Parsing JSON ===');
  WriteLn;
  
  JSONStr := '{"name": "John Doe", "age": 30, "active": true, "score": 95.5}';
  WriteLn('Input: ', JSONStr);
  WriteLn;
  
  // Parse JSON string (same as Delphi)
  Obj := TJSONObject.ParseJSONValue(JSONStr) as TJSONObject;
  try
    // Access values with type-safe methods
    WriteLn('Name: ', Obj.GetValueString('name'));
    WriteLn('Age: ', Obj.GetValueInt('age'));
    WriteLn('Active: ', Obj.GetValueBool('active'));
    WriteLn('Score: ', Obj.GetValueDouble('score'):0:1);
    
    // With default values
    WriteLn('Missing (default): ', Obj.GetValueString('missing', 'N/A'));
  finally
    Obj.Free;
  end;
  
  WriteLn;
end;

procedure DemoCreateJSON;
var
  Obj: TJSONObject;
begin
  WriteLn('=== Creating JSON ===');
  WriteLn;
  
  // Create JSON object with fluent interface (same as Delphi)
  Obj := TJSONObject.Create;
  try
    Obj.AddPair('name', 'Jane Smith')
       .AddPair('email', 'jane@example.com')
       .AddPair('age', 25)
       .AddPair('verified', True)
       .AddPair('balance', 1234.56);
    
    WriteLn('Compact: ', Obj.ToJSON);
    WriteLn;
    WriteLn('Formatted:');
    WriteLn(Obj.Format(2));
  finally
    Obj.Free;
  end;
  
  WriteLn;
end;

procedure DemoJSONArray;
var
  Arr: TJSONArray;
  Obj: TJSONObject;
  I: Integer;
begin
  WriteLn('=== JSON Arrays ===');
  WriteLn;
  
  // Create array with mixed types
  Arr := TJSONArray.Create;
  try
    Arr.Add('string')
       .Add(42)
       .Add(3.14)
       .Add(True)
       .Add(TJSONNull.Create);
    
    // Add a nested object
    Obj := TJSONObject.Create;
    Obj.AddPair('nested', 'value');
    Arr.Add(Obj);
    
    WriteLn('Array: ', Arr.ToJSON);
    WriteLn('Count: ', Arr.Count);
    WriteLn;
    
    // Access elements
    for I := 0 to Arr.Count - 1 do
      WriteLn('  [', I, ']: ', Arr[I].ToJSON);
  finally
    Arr.Free;
  end;
  
  WriteLn;
end;

procedure DemoNestedJSON;
var
  Root, User, Address: TJSONObject;
  Emails: TJSONArray;
begin
  WriteLn('=== Nested JSON ===');
  WriteLn;
  
  // Build complex nested structure
  Root := TJSONObject.Create;
  try
    User := TJSONObject.Create;
    User.AddPair('name', 'John')
        .AddPair('age', 30);
    
    Address := TJSONObject.Create;
    Address.AddPair('street', '123 Main St')
           .AddPair('city', 'New York')
           .AddPair('zip', '10001');
    User.AddPair('address', Address);
    
    Emails := TJSONArray.Create;
    Emails.Add('john@work.com')
          .Add('john@personal.com');
    User.AddPair('emails', Emails);
    
    Root.AddPair('user', User);
    Root.AddPair('timestamp', '2024-01-15T10:30:00Z');
    
    WriteLn(Root.Format(2));
  finally
    Root.Free;
  end;
  
  WriteLn;
end;

procedure DemoJSONPairs;
var
  Obj: TJSONObject;
  Pair: TJSONPair;
  I: Integer;
begin
  WriteLn('=== Working with TJSONPair ===');
  WriteLn;
  
  Obj := TJSONObject.ParseJSONValue('{"a": 1, "b": 2, "c": 3}') as TJSONObject;
  try
    // Get pair by name
    Pair := Obj.Get('b');
    if Pair <> nil then
      WriteLn('Found pair "b": ', Pair.JsonValue.ToJSON);
    
    WriteLn;
    WriteLn('All pairs:');
    
    // Iterate by index
    for I := 0 to Obj.Count - 1 do
    begin
      Pair := Obj.Pairs[I];
      WriteLn('  ', Pair.JsonString.Value, ' = ', Pair.JsonValue.ToJSON);
    end;
    
    WriteLn;
    WriteLn('Using for-in enumeration:');
    
    // Using for-in (if supported)
    for Pair in Obj do
      WriteLn('  Key: ', Pair.JsonString.Value);
  finally
    Obj.Free;
  end;
  
  WriteLn;
end;

procedure DemoCloning;
var
  Original, Clone: TJSONObject;
begin
  WriteLn('=== Cloning JSON ===');
  WriteLn;
  
  Original := TJSONObject.Create;
  try
    Original.AddPair('name', 'Original')
            .AddPair('value', 100);
    
    WriteLn('Original: ', Original.ToJSON);
    
    // Clone creates independent copy
    Clone := Original.Clone as TJSONObject;
    try
      Clone.AddPair('extra', 'added to clone');
      
      WriteLn('After modifying clone:');
      WriteLn('  Original: ', Original.ToJSON);
      WriteLn('  Clone: ', Clone.ToJSON);
    finally
      Clone.Free;
    end;
  finally
    Original.Free;
  end;
  
  WriteLn;
end;

procedure DemoErrorHandling;
var
  Value: TJSONValue;
begin
  WriteLn('=== Error Handling ===');
  WriteLn;
  
  // With RaiseException = True (default)
  try
    Value := TJSONValue.ParseJSONValue('invalid json', True, True);
    Value.Free;
  except
    on E: EJSONParseException do
      WriteLn('Parse error (expected): ', E.Message);
  end;
  
  // With RaiseException = False
  Value := TJSONValue.ParseJSONValue('invalid json', True, False);
  if Value = nil then
    WriteLn('Parse returned nil (no exception)')
  else
    Value.Free;
  
  WriteLn;
end;

procedure DemoDelphiPorting;
var
  Obj: TJSONObject;
  Name: string;
  Age: Integer;
  Active: Boolean;
begin
  WriteLn('=== Delphi Code Porting Example ===');
  WriteLn;
  WriteLn('This code looks almost identical to Delphi''s System.JSON usage:');
  WriteLn;
  
  // This is how you''d write it in Delphi (and nearly the same here)
  Obj := TJSONObject.ParseJSONValue('{"name":"Test User","age":42,"active":true}') as TJSONObject;
  try
    // In Delphi: Name := Obj.GetValue<string>('name');
    // In FPC:   Name := Obj.GetValueString('name');
    Name := Obj.GetValueString('name');
    Age := Obj.GetValueInt('age');
    Active := Obj.GetValueBool('active');
    
    WriteLn('Name: ', Name);
    WriteLn('Age: ', Age);
    WriteLn('Active: ', Active);
  finally
    Obj.Free;
  end;
  
  WriteLn;
  WriteLn('The only difference from Delphi is:');
  WriteLn('  GetValue<string>  -> GetValueString');
  WriteLn('  GetValue<Integer> -> GetValueInt');
  WriteLn('  GetValue<Boolean> -> GetValueBool');
  WriteLn;
end;

begin
  WriteLn('SimpleJSON-FP: System.JSON Compatibility Demo');
  WriteLn('==============================================');
  WriteLn;
  
  DemoParseJSON;
  DemoCreateJSON;
  DemoJSONArray;
  DemoNestedJSON;
  DemoJSONPairs;
  DemoCloning;
  DemoErrorHandling;
  DemoDelphiPorting;
  
  WriteLn('Demo complete!');
  WriteLn;
  WriteLn('Press Enter to exit...');
  ReadLn;
end.
