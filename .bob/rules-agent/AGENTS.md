# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Non-Obvious Coding Rules

- **Never run `build.sh` from the repo root.** It `cd ..` and expects an `install/` sibling containing the unzipped ODM distribution. It will fail silently or corrupt state if run in-place.
- **Build context is the parent of this repo.** All `COPY` directives in Dockerfiles reference `$ODMDOCKERDIR/...` (e.g. `$ODMDOCKERDIR/common/script`) which resolves relative to the parent directory, not the repo root. This is why `context: ../` appears in every compose file.
- **`DOCKER_BUILDKIT=1` is mandatory** for all builds — the Dockerfiles use `--mount=type=secret` which requires BuildKit. Without it the build fails with a syntax error.
- **`common/` is the shared layer for all ODM components.** Edits to `common/script/`, `common/config/`, `common/drivers/`, or `common/security/` affect every service image (decisioncenter, decisionserverconsole, decisionserverruntime, decisionrunner, standalone).
- **Liberty startup injection pattern**: the run script is injected via `sed` into `/opt/ibm/helpers/runtime/docker-server.sh`, not declared as a CMD or ENTRYPOINT override. Match the exact sed expression per service.
- The `SAMPLE=true` line in `docker-compose.yml` is commented out by default. The CI pipeline uncomments it with `sed -i 's/^#\(.*SAMPLE=true\)/\1/'` before `docker compose up`. Don't hardcode it.
- Shell scripts: use `#!/bin/bash`, `set -ex`, 4-space indent, Apache license header. Opening brace on the same line as control structures.
