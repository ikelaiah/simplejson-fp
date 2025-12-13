unit SimpleJSON.Types;

{$mode objfpc}{$H+}{$J-}

interface

uses
  Classes, SysUtils, SimpleJSON, Generics.Collections, Math;
 
type
  // Base JSON value class 
  TJSONValue = class(TInterfacedObject, IJSONValue)
  protected
    function GetAsString: string; virtual;
    function GetAsNumber: Double; virtual;
    function GetAsInteger: Integer; virtual;
    function GetAsBoolean: Boolean; virtual;
    function GetAsObject: IJSONObject; virtual;
    function GetAsArray: IJSONArray; virtual;
    
    function IsString: Boolean; virtual;
    function IsNumber: Boolean; virtual;
    function IsBoolean: Boolean; virtual;
    function IsObject: Boolean; virtual;
    function IsArray: Boolean; virtual;
    function IsNull: Boolean; virtual;
    
    function ToString(Pretty: Boolean = False): string; virtual;
  end;

  // JSON object implementation 
  TJSONObject = class(TJSONValue, IJSONObject)
  private
    FItems: specialize TDictionary<string, IJSONValue>;
    FKeys: specialize TList<string>;  // To maintain insertion order
    procedure ClearItems;
  public
    constructor Create;
    destructor Destroy; override;
    function GetValue(const Name: string): IJSONValue;
    procedure SetValue(const Name: string; Value: IJSONValue);
    function GetCount: Integer;
    function GetNames: TStringArray;
    procedure Add(const Name: string; Value: IJSONValue); overload;
    procedure Add(const Name: string; const Value: string); overload;
    procedure Add(const Name: string; Value: Integer); overload;
    procedure Add(const Name: string; Value: Double); overload;
    procedure Add(const Name: string; Value: Boolean); overload;
    procedure Remove(const Name: string);
    function Contains(const Name: string): Boolean;
    function IsObject: Boolean; override;
    function GetAsObject: IJSONObject; override;
    function ToString(Pretty: Boolean = False): string; override;
    function GetOrderedKeys: TStringArray;
  end;

  // JSON array implementation 
  TJSONArray = class(TJSONValue, IJSONArray)
  private
    FItems: specialize TList<IJSONValue>;
    procedure ClearItems;
  public
    constructor Create;
    destructor Destroy; override;
    function GetItem(Index: Integer): IJSONValue;
    procedure SetItem(Index: Integer; Value: IJSONValue);
    function GetCount: Integer;
    procedure Add(Value: IJSONValue); overload;
    procedure Add(const Value: string); overload;
    procedure Add(Value: Integer); overload;
    procedure Add(Value: Double); overload;
    procedure Add(Value: Boolean); overload;
    procedure Delete(Index: Integer);
    procedure Clear;
    function IsArray: Boolean; override;
    function GetAsArray: IJSONArray; override;
    function ToString(Pretty: Boolean = False): string; override;
  end;

  // JSON string value 
  TJSONString = class(TJSONValue)
  private
    FValue: string;
  public
    constructor Create(const AValue: string);
    function GetAsString: string; override;
    function IsString: Boolean; override;
    function ToString(Pretty: Boolean = False): string; override;
  end;

  // JSON number value 
  TJSONNumber = class(TJSONValue)
  private
    FValue: Double;
    class function IsValidJSONNumber(const Value: Double): Boolean; static;
  public
    constructor Create(AValue: Double);
    function GetAsNumber: Double; override;
    function GetAsInteger: Integer; override;
    function IsNumber: Boolean; override;
    function ToString(Pretty: Boolean = False): string; override;
  end;

  // JSON boolean value 
  TJSONBoolean = class(TJSONValue)
  private
    FValue: Boolean;
  public
    constructor Create(AValue: Boolean);
    function GetAsBoolean: Boolean; override;
    function IsBoolean: Boolean; override;
    function ToString(Pretty: Boolean = False): string; override;
  end;

  // JSON null value - singleton 
  TJSONNull = class(TJSONValue)
  private
    class var FInstance: TJSONNull;
    constructor Create;
  public
    class function Instance: TJSONNull;
    function IsNull: Boolean; override;
    function ToString(Pretty: Boolean = False): string; override;
  end;

implementation

uses
  SimpleJSON.Writer;

// TJSONValue implementation 

function TJSONValue.GetAsString: string;
begin
  raise EJSONException.Create('Cannot convert this JSON value to string');
end;

function TJSONValue.GetAsNumber: Double;
begin
  raise EJSONException.Create('Cannot convert this JSON value to number');
end;

function TJSONValue.GetAsInteger: Integer;
begin
  raise EJSONException.Create('Cannot convert this JSON value to integer');
end;

function TJSONValue.GetAsBoolean: Boolean;
begin
  raise EJSONException.Create('Cannot convert this JSON value to boolean');
end;

function TJSONValue.GetAsObject: IJSONObject;
begin
  raise EJSONException.Create('Cannot convert this JSON value to object');
end;

function TJSONValue.GetAsArray: IJSONArray;
begin
  raise EJSONException.Create('Cannot convert this JSON value to array');
end;

function TJSONValue.IsString: Boolean;
begin
  Result := False;
end;

function TJSONValue.IsNumber: Boolean;
begin
  Result := False;
end;

function TJSONValue.IsBoolean: Boolean;
begin
  Result := False;
end;

function TJSONValue.IsObject: Boolean;
begin
  Result := False;
end;

function TJSONValue.IsArray: Boolean;
begin
  Result := False;
end;

function TJSONValue.IsNull: Boolean;
begin
  Result := Self is TJSONNull;
end;

function TJSONValue.ToString(Pretty: Boolean): string;
begin
  Result := '';
end;

// TJSONObject implementation 

procedure TJSONObject.ClearItems;
begin
  if Assigned(FItems) then
  begin
    FItems.Clear;  // TDictionary will handle interface cleanup
    if Assigned(FKeys) then
      FKeys.Clear;
  end;
end;

constructor TJSONObject.Create;
begin
  inherited Create;
  FItems := specialize TDictionary<string, IJSONValue>.Create;
  FKeys := specialize TList<string>.Create;
end;

destructor TJSONObject.Destroy;
begin
  ClearItems;
  FreeAndNil(FItems);
  FreeAndNil(FKeys);
  inherited Destroy;
end;

function TJSONObject.GetValue(const Name: string): IJSONValue;
begin
  if not FItems.TryGetValue(Name, Result) then
    Result := nil;
end;

procedure TJSONObject.SetValue(const Name: string; Value: IJSONValue);
begin
  if Value = nil then
    Value := TJSONNull.Instance;
    
  if not FItems.ContainsKey(Name) then
    FKeys.Add(Name);
    
  FItems.AddOrSetValue(Name, Value);
end;

function TJSONObject.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TJSONObject.GetNames: TStringArray;
var
  I: Integer;
begin
  SetLength(Result, FKeys.Count);
  for I := 0 to FKeys.Count - 1 do
    Result[I] := FKeys[I];
end;

procedure TJSONObject.Add(const Name: string; Value: IJSONValue);
begin
  SetValue(Name, Value);
end;

procedure TJSONObject.Add(const Name: string; const Value: string);
begin
  Add(Name, TJSONString.Create(Value));
end;

procedure TJSONObject.Add(const Name: string; Value: Integer);
begin
  Add(Name, TJSONNumber.Create(Value));
end;

procedure TJSONObject.Add(const Name: string; Value: Double);
begin
  Add(Name, TJSONNumber.Create(Value));
end;

procedure TJSONObject.Add(const Name: string; Value: Boolean);
begin
  Add(Name, TJSONBoolean.Create(Value));
end;

procedure TJSONObject.Remove(const Name: string);
begin
  if FItems.ContainsKey(Name) then
  begin
    FItems.Remove(Name);
    FKeys.Remove(Name);
  end;
end;

function TJSONObject.Contains(const Name: string): Boolean;
begin
  Result := FItems.ContainsKey(Name);
end;

function TJSONObject.IsObject: Boolean;
begin
  Result := True;
end;

function TJSONObject.GetAsObject: IJSONObject;
begin
  Result := Self;
end;

function TJSONObject.ToString(Pretty: Boolean): string;
var
  Writer: TJSONWriter;
begin
  Writer := TJSONWriter.Create(not Pretty);
  try
    Result := Writer.Write(Self);
  finally
    Writer.Free;
  end;
end;

function TJSONObject.GetOrderedKeys: TStringArray;
var
  I: Integer;
begin
  SetLength(Result, FKeys.Count);
  for I := 0 to FKeys.Count - 1 do
    Result[I] := FKeys[I];
end;

// TJSONArray implementation 

procedure TJSONArray.ClearItems;
begin
  if Assigned(FItems) then
    FItems.Clear;  // TList will handle interface cleanup
end;

constructor TJSONArray.Create;
begin
  inherited Create;
  FItems := specialize TList<IJSONValue>.Create;
end;

destructor TJSONArray.Destroy;
begin
  ClearItems;
  FreeAndNil(FItems);
  inherited Destroy;
end;

function TJSONArray.GetItem(Index: Integer): IJSONValue;
begin
  if (Index >= 0) and (Index < FItems.Count) then
    Result := FItems[Index]
  else
    Result := nil;
end;

procedure TJSONArray.SetItem(Index: Integer; Value: IJSONValue);
begin
  if Value = nil then
    Value := TJSONNull.Instance;

  if (Index >= 0) and (Index < FItems.Count) then
    FItems[Index] := Value;
end;

function TJSONArray.GetCount: Integer;
begin
  Result := FItems.Count;
end;

procedure TJSONArray.Add(Value: IJSONValue);
begin
  if Value = nil then
    Value := TJSONNull.Instance;
  FItems.Add(Value);
end;

procedure TJSONArray.Add(const Value: string);
begin
  Add(TJSONString.Create(Value));
end;

procedure TJSONArray.Add(Value: Integer);
begin
  Add(TJSONNumber.Create(Value));
end;

procedure TJSONArray.Add(Value: Double);
begin
  Add(TJSONNumber.Create(Value));
end;

procedure TJSONArray.Add(Value: Boolean);
begin
  Add(TJSONBoolean.Create(Value));
end;

procedure TJSONArray.Delete(Index: Integer);
begin
  if (Index >= 0) and (Index < FItems.Count) then
    FItems.Delete(Index);
end;

procedure TJSONArray.Clear;
begin
  ClearItems;
end;

function TJSONArray.IsArray: Boolean;
begin
  Result := True;
end;

function TJSONArray.GetAsArray: IJSONArray;
begin
  Result := Self;
end;

function TJSONArray.ToString(Pretty: Boolean): string;
var
  Writer: TJSONWriter;
begin
  Writer := TJSONWriter.Create(not Pretty);
  try
    Result := Writer.Write(Self);
  finally
    Writer.Free;
  end;
end;

// TJSONString 

constructor TJSONString.Create(const AValue: string);
begin
  inherited Create;
  FValue := AValue;
end;

function TJSONString.GetAsString: string;
begin
  Result := FValue;
end;

function TJSONString.IsString: Boolean;
begin
  Result := True;
end;

function TJSONString.ToString(Pretty: Boolean): string;
var
  I: Integer;
  C: Char;
  S: string;
begin
  S := '';
  for I := 1 to Length(FValue) do
  begin
    C := FValue[I];
    case C of
      #8:  S := S + '\b';
      #9:  S := S + '\t';
      #10: S := S + '\n';
      #12: S := S + '\f';
      #13: S := S + '\r';
      '"': S := S + '\"';
      '\': S := S + '\\';
      else
        if Ord(C) < 32 then
          S := S + Format('\u%.4x', [Ord(C)])
        else
          S := S + C;
    end;
  end;
  Result := '"' + S + '"';
end;

// TJSONNumber 

class function TJSONNumber.IsValidJSONNumber(const Value: Double): Boolean;
begin
  (* According to JSON standard:
   - Must be finite (no NaN or Infinity)
   - Must not be octal or hexadecimal
   - Must not have leading zeros *)
  Result := not (IsNan(Value) or IsInfinite(Value));
end;

constructor TJSONNumber.Create(AValue: Double);
begin
  inherited Create;
  if not IsValidJSONNumber(AValue) then
    raise EJSONException.Create('Invalid JSON number: must be finite (no NaN or Infinity)');
  FValue := AValue;
end;

function TJSONNumber.GetAsNumber: Double;
begin
  Result := FValue;
end;

function TJSONNumber.GetAsInteger: Integer;
begin
  if (FValue > High(Integer)) or (FValue < Low(Integer)) then
    raise EJSONException.Create('Number exceeds Integer range');
  if Frac(FValue) <> 0 then
    raise EJSONException.Create('Cannot convert non-integer number to integer');
  Result := Round(FValue);
end;

function TJSONNumber.IsNumber: Boolean;
begin
  Result := True;
end;

function TJSONNumber.ToString(Pretty: Boolean = False): string;
var
  S: string;
  JSONFormat: TFormatSettings;
begin
  (* Format number according to JSON standard:
   - No special values (NaN, Infinity)
   - Use period as decimal separator
   - No trailing decimal point
   - No leading zeros
   - No plus sign
   - Scientific notation for very large/small numbers *)
  
  // Use locale-independent formatting with period as decimal separator
  JSONFormat := DefaultFormatSettings;
  JSONFormat.DecimalSeparator := '.';
  JSONFormat.ThousandSeparator := #0;
  
  S := FloatToStr(FValue, JSONFormat);
  
  // Remove trailing zeros after decimal point
  if (Pos('.', S) > 0) then
  begin
    while (Length(S) > 0) and (S[Length(S)] = '0') do
      SetLength(S, Length(S) - 1);
    if (Length(S) > 0) and (S[Length(S)] = '.') then
      SetLength(S, Length(S) - 1);
  end;
  
  Result := S;
end;

// TJSONBoolean 

constructor TJSONBoolean.Create(AValue: Boolean);
begin
  inherited Create;
  FValue := AValue;
end;

function TJSONBoolean.GetAsBoolean: Boolean;
begin
  Result := FValue;
end;

function TJSONBoolean.IsBoolean: Boolean;
begin
  Result := True;
end;

function TJSONBoolean.ToString(Pretty: Boolean): string;
begin
  if FValue then
    Result := 'true'
  else
    Result := 'false';
end;

// TJSONNull 

constructor TJSONNull.Create;
begin
  inherited Create;
end;

class function TJSONNull.Instance: TJSONNull;
begin
  if FInstance = nil then
  begin
    FInstance := TJSONNull.Create;
    // Prevent automatic cleanup of the singleton
    FInstance._AddRef;
  end;
  Result := FInstance;
end;

function TJSONNull.IsNull: Boolean;
begin
  Result := True;
end;

function TJSONNull.ToString(Pretty: Boolean): string;
begin
  Result := 'null';
end;

initialization
  TJSONNull.FInstance := nil;

finalization
  if Assigned(TJSONNull.FInstance) then
  begin
    // Release the extra reference we added
    TJSONNull.FInstance._Release;
    TJSONNull.FInstance := nil;
  end;

end. 
