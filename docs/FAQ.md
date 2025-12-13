# SimpleJSON-FP FAQ

> [!NOTE]
> This library was extracted from [TidyKit-FP](https://github.com/ikelaiah/tidykit-fp). It contains only the JSON functionality from the original library.

## Contents

- [SimpleJSON-FP FAQ](#simplejson-fp-faq)
  - [Contents](#contents)
  - [Why does SimpleJSON-FP use ARC (Automatic Reference Counting) and interfaces?](#why-does-simplejson-fp-use-arc-automatic-reference-counting-and-interfaces)
  - [Performance: Automatic vs Manual Memory Management](#performance-automatic-vs-manual-memory-management)
    - [For Experienced: "Why use automatic when manual is more performant?"](#for-experienced-why-use-automatic-when-manual-is-more-performant)
    - [For New Users: "Why does SimpleJSON-FP require no manual freeing of objects?"](#for-new-users-why-does-simplejson-fp-require-no-manual-freeing-of-objects)
  - [What is a Factory Method? How is it different from interfaces or static functions?](#what-is-a-factory-method-how-is-it-different-from-interfaces-or-static-functions)
  - [Summary](#summary)

## Why does SimpleJSON-FP use ARC (Automatic Reference Counting) and interfaces?

SimpleJSON-FP uses interfaces with ARC for JSON types to provide:

- **Automatic memory management:** Objects are automatically freed when no longer referenced, reducing memory leaks and double-frees.
- **Safety:** No need to remember to call `Free` or handle exceptions for cleanup—ARC handles it for you.
- **Modern Pascal best practices:** Many modern Pascal libraries (including FPC's own JSON, XML, and database layers) use interfaces for memory safety and composability.
- **Cleaner code:** You can return objects from functions, store them in variables, and pass them around without worrying about manual cleanup.

**Example:**
```pascal
var
  Person, Address: IJSONObject;
begin
  Person := TJSON.Obj;
  Person.Add('name', 'John Smith');
  
  Address := TJSON.Obj;
  Address.Add('street', '123 Main St');
  Person.Add('address', Address);
  
  // No need to call Free—memory is managed automatically
end;
```

**What if I want manual memory management?**
TidyKit is designed for safety and ease of use. Manual memory management is error-prone and not recommended for most users. If you need explicit control, you can use the underlying classes directly, but this is advanced usage and not the default.

## Performance: Automatic vs Manual Memory Management

### For Experienced: "Why use automatic when manual is more performant?"

This is a valid concern. Here's why TidyKit made this trade-off:

- **Correctness over raw performance:** Memory leaks and access violations are much harder to debug than slight performance hits.
- **Real bottlenecks:** In most real-world applications, algorithm efficiency and I/O are bigger bottlenecks than ARC overhead.
- **Cost vs. Benefit:** The performance cost is minimal for most use cases, while the safety benefit is substantial.
- **Measured impact:** The overhead of reference counting varies by operation - from negligible for most use cases to more noticeable in tight loops with many temporary objects. This trade-off is generally acceptable for the safety benefits provided.
- **Selective use:** TidyKit only uses ARC for complex objects where memory management errors are most likely to occur.

If maximum performance is critical for your specific use case, you can:

1. Minimize temporary object creation in tight loops
2. Pre-allocate objects outside loops
3. For advanced cases, access the underlying implementation classes directly (not recommended)

### For New Users: "Why does SimpleJSON-FP require no manual freeing of objects?"

SimpleJSON-FP uses interface-based ARC for memory management:

1. **Interface-based ARC:** When you see an `I`-prefixed type (e.g., `IJSONObject`, `IJSONArray`, `IJSONValue`), you're using automatic reference counting. The object will be automatically freed when your variable goes out of scope or is assigned a different value.

**Benefits for beginners:**

- No need to remember to call `Free`
- No chance of "double-free" errors
- No memory leaks from forgotten `Free` calls
- No try-finally blocks needed for cleanup
- Safe to use in complex code paths

```pascal
// Safe, even if exceptions occur
procedure ProcessData;
var
  Data: IJSONObject;
begin
  Data := TJSON.Parse(SomeInput);
  // Use Data...
  // No Free needed - cleanup happens automatically
end;
```

## What is a Factory Method? How is it different from interfaces or static functions?

A **Factory Method** is a design pattern where a static function (usually on a class) creates and returns an instance of an object, often as an interface. This pattern is used extensively in SimpleJSON-FP.

- **Factory Method:**
  - Static function (e.g., `TJSON.Obj`, `TJSON.Arr`, `TJSON.Parse`)
  - Returns an interface (e.g., `IJSONObject`, `IJSONArray`, `IJSONValue`)
  - Hides the concrete implementation from the user
  - Ensures memory is managed automatically via ARC

**Example:**

```pascal
var
  Person: IJSONObject;
  Skills: IJSONArray;
begin
  // Factory methods create the objects
  Person := TJSON.Obj;
  Person.Add('name', 'John Smith');

  Skills := TJSON.Arr;
  Skills.Add('Pascal');
  Skills.Add('Python');
  Person.Add('skills', Skills);
end;
```

- **Interfaces:**
  - Define a contract for what methods/properties an object must have
  - Enable ARC when used as variable types
  - Used for memory safety and abstraction

- **Static Functions:**
  - Functions that belong to a class but do not require an instance
  - Used for utility operations (e.g., `TJSON.Parse`, `TJSON.PrettyPrint`)
  - May or may not return objects/interfaces

**Summary Table:**

| Pattern           | Example Usage                | Memory Management | Purpose                        |
|-------------------|-----------------------------|-------------------|--------------------------------|
| Factory Method    | `TJSON.Obj`                 | ARC (interface)   | Create and return an object    |
| Interface         | `IJSONObject`               | ARC               | Abstraction, memory safety     |
| Static Function   | `TJSON.Parse(...)`          | ARC (interface)   | Parse and return JSON          |

## Summary

- SimpleJSON-FP uses ARC and interfaces for safety, modernity, and ease of use.
- Factory methods are static functions that create and return interface-based objects, combining the best of both worlds.
- All JSON objects use interface-based memory management - no manual `Free` calls needed.
- This approach makes JSON handling safe and prevents memory leaks.

If you have more questions, please open an issue or discussion on GitHub!