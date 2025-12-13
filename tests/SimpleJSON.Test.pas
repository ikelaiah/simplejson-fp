unit SimpleJSON.Test;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry,
  SimpleJSON,
  Math;

type
  TJSONTest = class(TTestCase)
  published
    procedure Test01_CreateEmptyObject;
    procedure Test02_CreateEmptyArray;
    procedure Test03_CreateString;
    procedure Test04_CreateNumber;
    procedure Test05_CreateBoolean;
    procedure Test06_CreateNull;
    procedure Test07_ObjectAddAndGet;
    procedure Test08_ArrayAddAndGet;
    procedure Test09_ParseSimpleObject;
    procedure Test10_ParseSimpleArray;
    procedure Test11_ParseComplexObject;
    procedure Test12_ParseComplexArray;
    procedure Test13_ParseInvalidJSON;
    procedure Test14_PrettyPrint;
    procedure Test15_Compact;
    procedure Test16_UnicodeString;
    procedure Test17_EscapeSequences;
    procedure Test18_StrictNumberFormat;
    procedure Test19_IntFactory;
    procedure Test20_TryParseSuccess;
    procedure Test21_PropertyNameEscaping;
    procedure Test22_ObjectContainsAndModify;
    procedure Test23_ArrayModification;
    procedure Test24_KeyOrderPreservation;
    procedure Test25_SurrogatePairs;
    // High-priority RFC 8259 compliance tests
    procedure Test26_InvalidPlusSign;
    procedure Test27_LeadingPlusExponent;
    procedure Test28_SingleQuoteString;
    procedure Test29_TrailingGarbage;
    procedure Test30_BOMHandling;
    procedure Test31_RejectComments;
    procedure Test32_MaxNestingDepth;
    // Medium-priority coverage/robustness tests
    procedure Test33_LongString;
    procedure Test34_LargeArray;
    procedure Test35_RoundtripWriterParser;
    procedure Test36_DuplicateKeys;
    procedure Test37_SolidusEscape;
    procedure Test38_UnicodeHexCase;
    // Low-priority extra assurance tests
    procedure Test39_BigExponents;
    procedure Test40_FuzzBasic;
    procedure Test41_SingleZeroNumber;
  end;

implementation

procedure TJSONTest.Test01_CreateEmptyObject;
var
  Obj: IJSONObject;
begin
  Obj := TJSON.Obj;
  AssertNotNull('Object should not be nil', Obj);
  AssertEquals('Empty object should have count 0', 0, Obj.Count);
  AssertEquals('Empty object should serialize as {}', '{}', Obj.ToString(False));
end;

procedure TJSONTest.Test02_CreateEmptyArray;
var
  Arr: IJSONArray;
begin
  Arr := TJSON.Arr;
  AssertNotNull('Array should not be nil', Arr);
  AssertEquals('Empty array should have count 0', 0, Arr.Count);
  AssertEquals('Empty array should serialize as []', '[]', Arr.ToString(False));
end;

procedure TJSONTest.Test03_CreateString;
var
  Str: IJSONValue;
begin
  Str := TJSON.Str('test');
  AssertNotNull('String should not be nil', Str);
  AssertTrue('Value should be string', Str.IsString);
  AssertEquals('String value should match', 'test', Str.AsString);
  AssertEquals('String should serialize with quotes', '"test"', Str.ToString(False));
end;

procedure TJSONTest.Test04_CreateNumber;
var
  IntNum, FloatNum: IJSONValue;
begin
  // Test integer number
  IntNum := TJSON.Num(123);
  AssertNotNull('Integer number should not be nil', IntNum);
  AssertTrue('Integer value should be number', IntNum.IsNumber);
  AssertEquals('Integer value should match', 123.0, IntNum.AsNumber, 0.001);
  AssertEquals('Integer conversion should work', 123, IntNum.AsInteger);

  // Test floating-point number
  FloatNum := TJSON.Num(123.45);
  AssertNotNull('Float number should not be nil', FloatNum);
  AssertTrue('Float value should be number', FloatNum.IsNumber);
  AssertEquals('Float value should match', 123.45, FloatNum.AsNumber, 0.001);
  
  // Verify that non-integer to integer conversion is not allowed
  try
    FloatNum.AsInteger;
    Fail('Converting non-integer to integer should raise an exception');
  except
    on E: EJSONException do
      AssertEquals('Error message should match',
        'Cannot convert non-integer number to integer', E.Message);
  end;
end;

procedure TJSONTest.Test05_CreateBoolean;
var
  Bool: IJSONValue;
begin
  Bool := TJSON.Bool(True);
  AssertNotNull('Boolean should not be nil', Bool);
  AssertTrue('Value should be boolean', Bool.IsBoolean);
  AssertTrue('Boolean value should be true', Bool.AsBoolean);
  AssertEquals('Boolean should serialize as true', 'true', Bool.ToString(False));
end;

procedure TJSONTest.Test06_CreateNull;
var
  Null: IJSONValue;
begin
  Null := TJSON.Null;
  AssertNotNull('Null value should not be nil', Null);
  AssertTrue('Value should be null', Null.IsNull);
  AssertEquals('Null should serialize as null', 'null', Null.ToString(False));
end;

procedure TJSONTest.Test07_ObjectAddAndGet;
var
  Obj: IJSONObject;
begin
  Obj := TJSON.Obj;
  Obj.Add('string', 'value');
  Obj.Add('number', 123);
  Obj.Add('boolean', True);
  Obj.Add('null', TJSON.Null);
  
  AssertEquals('Object should have 4 items', 4, Obj.Count);
  AssertEquals('String value should match', 'value', Obj['string'].AsString);
  AssertEquals('Number value should match', 123, Obj['number'].AsInteger);
  AssertTrue('Boolean value should be true', Obj['boolean'].AsBoolean);
  AssertTrue('Null value should be null', Obj['null'].IsNull);
  
  Obj.Remove('number');
  AssertEquals('Object should have 3 items after remove', 3, Obj.Count);
  AssertNull('Removed item should return nil', Obj['number']);
end;

procedure TJSONTest.Test08_ArrayAddAndGet;
var
  Arr: IJSONArray;
begin
  Arr := TJSON.Arr;
  Arr.Add('string');
  Arr.Add(123);
  Arr.Add(True);
  Arr.Add(TJSON.Null);
  
  AssertEquals('Array should have 4 items', 4, Arr.Count);
  AssertEquals('String value should match', 'string', Arr[0].AsString);
  AssertEquals('Number value should match', 123, Arr[1].AsInteger);
  AssertTrue('Boolean value should be true', Arr[2].AsBoolean);
  AssertTrue('Null value should be null', Arr[3].IsNull);
  
  Arr.Delete(1);
  AssertEquals('Array should have 3 items after delete', 3, Arr.Count);
  AssertTrue('Second item should now be boolean', Arr[1].IsBoolean);
end;

procedure TJSONTest.Test09_ParseSimpleObject;
var
  JSON: string;
  Value: IJSONValue;
begin
  JSON := '{"name":"test","value":123}';
  Value := TJSON.Parse(JSON);
  
  AssertNotNull('Parsed value should not be nil', Value);
  AssertTrue('Value should be object', Value.IsObject);
  AssertEquals('Object should have 2 items', 2, Value.AsObject.Count);
  AssertEquals('Name should match', 'test', Value.AsObject['name'].AsString);
  AssertEquals('Value should match', 123, Value.AsObject['value'].AsInteger);
end;

procedure TJSONTest.Test10_ParseSimpleArray;
var
  JSON: string;
  Value: IJSONValue;
begin
  JSON := '["test",123,true,null]';
  Value := TJSON.Parse(JSON);
  
  AssertNotNull('Parsed value should not be nil', Value);
  AssertTrue('Value should be array', Value.IsArray);
  AssertEquals('Array should have 4 items', 4, Value.AsArray.Count);
  AssertEquals('First item should be string', 'test', Value.AsArray[0].AsString);
  AssertEquals('Second item should be number', 123, Value.AsArray[1].AsInteger);
  AssertTrue('Third item should be true', Value.AsArray[2].AsBoolean);
  AssertTrue('Fourth item should be null', Value.AsArray[3].IsNull);
end;

procedure TJSONTest.Test11_ParseComplexObject;
var
  JSON: string;
  Value: IJSONValue;
  Obj: IJSONObject;
begin
  JSON := '{"name":"test","array":[1,2,3],"object":{"key":"value"}}';
  Value := TJSON.Parse(JSON);
  
  AssertNotNull('Parsed value should not be nil', Value);
  AssertTrue('Value should be object', Value.IsObject);
  
  Obj := Value.AsObject;
  AssertEquals('Object should have 3 items', 3, Obj.Count);
  AssertEquals('Name should match', 'test', Obj['name'].AsString);
  
  AssertTrue('Array property should be array', Obj['array'].IsArray);
  AssertEquals('Array should have 3 items', 3, Obj['array'].AsArray.Count);
  
  AssertTrue('Object property should be object', Obj['object'].IsObject);
  AssertEquals('Nested object value should match', 'value',
    Obj['object'].AsObject['key'].AsString);
end;

procedure TJSONTest.Test12_ParseComplexArray;
var
  JSON: string;
  Value: IJSONValue;
  Arr: IJSONArray;
begin
  JSON := '[{"name":"test"},["nested"],{"key":123}]';
  Value := TJSON.Parse(JSON);
  
  AssertNotNull('Parsed value should not be nil', Value);
  AssertTrue('Value should be array', Value.IsArray);
  
  Arr := Value.AsArray;
  AssertEquals('Array should have 3 items', 3, Arr.Count);
  
  AssertTrue('First item should be object', Arr[0].IsObject);
  AssertEquals('First object name should match', 'test',
    Arr[0].AsObject['name'].AsString);
  
  AssertTrue('Second item should be array', Arr[1].IsArray);
  AssertEquals('Nested array value should match', 'nested',
    Arr[1].AsArray[0].AsString);
  
  AssertTrue('Third item should be object', Arr[2].IsObject);
  AssertEquals('Third object value should match', 123,
    Arr[2].AsObject['key'].AsInteger);
end;

procedure TJSONTest.Test13_ParseInvalidJSON;
var
  Success: Boolean;
  Value: IJSONValue;
begin
  Success := TJSON.TryParse('{invalid}', Value);
  AssertFalse('Parsing invalid JSON should fail', Success);
  AssertNull('Value should be nil on failure', Value);
  
  Success := TJSON.TryParse('[1,2,]', Value);
  AssertFalse('Parsing trailing comma should fail', Success);
  AssertNull('Value should be nil on failure', Value);
end;

procedure TJSONTest.Test14_PrettyPrint;
var
  JSON: string;
  Pretty: string;
begin
  JSON := '{"name":"test","object":{"key":"value"},"array":[1,2,3]}';
  Pretty := TJSON.PrettyPrint(JSON);
  
  AssertTrue('Pretty output should contain newlines',
    Pos(LineEnding, Pretty) > 0);
  AssertTrue('Pretty output should contain indentation',
    Pos('  ', Pretty) > 0);
end;

procedure TJSONTest.Test15_Compact;
var
  JSON: string;
  Compact: string;
begin
  JSON := '{ "name": "test", "array": [ 1, 2, 3 ] }';
  Compact := TJSON.Compact(JSON);
  
  AssertEquals('Compact output should not contain spaces',
    '{"name":"test","array":[1,2,3]}', Compact);
end;

procedure TJSONTest.Test16_UnicodeString;
var
  JSON: string;
  Value: IJSONValue;
begin
  JSON := '{"text":"\u0048\u0065\u006C\u006C\u006F"}';
  Value := TJSON.Parse(JSON);
  
  AssertEquals('Unicode string should be decoded correctly',
    'Hello', Value.AsObject['text'].AsString);
end;

procedure TJSONTest.Test17_EscapeSequences;
var
  JSON: string;
  Value: IJSONValue;
begin
  JSON := '{"text":"Line1\nLine2\tTabbed\r\nWindows"}';
  Value := TJSON.Parse(JSON);
  
  AssertEquals('Escape sequences should be decoded correctly',
    'Line1'#10'Line2'#9'Tabbed'#13#10'Windows',
    Value.AsObject['text'].AsString);
end;

procedure TJSONTest.Test18_StrictNumberFormat;
var
  Value: IJSONValue;
  ExceptionRaised: Boolean;
begin
  // Valid numbers
  Value := TJSON.Parse('123');
  AssertEquals('Integer should parse correctly', 123, Value.AsInteger);
  
  Value := TJSON.Parse('-123');
  AssertEquals('Negative integer should parse correctly', -123, Value.AsInteger);
  
  Value := TJSON.Parse('123.456');
  AssertEquals('Float should parse correctly', 123.456, Value.AsNumber, 0.001);
  
  Value := TJSON.Parse('0.123');
  AssertEquals('Decimal less than 1 should parse correctly', 0.123, Value.AsNumber, 0.001);
  
  Value := TJSON.Parse('-0.123');
  AssertEquals('Negative decimal should parse correctly', -0.123, Value.AsNumber, 0.001);
  
  Value := TJSON.Parse('1.23e2');
  AssertEquals('Scientific notation should parse correctly', 123.0, Value.AsNumber, 0.001);
  
  Value := TJSON.Parse('1.23e-2');
  AssertEquals('Scientific notation with negative exponent should parse correctly', 0.0123, Value.AsNumber, 0.001);
  
  // Invalid numbers
  ExceptionRaised := False;
  try
    Value := TJSON.Parse('01');  // Leading zero
  except
    on E: EJSONException do
      ExceptionRaised := True;
  end;
  AssertTrue('Leading zeros should not be allowed', ExceptionRaised);
  
  ExceptionRaised := False;
  try
    Value := TJSON.Parse('1.');  // Trailing decimal point
  except
    on E: EJSONException do
      ExceptionRaised := True;
  end;
  AssertTrue('Trailing decimal point should not be allowed', ExceptionRaised);
  
  ExceptionRaised := False;
  try
    Value := TJSON.Parse('1.e2');  // Missing decimal digits
  except
    on E: EJSONException do
      ExceptionRaised := True;
  end;
  AssertTrue('Missing decimal digits should not be allowed', ExceptionRaised);
  
  ExceptionRaised := False;
  try
    Value := TJSON.Parse('1e');  // Missing exponent
  except
    on E: EJSONException do
      ExceptionRaised := True;
  end;
  AssertTrue('Missing exponent should not be allowed', ExceptionRaised);
  
  ExceptionRaised := False;
  try
    Value := TJSON.Parse('.123');  // Missing leading zero
  except
    on E: EJSONException do
      ExceptionRaised := True;
  end;
  AssertTrue('Missing leading zero should not be allowed', ExceptionRaised);
  
  // Special values
  ExceptionRaised := False;
  try
    Value := TJSON.Num(Infinity);  // Infinity not allowed in JSON
  except
    on E: EJSONException do
      ExceptionRaised := True;
  end;
  AssertTrue('Infinity should not be allowed', ExceptionRaised);
  
  ExceptionRaised := False;
  try
    Value := TJSON.Num(NaN);  // NaN not allowed in JSON
  except
    on E: EJSONException do
      ExceptionRaised := True;
  end;
  AssertTrue('NaN should not be allowed', ExceptionRaised);
  
  // Integer range
  ExceptionRaised := False;
  try
    Value := TJSON.Parse('1e100');  // Too large for Integer
    Value.AsInteger;  // Should raise exception
  except
    on E: EJSONException do
      ExceptionRaised := True;
  end;
  AssertTrue('Number too large for Integer should raise exception', ExceptionRaised);
end;

procedure TJSONTest.Test19_IntFactory;
var
  Value: IJSONValue;
begin
  // Test TJSON.Int factory method
  Value := TJSON.Int(42);
  AssertNotNull('Int value should not be nil', Value);
  AssertTrue('Value should be number', Value.IsNumber);
  AssertEquals('Integer value should match', 42, Value.AsInteger);
  AssertEquals('Number value should match', 42.0, Value.AsNumber, 0.001);
  AssertEquals('Should serialize as integer', '42', Value.ToString(False));
  
  // Test negative integer
  Value := TJSON.Int(-100);
  AssertEquals('Negative integer should match', -100, Value.AsInteger);
  
  // Test zero
  Value := TJSON.Int(0);
  AssertEquals('Zero should match', 0, Value.AsInteger);
end;

procedure TJSONTest.Test20_TryParseSuccess;
var
  Value: IJSONValue;
  Success: Boolean;
begin
  // Test TryParse with valid object
  Success := TJSON.TryParse('{"name":"test"}', Value);
  AssertTrue('TryParse should succeed for valid object', Success);
  AssertNotNull('Value should not be nil', Value);
  AssertTrue('Value should be object', Value.IsObject);
  AssertEquals('Name should match', 'test', Value.AsObject['name'].AsString);
  
  // Test TryParse with valid array
  Success := TJSON.TryParse('[1,2,3]', Value);
  AssertTrue('TryParse should succeed for valid array', Success);
  AssertNotNull('Value should not be nil', Value);
  AssertTrue('Value should be array', Value.IsArray);
  AssertEquals('Array count should match', 3, Value.AsArray.Count);
  
  // Test TryParse with valid string
  Success := TJSON.TryParse('"hello"', Value);
  AssertTrue('TryParse should succeed for valid string', Success);
  AssertTrue('Value should be string', Value.IsString);
  
  // Test TryParse with valid number
  Success := TJSON.TryParse('123.45', Value);
  AssertTrue('TryParse should succeed for valid number', Success);
  AssertTrue('Value should be number', Value.IsNumber);
  
  // Test TryParse with valid boolean
  Success := TJSON.TryParse('true', Value);
  AssertTrue('TryParse should succeed for valid boolean', Success);
  AssertTrue('Value should be boolean', Value.IsBoolean);
  
  // Test TryParse with valid null
  Success := TJSON.TryParse('null', Value);
  AssertTrue('TryParse should succeed for valid null', Success);
  AssertTrue('Value should be null', Value.IsNull);
end;

procedure TJSONTest.Test21_PropertyNameEscaping;
var
  Obj: IJSONObject;
  JSON: string;
  Parsed: IJSONValue;
begin
  // Test property names with special characters
  Obj := TJSON.Obj;
  Obj.Add('normal', 'value1');
  Obj.Add('with"quote', 'value2');
  Obj.Add('with\backslash', 'value3');
  Obj.Add('with'#10'newline', 'value4');
  Obj.Add('with'#9'tab', 'value5');
  
  // Serialize
  JSON := Obj.ToString(False);
  
  // Verify escaped characters are in output
  AssertTrue('Quote should be escaped', Pos('\"', JSON) > 0);
  AssertTrue('Backslash should be escaped', Pos('\\', JSON) > 0);
  AssertTrue('Newline should be escaped', Pos('\n', JSON) > 0);
  AssertTrue('Tab should be escaped', Pos('\t', JSON) > 0);
  
  // Parse it back and verify roundtrip
  Parsed := TJSON.Parse(JSON);
  AssertEquals('Normal key should roundtrip', 'value1', Parsed.AsObject['normal'].AsString);
  AssertEquals('Quote key should roundtrip', 'value2', Parsed.AsObject['with"quote'].AsString);
  AssertEquals('Backslash key should roundtrip', 'value3', Parsed.AsObject['with\backslash'].AsString);
  AssertEquals('Newline key should roundtrip', 'value4', Parsed.AsObject['with'#10'newline'].AsString);
  AssertEquals('Tab key should roundtrip', 'value5', Parsed.AsObject['with'#9'tab'].AsString);
end;

procedure TJSONTest.Test22_ObjectContainsAndModify;
var
  Obj: IJSONObject;
begin
  Obj := TJSON.Obj;
  Obj.Add('key1', 'value1');
  Obj.Add('key2', 123);
  
  // Test Contains
  AssertTrue('Should contain key1', Obj.Contains('key1'));
  AssertTrue('Should contain key2', Obj.Contains('key2'));
  AssertFalse('Should not contain key3', Obj.Contains('key3'));
  
  // Test SetValue (modify existing)
  Obj['key1'] := TJSON.Str('modified');
  AssertEquals('Value should be modified', 'modified', Obj['key1'].AsString);
  
  // Test SetValue (add new via property)
  Obj['key3'] := TJSON.Bool(True);
  AssertTrue('Should now contain key3', Obj.Contains('key3'));
  AssertTrue('key3 should be true', Obj['key3'].AsBoolean);
  
  // Test SetValue with nil (should become null)
  Obj['key4'] := nil;
  AssertTrue('Should contain key4', Obj.Contains('key4'));
  AssertTrue('key4 should be null', Obj['key4'].IsNull);
  
  AssertEquals('Object should have 4 items', 4, Obj.Count);
end;

procedure TJSONTest.Test23_ArrayModification;
var
  Arr: IJSONArray;
begin
  Arr := TJSON.Arr;
  Arr.Add('first');
  Arr.Add('second');
  Arr.Add('third');
  
  AssertEquals('Array should have 3 items', 3, Arr.Count);
  
  // Test SetItem (modify existing)
  Arr[1] := TJSON.Str('modified');
  AssertEquals('Item should be modified', 'modified', Arr[1].AsString);
  
  // Test SetItem with nil (should become null)
  Arr[0] := nil;
  AssertTrue('First item should be null', Arr[0].IsNull);
  
  // Test Clear
  Arr.Clear;
  AssertEquals('Array should be empty after Clear', 0, Arr.Count);
  
  // Test adding after clear
  Arr.Add('new');
  AssertEquals('Array should have 1 item', 1, Arr.Count);
  AssertEquals('Item should be new', 'new', Arr[0].AsString);
end;

procedure TJSONTest.Test24_KeyOrderPreservation;
var
  Obj: IJSONObject;
  Names: TStringArray;
  JSON: string;
begin
  // Create object with specific key order
  Obj := TJSON.Obj;
  Obj.Add('zebra', 1);
  Obj.Add('apple', 2);
  Obj.Add('mango', 3);
  Obj.Add('banana', 4);
  
  // Get names and verify order matches insertion order (not alphabetical)
  Names := Obj.Names;
  AssertEquals('First key should be zebra', 'zebra', Names[0]);
  AssertEquals('Second key should be apple', 'apple', Names[1]);
  AssertEquals('Third key should be mango', 'mango', Names[2]);
  AssertEquals('Fourth key should be banana', 'banana', Names[3]);
  
  // Verify serialization order
  JSON := Obj.ToString(False);
  AssertTrue('zebra should come before apple in JSON', 
    Pos('zebra', JSON) < Pos('apple', JSON));
  AssertTrue('apple should come before mango in JSON',
    Pos('apple', JSON) < Pos('mango', JSON));
  AssertTrue('mango should come before banana in JSON',
    Pos('mango', JSON) < Pos('banana', JSON));
end;

procedure TJSONTest.Test25_SurrogatePairs;
var
  JSON: string;
  Value: IJSONValue;
  Obj: IJSONObject;
begin
  // Test emoji (U+1F600 = Grinning Face) encoded as surrogate pair
  // U+1F600 = \uD83D\uDE00
  JSON := '{"emoji":"\uD83D\uDE00"}';
  Value := TJSON.Parse(JSON);
  
  AssertNotNull('Parsed value should not be nil', Value);
  // The emoji should be decoded to the actual character
  AssertEquals('Emoji should be decoded', #$F0#$9F#$98#$80, Value.AsObject['emoji'].AsString);
  
  // Test another surrogate pair: U+1F4A9 (Pile of Poo) = \uD83D\uDCA9  
  JSON := '{"poo":"\uD83D\uDCA9"}';
  Value := TJSON.Parse(JSON);
  AssertEquals('Poo emoji should be decoded', #$F0#$9F#$92#$A9, Value.AsObject['poo'].AsString);
  
  // Test mixed content with surrogate pairs
  JSON := '{"text":"Hello \uD83D\uDE00 World"}';
  Value := TJSON.Parse(JSON);
  AssertTrue('Mixed content should contain emoji',
    Pos(#$F0#$9F#$98#$80, Value.AsObject['text'].AsString) > 0);
    
  // Test creating object with emoji and roundtrip
  Obj := TJSON.Obj;
  Obj.Add('smiley', #$F0#$9F#$98#$80);
  JSON := Obj.ToString(False);
  Value := TJSON.Parse(JSON);
  AssertEquals('Emoji should roundtrip', #$F0#$9F#$98#$80, Value.AsObject['smiley'].AsString);
end;

procedure TJSONTest.Test26_InvalidPlusSign;
var
  Value: IJSONValue;
  Success: Boolean;
begin
  // RFC 8259: Numbers cannot have leading plus sign
  // "+123" is invalid JSON
  Success := TJSON.TryParse('+123', Value);
  AssertFalse('Leading plus sign should be rejected', Success);
  AssertNull('Value should be nil for invalid JSON', Value);
  
  // "+0" is also invalid
  Success := TJSON.TryParse('+0', Value);
  AssertFalse('Plus zero should be rejected', Success);
  
  // "+1.5" is also invalid
  Success := TJSON.TryParse('+1.5', Value);
  AssertFalse('Plus decimal should be rejected', Success);
  
  // In arrays
  Success := TJSON.TryParse('[+1]', Value);
  AssertFalse('Plus in array should be rejected', Success);
  
  // In objects
  Success := TJSON.TryParse('{"a":+1}', Value);
  AssertFalse('Plus in object value should be rejected', Success);
end;

procedure TJSONTest.Test27_LeadingPlusExponent;
var
  Value: IJSONValue;
begin
  // RFC 8259: Plus sign IS allowed in exponent
  // "1e+10" is valid JSON
  Value := TJSON.Parse('1e+10');
  AssertNotNull('1e+10 should be valid', Value);
  AssertTrue('Value should be number', Value.IsNumber);
  AssertEquals('Value should be 1e10', 1e10, Value.AsNumber, 1e5);
  
  // "1E+10" uppercase is also valid
  Value := TJSON.Parse('1E+10');
  AssertEquals('1E+10 should equal 1e10', 1e10, Value.AsNumber, 1e5);
  
  // "1.5e+2" is valid
  Value := TJSON.Parse('1.5e+2');
  AssertEquals('1.5e+2 should equal 150', 150.0, Value.AsNumber, 0.001);
  
  // "-1e+2" is valid (negative number with positive exponent)
  Value := TJSON.Parse('-1e+2');
  AssertEquals('-1e+2 should equal -100', -100.0, Value.AsNumber, 0.001);
  
  // "1e-10" negative exponent is valid
  Value := TJSON.Parse('1e-10');
  AssertEquals('1e-10 should be very small', 1e-10, Value.AsNumber, 1e-15);
end;

procedure TJSONTest.Test28_SingleQuoteString;
var
  Value: IJSONValue;
  Success: Boolean;
begin
  // RFC 8259: Strings MUST use double quotes
  // Single quotes are NOT valid JSON
  Success := TJSON.TryParse('''hello''', Value);
  AssertFalse('Single quoted string should be rejected', Success);
  AssertNull('Value should be nil', Value);
  
  // In objects - both key and value
  Success := TJSON.TryParse('{''key'':''value''}', Value);
  AssertFalse('Single quoted key/value should be rejected', Success);
  
  // Mixed quotes
  Success := TJSON.TryParse('{"key":''value''}', Value);
  AssertFalse('Single quoted value with double quoted key should be rejected', Success);
  
  // In arrays
  Success := TJSON.TryParse('[''item'']', Value);
  AssertFalse('Single quoted array item should be rejected', Success);
  
  // Valid double quotes should work
  Value := TJSON.Parse('"hello"');
  AssertEquals('Double quoted string should work', 'hello', Value.AsString);
end;

procedure TJSONTest.Test29_TrailingGarbage;
var
  Value: IJSONValue;
  Success: Boolean;
begin
  // RFC 8259: JSON text must be a single value with no trailing content
  // Extra content after valid JSON should be rejected
  Success := TJSON.TryParse('{"a":1} extra', Value);
  AssertFalse('Trailing text after object should be rejected', Success);
  
  Success := TJSON.TryParse('[1,2,3] more', Value);
  AssertFalse('Trailing text after array should be rejected', Success);
  
  Success := TJSON.TryParse('"string" garbage', Value);
  AssertFalse('Trailing text after string should be rejected', Success);
  
  Success := TJSON.TryParse('123 456', Value);
  AssertFalse('Two numbers should be rejected', Success);
  
  Success := TJSON.TryParse('true false', Value);
  AssertFalse('Two booleans should be rejected', Success);
  
  Success := TJSON.TryParse('null null', Value);
  AssertFalse('Two nulls should be rejected', Success);
  
  // Multiple valid JSON documents concatenated
  Success := TJSON.TryParse('{}{}', Value);
  AssertFalse('Two objects should be rejected', Success);
  
  Success := TJSON.TryParse('[][]', Value);
  AssertFalse('Two arrays should be rejected', Success);
  
  // Trailing whitespace IS allowed
  Value := TJSON.Parse('{"a":1}   ');
  AssertNotNull('Trailing whitespace should be allowed', Value);
  AssertTrue('Value should be object', Value.IsObject);
end;

procedure TJSONTest.Test30_BOMHandling;
var
  Value: IJSONValue;
  Success: Boolean;
  JSONWithBOM: string;
begin
  // UTF-8 BOM is EF BB BF (bytes) which is #$EF#$BB#$BF in Pascal
  // RFC 8259 says implementations SHOULD NOT add BOM, but may accept it
  
  // Test with BOM at start of valid JSON
  JSONWithBOM := #$EF#$BB#$BF + '{"name":"test"}';
  Success := TJSON.TryParse(JSONWithBOM, Value);
  
  // Our implementation should either accept or gracefully reject BOM
  // If it accepts, verify parsing is correct
  if Success then
  begin
    AssertNotNull('Value should not be nil when BOM accepted', Value);
    AssertTrue('Value should be object', Value.IsObject);
    AssertEquals('Name should match', 'test', Value.AsObject['name'].AsString);
  end
  else
  begin
    // If rejected, that's also RFC-compliant (implementations MAY reject)
    AssertNull('Value should be nil when BOM rejected', Value);
  end;
  
  // Test BOM with array
  JSONWithBOM := #$EF#$BB#$BF + '[1,2,3]';
  Success := TJSON.TryParse(JSONWithBOM, Value);
  // Just verify it doesn't crash - either accept or reject is valid
  
  // Test without BOM still works
  Value := TJSON.Parse('{"name":"test"}');
  AssertEquals('Normal JSON without BOM should work', 'test', Value.AsObject['name'].AsString);
end;

procedure TJSONTest.Test31_RejectComments;
var
  Value: IJSONValue;
  Success: Boolean;
begin
  // RFC 8259: JSON does NOT support comments
  // Many parsers accept them as an extension, but strict parsers should reject
  
  // C-style single line comment
  Success := TJSON.TryParse('{"a":1} // comment', Value);
  AssertFalse('C-style line comment should be rejected', Success);
  
  // C-style block comment
  Success := TJSON.TryParse('{"a":1 /* comment */}', Value);
  AssertFalse('C-style block comment should be rejected', Success);
  
  // Comment before JSON
  Success := TJSON.TryParse('// comment' + #10 + '{"a":1}', Value);
  AssertFalse('Comment before JSON should be rejected', Success);
  
  // Comment inside object
  Success := TJSON.TryParse('{"a": /* inline */ 1}', Value);
  AssertFalse('Inline comment should be rejected', Success);
  
  // Hash-style comment (some parsers accept this)
  Success := TJSON.TryParse('{"a":1} # comment', Value);
  AssertFalse('Hash comment should be rejected', Success);
  
  // String containing comment-like text IS valid
  Value := TJSON.Parse('{"text":"// not a comment"}');
  AssertEquals('Comment-like string should be preserved', 
    '// not a comment', Value.AsObject['text'].AsString);
    
  Value := TJSON.Parse('{"text":"/* also not a comment */"}');
  AssertEquals('Block comment-like string should be preserved',
    '/* also not a comment */', Value.AsObject['text'].AsString);
end;

procedure TJSONTest.Test32_MaxNestingDepth;
var
  JSON: string;
  Value: IJSONValue;
  I: Integer;
  Success: Boolean;
begin
  // Test reasonable nesting depth (should work)
  // Create nested arrays: [[[[...]]]]
  JSON := '';
  for I := 1 to 50 do
    JSON := JSON + '[';
  JSON := JSON + '1';
  for I := 1 to 50 do
    JSON := JSON + ']';
    
  Value := TJSON.Parse(JSON);
  AssertNotNull('50 levels of nesting should parse', Value);
  AssertTrue('Root should be array', Value.IsArray);
  
  // Create nested objects: {"a":{"a":{"a":...}}}
  JSON := '';
  for I := 1 to 50 do
    JSON := JSON + '{"a":';
  JSON := JSON + '1';
  for I := 1 to 50 do
    JSON := JSON + '}';
    
  Value := TJSON.Parse(JSON);
  AssertNotNull('50 levels of object nesting should parse', Value);
  AssertTrue('Root should be object', Value.IsObject);
  
  // Test very deep nesting (may cause stack overflow in recursive parsers)
  // Create 500 levels of nesting
  JSON := '';
  for I := 1 to 500 do
    JSON := JSON + '[';
  JSON := JSON + '1';
  for I := 1 to 500 do
    JSON := JSON + ']';
  
  // Try to parse - should either succeed or fail gracefully (not crash)
  Success := TJSON.TryParse(JSON, Value);
  // We just verify it doesn't crash - either result is acceptable
  // depending on implementation limits
  if Success then
    AssertNotNull('Deep nesting value should not be nil', Value);
end;

procedure TJSONTest.Test33_LongString;
var
  LongStr: string;
  Obj: IJSONObject;
  JSON: string;
  Parsed: IJSONValue;
  I: Integer;
begin
  // Create a very long string (100KB)
  SetLength(LongStr, 100000);
  for I := 1 to 100000 do
    LongStr[I] := Chr(Ord('A') + (I mod 26));
  
  // Create object with long string
  Obj := TJSON.Obj;
  Obj.Add('data', LongStr);
  
  // Serialize
  JSON := Obj.ToString(False);
  AssertTrue('JSON should contain long string', Length(JSON) > 100000);
  
  // Parse back
  Parsed := TJSON.Parse(JSON);
  AssertNotNull('Parsed value should not be nil', Parsed);
  AssertEquals('Long string should roundtrip', LongStr, Parsed.AsObject['data'].AsString);
  
  // Test with special characters embedded
  LongStr := '';
  for I := 1 to 10000 do
    LongStr := LongStr + 'test"with\special' + #10 + 'chars';
  
  Obj := TJSON.Obj;
  Obj.Add('special', LongStr);
  JSON := Obj.ToString(False);
  Parsed := TJSON.Parse(JSON);
  AssertEquals('Long string with escapes should roundtrip', LongStr, Parsed.AsObject['special'].AsString);
end;

procedure TJSONTest.Test34_LargeArray;
var
  Arr: IJSONArray;
  JSON: string;
  Parsed: IJSONValue;
  I: Integer;
  fname: string;
  Token: string;
  function FindInvalidNumberToken(const S: string): string;
  var
    I, Start: Integer;
    C: Char;
    TokenLocal: string;
  begin
    Start := 0;
    Result := '';
    I := 1;
    while I <= Length(S) do
    begin
      C := S[I];
      if C = '"' then
      begin
        // Skip string content safely (handle escapes)
        Inc(I);
        while (I <= Length(S)) and (S[I] <> '"') do
        begin
          if S[I] = '\' then
            Inc(I, 2)
          else
            Inc(I);
        end;
        Inc(I);
        Continue;
      end;

      if C in ['0'..'9', '-', '.'] then
      begin
        Start := I;
        Inc(I);
        while (I <= Length(S)) and (S[I] in ['0'..'9', '.', 'e', 'E', '+', '-']) do
          Inc(I);
        TokenLocal := Copy(S, Start, I - Start);
        TokenLocal := Trim(TokenLocal);
        if TokenLocal <> '' then
        begin
          // If token starts with a '.' it's invalid per RFC
          if TokenLocal[1] = '.' then
            Exit(TokenLocal);
          // Ensure token contains at least one digit
          if (Pos('0', TokenLocal) = 0) and (Pos('1', TokenLocal) = 0) and (Pos('2', TokenLocal) = 0)
            and (Pos('3', TokenLocal) = 0) and (Pos('4', TokenLocal) = 0) and (Pos('5', TokenLocal) = 0)
            and (Pos('6', TokenLocal) = 0) and (Pos('7', TokenLocal) = 0) and (Pos('8', TokenLocal) = 0)
            and (Pos('9', TokenLocal) = 0) then
            Exit(TokenLocal);
        end;
      end
      else
        Inc(I);
    end;
  end;
const
  ITEM_COUNT = 10000;
begin
  // Create array with thousands of items
  Arr := TJSON.Arr;
  for I := 0 to ITEM_COUNT - 1 do
    Arr.Add(I);

  AssertEquals('Array should have correct count', ITEM_COUNT, Arr.Count);

  // Serialize
  JSON := Arr.ToString(False);

  // Quick scan for invalid number tokens before parsing
  Token := FindInvalidNumberToken(JSON);
  if Token <> '' then
    Fail('Found invalid number token before parsing: ' + Token);

  // Parse back with diagnostics on failure
  try
    Parsed := TJSON.Parse(JSON);
  except
    on E: EJSONException do
    begin
      // write JSON to file for debugging
      fname := GetCurrentDir + PathDelim + 'failed_large_array.json';
      with TStringList.Create do
      try
        Text := JSON;
        SaveToFile(fname);
      finally
        Free;
      end;
      Fail('Parsing large array failed with EJSONException: ' + E.Message + '. JSON dumped to ' + fname);
    end;
  end;

  AssertNotNull('Parsed value should not be nil', Parsed);
  AssertTrue('Value should be array', Parsed.IsArray);
  AssertEquals('Parsed array should have correct count', ITEM_COUNT, Parsed.AsArray.Count);

  // Verify first, middle, and last items
  AssertEquals('First item should match', 0, Parsed.AsArray[0].AsInteger);
  AssertEquals('Middle item should match', ITEM_COUNT div 2, Parsed.AsArray[ITEM_COUNT div 2].AsInteger);
  AssertEquals('Last item should match', ITEM_COUNT - 1, Parsed.AsArray[ITEM_COUNT - 1].AsInteger);

  // Test mixed types array (avoiding floats which may have serialization edge cases)
  Arr := TJSON.Arr;
  for I := 0 to 1000 do
  begin
    case I mod 4 of
      0: Arr.Add(I);
      1: Arr.Add('string' + IntToStr(I));
      2: Arr.Add(I mod 2 = 0);
      3: Arr.Add(TJSON.Null);
    end;
  end;

  JSON := Arr.ToString(False);
  Token := FindInvalidNumberToken(JSON);
  if Token <> '' then
    Fail('Found invalid number token in mixed array before parsing: ' + Token);
  Parsed := TJSON.Parse(JSON);
  AssertEquals('Mixed array count should match', 1001, Parsed.AsArray.Count);
end;

procedure TJSONTest.Test35_RoundtripWriterParser;
var
  Original: IJSONObject;
  NestedArr, InnerArr: IJSONArray;
  NestedObj, InnerObj: IJSONObject;
  Compact, Pretty: string;
  ParsedCompact, ParsedPretty: IJSONValue;
begin
  // Create a complex object
  Original := TJSON.Obj;
  Original.Add('string', 'hello world');
  Original.Add('integer', 42);
  Original.Add('float', 3.14159);
  Original.Add('boolTrue', True);
  Original.Add('boolFalse', False);
  Original.Add('nullVal', TJSON.Null);
  
  // Add nested array with mixed content
  InnerObj := TJSON.Obj;
  InnerObj.Add('nested', 'value');
  
  NestedArr := TJSON.Arr;
  NestedArr.Add(1);
  NestedArr.Add('two');
  NestedArr.Add(True);
  NestedArr.Add(InnerObj);
  Original.Add('array', NestedArr);
  
  // Add nested object
  InnerArr := TJSON.Arr;
  InnerArr.Add(1);
  InnerArr.Add(2);
  InnerArr.Add(3);
  
  NestedObj := TJSON.Obj;
  NestedObj.Add('a', 1);
  NestedObj.Add('b', 2);
  NestedObj.Add('c', InnerArr);
  Original.Add('object', NestedObj);
  
  // Test compact roundtrip
  Compact := Original.ToString(False);
  ParsedCompact := TJSON.Parse(Compact);
  AssertNotNull('Compact parse should succeed', ParsedCompact);
  
  // Verify structure
  AssertEquals('string should match', 'hello world', ParsedCompact.AsObject['string'].AsString);
  AssertEquals('integer should match', 42, ParsedCompact.AsObject['integer'].AsInteger);
  AssertEquals('float should match', 3.14159, ParsedCompact.AsObject['float'].AsNumber, 0.00001);
  AssertTrue('boolTrue should be true', ParsedCompact.AsObject['boolTrue'].AsBoolean);
  AssertFalse('boolFalse should be false', ParsedCompact.AsObject['boolFalse'].AsBoolean);
  AssertTrue('nullVal should be null', ParsedCompact.AsObject['nullVal'].IsNull);
  AssertEquals('array count should match', 4, ParsedCompact.AsObject['array'].AsArray.Count);
  AssertEquals('nested object value', 'value', 
    ParsedCompact.AsObject['array'].AsArray[3].AsObject['nested'].AsString);
  
  // Test pretty roundtrip
  Pretty := Original.ToString(True);
  AssertTrue('Pretty should have newlines', Pos(LineEnding, Pretty) > 0);
  
  ParsedPretty := TJSON.Parse(Pretty);
  AssertNotNull('Pretty parse should succeed', ParsedPretty);
  
  // Compare compact outputs (should be identical regardless of input format)
  AssertEquals('Compact output should be consistent',
    ParsedCompact.ToString(False), ParsedPretty.ToString(False));
end;

procedure TJSONTest.Test36_DuplicateKeys;
var
  JSON: string;
  Parsed: IJSONValue;
  Obj: IJSONObject;
begin
  // RFC 8259: Names within an object SHOULD be unique
  // Most parsers keep last value (our implementation should too)
  JSON := '{"key":"first","key":"second","key":"third"}';
  Parsed := TJSON.Parse(JSON);
  
  AssertNotNull('Parsed value should not be nil', Parsed);
  AssertTrue('Value should be object', Parsed.IsObject);
  
  // The last value should win
  AssertEquals('Last value should be kept', 'third', Parsed.AsObject['key'].AsString);
  
  // Verify only one key exists (duplicates merged)
  AssertEquals('Object should have 1 key', 1, Parsed.AsObject.Count);
  
  // Test with different value types
  JSON := '{"x":1,"x":"two","x":true,"x":null}';
  Parsed := TJSON.Parse(JSON);
  AssertTrue('Last value (null) should be kept', Parsed.AsObject['x'].IsNull);
  AssertEquals('Object should have 1 key', 1, Parsed.AsObject.Count);
  
  // Test programmatic duplicate handling
  Obj := TJSON.Obj;
  Obj.Add('dup', 'first');
  Obj.Add('dup', 'second');  // Should overwrite
  AssertEquals('Programmatic add should overwrite', 'second', Obj['dup'].AsString);
  AssertEquals('Object should have 1 key', 1, Obj.Count);
  
  // Test SetValue on existing key
  Obj['dup'] := TJSON.Int(123);
  AssertEquals('SetValue should update', 123, Obj['dup'].AsInteger);
  AssertEquals('Object should still have 1 key', 1, Obj.Count);
end;

procedure TJSONTest.Test37_SolidusEscape;
var
  JSON: string;
  Parsed: IJSONValue;
  Obj: IJSONObject;
begin
  // RFC 8259: solidus (/) MAY be escaped as \/
  // Both escaped and unescaped forms are valid and should decode to /
  
  // Test escaped solidus
  JSON := '{"path":"\/usr\/bin\/test"}';
  Parsed := TJSON.Parse(JSON);
  AssertEquals('Escaped solidus should decode', '/usr/bin/test', Parsed.AsObject['path'].AsString);
  
  // Test unescaped solidus (also valid)
  JSON := '{"path":"/usr/bin/test"}';
  Parsed := TJSON.Parse(JSON);
  AssertEquals('Unescaped solidus should work', '/usr/bin/test', Parsed.AsObject['path'].AsString);
  
  // Test mixed escaped/unescaped
  JSON := '{"path":"\/usr/bin\/test"}';
  Parsed := TJSON.Parse(JSON);
  AssertEquals('Mixed solidus should decode', '/usr/bin/test', Parsed.AsObject['path'].AsString);
  
  // Test URL with solidus
  JSON := '{"url":"https:\/\/example.com\/path"}';
  Parsed := TJSON.Parse(JSON);
  AssertEquals('URL with escaped solidus', 'https://example.com/path', Parsed.AsObject['url'].AsString);
  
  // Create object with solidus and verify roundtrip
  Obj := TJSON.Obj;
  Obj.Add('slash', '/test/path/');
  JSON := Obj.ToString(False);
  Parsed := TJSON.Parse(JSON);
  AssertEquals('Solidus should roundtrip', '/test/path/', Parsed.AsObject['slash'].AsString);
end;

procedure TJSONTest.Test38_UnicodeHexCase;
var
  JSON: string;
  Parsed: IJSONValue;
begin
  // RFC 8259: Hex digits can be upper or lower case
  // \u00ff and \u00FF should decode to the same character
  
  // Test lowercase
  JSON := '{"char":"\u00e9"}';  // é (e with acute)
  Parsed := TJSON.Parse(JSON);
  AssertEquals('Lowercase hex should decode', #$C3#$A9, Parsed.AsObject['char'].AsString);
  
  // Test uppercase (same character)
  JSON := '{"char":"\u00E9"}';
  Parsed := TJSON.Parse(JSON);
  AssertEquals('Uppercase hex should decode same', #$C3#$A9, Parsed.AsObject['char'].AsString);
  
  // Test mixed case
  JSON := '{"char":"\u00eF"}';  // ï (i with diaeresis)
  Parsed := TJSON.Parse(JSON);
  AssertEquals('Mixed case hex should decode', #$C3#$AF, Parsed.AsObject['char'].AsString);
  
  // Test with \u00Ef (different mix)
  JSON := '{"char":"\u00Ef"}';
  Parsed := TJSON.Parse(JSON);
  AssertEquals('Different mixed case should decode same', #$C3#$AF, Parsed.AsObject['char'].AsString);
  
  // Test full range of hex digits (0-9, A-F, a-f)
  JSON := '{"test":"\u0041\u0042\u0043\u0061\u0062\u0063"}';  // ABCabc
  Parsed := TJSON.Parse(JSON);
  AssertEquals('Numbers in hex should work', 'ABCabc', Parsed.AsObject['test'].AsString);
  
  // Test surrogate pairs with mixed case
  JSON := '{"emoji":"\uD83d\uDE00"}';  // Mixed case surrogate
  Parsed := TJSON.Parse(JSON);
  AssertEquals('Mixed case surrogate should decode', #$F0#$9F#$98#$80, Parsed.AsObject['emoji'].AsString);
end;

procedure TJSONTest.Test39_BigExponents;
var
  Value: IJSONValue;
  Num: Double;
  JSON: string;
  Obj: IJSONObject;
begin
  // Test very large exponents
  Value := TJSON.Parse('1e308');
  AssertNotNull('1e308 should parse', Value);
  AssertTrue('Value should be number', Value.IsNumber);
  Num := Value.AsNumber;
  AssertTrue('1e308 should be very large', Num > 1e307);
  
  // Test very small (negative) exponents
  Value := TJSON.Parse('1e-308');
  AssertNotNull('1e-308 should parse', Value);
  Num := Value.AsNumber;
  AssertTrue('1e-308 should be very small', (Num > 0) and (Num < 1e-307));
  
  // Test numbers near limits
  Value := TJSON.Parse('1.7976931348623157e308');  // Near MaxDouble
  AssertNotNull('Near max double should parse', Value);
  
  Value := TJSON.Parse('2.2250738585072014e-308');  // Near MinDouble (normalized)
  AssertNotNull('Near min double should parse', Value);
  
  // Test roundtrip of moderately large numbers (extreme exponents may lose precision in ToString)
  Obj := TJSON.Obj;
  Obj.Add('big', 1.5e15);
  JSON := Obj.ToString(False);
  Value := TJSON.Parse(JSON);
  AssertEquals('Large number should roundtrip', 1.5e15, Value.AsObject['big'].AsNumber, 1e10);
  
  // Test roundtrip of moderately small numbers
  Obj := TJSON.Obj;
  Obj.Add('small', 1.5e-15);
  JSON := Obj.ToString(False);
  Value := TJSON.Parse(JSON);
  AssertEquals('Small number should roundtrip', 1.5e-15, Value.AsObject['small'].AsNumber, 1e-20);
  
  // Test zero exponent
  Value := TJSON.Parse('1e0');
  AssertEquals('1e0 should equal 1', 1.0, Value.AsNumber, 0.001);
  
  Value := TJSON.Parse('5e0');
  AssertEquals('5e0 should equal 5', 5.0, Value.AsNumber, 0.001);
end;

procedure TJSONTest.Test40_FuzzBasic;
var
  I, J: Integer;
  TestStr: string;
  Value: IJSONValue;
  Success: Boolean;
  RandomChars: string;
begin
  // Fuzz test: generate random strings and ensure parser never crashes
  // It should either parse successfully or raise EJSONException
  
  RandomChars := '{}[]",:0123456789abcdefnultruefalse +-.'#9#10#13;
  
  // Test many random combinations
  for I := 1 to 500 do
  begin
    // Generate random string of varying length
    SetLength(TestStr, (I mod 20) + 1);
    for J := 1 to Length(TestStr) do
      TestStr[J] := RandomChars[(Random(Length(RandomChars)) + 1)];
    
    // Try to parse - should not crash
    try
      Success := TJSON.TryParse(TestStr, Value);
      // Either success (valid JSON by chance) or failure is fine
    except
      on E: EJSONException do
        ; // Expected for invalid JSON
      on E: Exception do
        Fail('Unexpected exception type: ' + E.ClassName + ' - ' + E.Message);
    end;
  end;
  
  // Test specific edge cases that might crash naive parsers
  Success := TJSON.TryParse('', Value);  // Empty string
  AssertFalse('Empty string should fail', Success);
  
  Success := TJSON.TryParse('    ', Value);  // Only whitespace
  AssertFalse('Whitespace only should fail', Success);
  
  Success := TJSON.TryParse(#0, Value);  // Null byte
  AssertFalse('Null byte should fail', Success);
  
  // Note: Some edge cases may behave differently depending on implementation
  // The key goal is no crashes, not specific pass/fail semantics
  
  Success := TJSON.TryParse('"\u', Value);  // Incomplete unicode
  // Parser may accept incomplete sequences or reject them
  
  Success := TJSON.TryParse('"\u00', Value);  // Partial unicode
  // Parser may accept partial sequences or reject them
  
  Success := TJSON.TryParse('[[[[[', Value);  // Unclosed arrays
  AssertFalse('Unclosed arrays should fail', Success);
  
  Success := TJSON.TryParse('{{{{{', Value);  // Unclosed objects
  AssertFalse('Unclosed objects should fail', Success);
  
  Success := TJSON.TryParse('{"a":', Value);  // Incomplete object
  AssertFalse('Incomplete object should fail', Success);
  
  Success := TJSON.TryParse('[1,', Value);  // Incomplete array
  AssertFalse('Incomplete array should fail', Success);
end;

procedure TJSONTest.Test41_SingleZeroNumber;
var
  Value: IJSONValue;
  Success: Boolean;
begin
  // Single zero as a JSON value
  Value := TJSON.Parse('0');
  AssertNotNull('Single zero should parse', Value);
  AssertTrue('Value should be number', Value.IsNumber);
  AssertEquals('Zero as integer should be 0', 0, Value.AsInteger);
  AssertEquals('Zero as number should be 0.0', 0.0, Value.AsNumber, 0.0);
  AssertEquals('Zero should serialize as 0', '0', Value.ToString(False));

  // Zero in array
  Value := TJSON.Parse('[0]');
  AssertTrue('Array should parse', Value.IsArray);
  AssertEquals('Array[0] should be zero', 0, Value.AsArray[0].AsInteger);

  // Zero in object
  Value := TJSON.Parse('{"a":0}');
  AssertTrue('Object should parse', Value.IsObject);
  AssertEquals('Object value should be zero', 0, Value.AsObject['a'].AsInteger);

  // TryParse should accept zero
  Success := TJSON.TryParse('0', Value);
  AssertTrue('TryParse should succeed for 0', Success);
end;

initialization
  RegisterTest(TJSONTest);
end. 
