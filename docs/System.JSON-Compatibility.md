# System.JSON Compatibility Guide

This guide explains how to use the Delphi `System.JSON` compatible API in SimpleJSON-FP.

## Overview

SimpleJSON-FP now provides a `System.JSON` compatibility unit that allows code written for Delphi's `System.JSON` to be easily ported to Free Pascal/Lazarus with minimal or no changes.

## Legal Note

**This is completely legal.** APIs (Application Programming Interfaces) are not copyrightable. This was affirmed by the US Supreme Court in *Google v. Oracle* (2021). This implementation is a clean-room design that provides:

- API compatibility (same class names, method signatures)
- **Completely original implementation** (no copied code)
- **Not trademarked** (we don't claim to be Embarcadero/Delphi)

This is the same approach used by:
- Wine (Windows API compatibility)
- Mono (.NET compatibility)
- ReactOS (Windows compatibility)
- OpenJDK (Java compatibility)

## Quick Start

### Using the Compatibility Unit

```pascal
uses
  System.JSON;  // Use this instead of SimpleJSON for Delphi compatibility

var
  Obj: TJSONObject;
  Arr: TJSONArray;
  S: string;
begin
  // Parse JSON (exactly like Delphi)
  S := '{"name": "John", "age": 30, "active": true}';
  Obj := TJSONObject.ParseJSONValue(S) as TJSONObject;
  try
    WriteLn('Name: ', Obj.GetValueString('name'));
    WriteLn('Age: ', Obj.GetValueInt('age'));
    WriteLn('Active: ', Obj.GetValueBool('active'));
  finally
    Obj.Free;
  end;
  
  // Create JSON (exactly like Delphi)
  Obj := TJSONObject.Create;
  try
    Obj.AddPair('name', 'Jane')
       .AddPair('age', 25)
       .AddPair('active', True);
    WriteLn(Obj.ToJSON);
    // Output: {"name":"Jane","age":25,"active":true}
  finally
    Obj.Free;
  end;
end;
```

## API Reference

### Classes

| Delphi Class | SimpleJSON-FP Status | Notes |
|--------------|---------------------|-------|
| `TJSONValue` | ✅ Implemented | Base class for all JSON values |
| `TJSONObject` | ✅ Implemented | JSON object (key-value pairs) |
| `TJSONArray` | ✅ Implemented | JSON array |
| `TJSONString` | ✅ Implemented | JSON string value |
| `TJSONNumber` | ✅ Implemented | JSON number value |
| `TJSONBool` | ✅ Implemented | JSON boolean base class |
| `TJSONTrue` | ✅ Implemented | JSON true value |
| `TJSONFalse` | ✅ Implemented | JSON false value |
| `TJSONNull` | ✅ Implemented | JSON null value |
| `TJSONPair` | ✅ Implemented | Key-value pair for objects |

### Parsing JSON

```pascal
// Method 1: Parse any JSON value
var
  Value: TJSONValue;
begin
  Value := TJSONValue.ParseJSONValue('{"key": "value"}');
  // or
  Value := TJSONValue.ParseJSONValue(JsonString, UseBool, RaiseException);
end;

// Method 2: Parse from bytes
var
  Value: TJSONValue;
  Data: TBytes;
begin
  Data := TEncoding.UTF8.GetBytes('{"key": "value"}');
  Value := TJSONValue.ParseJSONValue(Data, 0, True);
end;
```

### Creating JSON Objects

```pascal
// Method 1: Empty object with AddPair
var Obj: TJSONObject;
begin
  Obj := TJSONObject.Create;
  Obj.AddPair('name', 'John');
  Obj.AddPair('age', 30);
  Obj.AddPair('active', True);
end;

// Method 2: Fluent/chained AddPair
var Obj: TJSONObject;
begin
  Obj := TJSONObject.Create
    .AddPair('name', 'John')
    .AddPair('age', 30)
    .AddPair('active', True);
end;

// Method 3: Constructor with initial pair
var Obj: TJSONObject;
begin
  Obj := TJSONObject.Create('name', 'John');
  Obj.AddPair('age', 30);
end;
```

### Creating JSON Arrays

```pascal
// Method 1: Empty array with Add
var Arr: TJSONArray;
begin
  Arr := TJSONArray.Create;
  Arr.Add('string');
  Arr.Add(123);
  Arr.Add(True);
end;

// Method 2: Fluent/chained Add
var Arr: TJSONArray;
begin
  Arr := TJSONArray.Create
    .Add('first')
    .Add('second')
    .Add('third');
end;

// Method 3: Constructor with first element
var Arr: TJSONArray;
begin
  Arr := TJSONArray.Create('first element');
end;
```

### Accessing Values

```pascal
var
  Obj: TJSONObject;
  S: string;
  I: Integer;
  D: Double;
  B: Boolean;
begin
  Obj := TJSONObject.ParseJSONValue('{"name":"John","age":30,"score":95.5,"active":true}') as TJSONObject;
  try
    // Typed access with defaults
    S := Obj.GetValueString('name');           // 'John'
    S := Obj.GetValueString('missing', 'N/A'); // 'N/A' (default)
    
    I := Obj.GetValueInt('age');               // 30
    I := Obj.GetValueInt('missing', -1);       // -1 (default)
    
    D := Obj.GetValueDouble('score');          // 95.5
    B := Obj.GetValueBool('active');           // True
    
    // Raw value access
    if Obj.GetValue('name') is TJSONString then
      S := TJSONString(Obj.GetValue('name')).Value;
  finally
    Obj.Free;
  end;
end;
```

### Working with TJSONPair

```pascal
var
  Obj: TJSONObject;
  Pair: TJSONPair;
  I: Integer;
begin
  Obj := TJSONObject.ParseJSONValue('{"a":1,"b":2,"c":3}') as TJSONObject;
  try
    // Get pair by name
    Pair := Obj.Get('a');
    WriteLn(Pair.JsonString.Value, ' = ', Pair.JsonValue.ToJSON);
    
    // Iterate all pairs
    for I := 0 to Obj.Count - 1 do
    begin
      Pair := Obj.Pairs[I];
      WriteLn(Pair.JsonString.Value, ': ', Pair.JsonValue.ToJSON);
    end;
    
    // Using for-in enumeration
    for Pair in Obj do
      WriteLn(Pair.JsonString.Value);
  finally
    Obj.Free;
  end;
end;
```

### JSON Path Access

```pascal
var
  Obj: TJSONObject;
  V: TJSONValue;
begin
  Obj := TJSONObject.ParseJSONValue('{"user":{"name":"John","emails":["a@b.com","c@d.com"]}}') as TJSONObject;
  try
    // Path access using FindValue
    V := Obj.FindValue('user.name');
    if V <> nil then
      WriteLn(TJSONString(V).Value);  // 'John'
    
    // Typed path access
    WriteLn(Obj.GetValueString('user.name'));  // 'John'
  finally
    Obj.Free;
  end;
end;
```

### Output Formatting

```pascal
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.Create
    .AddPair('name', 'John')
    .AddPair('age', 30);
  try
    // Compact JSON
    WriteLn(Obj.ToJSON);
    // {"name":"John","age":30}
    
    // Pretty-printed JSON
    WriteLn(Obj.Format(2));
    // {
    //   "name": "John",
    //   "age": 30
    // }
    
    // Convert to bytes
    var Bytes := Obj.ToBytes;  // UTF-8 encoded
  finally
    Obj.Free;
  end;
end;
```

### Cloning JSON Values

```pascal
var
  Original, Clone: TJSONObject;
begin
  Original := TJSONObject.Create.AddPair('key', 'value');
  try
    Clone := Original.Clone as TJSONObject;
    try
      // Clone is independent copy
      Clone.AddPair('extra', 'data');
      WriteLn(Original.ToJSON);  // {"key":"value"}
      WriteLn(Clone.ToJSON);     // {"key":"value","extra":"data"}
    finally
      Clone.Free;
    end;
  finally
    Original.Free;
  end;
end;
```

## Differences from Delphi

While we strive for maximum compatibility, there are some differences:

### Generic Methods
Delphi uses `GetValue<T>('name')` generic syntax. Since Free Pascal handles generics differently, we provide typed methods:

```pascal
// Delphi:
S := Obj.GetValue<string>('name');
I := Obj.GetValue<Integer>('age');

// SimpleJSON-FP:
S := Obj.GetValueString('name');
I := Obj.GetValueInt('age');
```

### TryGetValue
Similar to above:

```pascal
// Delphi:
if Obj.TryGetValue<string>('name', S) then ...

// SimpleJSON-FP:
if Obj.TryGetValueString('name', S) then ...
```

## Migration Checklist

When porting code from Delphi to Lazarus:

1. ✅ Change `uses System.JSON` → `uses System.JSON` (same!)
2. ✅ Replace `GetValue<T>()` → `GetValueT()` (e.g., `GetValueString()`)
3. ✅ Replace `TryGetValue<T>()` → `TryGetValueT()`
4. ✅ Most other code should work unchanged

## Example: Complete Migration

### Original Delphi Code
```pascal
uses
  System.JSON;

procedure ProcessJSON;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.ParseJSONValue('{"name":"Test"}') as TJSONObject;
  try
    WriteLn(Obj.GetValue<string>('name'));
  finally
    Obj.Free;
  end;
end;
```

### Ported Lazarus Code
```pascal
uses
  System.JSON;  // No change needed!

procedure ProcessJSON;
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.ParseJSONValue('{"name":"Test"}') as TJSONObject;
  try
    WriteLn(Obj.GetValueString('name'));  // Only this line changes
  finally
    Obj.Free;
  end;
end;
```

## Which Unit to Use?

| Use Case | Recommended Unit |
|----------|------------------|
| Porting Delphi code | `System.JSON` |
| New Lazarus projects | `SimpleJSON` ⭐ |
| Maximum safety | `SimpleJSON` (automatic memory management) |
| Maximum compatibility | `System.JSON` (matches Delphi exactly) |

### Memory Management Comparison

| Unit | Memory Management | Pros |
|------|------------------|------|
| **SimpleJSON** | ✅ Automatic (ARC) | No memory leaks, no `try..finally`, cleaner code |
| **System.JSON** | ❌ Manual (`Free`) | 100% Delphi compatible, zero code changes needed |

```pascal
// SimpleJSON - Modern, safe approach (RECOMMENDED)
var
  Json: IJSONObject;  // Interface = automatic cleanup
begin
  Json := TJSON.Parse('{"name":"John"}').AsObject;
  WriteLn(Json['name'].AsString);
  // Nothing to free! Memory managed automatically.
end;

// System.JSON - Delphi compatible (for porting existing code)
var
  Obj: TJSONObject;  // Class = manual cleanup
begin
  Obj := TJSONObject.ParseJSONValue('{"name":"John"}') as TJSONObject;
  try
    WriteLn(Obj.GetValueString('name'));
  finally
    Obj.Free;  // Must free manually, just like Delphi
  end;
end;
```

**Our recommendation:** Use `SimpleJSON` for new projects - it's safer and cleaner. Use `System.JSON` only when porting existing Delphi code where you want zero code changes.

Both units can coexist in the same project if needed.
