program json_example;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils,
  SimpleJSON;

procedure DemonstrateCreation;
var
  Person: IJSONObject;
  Address: IJSONObject;
  Hobbies: IJSONArray;
  JSON: string;
begin
  WriteLn('Creating a JSON object...');
  
  // Create a person object
  Person := TJSON.Obj;
  Person.Add('name', 'John Smith');
  Person.Add('age', 30);
  Person.Add('isActive', True);
  
  // Create and add an address object
  Address := TJSON.Obj;
  Address.Add('street', '123 Main St');
  Address.Add('city', 'Springfield');
  Address.Add('zipCode', '12345');
  Person.Add('address', Address);
  
  // Create and add a hobbies array
  Hobbies := TJSON.Arr;
  Hobbies.Add('reading');
  Hobbies.Add('cycling');
  Hobbies.Add('swimming');
  Person.Add('hobbies', Hobbies);
  
  // Convert to JSON string with pretty printing
  JSON := Person.ToString(True);
  WriteLn(JSON);
  WriteLn;
end;

procedure DemonstrateParsing;
var
  JSON: string;
  Value: IJSONValue;
  Person: IJSONObject;
begin
  WriteLn('Parsing a JSON string...');
  
  JSON :=
    '{'#10 +
    '  "name": "Jane Doe",'#10 +
    '  "age": 25,'#10 +
    '  "contacts": {'#10 +
    '    "email": "jane@example.com",'#10 +
    '    "phone": "+1-555-123-4567"'#10 +
    '  },'#10 +
    '  "skills": ["Python", "Pascal", "SQL"]'#10 +
    '}';
    
  Value := TJSON.Parse(JSON);
  Person := Value.AsObject;
  
  WriteLn('Name: ', Person['name'].AsString);
  WriteLn('Age: ', Person['age'].AsInteger);
  WriteLn('Email: ', Person['contacts'].AsObject['email'].AsString);
  WriteLn('First Skill: ', Person['skills'].AsArray[0].AsString);
  WriteLn;
end;

procedure DemonstrateModification;
var
  JSON: string;
  Value: IJSONValue;
  Config: IJSONObject;
begin
  WriteLn('Modifying JSON...');
  
  // Parse initial JSON
  JSON := '{"settings":{"theme":"light","fontSize":12}}';
  WriteLn('Original: ', JSON);
  
  // Parse and modify
  Value := TJSON.Parse(JSON);
  Config := Value.AsObject;
  
  Config['settings'].AsObject['theme'] := TJSON.Str('dark');
  Config['settings'].AsObject['fontSize'] := TJSON.Int(14);
  Config['settings'].AsObject.Add('showToolbar', True);
  
  // Show the modified JSON
  WriteLn('Modified: ', Config.ToString(True));
  WriteLn;
end;

procedure DemonstrateErrorHandling;
var
  Success: Boolean;
  Value: IJSONValue;
begin
  WriteLn('Demonstrating error handling...');
  
  // Try to parse invalid JSON
  Success := TJSON.TryParse('{invalid json}', Value);
  if not Success then
    WriteLn('Successfully caught invalid JSON')
  else
    WriteLn('Unexpected success with invalid JSON');
    
  try
    Value := TJSON.Parse('[1,2,]'); // Trailing comma
    WriteLn('This line should not be reached');
  except
    on E: EJSONException do
      WriteLn('Caught expected exception: ', E.Message);
  end;
  WriteLn;
end;

begin
  try
    WriteLn('SimpleJSON Library Example');
    WriteLn('==========================');
    WriteLn;
    
    DemonstrateCreation;
    DemonstrateParsing;
    DemonstrateModification;
    DemonstrateErrorHandling;
    
    WriteLn('Example completed successfully.');
  except
    on E: Exception do
    begin
      WriteLn('Error: ', E.Message);
      ExitCode := 1;
    end;
  end;
end. 