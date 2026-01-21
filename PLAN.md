# kira-test: Testing Framework for Kira

## Overview

A functional testing framework that exercises Kira's ADTs, pattern matching, higher-order functions, closures, and effect system.

## Core Design

### ADTs (Algebraic Data Types)

```kira
type AssertionResult =
    | Passed
    | Failed(string)

type TestResult = {
    name: string,
    passed: bool,
    message: string
}

type TestCase = {
    name: string,
    run: fn() -> AssertionResult
}

type TestSuite = {
    name: string,
    tests: List[TestCase],
    setup: Option[fn() -> void],
    teardown: Option[fn() -> void]
}

type TestSummary = {
    suite_name: string,
    total: i32,
    passed: i32,
    failed: i32,
    failures: List[TestResult]
}
```

### Assertion Functions (Pure)

Type-specific assertions (no traits available):
- `assert_true`, `assert_false`
- `assert_eq_i32`, `assert_eq_str`, `assert_eq_bool`, `assert_eq_f64`
- `assert_not_eq_i32`, `assert_not_eq_str`
- `assert_some_i32`, `assert_none_i32`, `assert_some_eq_i32`
- `assert_ok_i32`, `assert_err_i32`, `assert_ok_eq_i32`
- `assert_greater_i32`, `assert_less_i32`
- `assert_contains`, `assert_starts_with`, `assert_ends_with`
- `assert_empty_i32`, `assert_not_empty_i32`, `assert_length_i32`
- `assert_approx_eq` (for floats with epsilon)

### Test Builders (Pure)

```kira
fn test(name: string, test_fn: fn() -> AssertionResult) -> TestCase
fn suite(name: string, tests: List[TestCase]) -> TestSuite
fn suite_with_setup(name: string, tests: List[TestCase], setup: fn() -> void) -> TestSuite
fn suite_with_lifecycle(name: string, tests: List[TestCase], setup: fn() -> void, teardown: fn() -> void) -> TestSuite
```

### Test Runner (Pure + Effect for output)

```kira
fn run_suite(suite: TestSuite) -> TestSummary           // Pure
fn run_all_suites(suites: List[TestSuite]) -> List[TestSummary]  // Pure
effect fn run_and_report(suites: List[TestSuite]) -> bool  // Effect for I/O
```

## Files to Create

1. **`lib/kira-test.ki`** - Main framework (~250 lines)
   - Core types (ADTs)
   - All assertion functions
   - Test builders
   - Test runner
   - Reporting functions

2. **`examples/test_demo.ki`** - Usage example (~80 lines)
   - Sample functions to test
   - Example test cases and suites
   - Main entry point

## Features Exercised

| Kira Feature | How Used |
|--------------|----------|
| Sum types (ADT) | AssertionResult (Passed/Failed) |
| Product types (records) | TestResult, TestCase, TestSuite, TestSummary |
| Pattern matching | All assertion return handling, Option/Result checks |
| Higher-order functions | test() takes closures, map/fold for running tests |
| Closures | Test bodies as `fn() -> AssertionResult` |
| Generics | List[TestCase], Option[fn() -> void] |
| Effects | print_summary, run_and_report marked `effect fn` |
| std.list | map, filter, fold, cons, empty, length |
| std.string | contains, starts_with, ends_with |
| Option/Result | Assertions for Some/None, Ok/Err |

## Example Usage

```kira
import kira_test.{ test, suite, run_and_report, assert_eq_i32 }

fn add(a: i32, b: i32) -> i32 { return a + b }

effect fn main() -> void {
    let t1: TestCase = test("add works", fn() -> AssertionResult {
        return assert_eq_i32(5, add(2, 3))
    })

    let tests: List[TestCase] = std.list.singleton(t1)
    let s: TestSuite = suite("Math", tests)
    let suites: List[TestSuite] = std.list.singleton(s)

    let _: bool = run_and_report(suites)
}
```

## Verification

1. Run the example: `zig build run -- examples/test_demo.ki`
2. Expected output:
   ```
   Suite: Math Tests
   =================

   All 3 tests passed!
   ```
3. Modify a test to fail and verify failure reporting shows the error message

## Implementation Order

1. Create `lib/kira-test.ki` with core types
2. Add assertion functions
3. Add test builders
4. Add test runner
5. Add reporting (effect functions)
6. Create `examples/test_demo.ki`
7. Run and verify output
