# Go Best Practices

## Code Style

1. **`gofmt` / `goimports` is mandatory**: All code must be formatted. Run automatically on save and in CI. Never bypass.
2. **`golangci-lint`**: Enable at minimum: `errcheck`, `govet`, `staticcheck`, `gosimple`, `revive`, `gocyclo`, `exhaustive`.
3. **Naming**:
   - Packages: short, lowercase, single word — `user`, `postgres`, `httputil`. No `_` or `camelCase`.
   - Exported: `PascalCase`. Unexported: `camelCase`.
   - Interfaces: single-method types use `-er` suffix (`Reader`, `Storer`). Multi-method types use a noun (`UserRepository`).
   - Avoid redundant package prefix in names: `user.UserService` → `user.Service`.
4. **Comments**: Every exported type, function, and method must have a doc comment beginning with its name.
5. **Line length**: No hard limit; `gofmt` handles wrapping. Keep function signatures readable — break long parameter lists.

## Error Handling

6. **Always handle errors explicitly**: Never discard with `_` unless the error is provably irrelevant and that is documented.
7. **Wrap errors with context**: Use `fmt.Errorf("doing X: %w", err)` to add call-site context. Unwrap with `errors.Is` / `errors.As`.
8. **Typed sentinel errors** for expected conditions:
    ```go
    var ErrNotFound = errors.New("not found")
    ```
9. **Typed error structs** for errors that carry data:
    ```go
    type ValidationError struct {
        Field   string
        Message string
    }
    func (e *ValidationError) Error() string {
        return fmt.Sprintf("%s: %s", e.Field, e.Message)
    }
    ```
10. **Never panic in library code**: Use `panic` only for truly unrecoverable programmer errors (e.g. nil receiver that should never be nil). Recover at the HTTP handler boundary only.

## Interfaces

11. **Define interfaces where they are used** (consumer side), not where they are implemented. This inverts the dependency correctly.
12. **Keep interfaces small**: Prefer composing small interfaces over large ones. A 1–3 method interface is ideal.
13. **Compile-time interface compliance check**:
    ```go
    var _ application.UserRepository = (*postgres.UserRepository)(nil)
    ```
14. **Accept interfaces, return concrete types** in function signatures unless the return type is genuinely polymorphic.

## Concurrency

15. **Always know who owns a goroutine**: Every goroutine started must be tracked and terminated — use `context.Context` for cancellation.
16. **Use `sync.WaitGroup`** to wait for goroutines; use `errgroup.Group` when goroutines can return errors.
17. **Protect shared state with `sync.Mutex` or channels**: Never read/write shared memory without synchronization. Run tests with `-race`.
18. **Channels for coordination, mutexes for state**: Use channels to signal events between goroutines; use mutexes to guard shared data structs.
19. **Avoid goroutine leaks**: Close channels from the sender side. Use `defer cancel()` immediately after `context.WithCancel`.

## Context

20. **`context.Context` is the first parameter** on every function that performs I/O, calls external services, or could block.
21. **Never store context in a struct**: Pass it explicitly through the call stack.
22. **Use `context.WithTimeout` / `context.WithDeadline`** for all outbound network calls. Never call external services without a timeout.
23. **Only store request-scoped values in context** (e.g. request ID, auth claims). Do not use context as a general dependency container.

## Packages and Modules

24. **`internal/` for private code**: Anything not intended for external consumers goes under `internal/`.
25. **`pkg/` for shared utilities**: Only place genuinely reusable, dependency-free code here. Never put business logic in `pkg/`.
26. **`cmd/` for entry points**: Each binary has its own subdirectory with a `main.go`. Wiring/DI happens only here.
27. **Minimal `init()` usage**: Avoid side effects in `init()`. Prefer explicit initialization in `main`.
28. **Go module path**: Use a fully qualified path (`github.com/org/repo`). Never use a generic path for shared internal libraries.

## Structs and Data

29. **Use struct embedding for composition**, not inheritance. Embed only unexported types to avoid accidental API surface.
30. **Use functional options pattern** for structs with many optional configuration parameters:
    ```go
    type Option func(*Server)
    func WithTimeout(d time.Duration) Option { return func(s *Server) { s.timeout = d } }
    ```
31. **Prefer value receivers** for small structs; **pointer receivers** when the method mutates state or the struct is large.
32. **Consistent receiver name**: Use a short, consistent abbreviation — `s` for `Server`, `r` for `Repository`.

## Testing

33. **Use `testing` standard library** as the base. Use `testify/assert` and `testify/require` for assertions.
34. **Table-driven tests** for functions with multiple input/output cases:
    ```go
    tests := []struct {
        name  string
        input string
        want  int
    }{
        {"empty", "", 0},
        {"single word", "hello", 5},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) { ... })
    }
    ```
35. **Use `t.Parallel()`** in unit tests to speed up the suite.
36. **Integration tests**: Tag with `//go:build integration` and run separately in CI with a real database.
37. **Mock interfaces with `testify/mock` or `mockery`**: Generate mocks; do not hand-write them.
38. **Run with `-race`** in CI: `go test -race ./...`.

## Performance

39. **Profile before optimizing**: Use `pprof` to identify actual bottlenecks. Do not optimize prematurely.
40. **Pre-allocate slices and maps** when size is known: `make([]T, 0, n)`, `make(map[K]V, n)`.
41. **Use `strings.Builder`** for string concatenation in loops, not `+=`.
42. **Avoid unnecessary allocations in hot paths**: Prefer value types; use `sync.Pool` for short-lived, frequently allocated objects.

## Security

43. **Validate all external input**: Use a validation library (e.g. `go-playground/validator`) at HTTP/gRPC boundaries.
44. **Parameterize all SQL**: Use `database/sql` placeholders (`$1`, `?`), never `fmt.Sprintf` into queries.
45. **Never log sensitive data**: Scrub passwords, tokens, PII before logging.
46. **Use `crypto/rand`** for security-sensitive random values, never `math/rand`.

## Project Configuration

47. **`go.mod` and `go.sum` must be committed** and kept up to date.
48. **Use `Makefile`** for common tasks: `make lint`, `make test`, `make build`.
49. **Structure**: Follow Clean Architecture layout (see `project-layout.md`).
