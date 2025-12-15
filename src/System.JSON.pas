unit System.JSON;

{$mode objfpc}{$H+}{$J-}
{$modeswitch advancedrecords}

(* System.JSON Compatibility Layer for SimpleJSON-FP
   
   This unit provides a Delphi System.JSON-compatible API for Free Pascal/Lazarus.
   It allows code written for Delphi's System.JSON to be easily ported to Lazarus
   with minimal or no changes.
   
   LEGAL NOTE:
   This is a clean-room API-compatible implementation. APIs are not copyrightable
   (Google v. Oracle, 2021). This implementation is entirely original code that
   provides method/class signature compatibility for easier code porting.
   
   Supported Classes:
   - TJSONValue      (base class for all JSON values)
   - TJSONObject     (JSON object: key-value pairs)
   - TJSONArray      (JSON array)
   - TJSONString     (JSON string value)
   - TJSONNumber     (JSON number value)
   - TJSONBool       (JSON boolean value)
   - TJSONTrue       (JSON true value)
   - TJSONFalse      (JSON false value)
   - TJSONNull       (JSON null value)
   - TJSONPair       (key-value pair for objects)
   
   Example usage (same as Delphi):
   
     var
       Obj: TJSONObject;
       S: string;
     begin
       S := '{"name": "John", "age": 30}';
       Obj := TJSONObject.ParseJSONValue(S) as TJSONObject;
       try
         WriteLn(Obj.GetValue<string>('name'));
         WriteLn(Obj.GetValue<Integer>('age'));
       finally
         Obj.Free;
       end;
     end;
   
   Author: SimpleJSON-FP Contributors
   License: MIT *)

interface

uses
  Classes, SysUtils, Generics.Collections;

type
  // Forward declarations
  TJSONValue = class;
  TJSONObject = class;
  TJSONArray = class;
  TJSONString = class;
  TJSONNumber = class;
  TJSONBool = class;
  TJSONTrue = class;
  TJSONFalse = class;
  TJSONNull = class;
  TJSONPair = class;
  
  // JSON exception class (compatible with Delphi)
  EJSONException = class(Exception);
  EJSONParseException = class(EJSONException);
  
  // TJSONValue - Base class for all JSON values
  TJSONValue = class
  private
    FOwned: Boolean;
  protected
    function GetValue: string; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    
    // Parsing methods (class methods like Delphi)
    class function ParseJSONValue(const Data: string): TJSONValue; overload; static;
    class function ParseJSONValue(const Data: string; UseBool: Boolean): TJSONValue; overload; static;
    class function ParseJSONValue(const Data: string; UseBool: Boolean; RaiseExc: Boolean): TJSONValue; overload; static;
    class function ParseJSONValue(const Data: TBytes; Offset: Integer; IsUTF8: Boolean = True): TJSONValue; overload; static;
    
    // Output methods
    function ToJSON: string; virtual;
    function ToString: string; override;
    function Format(IndentSize: Integer = 2): string; virtual;
    function ToBytes(Encoding: TEncoding = nil): TBytes;
    
    // Value access
    function Value: string; virtual;
    
    // Type checking
    function Null: Boolean; virtual;
    
    // Clone method
    function Clone: TJSONValue; virtual;
    
    // Estimated size
    function EstimatedByteSize: Integer; virtual;
    
    // Generic value access (Delphi-style) - without generics, use typed methods
    function GetValueString(const APath: string; DefaultValue: string = ''): string;
    function GetValueInt(const APath: string; DefaultValue: Integer = 0): Integer;
    function GetValueInt64(const APath: string; DefaultValue: Int64 = 0): Int64;
    function GetValueDouble(const APath: string; DefaultValue: Double = 0): Double;
    function GetValueBool(const APath: string; DefaultValue: Boolean = False): Boolean;
    
    // Find value at path
    function FindValue(const APath: string): TJSONValue;
    
    // Try get value
    function TryGetValueString(const APath: string; out AValue: string): Boolean;
    function TryGetValueInt(const APath: string; out AValue: Integer): Boolean;
    function TryGetValueInt64(const APath: string; out AValue: Int64): Boolean;
    function TryGetValueDouble(const APath: string; out AValue: Double): Boolean;
    function TryGetValueBool(const APath: string; out AValue: Boolean): Boolean;
    function TryGetValueObj(const APath: string; out AValue: TJSONValue): Boolean;
    
    // Ownership
    property Owned: Boolean read FOwned write FOwned;
  end;

  // TJSONPair - Key-value pair for TJSONObject
  TJSONPair = class
  private
    FJsonString: TJSONString;
    FJsonValue: TJSONValue;
    function GetJsonString: TJSONString;
    function GetJsonValue: TJSONValue;
  public
    constructor Create; overload;
    constructor Create(const Str: string; const AValue: TJSONValue); overload;
    constructor Create(const Str: string; const AValue: string); overload;
    constructor Create(const Str: string; AValue: Integer); overload;
    constructor Create(const Str: string; AValue: Double); overload;
    constructor Create(const Str: string; AValue: Boolean); overload;
    constructor Create(const Str: TJSONString; const AValue: TJSONValue); overload;
    destructor Destroy; override;
    
    function ToJSON: string;
    function ToString: string; override;
    function Clone: TJSONPair;
    function EstimatedByteSize: Integer;
    
    property JsonString: TJSONString read GetJsonString;
    property JsonValue: TJSONValue read GetJsonValue;
  end;
  
  TJSONPairList = specialize TObjectList<TJSONPair>;
  TJSONPairEnumerator = TJSONPairList.TEnumerator;
  
  // TJSONObject - JSON object containing key-value pairs
  TJSONObject = class(TJSONValue)
  private
    FPairs: TJSONPairList;
    function GetPair(Index: Integer): TJSONPair;
    function GetCount: Integer;
  public
    constructor Create; overload;
    constructor Create(const Pair: TJSONPair); overload;
    constructor Create(const AKey: string; const AValue: TJSONValue); overload;
    constructor Create(const AKey: string; const AValue: string); overload;
    destructor Destroy; override;
    
    // Parsing (inherited and overridden)
    class function ParseJSONValue(const Data: string): TJSONValue; overload; static;
    
    // Adding pairs
    function AddPair(const Pair: TJSONPair): TJSONObject; overload;
    function AddPair(const Str: string; const AValue: TJSONValue): TJSONObject; overload;
    function AddPair(const Str: string; const AValue: string): TJSONObject; overload;
    function AddPair(const Str: string; AValue: Integer): TJSONObject; overload;
    function AddPair(const Str: string; AValue: Double): TJSONObject; overload;
    function AddPair(const Str: string; AValue: Boolean): TJSONObject; overload;
    function AddPair(const Str: TJSONString; const AValue: TJSONValue): TJSONObject; overload;
    
    // Removing pairs
    // Removes and returns the TJSONPair with name PairName.
    // NOTE: Ownership semantics -- the returned TJSONPair is not freed by the
    // TObjectList that holds the pairs. The caller is responsible for freeing
    // the returned TJSONPair (and, transitively, its JsonValue if desired).
    // If the pair is not found, the function returns nil.
    function RemovePair(const PairName: string): TJSONPair;
    
    // Getting values
    function Get(const PairName: string): TJSONPair; overload;
    function Get(Index: Integer): TJSONPair; overload;
    function GetValue(const Name: string): TJSONValue;
    
    // Typed value access
    function GetValueString(const Name: string; DefaultValue: string = ''): string;
    function GetValueInt(const Name: string; DefaultValue: Integer = 0): Integer;
    function GetValueInt64(const Name: string; DefaultValue: Int64 = 0): Int64;
    function GetValueDouble(const Name: string; DefaultValue: Double = 0): Double;
    function GetValueBool(const Name: string; DefaultValue: Boolean = False): Boolean;
    
    // Finding values
    function FindValue(const APath: string): TJSONValue;
    
    // Output
    function ToJSON: string; override;
    function Format(IndentSize: Integer = 2): string; override;
    function Clone: TJSONValue; override;
    function EstimatedByteSize: Integer; override;
    
    // Enumeration support
    function GetEnumerator: TJSONPairEnumerator;
    
    // Properties
    property Count: Integer read GetCount;
    property Pairs[Index: Integer]: TJSONPair read GetPair;
  end;
  
  TJSONValueList = specialize TObjectList<TJSONValue>;
  TJSONValueEnumerator = TJSONValueList.TEnumerator;
  
  // TJSONArray - JSON array of values
  TJSONArray = class(TJSONValue)
  private
    FElements: TJSONValueList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TJSONValue;
    procedure SetItem(Index: Integer; AValue: TJSONValue);
  public
    constructor Create; overload;
    constructor Create(const FirstElem: TJSONValue); overload;
    constructor Create(const FirstElem: string); overload;
    destructor Destroy; override;
    
    // Adding elements
    function Add(const Element: TJSONValue): TJSONArray; overload;
    function Add(const Element: string): TJSONArray; overload;
    function Add(Element: Integer): TJSONArray; overload;
    function Add(Element: Double): TJSONArray; overload;
    function Add(Element: Boolean): TJSONArray; overload;
    function AddElement(const Element: TJSONValue): TJSONArray;
    
    // Removing elements
    function Remove(Index: Integer): TJSONValue;
    procedure Delete(Index: Integer);
    function Pop: TJSONValue;
    
    // Output
    function ToJSON: string; override;
    function Format(IndentSize: Integer = 2): string; override;
    function Clone: TJSONValue; override;
    function EstimatedByteSize: Integer; override;
    
    // Enumeration support
    function GetEnumerator: TJSONValueEnumerator;
    
    // Properties
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TJSONValue read GetItem write SetItem; default;
  end;
  
  // TJSONString - JSON string value
  TJSONString = class(TJSONValue)
  private
    FValue: string;
  public
    constructor Create; overload;
    constructor Create(const AValue: string); overload;
    
    function Value: string; override;
    function ToJSON: string; override;
    function Clone: TJSONValue; override;
    function EstimatedByteSize: Integer; override;
  end;
  
  // TJSONNumber - JSON number value
  TJSONNumber = class(TJSONValue)
  private
    FValue: string;
  public
    constructor Create; overload;
    constructor Create(const AValue: Double); overload;
    constructor Create(const AValue: Integer); overload;
    constructor Create(const AValue: Int64); overload;
    constructor Create(const AValue: string); overload;
    
    function Value: string; override;
    function AsDouble: Double;
    function AsInt: Integer;
    function AsInt64: Int64;
    function ToJSON: string; override;
    function Clone: TJSONValue; override;
    function EstimatedByteSize: Integer; override;
  end;
  
  // TJSONBool - JSON boolean value (base class for TJSONTrue/TJSONFalse)
  TJSONBool = class(TJSONValue)
  private
    FValue: Boolean;
  public
    constructor Create; overload;
    constructor Create(AValue: Boolean); overload;
    
    function Value: string; override;
    function AsBoolean: Boolean;
    function ToJSON: string; override;
    function Clone: TJSONValue; override;
    function EstimatedByteSize: Integer; override;
  end;
  
  // TJSONTrue - JSON true value
  TJSONTrue = class(TJSONBool)
  public
    constructor Create;
  end;
  
  // TJSONFalse - JSON false value
  TJSONFalse = class(TJSONBool)
  public
    constructor Create;
  end;
  
  // TJSONNull - JSON null value
  TJSONNull = class(TJSONValue)
  public
    constructor Create;
    
    function Null: Boolean; override;
    function Value: string; override;
    function ToJSON: string; override;
    function Clone: TJSONValue; override;
    function EstimatedByteSize: Integer; override;
  end;

implementation

uses
  Math;

{ Helper functions }

function EscapeJSONString(const S: string): string;
var
  I: Integer;
  C: Char;
begin
  Result := '';
  for I := 1 to Length(S) do
  begin
    C := S[I];
    case C of
      #8:  Result := Result + '\b';
      #9:  Result := Result + '\t';
      #10: Result := Result + '\n';
      #12: Result := Result + '\f';
      #13: Result := Result + '\r';
      '"': Result := Result + '\"';
      '\': Result := Result + '\\';
      else
        if Ord(C) < 32 then
          Result := Result + Format('\u%.4x', [Ord(C)])
        else
          Result := Result + C;
    end;
  end;
end;

{ Simple JSON Parser for this compatibility layer }

type
  TSimpleJSONParser = class
  private
    FData: string;
    FPos: Integer;
    FUseBool: Boolean;
    
    procedure SkipWhitespace;
    function PeekChar: Char;
    function ReadChar: Char;
    function ReadString: string;
    function ReadNumber: string;
    function ParseValue: TJSONValue;
    function ParseObject: TJSONObject;
    function ParseArray: TJSONArray;
    function ParseString: TJSONString;
    function ParseNumber: TJSONNumber;
    function ParseTrue: TJSONValue;
    function ParseFalse: TJSONValue;
    function ParseNull: TJSONNull;
  public
    constructor Create(const AData: string; AUseBool: Boolean = True);
    function Parse: TJSONValue;
  end;

constructor TSimpleJSONParser.Create(const AData: string; AUseBool: Boolean = True);
begin
  inherited Create;
  FData := AData;
  FPos := 1;
  FUseBool := AUseBool;
end;

procedure TSimpleJSONParser.SkipWhitespace;
begin
  while (FPos <= Length(FData)) and (FData[FPos] in [' ', #9, #10, #13]) do
    Inc(FPos);
end;

function TSimpleJSONParser.PeekChar: Char;
begin
  SkipWhitespace;
  if FPos <= Length(FData) then
    Result := FData[FPos]
  else
    Result := #0;
end;

function TSimpleJSONParser.ReadChar: Char;
begin
  Result := PeekChar;
  if FPos <= Length(FData) then
    Inc(FPos);
end;

function TSimpleJSONParser.ReadString: string;
var
  C: Char;
  Unicode: string;
begin
  Result := '';
  if ReadChar <> '"' then
    raise EJSONParseException.Create('Expected "');
    
  while FPos <= Length(FData) do
  begin
    C := FData[FPos];
    Inc(FPos);
    
    if C = '"' then
      Exit;
      
    if C = '\' then
    begin
      if FPos > Length(FData) then
        raise EJSONParseException.Create('Unexpected end of escape sequence');
        
      C := FData[FPos];
      Inc(FPos);
      
      case C of
        '"': Result := Result + '"';
        '\': Result := Result + '\';
        '/': Result := Result + '/';
        'b': Result := Result + #8;
        'f': Result := Result + #12;
        'n': Result := Result + #10;
        'r': Result := Result + #13;
        't': Result := Result + #9;
        'u': begin
          if FPos + 3 > Length(FData) then
            raise EJSONParseException.Create('Invalid unicode escape');
          Unicode := Copy(FData, FPos, 4);
          Result := Result + Char(StrToInt('$' + Unicode));
          Inc(FPos, 4);
        end;
        else
          raise EJSONParseException.CreateFmt('Invalid escape sequence: \%s', [C]);
      end;
    end
    else
      Result := Result + C;
  end;
  
  raise EJSONParseException.Create('Unterminated string');
end;

function TSimpleJSONParser.ReadNumber: string;
var
  C: Char;
begin
  Result := '';
  
  // Optional minus
  if (FPos <= Length(FData)) and (FData[FPos] = '-') then
  begin
    Result := Result + FData[FPos];
    Inc(FPos);
  end;
  
  // Integer part
  while (FPos <= Length(FData)) and (FData[FPos] in ['0'..'9']) do
  begin
    Result := Result + FData[FPos];
    Inc(FPos);
  end;
  
  // Fractional part
  if (FPos <= Length(FData)) and (FData[FPos] = '.') then
  begin
    Result := Result + FData[FPos];
    Inc(FPos);
    while (FPos <= Length(FData)) and (FData[FPos] in ['0'..'9']) do
    begin
      Result := Result + FData[FPos];
      Inc(FPos);
    end;
  end;
  
  // Exponent part
  if (FPos <= Length(FData)) and (FData[FPos] in ['e', 'E']) then
  begin
    Result := Result + FData[FPos];
    Inc(FPos);
    if (FPos <= Length(FData)) and (FData[FPos] in ['+', '-']) then
    begin
      Result := Result + FData[FPos];
      Inc(FPos);
    end;
    while (FPos <= Length(FData)) and (FData[FPos] in ['0'..'9']) do
    begin
      Result := Result + FData[FPos];
      Inc(FPos);
    end;
  end;
end;

function TSimpleJSONParser.ParseValue: TJSONValue;
var
  C: Char;
begin
  C := PeekChar;
  case C of
    '{': Result := ParseObject;
    '[': Result := ParseArray;
    '"': Result := ParseString;
    't': Result := ParseTrue;
    'f': Result := ParseFalse;
    'n': Result := ParseNull;
    '-', '0'..'9': Result := ParseNumber;
    else
      raise EJSONParseException.CreateFmt('Unexpected character: %s at position %d', [C, FPos]);
  end;
end;

function TSimpleJSONParser.ParseObject: TJSONObject;
var
  Key: string;
  Value: TJSONValue;
begin
  Result := TJSONObject.Create;
  try
    if ReadChar <> '{' then
      raise EJSONParseException.Create('Expected {');
      
    if PeekChar = '}' then
    begin
      ReadChar;
      Exit;
    end;
    
    repeat
      // Read key
      SkipWhitespace;
      Key := ReadString;
      
      // Read colon
      SkipWhitespace;
      if ReadChar <> ':' then
        raise EJSONParseException.Create('Expected :');
        
      // Read value
      SkipWhitespace;
      Value := ParseValue;
      
      Result.AddPair(Key, Value);
      
      // Check for more pairs
      SkipWhitespace;
      if PeekChar = ',' then
        ReadChar
      else
        Break;
    until False;
    
    if ReadChar <> '}' then
      raise EJSONParseException.Create('Expected }');
  except
    Result.Free;
    raise;
  end;
end;

function TSimpleJSONParser.ParseArray: TJSONArray;
var
  Value: TJSONValue;
begin
  Result := TJSONArray.Create;
  try
    if ReadChar <> '[' then
      raise EJSONParseException.Create('Expected [');
      
    if PeekChar = ']' then
    begin
      ReadChar;
      Exit;
    end;
    
    repeat
      SkipWhitespace;
      Value := ParseValue;
      Result.Add(Value);
      
      SkipWhitespace;
      if PeekChar = ',' then
        ReadChar
      else
        Break;
    until False;
    
    if ReadChar <> ']' then
      raise EJSONParseException.Create('Expected ]');
  except
    Result.Free;
    raise;
  end;
end;

function TSimpleJSONParser.ParseString: TJSONString;
begin
  Result := TJSONString.Create(ReadString);
end;

function TSimpleJSONParser.ParseNumber: TJSONNumber;
begin
  Result := TJSONNumber.Create(ReadNumber);
end;

function TSimpleJSONParser.ParseTrue: TJSONValue;
begin
  if Copy(FData, FPos, 4) = 'true' then
  begin
    Inc(FPos, 4);
    if FUseBool then
      Result := TJSONTrue.Create
    else
      Result := TJSONBool.Create(True);
  end
  else
    raise EJSONParseException.Create('Expected true');
end;

function TSimpleJSONParser.ParseFalse: TJSONValue;
begin
  if Copy(FData, FPos, 5) = 'false' then
  begin
    Inc(FPos, 5);
    if FUseBool then
      Result := TJSONFalse.Create
    else
      Result := TJSONBool.Create(False);
  end
  else
    raise EJSONParseException.Create('Expected false');
end;

function TSimpleJSONParser.ParseNull: TJSONNull;
begin
  if Copy(FData, FPos, 4) = 'null' then
  begin
    Inc(FPos, 4);
    Result := TJSONNull.Create;
  end
  else
    raise EJSONParseException.Create('Expected null');
end;

function TSimpleJSONParser.Parse: TJSONValue;
begin
  Result := ParseValue;
  SkipWhitespace;
  if FPos <= Length(FData) then
    raise EJSONParseException.CreateFmt('Unexpected data at position %d', [FPos]);
end;

{ TJSONValue }

constructor TJSONValue.Create;
begin
  inherited Create;
  FOwned := False;
end;

destructor TJSONValue.Destroy;
begin
  inherited Destroy;
end;

function TJSONValue.GetValue: string;
begin
  Result := '';
end;

class function TJSONValue.ParseJSONValue(const Data: string): TJSONValue;
begin
  Result := ParseJSONValue(Data, True, True);
end;

class function TJSONValue.ParseJSONValue(const Data: string; UseBool: Boolean): TJSONValue;
begin
  Result := ParseJSONValue(Data, UseBool, True);
end;

class function TJSONValue.ParseJSONValue(const Data: string; UseBool: Boolean; RaiseExc: Boolean): TJSONValue;
var
  Parser: TSimpleJSONParser;
begin
  Result := nil;
  if Data = '' then
  begin
    if RaiseExc then
      raise EJSONParseException.Create('Empty JSON data');
    Exit;
  end;
  
  Parser := TSimpleJSONParser.Create(Data, UseBool);
  try
    try
      Result := Parser.Parse;
    except
      on E: EJSONParseException do
      begin
        if RaiseExc then
          raise
        else
          Result := nil;
      end;
    end;
  finally
    Parser.Free;
  end;
end;

class function TJSONValue.ParseJSONValue(const Data: TBytes; Offset: Integer; IsUTF8: Boolean = True): TJSONValue;
var
  S: string;
  Enc: TEncoding;
begin
  if IsUTF8 then
    Enc := TEncoding.UTF8
  else
    Enc := TEncoding.Unicode;
    
  S := Enc.GetString(Data, Offset, Length(Data) - Offset);
  Result := ParseJSONValue(S);
end;

function TJSONValue.ToJSON: string;
begin
  Result := '';
end;

function TJSONValue.ToString: string;
begin
  Result := ToJSON;
end;

function TJSONValue.Format(IndentSize: Integer): string;

  function FormatValue(AValue: TJSONValue; Indent: Integer): string;
  var
    IndentStr, NextIndentStr: string;
    I: Integer;
    Obj: TJSONObject;
    Arr: TJSONArray;
    First: Boolean;
  begin
    IndentStr := StringOfChar(' ', Indent);
    NextIndentStr := StringOfChar(' ', Indent + IndentSize);
    
    if AValue is TJSONObject then
    begin
      Obj := TJSONObject(AValue);
      if Obj.Count = 0 then
        Result := '{}'
      else
      begin
        Result := '{' + LineEnding;
        First := True;
        for I := 0 to Obj.Count - 1 do
        begin
          if not First then
            Result := Result + ',' + LineEnding;
          First := False;
          Result := Result + NextIndentStr + '"' + EscapeJSONString(Obj.Pairs[I].JsonString.Value) + '": ';
          Result := Result + FormatValue(Obj.Pairs[I].JsonValue, Indent + IndentSize);
        end;
        Result := Result + LineEnding + IndentStr + '}';
      end;
    end
    else if AValue is TJSONArray then
    begin
      Arr := TJSONArray(AValue);
      if Arr.Count = 0 then
        Result := '[]'
      else
      begin
        Result := '[' + LineEnding;
        First := True;
        for I := 0 to Arr.Count - 1 do
        begin
          if not First then
            Result := Result + ',' + LineEnding;
          First := False;
          Result := Result + NextIndentStr + FormatValue(Arr[I], Indent + IndentSize);
        end;
        Result := Result + LineEnding + IndentStr + ']';
      end;
    end
    else
      Result := AValue.ToJSON;
  end;

begin
  Result := FormatValue(Self, 0);
end;

function TJSONValue.ToBytes(Encoding: TEncoding = nil): TBytes;
begin
  if Encoding = nil then
    Encoding := TEncoding.UTF8;
  Result := Encoding.GetBytes(ToJSON);
end;

function TJSONValue.Value: string;
begin
  Result := GetValue;
end;

function TJSONValue.Null: Boolean;
begin
  Result := False;
end;

function TJSONValue.Clone: TJSONValue;
begin
  Result := nil;
end;

function TJSONValue.EstimatedByteSize: Integer;
begin
  Result := Length(ToJSON);
end;

function TJSONValue.GetValueString(const APath: string; DefaultValue: string = ''): string;
var
  V: TJSONValue;
begin
  V := FindValue(APath);
  if (V <> nil) and (V is TJSONString) then
    Result := TJSONString(V).Value
  else
    Result := DefaultValue;
end;

function TJSONValue.GetValueInt(const APath: string; DefaultValue: Integer = 0): Integer;
var
  V: TJSONValue;
begin
  V := FindValue(APath);
  if (V <> nil) and (V is TJSONNumber) then
    Result := TJSONNumber(V).AsInt
  else
    Result := DefaultValue;
end;

function TJSONValue.GetValueInt64(const APath: string; DefaultValue: Int64 = 0): Int64;
var
  V: TJSONValue;
begin
  V := FindValue(APath);
  if (V <> nil) and (V is TJSONNumber) then
    Result := TJSONNumber(V).AsInt64
  else
    Result := DefaultValue;
end;

function TJSONValue.GetValueDouble(const APath: string; DefaultValue: Double = 0): Double;
var
  V: TJSONValue;
begin
  V := FindValue(APath);
  if (V <> nil) and (V is TJSONNumber) then
    Result := TJSONNumber(V).AsDouble
  else
    Result := DefaultValue;
end;

function TJSONValue.GetValueBool(const APath: string; DefaultValue: Boolean = False): Boolean;
var
  V: TJSONValue;
begin
  V := FindValue(APath);
  if (V <> nil) and (V is TJSONBool) then
    Result := TJSONBool(V).AsBoolean
  else
    Result := DefaultValue;
end;

function TJSONValue.FindValue(const APath: string): TJSONValue;
var
  Parts: TStringArray;
  Current: TJSONValue;
  I, Index: Integer;
  Part: string;
begin
  Result := nil;
  if APath = '' then
  begin
    Result := Self;
    Exit;
  end;
  
  // Simple path parsing (supports . and [] notation)
  Parts := APath.Split(['.']);
  Current := Self;
  
  for I := 0 to Length(Parts) - 1 do
  begin
    Part := Parts[I];
    if Part = '' then
      Continue;
      
    // Check for array index
    if (Pos('[', Part) > 0) then
    begin
      // Handle array index notation
      Index := Pos('[', Part);
      if Index = 1 then
      begin
        // Pure array index like [0]
        if Current is TJSONArray then
        begin
          Part := Copy(Part, 2, Length(Part) - 2);
          if TryStrToInt(Part, Index) then
            Current := TJSONArray(Current).Items[Index]
          else
            Exit(nil);
        end
        else
          Exit(nil);
      end
      else
      begin
        // Property with array index like items[0]
        // Not fully implemented - basic path support only
        Exit(nil);
      end;
    end
    else if Current is TJSONObject then
      Current := TJSONObject(Current).GetValue(Part)
    else
      Exit(nil);
      
    if Current = nil then
      Exit;
  end;
  
  Result := Current;
end;

function TJSONValue.TryGetValueString(const APath: string; out AValue: string): Boolean;
var
  V: TJSONValue;
begin
  V := FindValue(APath);
  if (V <> nil) and (V is TJSONString) then
  begin
    AValue := TJSONString(V).Value;
    Result := True;
  end
  else
    Result := False;
end;

function TJSONValue.TryGetValueInt(const APath: string; out AValue: Integer): Boolean;
var
  V: TJSONValue;
begin
  V := FindValue(APath);
  if (V <> nil) and (V is TJSONNumber) then
  begin
    AValue := TJSONNumber(V).AsInt;
    Result := True;
  end
  else
    Result := False;
end;

function TJSONValue.TryGetValueInt64(const APath: string; out AValue: Int64): Boolean;
var
  V: TJSONValue;
begin
  V := FindValue(APath);
  if (V <> nil) and (V is TJSONNumber) then
  begin
    AValue := TJSONNumber(V).AsInt64;
    Result := True;
  end
  else
    Result := False;
end;

function TJSONValue.TryGetValueDouble(const APath: string; out AValue: Double): Boolean;
var
  V: TJSONValue;
begin
  V := FindValue(APath);
  if (V <> nil) and (V is TJSONNumber) then
  begin
    AValue := TJSONNumber(V).AsDouble;
    Result := True;
  end
  else
    Result := False;
end;

function TJSONValue.TryGetValueBool(const APath: string; out AValue: Boolean): Boolean;
var
  V: TJSONValue;
begin
  V := FindValue(APath);
  if (V <> nil) and (V is TJSONBool) then
  begin
    AValue := TJSONBool(V).AsBoolean;
    Result := True;
  end
  else
    Result := False;
end;

function TJSONValue.TryGetValueObj(const APath: string; out AValue: TJSONValue): Boolean;
begin
  AValue := FindValue(APath);
  Result := AValue <> nil;
end;

{ TJSONPair }

constructor TJSONPair.Create;
begin
  inherited Create;
  FJsonString := nil;
  FJsonValue := nil;
end;

constructor TJSONPair.Create(const Str: string; const AValue: TJSONValue);
begin
  Create;
  FJsonString := TJSONString.Create(Str);
  FJsonValue := AValue;
end;

constructor TJSONPair.Create(const Str: string; const AValue: string);
begin
  Create(Str, TJSONString.Create(AValue));
end;

constructor TJSONPair.Create(const Str: string; AValue: Integer);
begin
  Create(Str, TJSONNumber.Create(AValue));
end;

constructor TJSONPair.Create(const Str: string; AValue: Double);
begin
  Create(Str, TJSONNumber.Create(AValue));
end;

constructor TJSONPair.Create(const Str: string; AValue: Boolean);
begin
  if AValue then
    Create(Str, TJSONTrue.Create)
  else
    Create(Str, TJSONFalse.Create);
end;

constructor TJSONPair.Create(const Str: TJSONString; const AValue: TJSONValue);
begin
  Create;
  FJsonString := Str;
  FJsonValue := AValue;
end;

destructor TJSONPair.Destroy;
begin
  FreeAndNil(FJsonString);
  FreeAndNil(FJsonValue);
  inherited Destroy;
end;

function TJSONPair.GetJsonString: TJSONString;
begin
  Result := FJsonString;
end;

function TJSONPair.GetJsonValue: TJSONValue;
begin
  Result := FJsonValue;
end;

function TJSONPair.ToJSON: string;
begin
  Result := FJsonString.ToJSON + ':' + FJsonValue.ToJSON;
end;

function TJSONPair.ToString: string;
begin
  Result := ToJSON;
end;

function TJSONPair.Clone: TJSONPair;
begin
  Result := TJSONPair.Create(FJsonString.Clone as TJSONString, FJsonValue.Clone);
end;

function TJSONPair.EstimatedByteSize: Integer;
begin
  Result := FJsonString.EstimatedByteSize + 1 + FJsonValue.EstimatedByteSize;
end;

{ TJSONObject }

constructor TJSONObject.Create;
begin
  inherited Create;
  FPairs := TJSONPairList.Create(True);
end;

constructor TJSONObject.Create(const Pair: TJSONPair);
begin
  Create;
  AddPair(Pair);
end;

constructor TJSONObject.Create(const AKey: string; const AValue: TJSONValue);
begin
  Create;
  AddPair(AKey, AValue);
end;

constructor TJSONObject.Create(const AKey: string; const AValue: string);
begin
  Create;
  AddPair(AKey, AValue);
end;

destructor TJSONObject.Destroy;
begin
  FreeAndNil(FPairs);
  inherited Destroy;
end;

class function TJSONObject.ParseJSONValue(const Data: string): TJSONValue;
begin
  Result := TJSONValue.ParseJSONValue(Data);
end;

function TJSONObject.GetPair(Index: Integer): TJSONPair;
begin
  if (Index >= 0) and (Index < FPairs.Count) then
    Result := FPairs[Index]
  else
    Result := nil;
end;

function TJSONObject.GetCount: Integer;
begin
  Result := FPairs.Count;
end;

function TJSONObject.AddPair(const Pair: TJSONPair): TJSONObject;
begin
  FPairs.Add(Pair);
  Result := Self;
end;

function TJSONObject.AddPair(const Str: string; const AValue: TJSONValue): TJSONObject;
begin
  Result := AddPair(TJSONPair.Create(Str, AValue));
end;

function TJSONObject.AddPair(const Str: string; const AValue: string): TJSONObject;
begin
  Result := AddPair(TJSONPair.Create(Str, AValue));
end;

function TJSONObject.AddPair(const Str: string; AValue: Integer): TJSONObject;
begin
  Result := AddPair(TJSONPair.Create(Str, AValue));
end;

function TJSONObject.AddPair(const Str: string; AValue: Double): TJSONObject;
begin
  Result := AddPair(TJSONPair.Create(Str, AValue));
end;

function TJSONObject.AddPair(const Str: string; AValue: Boolean): TJSONObject;
begin
  Result := AddPair(TJSONPair.Create(Str, AValue));
end;

function TJSONObject.AddPair(const Str: TJSONString; const AValue: TJSONValue): TJSONObject;
begin
  Result := AddPair(TJSONPair.Create(Str, AValue));
end;

// Note: RemovePair removes the pair from the internal list and returns it to
// the caller. The internal list temporarily disables ownership so the caller
// receives the pair object; the caller is responsible for freeing the
// returned TJSONPair (and its JsonValue if necessary). If the pair is not
// found, the function returns nil.
function TJSONObject.RemovePair(const PairName: string): TJSONPair;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FPairs.Count - 1 do
  begin
    if FPairs[I].JsonString.Value = PairName then
    begin
      Result := FPairs[I];
      FPairs.OwnsObjects := False;
      FPairs.Delete(I);
      FPairs.OwnsObjects := True;
      Exit;
    end;
  end;
end;

function TJSONObject.Get(const PairName: string): TJSONPair;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FPairs.Count - 1 do
  begin
    if FPairs[I].JsonString.Value = PairName then
    begin
      Result := FPairs[I];
      Exit;
    end;
  end;
end;

function TJSONObject.Get(Index: Integer): TJSONPair;
begin
  Result := GetPair(Index);
end;

function TJSONObject.GetValue(const Name: string): TJSONValue;
var
  Pair: TJSONPair;
begin
  Pair := Get(Name);
  if Pair <> nil then
    Result := Pair.JsonValue
  else
    Result := nil;
end;

function TJSONObject.GetValueString(const Name: string; DefaultValue: string): string;
var
  V: TJSONValue;
begin
  V := GetValue(Name);
  if (V <> nil) and (V is TJSONString) then
    Result := TJSONString(V).Value
  else
    Result := DefaultValue;
end;

function TJSONObject.GetValueInt(const Name: string; DefaultValue: Integer): Integer;
var
  V: TJSONValue;
begin
  V := GetValue(Name);
  if (V <> nil) and (V is TJSONNumber) then
    Result := TJSONNumber(V).AsInt
  else
    Result := DefaultValue;
end;

function TJSONObject.GetValueInt64(const Name: string; DefaultValue: Int64): Int64;
var
  V: TJSONValue;
begin
  V := GetValue(Name);
  if (V <> nil) and (V is TJSONNumber) then
    Result := TJSONNumber(V).AsInt64
  else
    Result := DefaultValue;
end;

function TJSONObject.GetValueDouble(const Name: string; DefaultValue: Double): Double;
var
  V: TJSONValue;
begin
  V := GetValue(Name);
  if (V <> nil) and (V is TJSONNumber) then
    Result := TJSONNumber(V).AsDouble
  else
    Result := DefaultValue;
end;

function TJSONObject.GetValueBool(const Name: string; DefaultValue: Boolean): Boolean;
var
  V: TJSONValue;
begin
  V := GetValue(Name);
  if (V <> nil) and (V is TJSONBool) then
    Result := TJSONBool(V).AsBoolean
  else
    Result := DefaultValue;
end;

function TJSONObject.FindValue(const APath: string): TJSONValue;
begin
  Result := inherited FindValue(APath);
end;

function TJSONObject.ToJSON: string;
var
  I: Integer;
begin
  Result := '{';
  for I := 0 to FPairs.Count - 1 do
  begin
    if I > 0 then
      Result := Result + ',';
    Result := Result + FPairs[I].ToJSON;
  end;
  Result := Result + '}';
end;

function TJSONObject.Format(IndentSize: Integer): string;
begin
  Result := inherited Format(IndentSize);
end;

function TJSONObject.Clone: TJSONValue;
var
  Obj: TJSONObject;
  I: Integer;
begin
  Obj := TJSONObject.Create;
  for I := 0 to FPairs.Count - 1 do
    Obj.AddPair(FPairs[I].Clone);
  Result := Obj;
end;

function TJSONObject.EstimatedByteSize: Integer;
var
  I: Integer;
begin
  Result := 2; // {}
  for I := 0 to FPairs.Count - 1 do
  begin
    if I > 0 then
      Inc(Result); // ,
    Inc(Result, FPairs[I].EstimatedByteSize);
  end;
end;

function TJSONObject.GetEnumerator: TJSONPairEnumerator;
begin
  Result := FPairs.GetEnumerator;
end;

{ TJSONArray }

constructor TJSONArray.Create;
begin
  inherited Create;
  FElements := TJSONValueList.Create(True);
end;

constructor TJSONArray.Create(const FirstElem: TJSONValue);
begin
  Create;
  Add(FirstElem);
end;

constructor TJSONArray.Create(const FirstElem: string);
begin
  Create;
  Add(FirstElem);
end;

destructor TJSONArray.Destroy;
begin
  FreeAndNil(FElements);
  inherited Destroy;
end;

function TJSONArray.GetCount: Integer;
begin
  Result := FElements.Count;
end;

function TJSONArray.GetItem(Index: Integer): TJSONValue;
begin
  if (Index >= 0) and (Index < FElements.Count) then
    Result := FElements[Index]
  else
    Result := nil;
end;

procedure TJSONArray.SetItem(Index: Integer; AValue: TJSONValue);
begin
  if (Index >= 0) and (Index < FElements.Count) then
    FElements[Index] := AValue;
end;

function TJSONArray.Add(const Element: TJSONValue): TJSONArray;
begin
  FElements.Add(Element);
  Result := Self;
end;

function TJSONArray.Add(const Element: string): TJSONArray;
begin
  Result := Add(TJSONString.Create(Element));
end;

function TJSONArray.Add(Element: Integer): TJSONArray;
begin
  Result := Add(TJSONNumber.Create(Element));
end;

function TJSONArray.Add(Element: Double): TJSONArray;
begin
  Result := Add(TJSONNumber.Create(Element));
end;

function TJSONArray.Add(Element: Boolean): TJSONArray;
begin
  if Element then
    Result := Add(TJSONTrue.Create)
  else
    Result := Add(TJSONFalse.Create);
end;

function TJSONArray.AddElement(const Element: TJSONValue): TJSONArray;
begin
  Result := Add(Element);
end;

function TJSONArray.Remove(Index: Integer): TJSONValue;
begin
  if (Index >= 0) and (Index < FElements.Count) then
  begin
    Result := FElements[Index];
    FElements.OwnsObjects := False;
    FElements.Delete(Index);
    FElements.OwnsObjects := True;
  end
  else
    Result := nil;
end;

procedure TJSONArray.Delete(Index: Integer);
begin
  if (Index >= 0) and (Index < FElements.Count) then
    FElements.Delete(Index);
end;

function TJSONArray.Pop: TJSONValue;
begin
  if FElements.Count > 0 then
    Result := Remove(FElements.Count - 1)
  else
    Result := nil;
end;

function TJSONArray.ToJSON: string;
var
  I: Integer;
begin
  Result := '[';
  for I := 0 to FElements.Count - 1 do
  begin
    if I > 0 then
      Result := Result + ',';
    Result := Result + FElements[I].ToJSON;
  end;
  Result := Result + ']';
end;

function TJSONArray.Format(IndentSize: Integer): string;
begin
  Result := inherited Format(IndentSize);
end;

function TJSONArray.Clone: TJSONValue;
var
  Arr: TJSONArray;
  I: Integer;
begin
  Arr := TJSONArray.Create;
  for I := 0 to FElements.Count - 1 do
    Arr.Add(FElements[I].Clone);
  Result := Arr;
end;

function TJSONArray.EstimatedByteSize: Integer;
var
  I: Integer;
begin
  Result := 2; // []
  for I := 0 to FElements.Count - 1 do
  begin
    if I > 0 then
      Inc(Result); // ,
    Inc(Result, FElements[I].EstimatedByteSize);
  end;
end;

function TJSONArray.GetEnumerator: TJSONValueEnumerator;
begin
  Result := FElements.GetEnumerator;
end;

{ TJSONString }

constructor TJSONString.Create;
begin
  inherited Create;
  FValue := '';
end;

constructor TJSONString.Create(const AValue: string);
begin
  inherited Create;
  FValue := AValue;
end;

function TJSONString.Value: string;
begin
  Result := FValue;
end;

function TJSONString.ToJSON: string;
begin
  Result := '"' + EscapeJSONString(FValue) + '"';
end;

function TJSONString.Clone: TJSONValue;
begin
  Result := TJSONString.Create(FValue);
end;

function TJSONString.EstimatedByteSize: Integer;
begin
  Result := Length(ToJSON);
end;

{ TJSONNumber }

constructor TJSONNumber.Create;
begin
  inherited Create;
  FValue := '0';
end;

constructor TJSONNumber.Create(const AValue: Double);
var
  JSONFormat: TFormatSettings;
begin
  inherited Create;
  JSONFormat := DefaultFormatSettings;
  JSONFormat.DecimalSeparator := '.';
  JSONFormat.ThousandSeparator := #0;
  FValue := FloatToStr(AValue, JSONFormat);
  
  // Remove trailing zeros after decimal point
  if Pos('.', FValue) > 0 then
  begin
    while (Length(FValue) > 0) and (FValue[Length(FValue)] = '0') do
      SetLength(FValue, Length(FValue) - 1);
    if (Length(FValue) > 0) and (FValue[Length(FValue)] = '.') then
      SetLength(FValue, Length(FValue) - 1);
  end;
end;

constructor TJSONNumber.Create(const AValue: Integer);
begin
  inherited Create;
  FValue := IntToStr(AValue);
end;

constructor TJSONNumber.Create(const AValue: Int64);
begin
  inherited Create;
  FValue := IntToStr(AValue);
end;

constructor TJSONNumber.Create(const AValue: string);
begin
  inherited Create;
  FValue := AValue;
end;

function TJSONNumber.Value: string;
begin
  Result := FValue;
end;

function TJSONNumber.AsDouble: Double;
var
  JSONFormat: TFormatSettings;
begin
  JSONFormat := DefaultFormatSettings;
  JSONFormat.DecimalSeparator := '.';
  Result := StrToFloat(FValue, JSONFormat);
end;

function TJSONNumber.AsInt: Integer;
begin
  Result := Round(AsDouble);
end;

function TJSONNumber.AsInt64: Int64;
var
  DotPos: Integer;
begin
  // For large integers, StrToInt64 is more accurate than Round(AsDouble)
  // because Double loses precision for values > 2^53
  DotPos := Pos('.', FValue);
  if (DotPos = 0) and (Pos('e', LowerCase(FValue)) = 0) then
    // Pure integer string, use direct conversion
    Result := StrToInt64(FValue)
  else
    // Has decimal or exponent, use floating point
    Result := Round(AsDouble);
end;

function TJSONNumber.ToJSON: string;
begin
  Result := FValue;
end;

function TJSONNumber.Clone: TJSONValue;
begin
  Result := TJSONNumber.Create(FValue);
end;

function TJSONNumber.EstimatedByteSize: Integer;
begin
  Result := Length(FValue);
end;

{ TJSONBool }

constructor TJSONBool.Create;
begin
  inherited Create;
  FValue := False;
end;

constructor TJSONBool.Create(AValue: Boolean);
begin
  inherited Create;
  FValue := AValue;
end;

function TJSONBool.Value: string;
begin
  if FValue then
    Result := 'true'
  else
    Result := 'false';
end;

function TJSONBool.AsBoolean: Boolean;
begin
  Result := FValue;
end;

function TJSONBool.ToJSON: string;
begin
  Result := Value;
end;

function TJSONBool.Clone: TJSONValue;
begin
  if FValue then
    Result := TJSONTrue.Create
  else
    Result := TJSONFalse.Create;
end;

function TJSONBool.EstimatedByteSize: Integer;
begin
  if FValue then
    Result := 4 // 'true'
  else
    Result := 5; // 'false'
end;

{ TJSONTrue }

constructor TJSONTrue.Create;
begin
  inherited Create(True);
end;

{ TJSONFalse }

constructor TJSONFalse.Create;
begin
  inherited Create(False);
end;

{ TJSONNull }

constructor TJSONNull.Create;
begin
  inherited Create;
end;

function TJSONNull.Null: Boolean;
begin
  Result := True;
end;

function TJSONNull.Value: string;
begin
  Result := 'null';
end;

function TJSONNull.ToJSON: string;
begin
  Result := 'null';
end;

function TJSONNull.Clone: TJSONValue;
begin
  Result := TJSONNull.Create;
end;

function TJSONNull.EstimatedByteSize: Integer;
begin
  Result := 4; // 'null'
end;

end.
