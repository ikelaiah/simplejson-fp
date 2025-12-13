unit SimpleJSON.Parser;

{$mode objfpc}{$H+}{$J-}

interface

uses
  Classes, SysUtils, SimpleJSON, SimpleJSON.Scanner;

type
  // JSON parser class 
  TJSONParser = class
  private
    FScanner: TJSONScanner;
    FCurrentToken: TJSONToken;
    
    procedure GetNextToken;
    function ParseValue: IJSONValue;
    function ParseObject: IJSONObject;
    function ParseArray: IJSONArray;
  public
    constructor Create;
    destructor Destroy; override;
    function Parse(const JSON: string): IJSONValue;
  end;

implementation

uses
  SimpleJSON.Types;

constructor TJSONParser.Create;
begin
  inherited Create;
  FScanner := nil;
end;

destructor TJSONParser.Destroy;
begin
  FScanner.Free;
  inherited Destroy;
end;

procedure TJSONParser.GetNextToken;
begin
  FCurrentToken := FScanner.GetNextToken;
end;

function TJSONParser.ParseValue: IJSONValue;
begin
  case FCurrentToken.TokenType of
    ttCurlyOpen:
      Result := ParseObject;
      
    ttSquareOpen:
      Result := ParseArray;
      
    ttString:
      begin
        Result := TJSONString.Create(FCurrentToken.Value);
        GetNextToken;
      end;
      
    ttNumber:
      begin
        Result := TJSONNumber.Create(StrToFloat(FCurrentToken.Value));
        GetNextToken;
      end;
      
    ttTrue:
      begin
        Result := TJSONBoolean.Create(True);
        GetNextToken;
      end;
      
    ttFalse:
      begin
        Result := TJSONBoolean.Create(False);
        GetNextToken;
      end;
      
    ttNull:
      begin
        Result := TJSONNull.Instance;
        GetNextToken;
      end;
      
    else
      raise EJSONException.Create('Expected value');
  end;
end;

function TJSONParser.ParseObject: IJSONObject;
var
  Obj: IJSONObject;
  Name: string;
begin
  if FCurrentToken.TokenType <> ttCurlyOpen then
    raise EJSONException.Create('Expected {');
    
  Obj := TJSONObject.Create;
  GetNextToken;
  
  // Empty object
  if FCurrentToken.TokenType = ttCurlyClose then
  begin
    GetNextToken;
    Result := Obj;
    Exit;
  end;
  
  // Parse members
  while True do
  begin
    // Parse name
    if FCurrentToken.TokenType <> ttString then
      raise EJSONException.Create('Expected string');
      
    Name := FCurrentToken.Value;
    GetNextToken;
    
    // Parse colon
    if FCurrentToken.TokenType <> ttColon then
      raise EJSONException.Create('Expected :');
    GetNextToken;
    
    // Parse value
    Obj.Add(Name, ParseValue);
    
    // Check for more members
    if FCurrentToken.TokenType = ttComma then
    begin
      GetNextToken;
      Continue;
    end;
    
    if FCurrentToken.TokenType = ttCurlyClose then
    begin
      GetNextToken;
      Break;
    end;
    
    raise EJSONException.Create('Expected , or }');
  end;
  
  Result := Obj;
end;

function TJSONParser.ParseArray: IJSONArray;
var
  Arr: IJSONArray;
begin
  if FCurrentToken.TokenType <> ttSquareOpen then
    raise EJSONException.Create('Expected [');
    
  Arr := TJSONArray.Create;
  GetNextToken;
  
  // Empty array
  if FCurrentToken.TokenType = ttSquareClose then
  begin
    GetNextToken;
    Result := Arr;
    Exit;
  end;
  
  // Parse elements
  while True do
  begin
    Arr.Add(ParseValue);
    
    // Check for more elements
    if FCurrentToken.TokenType = ttComma then
    begin
      GetNextToken;
      Continue;
    end;
    
    if FCurrentToken.TokenType = ttSquareClose then
    begin
      GetNextToken;
      Break;
    end;
    
    raise EJSONException.Create('Expected , or ]');
  end;
  
  Result := Arr;
end;

function TJSONParser.Parse(const JSON: string): IJSONValue;
begin
  FreeAndNil(FScanner);
  FScanner := TJSONScanner.Create(JSON);
  
  GetNextToken;
  Result := ParseValue;
  
  if FCurrentToken.TokenType <> ttNone then
    raise EJSONException.Create('Unexpected tokens after JSON value');
end;

end. 