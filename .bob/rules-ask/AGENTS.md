# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Non-Obvious Documentation Context

- There is **no application source code** in this repo — only Dockerfiles, shell scripts, YAML, and a Maven `welcomepage` war built inside Docker. Don't look for Java/Node source outside `welcomepage/`.
- `welcomepage/` is a Maven Java project built **inside the Docker builder stage**, not locally. Its `pom.xml` and `settings.xml` (at repo root) are only relevant in that context.
- The `.env` file at repo root is gitignored and drives all compose variables. Its structure is not documented in README but can be inferred from `odm-standalone.yml` comments and variable references across compose files.
- `standalone/resdb-*.zip` and `rtsdb-*.zip` are pre-built Derby database seeds, versioned per ODM release (8.11, 8.11.1, 8.12, 9.0, 9.6). The standalone image uses these for embedded Derby mode.
- The `contrib/` directory contains independent utility scripts (populate-sample-db, update-images, validate-odm) with their own `.env` templates — they are not part of the main build pipeline.
- `odm-cluster.yml`, `odm-oidcwithbasicauthonruntime.yml`, `odm-azuread.yml`, etc. are **overlay/variant** compose files for specific topologies, not standalone. They reference services defined in `docker-compose.yml`.
