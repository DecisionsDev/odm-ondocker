# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Project Overview

IBM ODM on Docker — Dockerfiles and Docker Compose descriptors to build and deploy IBM Operational Decision Manager (ODM) images. No Node.js or Python; the stack is **Bash + Dockerfile + Docker Compose + Maven** (used only inside image builds for the `welcomepage` war).

## Build Commands

> `build.sh` must be run from the **repo root's parent directory** — it `cd ..` at the start and expects a sibling `install/` directory produced by unzipping the ODM distribution zip first. You **cannot** run it in-place.

```bash
# Full image build (requires ODM zip fetched from Artifactory, run from repo root):
bash build.sh

# Build individual compose files (from inside the repo dir, one level below build.sh context):
DOCKER_BUILDKIT=1 docker compose -f docker-compose.yml build
DOCKER_BUILDKIT=1 docker compose -f odm-standalone.yml build
DOCKER_BUILDKIT=1 docker compose -f odm-cluster.yml build
```

Required environment variables for `build.sh`:
- `ARTIFACTORY_USER`, `ARTIFACTORY_TOKEN` / `ARTIFACTORY_PASSWORD`
- `ODM_URL`, `ODM_VERSION`

## Test Command

There is no unit-test framework. The single integration test is:

```bash
# Start the stack first (enable SAMPLE data by uncommenting SAMPLE=true in docker-compose.yml),
# then run:
sh test/suite.sh
```

`test/suite.sh` polls HTTP endpoints via `curl` and pings container hostnames via `docker exec`. It exits non-zero on any failure. There is no way to run a single test — all checks are in one script.

## Lint

Linting runs via GitHub Actions only (super-linter v2.1.1). No local lint command. Markdown links are checked with `gaurav-nelson/github-action-markdown-link-check` using `.md_check_config.json` (ignores `http://localhost`, rewrites IBM docs URLs to test endpoint).

Secret scanning uses `detect-secrets` (pre-commit hook): `pre-commit run detect-secrets`.

## Dockerfile Patterns (Non-Obvious)

- **Multi-stage build pattern is mandatory**: every service Dockerfile uses three stages: `builder` (Debian-based), `oidc-liberty-builder` (Liberty), and final Liberty image. Do not collapse stages.
- **Build context is the parent directory** (`context: ../`), not the service subdirectory. All `COPY` paths in Dockerfiles are relative to the parent and use `$ODMDOCKERDIR` ARG (defaults to `odm-ondocker`).
- **`common/` is shared across all services**: `common/script/`, `common/config/`, `common/drivers/`, `common/security/` are copied into every image. Changes there affect all components.
- The Liberty startup hook is injected via `sed`: `sed -i 's|# Pass on to the real server run|. /script/run*.sh|' /opt/ibm/helpers/runtime/docker-server.sh`. Each service's run script name differs (`rundc.sh` for Decision Center, `run.sh` for Decision Server Console).
- Non-root users: Liberty images run as `USER 1001`, PostgreSQL as `USER 999`. All `COPY` to runtime stages use `--chown=1001:0`.
- `FROMDOCKERBUILD` / `FROMLIBERTY` / `FROMLIBERTYBUILD` ARGs are injected at compose time from `.env`. Never hardcode base image references in Dockerfiles.
- Artifactory credentials are passed as **Docker BuildKit secrets** (`--mount=type=secret,id=artifactory_user`), not build ARGs. `DOCKER_BUILDKIT=1` is required.

## Code Style (Shell Scripts)

From `CONTRIBUTING.md`:
- All files must have the Apache license header.
- Indent with 4 spaces, no tabs.
- Opening brace on same line as `if`/`for`/`function`/etc.

Shell scripts in `common/script/` use `#!/bin/bash` and `set -ex` at the top. Maintain this pattern in any new scripts.

## Key Environment Variables (`.env`)

The root `.env` file (gitignored) drives all compose variables: `ODMVERSION`, `ODMDBVERSION`, `ODMDOCKERDIR`, `REPOSITORY`, `PREFIXIMAGE`, `FROMLIBERTY`, `FROMDOCKERBUILD`, `FROMLIBERTYBUILD`, `FROMPOSTGRES`, `POSTGRESUID`, `CP4BAVERSION`, `PACKAGELIST`. See `contrib/validate-odm/.env.template` for the validation tool pattern.

## Service Port Mapping

| Service | Internal | Exposed |
|---|---|---|
| Decision Center | 9060/9453 | 9060/9643 |
| Decision Server Console | 9080/9443/1883 | 9080/9843 |
| Decision Server Runtime | 9080/9443 | 9090/9943 |
| Decision Runner | 9080/9443 | 9070/9743 |
| PostgreSQL | 5432 | 5432 |
