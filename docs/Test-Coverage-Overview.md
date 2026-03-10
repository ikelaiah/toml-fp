# Test Coverage Overview

Your test suite comprises 70 tests, categorized as follows:

## Basic Types Tests (Procedures 1-6):
- String, Integer, Float, Boolean, DateTime values.
- Covers basic data types essential for TOML parsing and serialization.

## Array Tests (Procedures 10-16):
- Homogeneous Arrays: Integer, String, Boolean arrays.
- Mixed-Type Arrays: Arrays containing multiple data types.
- Empty Arrays: Ensuring empty arrays are handled correctly.
- Arrays with Inline Tables: Testing the parsing and serialization of arrays containing inline tables with newlines.

## Table Tests (Procedures 20-25):
- Basic Tables: Single-level tables with different data types.
- Inline Tables: Compact table definitions.
- Empty Tables: Handling tables without any key-value pairs.
- Nested Tables: Tables within tables for hierarchical data.

## Serialization Tests (Procedures 30-37):
- Type-Specific Serialization: Ensures each data type serializes correctly.
- Table Serialization: Handling nested and complex table structures.
- Hierarchical Table Paths vs Literal Dotted Keys: Proper distinction between `[server.database]` (hierarchical) and `["server.database"]` (literal dotted key).
- Serialization Accuracy: Verifying the output matches expected TOML strings.
- Array of Tables Serialization: Ensuring arrays of tables are properly serialized using the [[table]] format.

## Error Cases (Procedures 40-44):
- Invalid Data Types: Testing parser's response to incorrect data types.
- Duplicate Keys: Ensuring duplicate keys are handled as per spec.
- Invalid Table Keys: Validating table key formats.

## TOML v1.0.0 Specification Tests (Procedures 50-60):
- Multiline Strings, Literal Strings: Handling different string formats, including Unicode escapes, strict basic-string escape validation, and multiline trimming rules.
- Numerical Formats: Integers with underscores, hexadecimal, octal, binary.
- Floating Points with Underscores: Ensuring proper parsing.
- DateTime Variants: Local dates, times, local datetimes with `T` or space separators, and datetime with offsets.
- Array of Tables, Dotted Table Keys: Advanced table structures.

## Additional Specification Tests (Procedures 61-72):
- Infinity and NaN Handling: Parsing special floating-point values.
- Offset DateTimes: Timezone-aware datetime parsing.
- Quoted Keys, Whitespace Handling: Ensuring flexibility in key definitions and parsing.
- Array Type Validation: Ensuring array types conform to TOML spec.
- Table Array Nesting: Testing nested array of tables structures.
- Complex Keys: Handling complex key expressions.
- Hierarchical Nested Tables: Correctly serializing nested table hierarchies (Test71).
- Literal Dotted Keys: Properly quoting keys containing dots (Test72).
