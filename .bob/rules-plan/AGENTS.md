# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Non-Obvious Architectural Constraints

- **Build requires an external ODM distribution zip** (from IBM Artifactory) that is not in this repo. `build.sh` downloads it at CI time. Any local build plan must account for this prerequisite.
- **Three-stage Dockerfile pattern is load-bearing.** Stage 1 (`builder`, Debian) unpacks WAR files and applies patches. Stage 2 (`oidc-liberty-builder`) installs Liberty features and injects the run script hook. Stage 3 is the final minimal Liberty image. Collapsing stages breaks the build because patched WARs must be copied from stage 1 and Liberty binaries from stage 2.
- **The test suite (`test/suite.sh`) is integration-only** — it requires the full compose stack running. There are no unit or component tests. All validation is done by polling live HTTP endpoints and running `ping` inside containers.
- **Service discovery inside containers uses Docker Compose service names as hostnames** (e.g. `dbserver`, `odm-decisionserverconsole`). The `test/suite.sh` checks this explicitly with `check_for_docker_url`. Any topology change must preserve these service names.
- **Decision Center JVM is hardcoded to `-Xmx14000m`** in `docker-compose.yml`. This is not configurable via `.env` — it must be edited directly or overridden with a compose override file.
- **OIDC/security configuration is injected at image-build time**, not at runtime. The `common/config/authOidc/` and `common/security/` keystores/truststores are baked into the image. Runtime OIDC config changes require a rebuild.
- **Healthchecks use different endpoints per service**: Decision Center → `/decisioncenter/healthCheck`, Decision Server Console → `/res/login.jsp`, Decision Server Runtime → `/DecisionService`, Decision Runner → `/DecisionRunner`. These are not configurable.
