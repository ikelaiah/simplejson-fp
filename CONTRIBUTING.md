# Contributing to SimpleJSON-FP

Thank you for your interest in contributing to SimpleJSON-FP! We want to make contributing to this project as easy and transparent as possible.

## 📝 Code of Conduct

- Be respectful and inclusive
- Use welcoming and inclusive language
- Be collaborative
- Focus on what is best for the community
- Show empathy towards other community members

## 🚀 Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/your-username/simplejson-fp.git
   ```
3. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 💻 Development Guidelines

### Code Style

#### Naming Conventions
- `T` prefix for types (e.g., `TJSON`, `TJSONObject`)
- `I` prefix for interfaces (e.g., `IJSONValue`, `IJSONObject`)
- `F` prefix for private fields (e.g., `FValue`, `FItems`)
- `A` prefix for parameters in documentation (e.g., `AKey`, `AValue`)
- PascalCase for types, methods, and variables
- UPPERCASE for constants

#### Formatting
- 2 spaces for indentation (no tabs)
- No space before opening parenthesis in method calls
- Space after commas in parameter lists
- Operators surrounded by spaces (`a := b + c`)
- Begin/end on new lines for procedures/functions
- Begin/end on same line for control structures

#### Documentation
- Block comments for class/interface documentation
- Line comments for implementation details
- Document public methods using:
  ```pascal
  { @description Detailed description
    @param ParamName Description
    @return Description of return value }
  ```
- Comments should explain why, not what (the code should be self-documenting)

#### Code Organization
- Public methods first, then protected, then private
- Group related methods together
- Implementation details after interface
- Local variables at the beginning of methods
- Keep methods focused and small (ideally < 50 lines)

#### Error Handling
- Use exceptions for error conditions
- Clean up resources in `finally` blocks
- Provide meaningful error messages
- Use custom exception types for specific error cases

### Commit Messages

- Use clear and meaningful commit messages
- Start with a verb (Add, Fix, Update, etc.)
- Reference issues when relevant

Example:
```
Add deep clone method to IJSONObject

- Implement deep cloning for JSON objects
- Add unit tests
- Update documentation
Fixes #123
```

### Testing

- Add unit tests for new functionality
- Ensure all tests pass before submitting PR
- Test on Windows (minimum requirement)
- If possible, test on Linux/macOS

### Documentation

- Update README.md if needed
- Add/update API documentation
- Include examples for new features
- Update changelog

## 📋 Pull Request Process

1. Update the README.md with details of changes if needed
2. Update the documentation
3. Add tests for new functionality
4. Ensure the test suite passes
5. Update the CHANGELOG.md
6. Submit a pull request

### Pull Request Title Format

```
[Type] Short description

Types:
- [Feature] - New functionality
- [Fix] - Bug fixes
- [Docs] - Documentation only
- [Test] - Test-related changes
- [Refactor] - Code refactoring
```

## 🐛 Reporting Issues

- Use the issue tracker
- Describe the bug or feature request clearly
- Include code examples if relevant
- Provide system information (OS, FPC version)
- Follow the issue template

## 📚 Documentation Contributions

We especially welcome documentation improvements:
- Fix typos
- Add examples
- Clarify confusing sections
- Add missing documentation
- Translate documentation

## ⭐ Recognition

Contributors will be recognized in:
- CONTRIBUTORS.md file
- Release notes
- Project documentation

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License. 