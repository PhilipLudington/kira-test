## Kira Development

This project uses the Kira-Toolkit framework (v0.1.0) for Kira development standards.

See `kira-toolkit/KIRATOOLKIT.md` for coding guidelines and available commands.
See `kira-toolkit/STANDARDS.md` for full coding standards.

### Key Syntax Requirements
- **Explicit types**: `let x: i32 = 42`
- **Explicit return**: `return value` (not implicit last expression)
- **Pure by default**: Use `effect fn` for IO operations
- **Pattern matching**: All matches must be exhaustive
- **Closures with full types**: `fn(x: i32) -> i32 { return x * 2 }`

## Running Tests

Always use the GitStat wrapper script to run tests:
```bash
./run-tests.sh
```
Do NOT run `kira run` on test files directly - use the wrapper script to preserve GitStat integration and result tracking.

## Building / Type Checking

Always use the GitStat wrapper script to check the build:
```bash
./build.sh
```
Do NOT run `kira check` directly - use the wrapper script to preserve GitStat integration.
