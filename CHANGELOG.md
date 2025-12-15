# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

-## [1.1.0] - 2025-12-15

### Added

- **System.JSON compatibility layer & examples**: Added `examples/SystemJSON` demonstrating a Delphi `System.JSON`-compatible API and migration patterns to ease porting Delphi code to Lazarus/FPC.
- **`ExtractValue` helper**: New convenience function `ExtractValue(Obj: IJSONObject; const Name: string): IJSONValue` to extract (take-and-remove) values from interface-based objects without manual freeing.
- **New example demos**: Added Find/TryGet/Remove, path-based access, type-checking, direct JSON types, and cloning demos to the System.JSON example.

### Changed

- **Documentation**: Updated `docs/cheat-sheet.md` and `docs/SimpleJSON.md` to document `ExtractValue` and clarify remove/extract semantics for interface- vs object-based APIs.

### Fixed

- **RemovePair ownership clarification & leak fix**: Clarified ownership semantics for `TJSONObject.RemovePair` in `src/System.JSON.pas` (caller must free returned `TJSONPair`), and fixed demo code to free removed pairs to avoid leaks.

### Added (tests)

- `Test42_ExtractValue`: Unit test validating `ExtractValue` behavior (returns value and removes key; returns nil for missing keys).


## [1.0.0] - 2025-12-13
- Focused library containing only JSON operations from the original TidyKit library
- **Breaking change**: Renamed namespace from `TidyKit.JSON` to `SimpleJSON` for a fresh start
- Updated all documentation to reflect SimpleJSON-FP branding
- Simplified README to focus on JSON-specific features
- Updated cheat sheet to include only JSON operations
- Updated FAQ to focus on JSON-related questions

### Fixed

- **Locale-safe number formatting**: `TJSONNumber.ToString` now uses `TFormatSettings` with explicit decimal separator to ensure correct output regardless of system locale
- **Property name escaping**: `TJSONWriter` now properly escapes special characters (`"`, `\`, control chars) in JSON object property names
- **Code cleanup**: Removed unused variables in `SimpleJSON.Scanner` and unused `TypInfo` unit in `SimpleJSON.pas`

### Added

- **7 new test cases** (Test19-Test25) for comprehensive coverage:
  - `Test19_IntFactory`: Tests `TJSON.Int()` factory method
  - `Test20_TryParseSuccess`: Tests `TryParse` with valid JSON (all types)
  - `Test21_PropertyNameEscaping`: Tests property names with special characters roundtrip
  - `Test22_ObjectContainsAndModify`: Tests `Contains`, `SetValue`, nil handling
  - `Test23_ArrayModification`: Tests `SetItem`, `Clear`, nil handling
  - `Test24_KeyOrderPreservation`: Verifies insertion order is maintained
  - `Test25_SurrogatePairs`: Tests emoji/Unicode surrogate pair handling

- **7 high-priority RFC 8259 compliance tests** (Test26-Test32):
  - `Test26_InvalidPlusSign`: Verifies `+123` is rejected (leading plus not allowed)
  - `Test27_LeadingPlusExponent`: Verifies `1e+10` is accepted (plus in exponent is valid)
  - `Test28_SingleQuoteString`: Verifies `'hello'` is rejected (only double quotes allowed)
  - `Test29_TrailingGarbage`: Verifies `{"a":1} extra` is rejected (no trailing content)
  - `Test30_BOMHandling`: Tests UTF-8 BOM handling (graceful accept or reject)
  - `Test31_RejectComments`: Verifies `//` and `/* */` comments are rejected
  - `Test32_MaxNestingDepth`: Tests deeply nested structures (50-500 levels)

### Added (Medium/Low priority tests)

- **9 new medium/low-priority tests** (Test33-Test41):
  - `Test33_LongString`: Very long string roundtrip and special characters handling
  - `Test34_LargeArray`: Thousands of items (performance/memory) and diagnostic dump on failure
  - `Test35_RoundtripWriterParser`: Ensures writer+parser roundtrip consistency for compact and pretty output
  - `Test36_DuplicateKeys`: Verifies last-in wins for duplicate object keys and insertion/replace semantics
  - `Test37_SolidusEscape`: Escaped/unescaped solidus handling (\/ vs /)
  - `Test38_UnicodeHexCase`: Unicode hex case-insensitivity \u00ff == \u00FF
  - `Test39_BigExponents`: Very large/small exponents parsing and roundtrip behavior
  - `Test40_FuzzBasic`: Basic fuzz testing ensures parser doesn't crash on malformed inputs
  - `Test41_SingleZeroNumber`: Asserts the scanner handles a single '0' token correctly

### Fixed (Additional)

- **Number scanning bug**: Fixed an edge-case in `SimpleJSON.Scanner.ReadNumber` where a single leading `0` was not counted toward digits, causing `Number must contain at least one digit` errors; added improved diagnostics with position info

### Features

- Interface-based design for automatic memory management
- Comprehensive JSON parsing and generation
- Support for all JSON data types (objects, arrays, strings, numbers, booleans, null)
- Pretty printing and compact output options
- Full Unicode support with proper escape sequence handling
- Error handling with descriptive messages
- Easy-to-use factory methods
- Standards compliant (ECMA-404, RFC 8259)
- 41 comprehensive test cases
- Cross-platform support (Windows 11 and Ubuntu 24.04.2 tested)

### Technical Details

- New `SimpleJSON` namespace for a fresh start (breaking change from TidyKit):
  - `SimpleJSON` - Main JSON interface
  - `SimpleJSON.Factory` - Factory methods for creating JSON values
  - `SimpleJSON.Parser` - JSON parsing functionality
  - `SimpleJSON.Scanner` - JSON tokenization
  - `SimpleJSON.Types` - Core JSON type implementations
  - `SimpleJSON.Writer` - JSON serialization

---

## Previous TidyKit-FP History

The following entries are from the original TidyKit-FP project before the JSON functionality was extracted into SimpleJSON-FP.

## Release [0.1.8] - 2025-05-20

### Added
- New TidyKit.Collections.* units with comprehensive generic collection implementations
- New `TidyKit.ParseArgs` unit for record-based command-line argument parsing

### Changed
- Refined README to better explain collection features and limitations
- Updated documentation for all modules to reflect the latest API and usage patterns

### Fixed
- Minor documentation corrections and typo fixes

## Release [0.1.7] - 2025-04-30

### Changed
- Moved all TidyKit.Math.* modules to a separate library
- Updated documentation to reflect the restructuring of modules
- Removed TidyKit.Core.pas unit

### Added
- New clear focus on application development utilities
- Improved installation instructions

### Fixes
- Various minor bugfixes and performance improvements

## Release [0.1.6] - 2025-04-24

### Added
- More examples to showcase the usage of TidyKit.FS module

### Fixes
- Various bugfixes and improvements to the TidyKit.FS module
- Bugfix TidyKit.Logger.pas unit

## [0.1.5] - 2025-04-21

### Added
- Added Ubuntu 24.04.02 compatibility for TidKit.DateTime and TidyKit.FS modules
- Added automatic test environment detection for TidyKit.Request
- Added HTTP fallback mechanism for testing HTTPS endpoints

### Fixed
- Fixed file timestamp handling issues on Unix systems
- Fixed path normalization for cross-platform compatibility
- Fixed OpenSSL initialization and error handling on Linux systems

### Changed
- Reorganized platform-specific code for better readability
- Improved test organization with clearer platform-specific sections

## [0.1.0] - 2025-03-13

### Added
- Initial release of TidyKit-FP
- JSON operations with interface-based memory management
- Logging system with multiple output destinations
- Cryptography enhancements (SHA3, SHA2, AES-256)
- Archive operations (ZIP/TAR)
- HTTP client with request/response handling
- FileSystem operations (`TFileKit`)
- String operations (`TStringKit`)
- DateTime operations (`TDateTimeKit`)
- Cross-platform support (Windows tested)

### Improved
- Comprehensive documentation
- Memory-safe interface design
- Professional README with badges and detailed feature list

### Fixed
- Memory leaks in various operations
- Error handling improvements
