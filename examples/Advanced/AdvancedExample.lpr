program AdvancedExample;

{**
  Advanced SimpleJSON-FP Example
  ==============================
  
  This example demonstrates advanced usage patterns of the SimpleJSON-FP library:
  
  1. Building complex nested JSON structures
  2. Iterating over JSON objects and arrays
  3. Working with JSON files (read/write)
  4. Data transformation and filtering
  5. Safe value access with type checking
  6. Working with Unicode and special characters
  7. Cloning and comparing JSON structures
  
  All memory is automatically managed through interface reference counting,
  so you never need to call Free on any JSON objects.
**}

{$mode objfpc}{$H+}{$J-}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,
  SysUtils,
  SimpleJSON;

const
  // Sample data file path (relative to executable)
  CONFIG_FILE = 'config.json';
  OUTPUT_FILE = 'output.json';

// ============================================================================
// EXAMPLE 1: Building Complex Nested Structures
// ============================================================================
procedure BuildComplexStructure;
var
  Root: IJSONObject;
  Database: IJSONObject;
  Server: IJSONObject;
  Endpoints: IJSONArray;
  Endpoint: IJSONObject;
  Users: IJSONArray;
  User: IJSONObject;
  Permissions: IJSONArray;
  i: Integer;
begin
  WriteLn('=== Example 1: Building Complex Nested Structures ===');
  WriteLn;
  
  // Create the root configuration object
  // TJSON.Obj creates an empty JSON object {}
  Root := TJSON.Obj;
  
  // Add simple key-value pairs
  // The Add method automatically wraps primitive values
  Root.Add('appName', 'MyApplication');
  Root.Add('version', '2.1.0');
  Root.Add('debug', False);
  Root.Add('maxConnections', 100);
  
  // Create a nested database configuration object
  Database := TJSON.Obj;
  Database.Add('host', 'localhost');
  Database.Add('port', 5432);
  Database.Add('name', 'myapp_production');
  Database.Add('ssl', True);
  Database.Add('poolSize', 10);
  
  // Add the database object as a nested property
  Root.Add('database', Database);
  
  // Create server configuration with multiple endpoints
  Server := TJSON.Obj;
  Server.Add('host', '0.0.0.0');
  Server.Add('port', 8080);
  
  // Create an array of endpoint configurations
  // TJSON.Arr creates an empty JSON array []
  Endpoints := TJSON.Arr;
  
  // Add multiple endpoint objects to the array
  Endpoint := TJSON.Obj;
  Endpoint.Add('path', '/api/users');
  Endpoint.Add('method', 'GET');
  Endpoint.Add('rateLimit', 100);
  Endpoints.Add(Endpoint);
  
  Endpoint := TJSON.Obj;
  Endpoint.Add('path', '/api/users');
  Endpoint.Add('method', 'POST');
  Endpoint.Add('rateLimit', 50);
  Endpoints.Add(Endpoint);
  
  Endpoint := TJSON.Obj;
  Endpoint.Add('path', '/api/data');
  Endpoint.Add('method', 'GET');
  Endpoint.Add('rateLimit', 200);
  Endpoints.Add(Endpoint);
  
  Server.Add('endpoints', Endpoints);
  Root.Add('server', Server);
  
  // Create an array of user objects with nested permissions
  Users := TJSON.Arr;
  
  for i := 1 to 3 do
  begin
    User := TJSON.Obj;
    User.Add('id', i);
    User.Add('username', 'user' + IntToStr(i));
    User.Add('email', 'user' + IntToStr(i) + '@example.com');
    User.Add('active', i mod 2 = 1); // Odd users are active
    
    // Create permissions array for each user
    Permissions := TJSON.Arr;
    Permissions.Add('read');
    if i >= 2 then
      Permissions.Add('write');
    if i = 3 then
      Permissions.Add('admin');
    
    User.Add('permissions', Permissions);
    Users.Add(User);
  end;
  
  Root.Add('users', Users);
  
  // Output the result with pretty printing (True = indented)
  WriteLn('Generated configuration:');
  WriteLn(Root.ToString(True));
  WriteLn;
end;

// ============================================================================
// EXAMPLE 2: Iterating Over JSON Objects and Arrays
// ============================================================================
procedure IterateJSON;
var
  JSON: string;
  Data: IJSONObject;
  Products: IJSONArray;
  Product: IJSONObject;
  Tags: IJSONArray;
  Names: TStringArray;
  Name: string;
  i, j: Integer;
  TotalPrice: Double;
begin
  WriteLn('=== Example 2: Iterating Over JSON Objects and Arrays ===');
  WriteLn;
  
  // Sample JSON data representing a product catalog
  JSON := 
    '{' +
    '  "store": "TechMart",' +
    '  "currency": "USD",' +
    '  "products": [' +
    '    {"name": "Laptop", "price": 999.99, "inStock": true, "tags": ["electronics", "computers"]},' +
    '    {"name": "Mouse", "price": 29.99, "inStock": true, "tags": ["electronics", "accessories"]},' +
    '    {"name": "Keyboard", "price": 79.99, "inStock": false, "tags": ["electronics", "accessories"]},' +
    '    {"name": "Monitor", "price": 349.99, "inStock": true, "tags": ["electronics", "displays"]}' +
    '  ]' +
    '}';
  
  // Parse the JSON string
  Data := TJSON.Parse(JSON).AsObject;
  
  // Access simple properties
  WriteLn('Store: ', Data['store'].AsString);
  WriteLn('Currency: ', Data['currency'].AsString);
  WriteLn;
  
  // Get the products array
  Products := Data['products'].AsArray;
  WriteLn('Number of products: ', Products.Count);
  WriteLn;
  
  // Iterate over all products using index-based access
  WriteLn('All products:');
  WriteLn('-------------');
  TotalPrice := 0;
  
  for i := 0 to Products.Count - 1 do
  begin
    // Each item in the array is an IJSONValue, convert to IJSONObject
    Product := Products[i].AsObject;
    
    WriteLn('  Product #', i + 1, ':');
    WriteLn('    Name: ', Product['name'].AsString);
    WriteLn('    Price: $', Product['price'].AsNumber:0:2);
    WriteLn('    In Stock: ', Product['inStock'].AsBoolean);
    
    // Iterate over the tags array
    Tags := Product['tags'].AsArray;
    Write('    Tags: ');
    for j := 0 to Tags.Count - 1 do
    begin
      if j > 0 then
        Write(', ');
      Write(Tags[j].AsString);
    end;
    WriteLn;
    WriteLn;
    
    TotalPrice := TotalPrice + Product['price'].AsNumber;
  end;
  
  WriteLn('Total catalog value: $', TotalPrice:0:2);
  WriteLn;
  
  // Iterate over object keys using GetNames
  WriteLn('Top-level keys in the JSON:');
  Names := Data.GetNames;
  for Name in Names do
    WriteLn('  - ', Name);
  WriteLn;
end;

// ============================================================================
// EXAMPLE 3: Working with JSON Files
// ============================================================================
procedure WorkWithFiles;
var
  Config: IJSONObject;
  Loaded: IJSONValue;
  FileContent: TStringList;
  Success: Boolean;
begin
  WriteLn('=== Example 3: Working with JSON Files ===');
  WriteLn;
  
  // Create a configuration object to save
  Config := TJSON.Obj;
  Config.Add('appName', 'FileExample');
  Config.Add('version', '1.0.0');
  Config.Add('settings', TJSON.Obj);
  Config['settings'].AsObject.Add('theme', 'dark');
  Config['settings'].AsObject.Add('language', 'en');
  Config['settings'].AsObject.Add('autoSave', True);
  
  // Save to file using TStringList
  FileContent := TStringList.Create;
  try
    // ToString(True) produces pretty-printed JSON
    FileContent.Text := Config.ToString(True);
    FileContent.SaveToFile(CONFIG_FILE);
    WriteLn('Saved configuration to: ', CONFIG_FILE);
    WriteLn(Config.ToString(True));
    WriteLn;
  finally
    FileContent.Free;
  end;
  
  // Load from file
  FileContent := TStringList.Create;
  try
    if FileExists(CONFIG_FILE) then
    begin
      FileContent.LoadFromFile(CONFIG_FILE);
      
      // Use TryParse for safe parsing (won't raise exception on error)
      Success := TJSON.TryParse(FileContent.Text, Loaded);
      
      if Success then
      begin
        WriteLn('Loaded configuration from file:');
        WriteLn('  App Name: ', Loaded.AsObject['appName'].AsString);
        WriteLn('  Version: ', Loaded.AsObject['version'].AsString);
        WriteLn('  Theme: ', Loaded.AsObject['settings'].AsObject['theme'].AsString);
        WriteLn;
      end
      else
        WriteLn('Error: Failed to parse configuration file');
    end
    else
      WriteLn('Config file not found: ', CONFIG_FILE);
  finally
    FileContent.Free;
  end;
  
  // Clean up the test file
  if FileExists(CONFIG_FILE) then
    DeleteFile(CONFIG_FILE);
end;

// ============================================================================
// EXAMPLE 4: Data Transformation and Filtering
// ============================================================================
procedure TransformAndFilter;
var
  SourceJSON: string;
  Source: IJSONObject;
  SourceUsers: IJSONArray;
  FilteredUsers: IJSONArray;
  TransformedUser: IJSONObject;
  User: IJSONObject;
  Result: IJSONObject;
  i: Integer;
begin
  WriteLn('=== Example 4: Data Transformation and Filtering ===');
  WriteLn;
  
  // Source data with users
  SourceJSON :=
    '{' +
    '  "users": [' +
    '    {"id": 1, "name": "Alice", "age": 30, "department": "Engineering", "salary": 75000},' +
    '    {"id": 2, "name": "Bob", "age": 25, "department": "Marketing", "salary": 55000},' +
    '    {"id": 3, "name": "Carol", "age": 35, "department": "Engineering", "salary": 85000},' +
    '    {"id": 4, "name": "David", "age": 28, "department": "Sales", "salary": 60000},' +
    '    {"id": 5, "name": "Eve", "age": 32, "department": "Engineering", "salary": 90000}' +
    '  ]' +
    '}';
  
  Source := TJSON.Parse(SourceJSON).AsObject;
  SourceUsers := Source['users'].AsArray;
  
  WriteLn('Original data has ', SourceUsers.Count, ' users');
  WriteLn;
  
  // Filter: Get only Engineering department users
  // Transform: Create a simplified structure with calculated fields
  FilteredUsers := TJSON.Arr;
  
  for i := 0 to SourceUsers.Count - 1 do
  begin
    User := SourceUsers[i].AsObject;
    
    // Filter condition: only Engineering department
    if User['department'].AsString = 'Engineering' then
    begin
      // Transform: create new structure
      TransformedUser := TJSON.Obj;
      TransformedUser.Add('employeeId', 'EMP-' + IntToStr(User['id'].AsInteger));
      TransformedUser.Add('fullName', User['name'].AsString);
      TransformedUser.Add('experience', User['age'].AsInteger - 22); // Assume started at 22
      TransformedUser.Add('seniorLevel', User['salary'].AsNumber >= 80000);
      
      FilteredUsers.Add(TransformedUser);
    end;
  end;
  
  // Build result object
  Result := TJSON.Obj;
  Result.Add('department', 'Engineering');
  Result.Add('employeeCount', FilteredUsers.Count);
  Result.Add('employees', FilteredUsers);
  
  WriteLn('Filtered and transformed result:');
  WriteLn(Result.ToString(True));
  WriteLn;
end;

// ============================================================================
// EXAMPLE 5: Safe Value Access with Type Checking
// ============================================================================
procedure SafeValueAccess;
var
  JSON: string;
  Data: IJSONObject;
  Value: IJSONValue;
  MaybeNull: IJSONValue;
begin
  WriteLn('=== Example 5: Safe Value Access with Type Checking ===');
  WriteLn;
  
  // JSON with various types including null
  JSON :=
    '{' +
    '  "name": "Test",' +
    '  "count": 42,' +
    '  "ratio": 3.14159,' +
    '  "active": true,' +
    '  "data": null,' +
    '  "items": [1, 2, 3],' +
    '  "nested": {"key": "value"}' +
    '}';
  
  Data := TJSON.Parse(JSON).AsObject;
  
  // Check types before accessing values
  WriteLn('Type checking each field:');
  WriteLn;
  
  // Check for string
  Value := Data['name'];
  if Value.IsString then
    WriteLn('  name is a string: "', Value.AsString, '"')
  else
    WriteLn('  name is not a string');
  
  // Check for number
  Value := Data['count'];
  if Value.IsNumber then
    WriteLn('  count is a number: ', Value.AsInteger)
  else
    WriteLn('  count is not a number');
  
  // Check for boolean
  Value := Data['active'];
  if Value.IsBoolean then
    WriteLn('  active is a boolean: ', Value.AsBoolean)
  else
    WriteLn('  active is not a boolean');
  
  // Check for null
  MaybeNull := Data['data'];
  if MaybeNull.IsNull then
    WriteLn('  data is null')
  else
    WriteLn('  data has a value');
  
  // Check for array
  Value := Data['items'];
  if Value.IsArray then
    WriteLn('  items is an array with ', Value.AsArray.Count, ' elements')
  else
    WriteLn('  items is not an array');
  
  // Check for object
  Value := Data['nested'];
  if Value.IsObject then
    WriteLn('  nested is an object')
  else
    WriteLn('  nested is not an object');
  
  WriteLn;
  
  // Using Contains to check if a key exists
  WriteLn('Checking key existence:');
  if Data.Contains('name') then
    WriteLn('  "name" key exists')
  else
    WriteLn('  "name" key does not exist');
    
  if Data.Contains('nonexistent') then
    WriteLn('  "nonexistent" key exists')
  else
    WriteLn('  "nonexistent" key does not exist');
  
  WriteLn;
end;

// ============================================================================
// EXAMPLE 6: Working with Unicode and Special Characters
// ============================================================================
procedure UnicodeAndSpecialChars;
var
  Data: IJSONObject;
  Parsed: IJSONObject;
  JSON: string;
begin
  WriteLn('=== Example 6: Working with Unicode and Special Characters ===');
  WriteLn;
  
  // Create JSON with various special characters
  Data := TJSON.Obj;
  
  // Unicode strings (various languages)
  Data.Add('greeting_en', 'Hello, World!');
  Data.Add('greeting_jp', 'こんにちは世界');
  Data.Add('greeting_cn', '你好世界');
  Data.Add('greeting_emoji', '👋🌍✨');
  
  // Strings with special characters that need escaping
  Data.Add('path', 'C:\Users\Documents\file.txt');
  Data.Add('quote', 'He said "Hello"');
  Data.Add('newlines', 'Line 1'#10'Line 2'#10'Line 3');
  Data.Add('tabs', 'Column1'#9'Column2'#9'Column3');
  
  // Output as JSON (special chars will be escaped)
  JSON := Data.ToString(True);
  WriteLn('JSON with special characters:');
  WriteLn(JSON);
  WriteLn;
  
  // Parse it back and verify
  Parsed := TJSON.Parse(JSON).AsObject;
  WriteLn('Parsed back successfully:');
  WriteLn('  Japanese: ', Parsed['greeting_jp'].AsString);
  WriteLn('  Chinese: ', Parsed['greeting_cn'].AsString);
  WriteLn('  Emoji: ', Parsed['greeting_emoji'].AsString);
  WriteLn('  Path: ', Parsed['path'].AsString);
  WriteLn;
end;

// ============================================================================
// EXAMPLE 7: Modifying Existing JSON
// ============================================================================
procedure ModifyExistingJSON;
var
  JSON: string;
  Config: IJSONObject;
  Features: IJSONArray;
begin
  WriteLn('=== Example 7: Modifying Existing JSON ===');
  WriteLn;
  
  // Start with existing JSON
  JSON := '{"name":"MyApp","version":"1.0.0","features":["basic","standard"]}';
  WriteLn('Original: ', JSON);
  WriteLn;
  
  // Parse it
  Config := TJSON.Parse(JSON).AsObject;
  
  // Modify existing values using SetValue or indexed assignment
  // Update version
  Config['version'] := TJSON.Str('2.0.0');
  
  // Add new fields
  Config.Add('author', 'John Doe');
  Config.Add('license', 'MIT');
  Config.Add('updated', True);
  
  // Modify the array - add new features
  Features := Config['features'].AsArray;
  Features.Add('premium');
  Features.Add('enterprise');
  
  // Add a nested object
  Config.Add('repository', TJSON.Obj);
  Config['repository'].AsObject.Add('type', 'git');
  Config['repository'].AsObject.Add('url', 'https://github.com/example/myapp');
  
  WriteLn('Modified:');
  WriteLn(Config.ToString(True));
  WriteLn;
end;

// ============================================================================
// MAIN PROGRAM
// ============================================================================
begin
  try
    WriteLn;
    WriteLn('╔══════════════════════════════════════════════════════════════╗');
    WriteLn('║     SimpleJSON-FP Advanced Examples                          ║');
    WriteLn('║     Demonstrating powerful JSON handling in Free Pascal      ║');
    WriteLn('╚══════════════════════════════════════════════════════════════╝');
    WriteLn;
    
    // Run all examples
    BuildComplexStructure;
    IterateJSON;
    WorkWithFiles;
    TransformAndFilter;
    SafeValueAccess;
    UnicodeAndSpecialChars;
    ModifyExistingJSON;
    
    WriteLn('═══════════════════════════════════════════════════════════════');
    WriteLn('All examples completed successfully!');
    WriteLn;
    WriteLn('Key takeaways:');
    WriteLn('  • Use TJSON.Obj and TJSON.Arr to create JSON structures');
    WriteLn('  • Use TJSON.Parse() to parse JSON strings');
    WriteLn('  • Use .AsObject, .AsArray, .AsString, etc. to access values');
    WriteLn('  • Use .IsString, .IsNumber, .IsNull, etc. for type checking');
    WriteLn('  • Memory is automatically managed - no need to call Free!');
    WriteLn('═══════════════════════════════════════════════════════════════');
    WriteLn;
    
    // Pause console
    WriteLn('Press Enter to exit...');
    ReadLn;
    
  except
    on E: Exception do
    begin
      WriteLn('Error: ', E.ClassName, ' - ', E.Message);
      WriteLn('Press Enter to exit...');
      ReadLn;
      ExitCode := 1;
    end;
  end;
end.
