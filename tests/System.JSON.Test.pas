unit System.JSON.Test;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry,
  System.JSON;

type
  { Test suite for System.JSON Delphi compatibility layer }
  TSystemJSONTest = class(TTestCase)
  published
    // Basic parsing tests (like Delphi examples)
    procedure Test01_ParseSimpleObject;
    procedure Test02_ParseSimpleArray;
    procedure Test03_ParseNestedObject;
    procedure Test04_ParseMixedArray;
    procedure Test05_ParseWithUseBool;
    procedure Test06_ParseWithRaiseException;
    procedure Test07_ParseFromBytes;
    
    // Object creation tests
    procedure Test10_CreateEmptyObject;
    procedure Test11_AddPairString;
    procedure Test12_AddPairInteger;
    procedure Test13_AddPairDouble;
    procedure Test14_AddPairBoolean;
    procedure Test15_AddPairChained;
    procedure Test16_AddPairWithTJSONPair;
    procedure Test17_CreateObjectWithPair;
    
    // Array creation tests
    procedure Test20_CreateEmptyArray;
    procedure Test21_ArrayAddString;
    procedure Test22_ArrayAddInteger;
    procedure Test23_ArrayAddDouble;
    procedure Test24_ArrayAddBoolean;
    procedure Test25_ArrayAddChained;
    procedure Test26_ArrayAddElement;
    procedure Test27_ArrayRemoveAndPop;
    
    // Value access tests
    procedure Test30_GetValueByName;
    procedure Test31_GetValueString;
    procedure Test32_GetValueInt;
    procedure Test33_GetValueInt64;
    procedure Test34_GetValueDouble;
    procedure Test35_GetValueBool;
    procedure Test36_GetValueWithDefault;
    procedure Test37_GetPairByIndex;
    procedure Test38_GetPairByName;
    
    // TryGetValue tests
    procedure Test40_TryGetValueString;
    procedure Test41_TryGetValueInt;
    procedure Test42_TryGetValueBool;
    procedure Test43_TryGetValueMissing;
    
    // Output tests
    procedure Test50_ToJSON;
    procedure Test51_ToString;
    procedure Test52_Format;
    procedure Test53_ToBytes;
    procedure Test54_EstimatedByteSize;
    
    // TJSONPair tests
    procedure Test60_PairCreate;
    procedure Test61_PairJsonString;
    procedure Test62_PairJsonValue;
    procedure Test63_PairToJSON;
    procedure Test64_PairClone;
    
    // Special value tests
    procedure Test70_TJSONNull;
    procedure Test71_TJSONTrue;
    procedure Test72_TJSONFalse;
    procedure Test73_TJSONString;
    procedure Test74_TJSONNumber;
    
    // Clone tests
    procedure Test80_CloneObject;
    procedure Test81_CloneArray;
    procedure Test82_CloneIndependence;
    
    // Enumeration tests
    procedure Test85_EnumerateObject;
    procedure Test86_EnumerateArray;
    
    // FindValue / Path tests
    procedure Test90_FindValueSimple;
    procedure Test91_FindValueNested;
    procedure Test92_FindValueMissing;
    
    // RemovePair tests
    procedure Test95_RemovePair;
    procedure Test96_RemovePairNotFound;
    
    // Real-world Delphi scenarios
    procedure Test100_DelphiStyleParsing;
    procedure Test101_DelphiStyleBuilding;
    procedure Test102_DelphiRESTResponse;
    procedure Test103_DelphiConfigFile;
  end;

implementation

{ Basic parsing tests }

procedure TSystemJSONTest.Test01_ParseSimpleObject;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.ParseJSONValue('{"name":"John","age":30}') as TJSONObject;
  try
    AssertNotNull('Object should not be nil', Obj);
    AssertEquals('Should have 2 pairs', 2, Obj.Count);
    AssertEquals('Name should be John', 'John', Obj.GetValueString('name'));
    AssertEquals('Age should be 30', 30, Obj.GetValueInt('age'));
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test02_ParseSimpleArray;
var
  Arr: TJSONArray;
begin
  Arr := TJSONValue.ParseJSONValue('[1,2,3,"four",true]') as TJSONArray;
  try
    AssertNotNull('Array should not be nil', Arr);
    AssertEquals('Should have 5 elements', 5, Arr.Count);
    AssertEquals('First should be 1', 1, TJSONNumber(Arr[0]).AsInt);
    AssertEquals('Fourth should be four', 'four', TJSONString(Arr[3]).Value);
    AssertTrue('Fifth should be true', TJSONBool(Arr[4]).AsBoolean);
  finally
    Arr.Free;
  end;
end;

procedure TSystemJSONTest.Test03_ParseNestedObject;
var
  Obj: TJSONObject;
  User: TJSONValue;
begin
  Obj := TJSONValue.ParseJSONValue('{"user":{"name":"Alice","email":"alice@test.com"}}') as TJSONObject;
  try
    User := Obj.GetValue('user');
    AssertNotNull('User should exist', User);
    AssertTrue('User should be object', User is TJSONObject);
    AssertEquals('Name should be Alice', 'Alice', TJSONObject(User).GetValueString('name'));
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test04_ParseMixedArray;
var
  Arr: TJSONArray;
begin
  Arr := TJSONValue.ParseJSONValue('[{"id":1},{"id":2},{"id":3}]') as TJSONArray;
  try
    AssertEquals('Should have 3 elements', 3, Arr.Count);
    AssertEquals('First id should be 1', 1, TJSONObject(Arr[0]).GetValueInt('id'));
    AssertEquals('Second id should be 2', 2, TJSONObject(Arr[1]).GetValueInt('id'));
  finally
    Arr.Free;
  end;
end;

procedure TSystemJSONTest.Test05_ParseWithUseBool;
var
  Value: TJSONValue;
begin
  // With UseBool = True (default), should create TJSONTrue/TJSONFalse
  Value := TJSONValue.ParseJSONValue('true', True);
  try
    AssertTrue('Should be TJSONTrue', Value is TJSONTrue);
  finally
    Value.Free;
  end;
  
  // With UseBool = False, should create TJSONBool
  Value := TJSONValue.ParseJSONValue('false', False);
  try
    AssertTrue('Should be TJSONBool', Value is TJSONBool);
    AssertFalse('Should be false', TJSONBool(Value).AsBoolean);
  finally
    Value.Free;
  end;
end;

procedure TSystemJSONTest.Test06_ParseWithRaiseException;
var
  Value: TJSONValue;
  ExceptionRaised: Boolean;
begin
  // With RaiseExc = False, should return nil for invalid JSON
  Value := TJSONValue.ParseJSONValue('invalid json', True, False);
  AssertNull('Should return nil for invalid JSON', Value);
  
  // With RaiseExc = True, should raise exception
  ExceptionRaised := False;
  try
    Value := TJSONValue.ParseJSONValue('invalid json', True, True);
    if Value <> nil then Value.Free;
  except
    on E: EJSONParseException do
      ExceptionRaised := True;
  end;
  AssertTrue('Should raise EJSONParseException', ExceptionRaised);
end;

procedure TSystemJSONTest.Test07_ParseFromBytes;
var
  Data: TBytes;
  Value: TJSONValue;
begin
  Data := TEncoding.UTF8.GetBytes('{"test":"value"}');
  Value := TJSONValue.ParseJSONValue(Data, 0, True);
  try
    AssertNotNull('Should parse from bytes', Value);
    AssertTrue('Should be object', Value is TJSONObject);
  finally
    Value.Free;
  end;
end;

{ Object creation tests }

procedure TSystemJSONTest.Test10_CreateEmptyObject;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.Create;
  try
    AssertEquals('Empty object count should be 0', 0, Obj.Count);
    AssertEquals('Empty object JSON should be {}', '{}', Obj.ToJSON);
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test11_AddPairString;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.Create;
  try
    Obj.AddPair('name', 'John');
    AssertEquals('Count should be 1', 1, Obj.Count);
    AssertEquals('Value should be John', 'John', Obj.GetValueString('name'));
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test12_AddPairInteger;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.Create;
  try
    Obj.AddPair('age', 25);
    AssertEquals('Value should be 25', 25, Obj.GetValueInt('age'));
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test13_AddPairDouble;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.Create;
  try
    Obj.AddPair('price', 19.99);
    AssertEquals('Value should be 19.99', 19.99, Obj.GetValueDouble('price'), 0.001);
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test14_AddPairBoolean;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.Create;
  try
    Obj.AddPair('active', True);
    Obj.AddPair('deleted', False);
    AssertTrue('Active should be true', Obj.GetValueBool('active'));
    AssertFalse('Deleted should be false', Obj.GetValueBool('deleted'));
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test15_AddPairChained;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.Create;
  try
    Obj.AddPair('a', 1)
       .AddPair('b', 2)
       .AddPair('c', 3);
    AssertEquals('Count should be 3', 3, Obj.Count);
    AssertEquals('a should be 1', 1, Obj.GetValueInt('a'));
    AssertEquals('b should be 2', 2, Obj.GetValueInt('b'));
    AssertEquals('c should be 3', 3, Obj.GetValueInt('c'));
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test16_AddPairWithTJSONPair;
var
  Obj: TJSONObject;
  Pair: TJSONPair;
begin
  Obj := TJSONObject.Create;
  try
    Pair := TJSONPair.Create('key', 'value');
    Obj.AddPair(Pair);
    AssertEquals('Value should be value', 'value', Obj.GetValueString('key'));
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test17_CreateObjectWithPair;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.Create('name', 'John');
  try
    AssertEquals('Count should be 1', 1, Obj.Count);
    AssertEquals('Name should be John', 'John', Obj.GetValueString('name'));
  finally
    Obj.Free;
  end;
end;

{ Array creation tests }

procedure TSystemJSONTest.Test20_CreateEmptyArray;
var
  Arr: TJSONArray;
begin
  Arr := TJSONArray.Create;
  try
    AssertEquals('Empty array count should be 0', 0, Arr.Count);
    AssertEquals('Empty array JSON should be []', '[]', Arr.ToJSON);
  finally
    Arr.Free;
  end;
end;

procedure TSystemJSONTest.Test21_ArrayAddString;
var
  Arr: TJSONArray;
begin
  Arr := TJSONArray.Create;
  try
    Arr.Add('hello');
    AssertEquals('Count should be 1', 1, Arr.Count);
    AssertEquals('Value should be hello', 'hello', TJSONString(Arr[0]).Value);
  finally
    Arr.Free;
  end;
end;

procedure TSystemJSONTest.Test22_ArrayAddInteger;
var
  Arr: TJSONArray;
begin
  Arr := TJSONArray.Create;
  try
    Arr.Add(42);
    AssertEquals('Value should be 42', 42, TJSONNumber(Arr[0]).AsInt);
  finally
    Arr.Free;
  end;
end;

procedure TSystemJSONTest.Test23_ArrayAddDouble;
var
  Arr: TJSONArray;
begin
  Arr := TJSONArray.Create;
  try
    Arr.Add(3.14);
    AssertEquals('Value should be 3.14', 3.14, TJSONNumber(Arr[0]).AsDouble, 0.001);
  finally
    Arr.Free;
  end;
end;

procedure TSystemJSONTest.Test24_ArrayAddBoolean;
var
  Arr: TJSONArray;
begin
  Arr := TJSONArray.Create;
  try
    Arr.Add(True);
    Arr.Add(False);
    AssertTrue('First should be true', TJSONBool(Arr[0]).AsBoolean);
    AssertFalse('Second should be false', TJSONBool(Arr[1]).AsBoolean);
  finally
    Arr.Free;
  end;
end;

procedure TSystemJSONTest.Test25_ArrayAddChained;
var
  Arr: TJSONArray;
begin
  Arr := TJSONArray.Create;
  try
    Arr.Add('a')
       .Add('b')
       .Add('c');
    AssertEquals('Count should be 3', 3, Arr.Count);
  finally
    Arr.Free;
  end;
end;

procedure TSystemJSONTest.Test26_ArrayAddElement;
var
  Arr: TJSONArray;
begin
  Arr := TJSONArray.Create;
  try
    Arr.AddElement(TJSONString.Create('test'));
    AssertEquals('Value should be test', 'test', TJSONString(Arr[0]).Value);
  finally
    Arr.Free;
  end;
end;

procedure TSystemJSONTest.Test27_ArrayRemoveAndPop;
var
  Arr: TJSONArray;
  Removed: TJSONValue;
begin
  Arr := TJSONArray.Create;
  try
    Arr.Add(1).Add(2).Add(3);
    AssertEquals('Count should be 3', 3, Arr.Count);
    
    // Remove by index
    Removed := Arr.Remove(0);
    try
      AssertEquals('Removed should be 1', 1, TJSONNumber(Removed).AsInt);
      AssertEquals('Count should be 2', 2, Arr.Count);
    finally
      Removed.Free;
    end;
    
    // Pop last element
    Removed := Arr.Pop;
    try
      AssertEquals('Popped should be 3', 3, TJSONNumber(Removed).AsInt);
      AssertEquals('Count should be 1', 1, Arr.Count);
    finally
      Removed.Free;
    end;
  finally
    Arr.Free;
  end;
end;

{ Value access tests }

procedure TSystemJSONTest.Test30_GetValueByName;
var
  Obj: TJSONObject;
  Value: TJSONValue;
begin
  Obj := TJSONObject.ParseJSONValue('{"name":"John"}') as TJSONObject;
  try
    Value := Obj.GetValue('name');
    AssertNotNull('Value should exist', Value);
    AssertTrue('Value should be string', Value is TJSONString);
    
    Value := Obj.GetValue('missing');
    AssertNull('Missing value should be nil', Value);
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test31_GetValueString;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.ParseJSONValue('{"name":"John"}') as TJSONObject;
  try
    AssertEquals('Name should be John', 'John', Obj.GetValueString('name'));
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test32_GetValueInt;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.ParseJSONValue('{"age":30}') as TJSONObject;
  try
    AssertEquals('Age should be 30', 30, Obj.GetValueInt('age'));
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test33_GetValueInt64;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.ParseJSONValue('{"big":9223372036854775807}') as TJSONObject;
  try
    AssertEquals('Big should be max int64', 9223372036854775807, Obj.GetValueInt64('big'));
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test34_GetValueDouble;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.ParseJSONValue('{"price":19.99}') as TJSONObject;
  try
    AssertEquals('Price should be 19.99', 19.99, Obj.GetValueDouble('price'), 0.001);
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test35_GetValueBool;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.ParseJSONValue('{"active":true,"deleted":false}') as TJSONObject;
  try
    AssertTrue('Active should be true', Obj.GetValueBool('active'));
    AssertFalse('Deleted should be false', Obj.GetValueBool('deleted'));
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test36_GetValueWithDefault;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.ParseJSONValue('{"name":"John"}') as TJSONObject;
  try
    AssertEquals('Missing string default', 'default', Obj.GetValueString('missing', 'default'));
    AssertEquals('Missing int default', -1, Obj.GetValueInt('missing', -1));
    AssertEquals('Missing double default', 0.5, Obj.GetValueDouble('missing', 0.5), 0.001);
    AssertTrue('Missing bool default', Obj.GetValueBool('missing', True));
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test37_GetPairByIndex;
var
  Obj: TJSONObject;
  Pair: TJSONPair;
begin
  Obj := TJSONObject.ParseJSONValue('{"a":1,"b":2}') as TJSONObject;
  try
    Pair := Obj.Pairs[0];
    AssertNotNull('First pair should exist', Pair);
    AssertEquals('First key should be a', 'a', Pair.JsonString.Value);
    
    Pair := Obj.Get(1);
    AssertEquals('Second key should be b', 'b', Pair.JsonString.Value);
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test38_GetPairByName;
var
  Obj: TJSONObject;
  Pair: TJSONPair;
begin
  Obj := TJSONObject.ParseJSONValue('{"name":"John","age":30}') as TJSONObject;
  try
    Pair := Obj.Get('name');
    AssertNotNull('Pair should exist', Pair);
    AssertEquals('Key should be name', 'name', Pair.JsonString.Value);
    AssertEquals('Value should be John', 'John', TJSONString(Pair.JsonValue).Value);
    
    Pair := Obj.Get('missing');
    AssertNull('Missing pair should be nil', Pair);
  finally
    Obj.Free;
  end;
end;

{ TryGetValue tests }

procedure TSystemJSONTest.Test40_TryGetValueString;
var
  Obj: TJSONObject;
  S: string;
begin
  Obj := TJSONObject.ParseJSONValue('{"name":"John"}') as TJSONObject;
  try
    AssertTrue('TryGetValue should succeed', Obj.TryGetValueString('name', S));
    AssertEquals('Value should be John', 'John', S);
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test41_TryGetValueInt;
var
  Obj: TJSONObject;
  I: Integer;
begin
  Obj := TJSONObject.ParseJSONValue('{"age":30}') as TJSONObject;
  try
    AssertTrue('TryGetValue should succeed', Obj.TryGetValueInt('age', I));
    AssertEquals('Value should be 30', 30, I);
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test42_TryGetValueBool;
var
  Obj: TJSONObject;
  B: Boolean;
begin
  Obj := TJSONObject.ParseJSONValue('{"active":true}') as TJSONObject;
  try
    AssertTrue('TryGetValue should succeed', Obj.TryGetValueBool('active', B));
    AssertTrue('Value should be true', B);
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test43_TryGetValueMissing;
var
  Obj: TJSONObject;
  S: string;
begin
  Obj := TJSONObject.ParseJSONValue('{"name":"John"}') as TJSONObject;
  try
    AssertFalse('TryGetValue should fail for missing', Obj.TryGetValueString('missing', S));
  finally
    Obj.Free;
  end;
end;

{ Output tests }

procedure TSystemJSONTest.Test50_ToJSON;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.Create;
  try
    Obj.AddPair('name', 'John').AddPair('age', 30);
    AssertEquals('ToJSON output', '{"name":"John","age":30}', Obj.ToJSON);
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test51_ToString;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.Create;
  try
    Obj.AddPair('test', 'value');
    AssertEquals('ToString should equal ToJSON', Obj.ToJSON, Obj.ToString);
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test52_Format;
var
  Obj: TJSONObject;
  Formatted: string;
begin
  Obj := TJSONObject.Create;
  try
    Obj.AddPair('name', 'John');
    Formatted := Obj.Format(2);
    AssertTrue('Should contain newline', Pos(LineEnding, Formatted) > 0);
    AssertTrue('Should contain indentation', Pos('  ', Formatted) > 0);
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test53_ToBytes;
var
  Obj: TJSONObject;
  Bytes: TBytes;
begin
  Obj := TJSONObject.Create;
  try
    Obj.AddPair('test', 'value');
    Bytes := Obj.ToBytes;
    AssertTrue('Should have bytes', Length(Bytes) > 0);
    AssertEquals('Bytes should match JSON', Obj.ToJSON, TEncoding.UTF8.GetString(Bytes));
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test54_EstimatedByteSize;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.Create;
  try
    Obj.AddPair('test', 'value');
    AssertTrue('EstimatedByteSize should be > 0', Obj.EstimatedByteSize > 0);
  finally
    Obj.Free;
  end;
end;

{ TJSONPair tests }

procedure TSystemJSONTest.Test60_PairCreate;
var
  Pair: TJSONPair;
begin
  Pair := TJSONPair.Create('key', 'value');
  try
    AssertNotNull('Pair should not be nil', Pair);
    AssertEquals('Key should be key', 'key', Pair.JsonString.Value);
  finally
    Pair.Free;
  end;
end;

procedure TSystemJSONTest.Test61_PairJsonString;
var
  Pair: TJSONPair;
begin
  Pair := TJSONPair.Create('mykey', 'myvalue');
  try
    AssertNotNull('JsonString should exist', Pair.JsonString);
    AssertEquals('JsonString value', 'mykey', Pair.JsonString.Value);
  finally
    Pair.Free;
  end;
end;

procedure TSystemJSONTest.Test62_PairJsonValue;
var
  Pair: TJSONPair;
begin
  Pair := TJSONPair.Create('key', TJSONNumber.Create(42));
  try
    AssertNotNull('JsonValue should exist', Pair.JsonValue);
    AssertTrue('JsonValue should be number', Pair.JsonValue is TJSONNumber);
    AssertEquals('JsonValue should be 42', 42, TJSONNumber(Pair.JsonValue).AsInt);
  finally
    Pair.Free;
  end;
end;

procedure TSystemJSONTest.Test63_PairToJSON;
var
  Pair: TJSONPair;
begin
  Pair := TJSONPair.Create('name', 'John');
  try
    AssertEquals('ToJSON output', '"name":"John"', Pair.ToJSON);
  finally
    Pair.Free;
  end;
end;

procedure TSystemJSONTest.Test64_PairClone;
var
  Original, Cloned: TJSONPair;
begin
  Original := TJSONPair.Create('key', 'value');
  try
    Cloned := Original.Clone;
    try
      AssertEquals('Cloned key should match', Original.JsonString.Value, Cloned.JsonString.Value);
      AssertEquals('Cloned value should match', 
        TJSONString(Original.JsonValue).Value, 
        TJSONString(Cloned.JsonValue).Value);
    finally
      Cloned.Free;
    end;
  finally
    Original.Free;
  end;
end;

{ Special value tests }

procedure TSystemJSONTest.Test70_TJSONNull;
var
  N: TJSONNull;
begin
  N := TJSONNull.Create;
  try
    AssertTrue('Should be null', N.Null);
    AssertEquals('Value should be null', 'null', N.Value);
    AssertEquals('ToJSON should be null', 'null', N.ToJSON);
  finally
    N.Free;
  end;
end;

procedure TSystemJSONTest.Test71_TJSONTrue;
var
  T: TJSONTrue;
begin
  T := TJSONTrue.Create;
  try
    AssertTrue('Should be boolean', T is TJSONBool);
    AssertTrue('AsBoolean should be true', T.AsBoolean);
    AssertEquals('ToJSON should be true', 'true', T.ToJSON);
  finally
    T.Free;
  end;
end;

procedure TSystemJSONTest.Test72_TJSONFalse;
var
  F: TJSONFalse;
begin
  F := TJSONFalse.Create;
  try
    AssertTrue('Should be boolean', F is TJSONBool);
    AssertFalse('AsBoolean should be false', F.AsBoolean);
    AssertEquals('ToJSON should be false', 'false', F.ToJSON);
  finally
    F.Free;
  end;
end;

procedure TSystemJSONTest.Test73_TJSONString;
var
  S: TJSONString;
begin
  S := TJSONString.Create('hello world');
  try
    AssertEquals('Value should match', 'hello world', S.Value);
    AssertEquals('ToJSON should be quoted', '"hello world"', S.ToJSON);
  finally
    S.Free;
  end;
end;

procedure TSystemJSONTest.Test74_TJSONNumber;
var
  N: TJSONNumber;
begin
  N := TJSONNumber.Create(42);
  try
    AssertEquals('AsInt should be 42', 42, N.AsInt);
    AssertEquals('AsDouble should be 42.0', 42.0, N.AsDouble, 0.001);
    AssertEquals('ToJSON should be 42', '42', N.ToJSON);
  finally
    N.Free;
  end;
  
  N := TJSONNumber.Create(3.14);
  try
    AssertEquals('AsDouble should be 3.14', 3.14, N.AsDouble, 0.001);
  finally
    N.Free;
  end;
end;

{ Clone tests }

procedure TSystemJSONTest.Test80_CloneObject;
var
  Original, Cloned: TJSONObject;
begin
  Original := TJSONObject.Create;
  try
    Original.AddPair('name', 'John').AddPair('age', 30);
    Cloned := Original.Clone as TJSONObject;
    try
      AssertEquals('Cloned count should match', Original.Count, Cloned.Count);
      AssertEquals('Cloned JSON should match', Original.ToJSON, Cloned.ToJSON);
    finally
      Cloned.Free;
    end;
  finally
    Original.Free;
  end;
end;

procedure TSystemJSONTest.Test81_CloneArray;
var
  Original, Cloned: TJSONArray;
begin
  Original := TJSONArray.Create;
  try
    Original.Add(1).Add(2).Add(3);
    Cloned := Original.Clone as TJSONArray;
    try
      AssertEquals('Cloned count should match', Original.Count, Cloned.Count);
      AssertEquals('Cloned JSON should match', Original.ToJSON, Cloned.ToJSON);
    finally
      Cloned.Free;
    end;
  finally
    Original.Free;
  end;
end;

procedure TSystemJSONTest.Test82_CloneIndependence;
var
  Original, Cloned: TJSONObject;
begin
  Original := TJSONObject.Create;
  try
    Original.AddPair('name', 'Original');
    Cloned := Original.Clone as TJSONObject;
    try
      Cloned.AddPair('extra', 'data');
      AssertEquals('Original should have 1 pair', 1, Original.Count);
      AssertEquals('Cloned should have 2 pairs', 2, Cloned.Count);
    finally
      Cloned.Free;
    end;
  finally
    Original.Free;
  end;
end;

{ Enumeration tests }

procedure TSystemJSONTest.Test85_EnumerateObject;
var
  Obj: TJSONObject;
  Pair: TJSONPair;
  Keys: string;
begin
  Obj := TJSONObject.ParseJSONValue('{"a":1,"b":2,"c":3}') as TJSONObject;
  try
    Keys := '';
    for Pair in Obj do
      Keys := Keys + Pair.JsonString.Value;
    AssertEquals('Should enumerate all keys', 'abc', Keys);
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test86_EnumerateArray;
var
  Arr: TJSONArray;
  Value: TJSONValue;
  Sum: Integer;
begin
  Arr := TJSONArray.Create;
  try
    Arr.Add(1).Add(2).Add(3);
    Sum := 0;
    for Value in Arr do
      Sum := Sum + TJSONNumber(Value).AsInt;
    AssertEquals('Sum should be 6', 6, Sum);
  finally
    Arr.Free;
  end;
end;

{ FindValue / Path tests }

procedure TSystemJSONTest.Test90_FindValueSimple;
var
  Obj: TJSONObject;
  Value: TJSONValue;
begin
  Obj := TJSONObject.ParseJSONValue('{"name":"John"}') as TJSONObject;
  try
    Value := Obj.FindValue('name');
    AssertNotNull('Should find value', Value);
    AssertEquals('Value should be John', 'John', TJSONString(Value).Value);
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test91_FindValueNested;
var
  Obj: TJSONObject;
  Value: TJSONValue;
begin
  Obj := TJSONObject.ParseJSONValue('{"user":{"name":"John","address":{"city":"NYC"}}}') as TJSONObject;
  try
    Value := Obj.FindValue('user.name');
    AssertNotNull('Should find nested value', Value);
    AssertEquals('Value should be John', 'John', TJSONString(Value).Value);
    
    Value := Obj.FindValue('user.address.city');
    AssertNotNull('Should find deep nested value', Value);
    AssertEquals('Value should be NYC', 'NYC', TJSONString(Value).Value);
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test92_FindValueMissing;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.ParseJSONValue('{"name":"John"}') as TJSONObject;
  try
    AssertNull('Should not find missing path', Obj.FindValue('missing'));
    AssertNull('Should not find nested missing path', Obj.FindValue('user.name'));
  finally
    Obj.Free;
  end;
end;

{ RemovePair tests }

procedure TSystemJSONTest.Test95_RemovePair;
var
  Obj: TJSONObject;
  Removed: TJSONPair;
begin
  Obj := TJSONObject.ParseJSONValue('{"a":1,"b":2,"c":3}') as TJSONObject;
  try
    AssertEquals('Should have 3 pairs', 3, Obj.Count);
    
    Removed := Obj.RemovePair('b');
    try
      AssertNotNull('Should return removed pair', Removed);
      AssertEquals('Removed key should be b', 'b', Removed.JsonString.Value);
      AssertEquals('Should have 2 pairs', 2, Obj.Count);
      AssertNull('b should no longer exist', Obj.GetValue('b'));
    finally
      Removed.Free;
    end;
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test96_RemovePairNotFound;
var
  Obj: TJSONObject;
  Removed: TJSONPair;
begin
  Obj := TJSONObject.ParseJSONValue('{"a":1}') as TJSONObject;
  try
    Removed := Obj.RemovePair('missing');
    AssertNull('Should return nil for missing pair', Removed);
    AssertEquals('Count should not change', 1, Obj.Count);
  finally
    Obj.Free;
  end;
end;

{ Real-world Delphi scenarios }

procedure TSystemJSONTest.Test100_DelphiStyleParsing;
var
  S: string;
  Obj: TJSONObject;
begin
  // This is exactly how Delphi developers would parse JSON
  S := '{"sid": "1234567890ABCDEF", "status": "queued"}';
  Obj := TJSONObject.ParseJSONValue(S) as TJSONObject;
  try
    // In Delphi: Obj.GetValue<string>('sid')
    // In FPC:   Obj.GetValueString('sid')
    AssertEquals('SID should match', '1234567890ABCDEF', Obj.GetValueString('sid'));
    AssertEquals('Status should match', 'queued', Obj.GetValueString('status'));
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test101_DelphiStyleBuilding;
var
  Obj: TJSONObject;
begin
  // This is exactly how Delphi developers would build JSON
  Obj := TJSONObject.Create;
  try
    Obj.AddPair('name', 'John Doe')
       .AddPair('email', 'john@example.com')
       .AddPair('age', 30)
       .AddPair('active', True);
       
    AssertTrue('Should contain name', Pos('"name"', Obj.ToJSON) > 0);
    AssertTrue('Should contain email', Pos('"email"', Obj.ToJSON) > 0);
    AssertTrue('Should contain age', Pos('"age":30', Obj.ToJSON) > 0);
    AssertTrue('Should contain active', Pos('"active":true', Obj.ToJSON) > 0);
  finally
    Obj.Free;
  end;
end;

procedure TSystemJSONTest.Test102_DelphiRESTResponse;
var
  Response: string;
  Root: TJSONObject;
  Data: TJSONArray;
  Item: TJSONObject;
begin
  // Simulating a typical REST API response
  Response := '{"success":true,"data":[{"id":1,"name":"Item 1"},{"id":2,"name":"Item 2"}],"total":2}';
  
  Root := TJSONObject.ParseJSONValue(Response) as TJSONObject;
  try
    // Check success flag
    AssertTrue('Success should be true', Root.GetValueBool('success'));
    
    // Get array of items
    Data := Root.GetValue('data') as TJSONArray;
    AssertNotNull('Data array should exist', Data);
    AssertEquals('Should have 2 items', 2, Data.Count);
    
    // Access first item
    Item := Data[0] as TJSONObject;
    AssertEquals('First item id should be 1', 1, Item.GetValueInt('id'));
    AssertEquals('First item name should be Item 1', 'Item 1', Item.GetValueString('name'));
    
    // Check total
    AssertEquals('Total should be 2', 2, Root.GetValueInt('total'));
  finally
    Root.Free;
  end;
end;

procedure TSystemJSONTest.Test103_DelphiConfigFile;
var
  Config: TJSONObject;
  Database, Server: TJSONObject;
begin
  // Building a typical config structure
  Config := TJSONObject.Create;
  try
    // Database section
    Database := TJSONObject.Create;
    Database.AddPair('host', 'localhost')
            .AddPair('port', 5432)
            .AddPair('name', 'mydb')
            .AddPair('poolSize', 10);
    Config.AddPair('database', Database);
    
    // Server section
    Server := TJSONObject.Create;
    Server.AddPair('host', '0.0.0.0')
          .AddPair('port', 8080)
          .AddPair('ssl', True);
    Config.AddPair('server', Server);
    
    // Verify structure
    AssertEquals('Database host', 'localhost', 
      (Config.GetValue('database') as TJSONObject).GetValueString('host'));
    AssertEquals('Server port', 8080,
      (Config.GetValue('server') as TJSONObject).GetValueInt('port'));
    AssertTrue('Server SSL', 
      (Config.GetValue('server') as TJSONObject).GetValueBool('ssl'));
      
    // Test formatted output contains expected structure
    AssertTrue('Should have database section', Pos('"database"', Config.Format) > 0);
    AssertTrue('Should have server section', Pos('"server"', Config.Format) > 0);
  finally
    Config.Free;
  end;
end;

initialization
  RegisterTest(TSystemJSONTest);
  
end.
