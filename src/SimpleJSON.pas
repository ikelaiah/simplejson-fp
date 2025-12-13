unit SimpleJSON;

{$mode objfpc}{$H+}{$J-}
{$modeswitch advancedrecords}
{$modeswitch typehelpers}

(* SimpleJSON - Standards-Compliant JSON Implementation

   This unit provides a JSON implementation that strictly conforms to:
   - ECMA-404 (The JSON Data Interchange Syntax)
   - RFC 8259 (The JavaScript Object Notation (JSON) Data Interchange Format)

   Standard Conformance:
   - Numbers:
     * No leading zeros (except for 0)
     * Decimal point must be followed by digits
     * Scientific notation (e.g., 1.23e2)
     * No special values (NaN, Infinity)
     * No octal or hexadecimal

   - Strings:
     * Double quotes required
     * Full escape sequence support (\b, \f, \n, \r, \t, \", \\, \/, \uXXXX)
     * Proper surrogate pair handling
     * No unescaped control characters

   - Structural:
     * Objects use { } with "key": value pairs
     * Arrays use [ ] with comma-separated values
     * No trailing commas
     * No comments

   - Unicode:
     * Full UTF-16 support
     * Proper surrogate pair handling
     * Complete \u escape sequence support

   Extensions Beyond Standard:
   - Property order preservation
   - Pretty printing
   - Type-safe interfaces
   - Memory safety through ARC
   - Detailed error messages *)

interface

uses
  Classes, SysUtils;
 
type
  // Forward declarations 
  IJSONValue = interface;
  IJSONObject = interface;
  IJSONArray = interface;
  
  // Core JSON value interface 
  IJSONValue = interface
    ['{A0D8C764-395B-4A32-8C34-FB4957157241}']
    function GetAsString: string;
    function GetAsNumber: Double;
    function GetAsInteger: Integer;
    function GetAsBoolean: Boolean;
    function GetAsObject: IJSONObject;
    function GetAsArray: IJSONArray;
    
    function IsString: Boolean;
    function IsNumber: Boolean;
    function IsBoolean: Boolean;
    function IsObject: Boolean;
    function IsArray: Boolean;
    function IsNull: Boolean;
    
    function ToString(Pretty: Boolean = False): string;
    
    property AsString: string read GetAsString;
    property AsNumber: Double read GetAsNumber;
    property AsInteger: Integer read GetAsInteger;
    property AsBoolean: Boolean read GetAsBoolean;
    property AsObject: IJSONObject read GetAsObject;
    property AsArray: IJSONArray read GetAsArray;
  end;

  // JSON object interface 
  IJSONObject = interface(IJSONValue)
    ['{B2C7F915-0D47-4A8E-B652-D0F9E4D23179}']
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
    
    property Values[const Name: string]: IJSONValue read GetValue write SetValue; default;
    property Count: Integer read GetCount;
    property Names: TStringArray read GetNames;
  end;

  // JSON array interface 
  IJSONArray = interface(IJSONValue)
    ['{C9E0D732-C2B1-4E6F-9F8A-8E8D5F54B3E7}']
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
    
    property Items[Index: Integer]: IJSONValue read GetItem write SetItem; default;
    property Count: Integer read GetCount;
  end;

  // JSON exception class 
  EJSONException = class(Exception);

  // JSON token types 
  TJSONTokenType = (
    ttNone,
    ttCurlyOpen,
    ttCurlyClose,
    ttSquareOpen,
    ttSquareClose,
    ttColon,
    ttComma,
    ttString,
    ttNumber,
    ttTrue,
    ttFalse,
    ttNull
  );

  // JSON token record 
  TJSONToken = record
    TokenType: TJSONTokenType;
    Value: string;
  end;

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
  SimpleJSON.Types, SimpleJSON.Factory;

// Re-export factory methods from SimpleJSON.Factory 

class function TJSON.Obj: IJSONObject;
begin
  Result := SimpleJSON.Factory.TJSON.Obj;
end;

class function TJSON.Arr: IJSONArray;
begin
  Result := SimpleJSON.Factory.TJSON.Arr;
end;

class function TJSON.Str(const Value: string): IJSONValue;
begin
  Result := SimpleJSON.Factory.TJSON.Str(Value);
end;

class function TJSON.Num(Value: Double): IJSONValue;
begin
  Result := SimpleJSON.Factory.TJSON.Num(Value);
end;

class function TJSON.Int(Value: Integer): IJSONValue;
begin
  Result := SimpleJSON.Factory.TJSON.Int(Value);
end;

class function TJSON.Bool(Value: Boolean): IJSONValue;
begin
  Result := SimpleJSON.Factory.TJSON.Bool(Value);
end;

class function TJSON.Null: IJSONValue;
begin
  Result := SimpleJSON.Factory.TJSON.Null;
end;

class function TJSON.Parse(const JSON: string): IJSONValue;
begin
  Result := SimpleJSON.Factory.TJSON.Parse(JSON);
end;

class function TJSON.TryParse(const JSON: string; out Value: IJSONValue): Boolean;
begin
  Result := SimpleJSON.Factory.TJSON.TryParse(JSON, Value);
end;

class function TJSON.PrettyPrint(const JSON: string): string;
begin
  Result := SimpleJSON.Factory.TJSON.PrettyPrint(JSON);
end;

class function TJSON.Compact(const JSON: string): string;
begin
  Result := SimpleJSON.Factory.TJSON.Compact(JSON);
end;

end. 