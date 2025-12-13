unit SimpleJSON.Scanner;

{$mode objfpc}{$H+}{$J-}

interface

uses
  Classes, SysUtils, SimpleJSON;
  
type
  // JSON scanner class
  TJSONScanner = class
  private
    FSource: string;
    FPosition: Integer;
    
    function IsWhitespace(C: Char): Boolean;
    function IsDigit(C: Char): Boolean;
    function IsNumberStart(C: Char): Boolean;
    function PeekChar: Char;
    function ReadChar: Char;
    function ReadHexDigit: Integer;
    function ReadUnicodeEscape: string;
    function ReadString: string;
    function ReadNumber: string;
    procedure SkipWhitespace;
  public
    constructor Create(const ASource: string);
    function GetNextToken: TJSONToken;
  end;

implementation

constructor TJSONScanner.Create(const ASource: string);
begin
  inherited Create;
  FSource := ASource;
  FPosition := 1;
end;

function TJSONScanner.IsWhitespace(C: Char): Boolean;
begin
  Result := (C = ' ') or (C = #9) or (C = #10) or (C = #13);
end;

function TJSONScanner.IsDigit(C: Char): Boolean;
begin
  Result := (C >= '0') and (C <= '9');
end;

function TJSONScanner.IsNumberStart(C: Char): Boolean;
begin
  Result := IsDigit(C) or (C = '-');
end;

function TJSONScanner.PeekChar: Char;
begin
  if FPosition <= Length(FSource) then
    Result := FSource[FPosition]
  else
    Result := #0;
end;

function TJSONScanner.ReadChar: Char;
begin
  if FPosition <= Length(FSource) then
  begin
    Result := FSource[FPosition];
    Inc(FPosition);
  end
  else
    Result := #0;
end;

function TJSONScanner.ReadHexDigit: Integer;
var
  C: Char;
begin
  C := ReadChar;
  case C of
    '0'..'9': Result := Ord(C) - Ord('0');
    'a'..'f': Result := Ord(C) - Ord('a') + 10;
    'A'..'F': Result := Ord(C) - Ord('A') + 10;
    else
      raise EJSONException.Create('Invalid hexadecimal digit: ' + C);
  end;
end;

function TJSONScanner.ReadUnicodeEscape: string;
var
  CodePoint, HighSurrogate, LowSurrogate: Integer;
  NextChar: Char;
begin
  // Read 4 hex digits
  CodePoint := (ReadHexDigit shl 12) or
               (ReadHexDigit shl 8) or
               (ReadHexDigit shl 4) or
               ReadHexDigit;

  // Check for surrogate pair
  if (CodePoint >= $D800) and (CodePoint <= $DBFF) then
  begin
    // High surrogate, expect low surrogate
    HighSurrogate := CodePoint;
    
    // Expect \u
    NextChar := ReadChar;
    if NextChar <> '\' then
      raise EJSONException.Create('Expected \u after high surrogate');
    NextChar := ReadChar;
    if NextChar <> 'u' then
      raise EJSONException.Create('Expected \u after high surrogate');
      
    // Read low surrogate
    LowSurrogate := (ReadHexDigit shl 12) or
                    (ReadHexDigit shl 8) or
                    (ReadHexDigit shl 4) or
                    ReadHexDigit;
                    
    if (LowSurrogate < $DC00) or (LowSurrogate > $DFFF) then
      raise EJSONException.Create('Invalid low surrogate');
      
    // Calculate final code point
    CodePoint := $10000 + ((HighSurrogate - $D800) shl 10) or (LowSurrogate - $DC00);
  end;
  
  // Convert to UTF-16 string
  if CodePoint <= $FFFF then
    Result := WideChar(CodePoint)
  else
  begin
    // Split into surrogate pair
    Dec(CodePoint, $10000);
    Result := WideChar($D800 or (CodePoint shr 10)) +
              WideChar($DC00 or (CodePoint and $3FF));
  end;
end;

function TJSONScanner.ReadString: string;
var
  C: Char;
  Escaped: Boolean;
begin
  Result := '';
  Escaped := False;
  
  // Skip opening quote
  ReadChar;
  
  while FPosition <= Length(FSource) do
  begin
    C := ReadChar;
    
    if Escaped then
    begin
      case C of
        '"', '\', '/': Result := Result + C;
        'b': Result := Result + #8;
        't': Result := Result + #9;
        'n': Result := Result + #10;
        'f': Result := Result + #12;
        'r': Result := Result + #13;
        'u': Result := Result + ReadUnicodeEscape;
        else
          raise EJSONException.Create('Invalid escape sequence: \' + C);
      end;
      Escaped := False;
    end
    else if C = '\' then
      Escaped := True
    else if C = '"' then
      Break
    else if Ord(C) < 32 then
      raise EJSONException.Create('Invalid control character in string')
    else
      Result := Result + C;
  end;
end;

function TJSONScanner.ReadNumber: string;
var
  C: Char;
  HasExponent: Boolean;
  DigitCount, ExponentDigits: Integer;
  StartPos: Integer;
begin
  Result := '';
  HasExponent := False;
  DigitCount := 0;
  ExponentDigits := 0;
  
  StartPos := FPosition;
  
  // Handle negative sign
  if PeekChar = '-' then
    Result := Result + ReadChar;
  
  // First digit must not be zero unless it's a decimal number
  C := PeekChar;
  if C = '0' then
  begin
    Result := Result + ReadChar;
    Inc(DigitCount);
    C := PeekChar;
    if IsDigit(C) then
      raise EJSONException.CreateFmt('Leading zeros are not allowed in JSON numbers at position %d', [StartPos]);
  end
  else if IsDigit(C) then
  begin
    // Read integer part
    while IsDigit(C) do
    begin
      Result := Result + ReadChar;
      Inc(DigitCount);
      C := PeekChar;
    end;
  end
  else
    raise EJSONException.CreateFmt('Invalid number format: digit expected at position %d', [StartPos]);
    
  // Handle decimal point
  if PeekChar = '.' then
  begin
    Result := Result + ReadChar;
    
    // Must have at least one digit after decimal point
    C := PeekChar;
    if not IsDigit(C) then
      raise EJSONException.CreateFmt('Expected digit after decimal point at position %d', [StartPos]);
      
    // Read fractional part
    while IsDigit(C) do
    begin
      Result := Result + ReadChar;
      Inc(DigitCount);
      C := PeekChar;
    end;
  end;
  
  // Handle exponent
  C := PeekChar;
  if (C = 'e') or (C = 'E') then
  begin
    Result := Result + ReadChar;
    HasExponent := True;
    
    // Handle exponent sign
    C := PeekChar;
    if (C = '+') or (C = '-') then
      Result := Result + ReadChar;
    
    // Must have at least one digit in exponent
    C := PeekChar;
    if not IsDigit(C) then
      raise EJSONException.CreateFmt('Expected digit in exponent at position %d', [StartPos]);
      
    // Read exponent digits
    while IsDigit(C) do
    begin
      Result := Result + ReadChar;
      Inc(ExponentDigits);
      C := PeekChar;
    end;
  end;
  
  // Validate number format
  if DigitCount = 0 then
    raise EJSONException.CreateFmt('Number must contain at least one digit at position %d', [StartPos]);
    
  if HasExponent and (ExponentDigits = 0) then
    raise EJSONException.CreateFmt('Exponent must contain at least one digit at position %d', [StartPos]);
    
  // Validate the resulting number can be parsed
  try
    StrToFloat(Result);
  except
    on E: Exception do
      raise EJSONException.CreateFmt('Invalid number format: %s at position %d', [E.Message, StartPos]);
  end;
end;

procedure TJSONScanner.SkipWhitespace;
begin
  while (FPosition <= Length(FSource)) and IsWhitespace(FSource[FPosition]) do
    Inc(FPosition);
end;

function TJSONScanner.GetNextToken: TJSONToken;
var
  C: Char;
begin
  SkipWhitespace;
  
  if FPosition > Length(FSource) then
  begin
    Result.TokenType := ttNone;
    Result.Value := '';
    Exit;
  end;
  
  C := PeekChar;
  case C of
    '{':
    begin
      ReadChar;
      Result.TokenType := ttCurlyOpen;
      Result.Value := '{';
    end;
    '}':
    begin
      ReadChar;
      Result.TokenType := ttCurlyClose;
      Result.Value := '}';
    end;
    '[':
    begin
      ReadChar;
      Result.TokenType := ttSquareOpen;
      Result.Value := '[';
    end;
    ']':
    begin
      ReadChar;
      Result.TokenType := ttSquareClose;
      Result.Value := ']';
    end;
    ':':
    begin
      ReadChar;
      Result.TokenType := ttColon;
      Result.Value := ':';
    end;
    ',':
    begin
      ReadChar;
      Result.TokenType := ttComma;
      Result.Value := ',';
    end;
    '"':
    begin
      Result.TokenType := ttString;
      Result.Value := ReadString;
    end;
    't':
    begin
      if Copy(FSource, FPosition, 4) = 'true' then
      begin
        Inc(FPosition, 4);
        Result.TokenType := ttTrue;
        Result.Value := 'true';
      end
      else
        raise EJSONException.Create('Invalid token');
    end;
    'f':
    begin
      if Copy(FSource, FPosition, 5) = 'false' then
      begin
        Inc(FPosition, 5);
        Result.TokenType := ttFalse;
        Result.Value := 'false';
      end
      else
        raise EJSONException.Create('Invalid token');
    end;
    'n':
    begin
      if Copy(FSource, FPosition, 4) = 'null' then
      begin
        Inc(FPosition, 4);
        Result.TokenType := ttNull;
        Result.Value := 'null';
      end
      else
        raise EJSONException.Create('Invalid token');
    end;
    else
    begin
      if IsNumberStart(C) then
      begin
        Result.TokenType := ttNumber;
        Result.Value := ReadNumber;
      end
      else
        raise EJSONException.Create('Invalid token');
    end;
  end;
end;

end. 