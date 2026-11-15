---
name: optimize-docker
description: Optimize any files that may help the Docker Image become better.
tags: docker, optimization
---
# Optimize Docker

## Objectives

1. **Smaller image size**: Reduce storage, network transfer, and deployment time.
2. **Faster builds**: Maximize build cache reuse and minimize unnecessary work.
3. **Security**: Reduce attack surface, dependencies, and vulnerabilities.
4. **Reproducibility**: Make builds deterministic and predictable.

## Rules

1. Use small base images. `python:3.12-slim`, `alpine`, `distroless`, or `scratch` (Go).
2. Multi-stage builds. Build in one stage. Copy artifacts to a minimal runtime stage.
3. Order layers by change frequency. Dependencies first. Source code last.
4. Copy dependency manifests first. Install. Then copy source.
5. Use `.dockerignore`. Exclude `.git`, `node_modules`, `__pycache__`, `.venv`, `tests`, `docs`, unecessary files.
6. Combine `RUN` commands. Clean up in the same layer.
7. Clean package caches in the same layer. `rm -rf /var/lib/apt/lists/*`.
8. Use `--no-install-recommends` with `apt`.
9. Use `--no-cache-dir` with `pip`. Or use `uv` with `--no-cache`.
10. Use BuildKit cache mounts. `RUN --mount=type=cache,target=/root/.cache/uv uv sync`.
11. Use BuildKit secrets for build-time credentials. Do not use `ARG` or `ENV` to pass secrets.
12. Pin base image versions. No `latest`. Use digests for reproducibility.
13. Run as non-root. `USER app`.
14. One process per container.
15. Use `COPY`, not `ADD`. Unless extracting tarballs.
16. Use exec-form `CMD/ENTRYPOIN`T. `["uvicorn", "app:app"]`.
17. Strip binaries. Go: `-ldflags="-s -w"`, `CGO_ENABLED=0`.
18. Install only production deps. `uv sync --no-dev --frozen`. Fix all vulnerable deps of base image, or OS.
19. Add `HEALTHCHECK`.
20. Scan images. `trivy`, `docker scout`.
21. Inspect layers. `dive`, `docker history`.
22. Avoid unnecessary processes and files
    1.  Do not install SSH servers inside application containers.
    2.  Do not include test suites in runtime images unless needed.
    3.  Do not include documentation or development tooling.
    4.  Do not run multiple unrelated services in one container.
    5.  Use exec-form `CMD` and `ENTRYPOINT`.