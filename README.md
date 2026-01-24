# kira-test

A functional testing framework for the Kira programming language.

## Features

- **Rich Assertions** - Boolean, equality, comparison, range, Option, Result, string, and list assertions
- **Test Organization** - Group tests into suites with descriptive names
- **Lifecycle Hooks** - Setup/teardown at suite level, before/after each test
- **Test Tagging** - Tag tests and filter by tags for selective execution
- **Multiple Runners** - Standard, timed, and parallel execution modes
- **Fail-Fast Mode** - Stop on first failure for quick feedback

## Installation

### As a Git Submodule (Recommended)

```bash
git submodule add <repo-url> deps/kira_test
```

Then add to your project's `kira.toml`:

```toml
[modules]
kira_test = "deps/kira_test"
```

### Project Structure

```
your-project/
├── kira.toml              # Your project manifest
├── deps/
│   └── kira_test/         # This package (submodule)
│       ├── kira.toml      # Package manifest
│       ├── kira_test.ki   # Main entry point
│       └── ...
├── src/
│   └── main.ki
└── tests/
    └── test_your_module.ki
```

## Usage

### Basic Test

```kira
import kira_test.{
    test, suite, run_and_report,
    assert_eq_i32, assert_true
}

fn add(a: i32, b: i32) -> i32 {
    return a + b
}

fn my_tests() -> TestSuite {
    let t1: TestCase = test("add returns correct sum", fn() -> AssertionResult {
        return assert_eq_i32(5, add(2, 3))
    })

    let t2: TestCase = test("add handles negatives", fn() -> AssertionResult {
        return assert_eq_i32(-1, add(2, -3))
    })

    let tests: List[TestCase] = std.list.cons(t1, std.list.singleton(t2))
    return suite("Math Tests", tests)
}

effect fn main() -> void {
    let suites: List[TestSuite] = std.list.singleton(my_tests())
    let passed: bool = run_and_report(suites)
    return
}
```

### Tagged Tests

```kira
import kira_test.{
    test_tagged, suite, run_and_report_with_config,
    config_with_tags, assert_true
}

fn tagged_tests() -> TestSuite {
    let unit_tag: List[string] = std.list.singleton("unit")
    let slow_tag: List[string] = std.list.singleton("slow")

    let t1: TestCase = test_tagged("fast test", unit_tag, fn() -> AssertionResult {
        return assert_true(true)
    })

    let t2: TestCase = test_tagged("slow test", slow_tag, fn() -> AssertionResult {
        return assert_true(true)
    })

    let tests: List[TestCase] = std.list.cons(t1, std.list.singleton(t2))
    return suite("Tagged Tests", tests)
}

effect fn main() -> void {
    let suites: List[TestSuite] = std.list.singleton(tagged_tests())
    let unit_tags: List[string] = std.list.singleton("unit")
    let config: RunConfig = config_with_tags(unit_tags)
    let passed: bool = run_and_report_with_config(suites, config)
    return
}
```

### Lifecycle Hooks

```kira
import kira_test.{
    test, suite_with_each, suite_full, run_and_report,
    assert_true
}

var counter: i32 = 0

fn setup() -> void {
    counter = 0
    return
}

fn before_each() -> void {
    counter = counter + 1
    return
}

fn hook_tests() -> TestSuite {
    let t1: TestCase = test("first test", fn() -> AssertionResult {
        return assert_true(counter > 0)
    })

    let tests: List[TestCase] = std.list.singleton(t1)
    return suite_with_each("Hook Tests", tests, before_each, fn() -> void { return })
}
```

### Timed and Parallel Execution

```kira
import kira_test.{
    run_and_report_timed,
    run_and_report_parallel,
    run_and_report_parallel_timed
}

effect fn main() -> void {
    let suites: List[TestSuite] = ...

    // Run with timing information
    let passed: bool = run_and_report_timed(suites)

    // Run tests in parallel
    let passed: bool = run_and_report_parallel(suites)

    // Run in parallel with timing
    let passed: bool = run_and_report_parallel_timed(suites)
    return
}
```

## Assertions

| Function | Description |
|----------|-------------|
| `assert_true(bool)` | Assert value is true |
| `assert_false(bool)` | Assert value is false |
| `assert_eq_i32(expected, actual)` | Assert i32 equality |
| `assert_eq_str(expected, actual)` | Assert string equality |
| `assert_eq_f64(expected, actual)` | Assert f64 equality |
| `assert_eq_bool(expected, actual)` | Assert bool equality |
| `assert_approx_eq(expected, actual, epsilon)` | Assert f64 approximate equality |
| `assert_greater_i32(than, value)` | Assert value > than |
| `assert_less_i32(than, value)` | Assert value < than |
| `assert_in_range_i32(min, max, value)` | Assert min <= value <= max |
| `assert_in_range_f64(min, max, value)` | Assert min <= value <= max |
| `assert_some_i32(option)` | Assert Option is Some |
| `assert_none_i32(option)` | Assert Option is None |
| `assert_some_eq_i32(expected, option)` | Assert Some contains expected |
| `assert_some_str(option)` | Assert Option[string] is Some |
| `assert_none_str(option)` | Assert Option[string] is None |
| `assert_some_eq_str(expected, option)` | Assert Some contains expected string |
| `assert_ok_i32(result)` | Assert Result is Ok |
| `assert_err_i32(result)` | Assert Result is Err |
| `assert_ok_eq_i32(expected, result)` | Assert Ok contains expected |
| `assert_err_contains_i32(result, substr)` | Assert Err message contains substring |
| `assert_contains(string, substr)` | Assert string contains substring |
| `assert_starts_with(string, prefix)` | Assert string starts with prefix |
| `assert_ends_with(string, suffix)` | Assert string ends with suffix |
| `assert_empty_i32(list)` | Assert list is empty |
| `assert_not_empty_i32(list)` | Assert list is not empty |
| `assert_length_i32(expected, list)` | Assert list has expected length |

## Configuration

```kira
// Default configuration
let config: RunConfig = default_config()

// Stop on first failure
let config: RunConfig = config_fail_fast()

// Filter by tags
let tags: List[string] = std.list.singleton("unit")
let config: RunConfig = config_with_tags(tags)

// Full configuration
let config: RunConfig = config_full(true, Some(tags))
```

## Package Structure

```
kira_test/
├── kira.toml          # Package manifest
├── kira_test.ki       # Main entry (re-exports all public items)
├── types.ki           # Core type definitions (ADTs)
├── assertions.ki      # Assertion functions
├── builders.ki        # Test/suite/config builders
├── runners.ki         # Test execution functions
├── tagging.ki         # Tag filtering
├── reporters.ki       # Result reporting (effect functions)
├── tests/             # Self-tests
└── examples/          # Usage examples
```

## Examples

See `examples/test_demo.ki` for a complete demonstration of all features.

## License

MIT License - see [LICENSE](LICENSE) for details.
