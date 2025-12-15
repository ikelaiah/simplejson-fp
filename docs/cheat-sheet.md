# 📋 SimpleJSON-FP Cheat Sheet

A comprehensive reference for SimpleJSON-FP's JSON functionality and usage examples.

> [!NOTE]
> This library was extracted from [TidyKit-FP](https://github.com/ikelaiah/tidykit-fp). It contains only the JSON functionality from the original library.

## Table of Contents

- [📋 SimpleJSON-FP Cheat Sheet](#-simplejson-fp-cheat-sheet)
  - [Table of Contents](#table-of-contents)
  - [🔄 JSON Operations](#-json-operations)
    - [Creating Values](#creating-values)
    - [Objects](#objects)
    - [Arrays](#arrays)
    - [Type Safety](#type-safety)
    - [Parsing \& Formatting](#parsing--formatting)
    - [Error Handling](#error-handling)

## 🔄 JSON Operations

### Creating Values
```pascal
TJSON.Obj                   // Empty object: {}
TJSON.Arr                   // Empty array: []
TJSON.Str('text')           // String: "text"
TJSON.Int(123)              // Integer: 123
TJSON.Num(123.45)           // Number: 123.45
TJSON.Bool(True)            // Boolean: true
TJSON.Null                  // Null: null
```

### Objects
```pascal
// Add values
Obj.Add('str', 'value')     // Add string
Obj.Add('num', 123)         // Add integer
Obj.Add('dec', 123.45)      // Add decimal
Obj.Add('bool', True)       // Add boolean
Obj.Add('null', TJSON.Null) // Add null

// Access values
Value := Obj['key']         // Get value
Exists := Obj.Contains('key')
Obj.Remove('key')           // Remove key
Count := Obj.Count          // Number of items
Keys := Obj.Names           // Get keys in order

// Extract (convenience)
Val := ExtractValue(Obj, 'key')  // Gets value and removes key; returns IJSONValue
```

### Arrays
```pascal
// Add values
Arr.Add('text')            // Add string
Arr.Add(123)               // Add integer
Arr.Add(123.45)            // Add decimal
Arr.Add(True)              // Add boolean

// Access values
Value := Arr[0]            // Get value
Arr.Delete(0)              // Delete item
Arr.Clear                  // Remove all
Count := Arr.Count         // Number of items
```

### Type Safety
```pascal
// Safe type checking
if Value.IsString then S := Value.AsString
if Value.IsNumber then
begin
  if Frac(Value.AsNumber) = 0 then
    I := Value.AsInteger   // Only for whole numbers
  else
    D := Value.AsNumber    // For any number
end
if Value.IsBoolean then B := Value.AsBoolean
if Value.IsObject then O := Value.AsObject
if Value.IsArray then A := Value.AsArray
if Value.IsNull then ...  // Handle null
```

### Parsing & Formatting
```pascal
// Parse JSON
Value := TJSON.Parse('{"key":"value"}')
Success := TJSON.TryParse(JSON, Value)

// Format JSON
Pretty := Value.ToString(True)   // With indentation
Compact := Value.ToString(False) // Without whitespace
```

### Error Handling
```pascal
try
  Value := TJSON.Parse(JSON);
except
  on E: EJSONException do
    // Handle JSON errors
end;
```
