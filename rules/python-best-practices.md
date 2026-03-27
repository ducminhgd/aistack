# Python Best Practices

## Code Style

1. **Follow PEP 8**: Use `snake_case` for variables, functions, and modules; `PascalCase` for classes; `UPPER_SNAKE_CASE` for constants.
2. **Line length**: Max 120 characters (configured in `pyproject.toml`). PEP 8 default is 79; prefer 99–120 for modern projects.
3. **Imports**: Group in order — standard library, third-party, local. Use `isort` to enforce.
4. **Formatter**: Use `ruff format` (preferred) or `black`. Never mix formatters in one project.
5. **Linter**: Use `ruff` (replaces `flake8`, `pylint`). Enable at minimum: `E`, `F`, `I`, `UP`, `B` rule sets.

## Type Annotations

6. **Annotate all public functions and methods** — parameters and return types. Use `-> None` explicitly.
7. **Use `from __future__ import annotations`** at the top of every file to enable postponed evaluation and avoid circular import issues with type hints.
8. **Prefer built-in generic types** over `typing` equivalents: `list[str]` over `List[str]`, `dict[str, int]` over `Dict[str, int]` (Python 3.10+).
9. **Use `X | None` instead of `Optional[X]`** (Python 3.10+).
10. **Run `mypy` or `pyright`** in strict mode in CI. Do not commit code with type errors.

## Functions and Classes

11. **Keep functions short**: A function should do one thing. If it needs a comment to explain what a block does, extract it.
12. **Avoid mutable default arguments**: Use `None` as default and assign inside the function body.
    ```python
    # Bad
    def add_item(item, items=[]):
        items.append(item)

    # Good
    def add_item(item, items: list | None = None) -> list:
        if items is None:
            items = []
        items.append(item)
        return items
    ```
13. **Prefer `dataclasses` or Pydantic models** over plain `dict` for structured data.
14. **Use `@classmethod` for alternative constructors**, not multiple `__init__` signatures.
15. **Use `@staticmethod` sparingly** — if a method doesn't use `self` or `cls`, consider making it a module-level function.
16. **`__slots__`**: Use on hot-path domain objects to reduce memory overhead.

## Error Handling

17. **Raise specific exceptions**: Define typed domain exceptions instead of raising bare `Exception` or `ValueError`.
18. **Never silence exceptions**: Avoid bare `except:` or `except Exception: pass`. Log at minimum.
19. **Use `contextlib.suppress`** only for expected, intentional suppression, and document why.
20. **Chain exceptions with `raise X from Y`** to preserve original traceback context.

## Async

21. **Use `asyncio` for I/O-bound work** (HTTP, DB, files). Use `ProcessPoolExecutor` for CPU-bound work.
22. **Never call blocking I/O inside a coroutine** without `asyncio.to_thread()` or an executor.
23. **Avoid `asyncio.gather` with bare exceptions** — handle errors per-task or use `return_exceptions=True` deliberately.
24. **Use `async with` and `async for`** for async context managers and iterators.

## Dependency Management

25. **Use `uv`** for package management and virtual environments (preferred over `pip` + `venv` directly).
26. **Pin direct dependencies** in `pyproject.toml`. Use a lock file (`uv.lock` or `requirements.lock`) for reproducibility.
27. **Separate dev dependencies**: Group test, lint, and type-checking tools under `[dependency-groups]` in `pyproject.toml`.

## Testing

28. **Use `pytest`** as the test framework. Avoid `unittest` unless wrapping legacy code.
29. **One assertion focus per test**: A test can have multiple assertions if they all validate the same behaviour; separate concerns into separate tests.
30. **Use fixtures for shared setup**, not inheritance from a base test class.
31. **Test filenames**: Mirror the module under test — `src/user.py` → `tests/test_user.py`.
32. **Prefer real objects over mocks** at the unit level. Only mock at system boundaries (HTTP, DB, external APIs).
33. **Measure coverage**: Aim for ≥ 80% line coverage. Run `pytest --cov` in CI.

## Security

34. **Never hardcode secrets**: Use environment variables and a secrets manager. Use `pydantic-settings` for config loading.
35. **Sanitize inputs at system boundaries**: Validate all external data with Pydantic or equivalent before use.
36. **Use `secrets` module** for cryptographic random values, never `random`.
37. **Parameterize all SQL queries**: Never format user input into SQL strings.

## Project Configuration

38. **Centralise config in `pyproject.toml`**: Include `[tool.ruff]`, `[tool.mypy]`, `[tool.pytest.ini_options]`.
39. **Use `.python-version`** to pin the interpreter version for tools like `uv` and `pyenv`.
40. **Structure**: Follow Clean Architecture layout (see `project-layout.md`).
