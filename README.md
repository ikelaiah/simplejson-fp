# 🔧 SimpleJSON-FP: A Simple JSON Library for Free Pascal

[![FPC](https://img.shields.io/badge/Free%20Pascal-3.2.2-blue.svg)](https://www.freepascal.org/)
[![Lazarus](https://img.shields.io/badge/Lazarus-3.6+-blue.svg)](https://www.lazarus-ide.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.md)
[![Documentation](https://img.shields.io/badge/Docs-Available-brightgreen.svg)](docs/)
[![Tests](https://img.shields.io/badge/Tests-Passing-brightgreen.svg)](tests/)
[![Status](https://img.shields.io/badge/Status-Development-yellow.svg)]()
[![Version](https://img.shields.io/badge/Version-1.0.0-blueviolet.svg)]()

**A lightweight, user-friendly JSON library for Free Pascal with automatic reference counting.**

> [!NOTE]
> 📦 This package was extracted from [TidyKit-FP](https://github.com/ikelaiah/tidykit-fp), which was archived earlier due to its size. SimpleJSON-FP contains only the JSON functionality from the original TidyKit library, making it more focused and easier to use.

## ✨ Say Goodbye to JSON Complexity

Working with JSON in Pascal has never been easier. SimpleJSON-FP provides a clean, intuitive API with automatic memory management.

```pascal
// JSON has never been easier
var
  Json: IJSONValue;
  Person: IJSONObject;
begin
  // Parse JSON with ease
  Json := TJSON.Parse('{"name":"Pascal","age":50}');
  WriteLn('Name: ', Json['name'].AsString);

  // Build JSON programmatically
  Person := TJSON.Obj;
  Person.Add('name', 'Alice');
  Person.Add('age', 30);
  Person.Add('isActive', True);

  // No need to worry about freeing - automatic memory management!
  WriteLn(Person.ToString(True));  // Pretty-printed JSON
end;
```

## 🌟 Why SimpleJSON-FP?

- **Focused and Lightweight**: Just JSON, done right - no bloat, no unnecessary dependencies
- **Modern Pascal**: Clean, consistent API with FPC 3.2.2 compatibility
- **Rock-Solid Reliability**: Extensive test suite with 41 comprehensive test cases
- **Standards Compliant**: Fully adheres to ECMA-404 and RFC 8259 JSON specifications
- **Smart Memory Management**: Forget manual Free calls with interface-based reference counting
- **Full Unicode Support**: Proper handling of UTF-16, escape sequences, and surrogate pairs

## 📑 Table of Contents

- [🔧 SimpleJSON-FP: A Simple JSON Library for Free Pascal](#-simplejson-fp-a-simple-json-library-for-free-pascal)
  - [✨ Say Goodbye to JSON Complexity](#-say-goodbye-to-json-complexity)
  - [🌟 Why SimpleJSON-FP?](#-why-simplejson-fp)
  - [📑 Table of Contents](#-table-of-contents)
  - [✨ Features](#-features)
    - [📝 JSON Handling](#-json-handling)
    - [All Features at a Glance](#all-features-at-a-glance)
  - [💻 Installation (Lazarus IDE)](#-installation-lazarus-ide)
  - [💻 Installation (General)](#-installation-general)
  - [📝 Library Usage](#-library-usage)
  - [🚀 Quick Start](#-quick-start)
    - [🔄 JSON Operations](#-json-operations)
  - [📖 System Requirements](#-system-requirements)
    - [Tested Environments](#tested-environments)
    - [Dependencies](#dependencies)
    - [Build Requirements](#build-requirements)
  - [📚 Documentation](#-documentation)
  - [✅ Testing](#-testing)
  - [🤝 Contributing](#-contributing)
  - [⚖️ License](#️-license)
  - [🙏 Acknowledgments](#-acknowledgments)

## ✨ Features

### 📝 JSON Handling
Parse, create and modify JSON with ease
```pascal
// Parse existing JSON
var
  Config: IJSONValue;
  User: IJSONObject;
begin
  Config := TJSON.Parse(jsonText);

  // Build JSON programmatically
  User := TJSON.Obj;
  User.Add('name', 'Alice');
  User.Add('age', 30);
end;
```

### All Features at a Glance

- 🔁 **JSON**: Memory-managed JSON with full Unicode support
  - Interface-based design for automatic memory management
  - Comprehensive JSON parsing and generation
  - Support for all JSON data types (objects, arrays, strings, numbers, booleans, null)
  - Pretty printing and compact output options
  - Full Unicode support with proper escape sequence handling
- Improved scanner validation and diagnostics for number parsing errors (including positional information)
  - Error handling with descriptive messages
  - Easy-to-use factory methods
  - Standards compliant (ECMA-404, RFC 8259)

## 💻 Installation (Lazarus IDE)

1. Clone the repository:

```bash
git clone https://github.com/ikelaiah/simplejson-fp
```

2. Open / start a new project in Lazarus IDE

3. Go to `Package` → `Open Package File (.lpk)...`

4. Navigate to the SimpleJSON-FP packages in the `packages/lazarus/` folder and select `simplejson_fp.lpk`

5. In the package window that opens, click `Compile`

6. Click `Use → Add to Project` to install the package

The SimpleJSON-FP package is now ready to use in your Lazarus project.

## 💻 Installation (General)

1. Clone the repository:

```bash
git clone https://github.com/ikelaiah/simplejson-fp
```

2. Add the source directory to your project's search path.

## 📝 Library Usage

```pascal
uses
  // JSON functionality
  SimpleJSON;              // All JSON functionality
```

## 🚀 Quick Start

### 🔄 JSON Operations

```pascal
var
  Person: IJSONObject;
  Address: IJSONObject;
  Hobbies: IJSONArray;
  JSON: string;
  Value: IJSONValue;
begin
  // Create a person object
  Person := TJSON.Obj;
  Person.Add('name', 'John Smith');
  Person.Add('age', 30);
  Person.Add('isActive', True);

  // Create and add an address object
  Address := TJSON.Obj;
  Address.Add('street', '123 Main St');
  Address.Add('city', 'Springfield');
  Address.Add('zipCode', '12345');
  Person.Add('address', Address);

  // Create and add a hobbies array
  Hobbies := TJSON.Arr;
  Hobbies.Add('reading');
  Hobbies.Add('cycling');
  Hobbies.Add('swimming');
  Person.Add('hobbies', Hobbies);

  // Convert to JSON string with pretty printing
  JSON := Person.ToString(True);
  WriteLn(JSON);

  // Parse JSON string
  JSON := '{"name":"Jane Doe","age":25,"skills":["Pascal","Python"]}';
  Value := TJSON.Parse(JSON);
  Person := Value.AsObject;

  // Access values
  WriteLn('Name: ', Person['name'].AsString);
  WriteLn('Age: ', Person['age'].AsInteger);
  WriteLn('First Skill: ', Person['skills'].AsArray[0].AsString);

  // Error handling
  try
    Value := TJSON.Parse('{invalid json}');
  except
    on E: EJSONException do
      WriteLn('Error: ', E.Message);
  end;
end;
```

## 📖 System Requirements

### Tested Environments

| Module                          | Windows 11 | Ubuntu 24.04.2 |
|---------------------------------|------------|----------------|
| SimpleJSON                      | ✅         | ✅             |
| SimpleJSON.Factory              | ✅         | ✅             |
| SimpleJSON.Parser               | ✅         | ✅             |
| SimpleJSON.Scanner              | ✅         | ✅             |
| SimpleJSON.Types                | ✅         | ✅             |
| SimpleJSON.Writer               | ✅         | ✅             |

### Dependencies

- Uses only standard Free Pascal RTL units
- No external dependencies required

### Build Requirements

- Free Pascal Compiler (FPC) 3.2.2+
- Lazarus 3.6+
- Basic development tools (git, terminal, etc)

## 📚 Documentation

For detailed documentation, see:

- 📋 [Cheat Sheet](docs/cheat-sheet.md)
- ❓ [FAQ](docs/FAQ.md) - Common questions about design decisions and patterns
- 🔄 [JSON Reference](docs/SimpleJSON.md)

## ✅ Testing

1. Open the `TestRunner.lpi` using Lazarus IDE
2. Compile the project
3. Run the Test Runner:

```bash
$ cd tests
$ ./TestRunner.exe -a --format=plain
```

- The test suite includes 41 tests that cover parsing, writing, edge-cases, roundtrip validation, and fuzz tests.
- A diagnostic (Test34) will dump a JSON file to `tests/failed_large_array.json` if a large array parse fails; useful for debugging.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the Project
2. Create your Feature Branch (git checkout -b feature/AmazingFeature)
3. Commit your Changes (git commit -m 'Add some AmazingFeature')
4. Push to the Branch (git push origin feature/AmazingFeature)
5. Open a Pull Request

## ⚖️ License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.

## 🙏 Acknowledgments

- Originally part of [TidyKit-FP](https://github.com/ikelaiah/tidykit-fp)
- FPC Team for Free Pascal
- Contributors and maintainers

---

*Feedback and suggestions are welcome! See the [issues](https://github.com/ikelaiah/simplejson-fp/issues) page to contribute ideas or track progress.*
