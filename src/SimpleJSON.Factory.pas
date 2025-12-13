unit SimpleJSON.Factory;

{$mode objfpc}{$H+}{$J-}

interface

uses
  Classes, SysUtils, SimpleJSON, SimpleJSON.Types, SimpleJSON.Parser;
 
type
  // JSON static helper class 
  TJSON = class
  public
    // Factory methods 
    class function Obj: IJSONObject; static;
    class function Arr: IJSONArray; static;
    class function Str(const Value: string): IJSONValue; static;
    class function Num(Value: Double): IJSONValue; static;
    class function Int(Value: Integer): IJSONValue; static;
    class function Bool(Value: Boolean): IJSONValue; static;
    class function Null: IJSONValue; static;
    
    // Parsing methods 
    class function Parse(const JSON: string): IJSONValue; static;
    class function TryParse(const JSON: string; out Value: IJSONValue): Boolean; static;
    
    // Formatting methods 
    class function PrettyPrint(const JSON: string): string; static;
    class function Compact(const JSON: string): string; static;
  end;

implementation

uses
  SimpleJSON.Writer;

// TJSON 

class function TJSON.Obj: IJSONObject;
begin
  Result := TJSONObject.Create;
end;

class function TJSON.Arr: IJSONArray;
begin
  Result := TJSONArray.Create;
end;

class function TJSON.Str(const Value: string): IJSONValue;
begin
  Result := TJSONString.Create(Value);
end;

class function TJSON.Num(Value: Double): IJSONValue;
begin
  Result := TJSONNumber.Create(Value);
end;

class function TJSON.Int(Value: Integer): IJSONValue;
begin
  Result := TJSONNumber.Create(Value);
end;

class function TJSON.Bool(Value: Boolean): IJSONValue;
begin
  Result := TJSONBoolean.Create(Value);
end;

class function TJSON.Null: IJSONValue;
begin
  Result := TJSONNull.Instance;
end;

class function TJSON.Parse(const JSON: string): IJSONValue;
var
  Parser: TJSONParser;
begin
  Parser := TJSONParser.Create;
  try
    Result := Parser.Parse(JSON);
  finally
    Parser.Free;
  end;
end;

class function TJSON.TryParse(const JSON: string; out Value: IJSONValue): Boolean;
begin
  try
    Value := Parse(JSON);
    Result := True;
  except
    on E: EJSONException do
    begin
      Value := nil;
      Result := False;
    end;
  end;
end;

class function TJSON.PrettyPrint(const JSON: string): string;
var
  Value: IJSONValue;
begin
  Value := Parse(JSON);
  Result := Value.ToString(True);
end;

class function TJSON.Compact(const JSON: string): string;
var
  Value: IJSONValue;
begin
  Value := Parse(JSON);
  Result := Value.ToString(False);
end;

end. 