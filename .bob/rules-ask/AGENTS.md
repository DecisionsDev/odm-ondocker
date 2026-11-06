# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Non-Obvious Documentation Context

- There is **no application source code** in this repo — only Dockerfiles, shell scripts, YAML, and a Maven `welcomepage` war built inside Docker. Don't look for Java/Node source outside `welcomepage/`.
- `welcomepage/` is a Maven Java project built **inside the Docker builder stage**, not locally. Its `pom.xml` and `settings.xml` (at repo root) are only relevant in that context.
- The `.env` file at repo root is gitignored and drives all compose variables. Its structure is not documented in README but can be inferred from `odm-standalone.yml` comments and variable references across compose files.
- `standalone/resdb-*.zip` and `rtsdb-*.zip` are pre-built Derby database seeds, versioned per ODM release (8.11, 8.11.1, 8.12, 9.0, 9.6). The standalone image uses these for embedded Derby mode.
- The `contrib/` directory contains independent utility scripts (populate-sample-db, update-images, validate-odm) with their own `.env` templates — they are not part of the main build pipeline.
- `odm-cluster.yml`, `odm-oidcwithbasicauthonruntime.yml`, `odm-azuread.yml`, etc. are **overlay/variant** compose files for specific topologies, not standalone. They reference services defined in `docker-compose.yml`.

## Documentation Structure (Counterintuitive)

- Main docs in docs/ subdirectory: README_standalone.md, README_standard.md, README_cluster.md
- Root README.md is overview only - detailed docs are in docs/ folder
- CONTRIBUTING.md contains code style rules (not just contribution process)
- Build instructions NOT in README - in build.sh script comments

## Directory Naming (Misleading)

- "common/" contains shared configs/scripts for ALL components (not just common utilities)
- "decisionserver/" contains BOTH console and runtime (two separate components)
- "databases/" contains database Dockerfiles (not database data or schemas)
- "contrib/" contains examples and utilities (not contributed code)

## Configuration File Locations (Hidden)

- LTPA keys in common/security/ shared across ALL components (not per-component)
- JVM options in common/config/jvm/jvm.options (not in component directories)
- Database drivers in common/drivers/ (not in databases/ directory)
- OIDC templates in common/config/authOidc/ (not in component configs)

## Script Organization (Non-Standard)

- Init scripts in component/script/ directories (rundc.sh, run.sh)
- Shared utilities in common/script/ (configureDatabase.sh, etc.)
- Feature loading scripts in common/features/ (not common/script/)
- Custom hooks (customStart.sh, customEnd.sh) NOT in repo - user-provided

## Environment Variables (Undocumented Patterns)

- ODMDOCKERDIR points to subdirectory name, not full path
- PACKAGELIST is space-separated string, not array or comma-separated
- DB_DRIVER_URL accepts comma-separated URLs (downloads multiple drivers)
- OPENID_MODE presence (any value) changes behavior - not true/false flag

## Build Context (Critical Gotcha)

- Dockerfiles expect context to be parent directory (`../`), not current
- Build MUST run from parent after extracting ODM distribution
- odm-ondocker copied INTO extracted distribution (install/odm-ondocker)
- Cannot build from odm-ondocker directory directly

## Testing Patterns (Hidden Requirements)

- Container names include project prefix: odm-ondocker-odm-{component}-1
- Tests check internal Docker network connectivity (not just HTTP endpoints)
- Default credentials hardcoded in test suite (not configurable)
- Test timeout: 10 retries × 15s = 150s max wait per endpoint

## Configuration Initialization (One-Time Only)

- Init scripts run ONLY on first start (checked via /config/initialized flag)
- No re-initialization on restart - flag persists in volume
- Custom hooks (customStart.sh, customEnd.sh) run inside flag check
- To re-initialize: delete /config/initialized file or recreate container

## Security Configuration (Multiple Sources)

- Secrets can be env vars OR mounted files (dual pattern)
- FIPS mode uses different config files (tlsSecurityFIPS.xml, ltpaFIPS.xml)
- Default passwords: keystore=changeme, truststore=changeme (or changeit with /shared/tls/)
- OIDC client secret optional if OPENID_MODE set (line deleted from config)
