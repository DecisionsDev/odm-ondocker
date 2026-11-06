# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Build System (Non-Standard Patterns)

- Build MUST run from parent directory (`cd ..` in build.sh) - downloads ODM distribution zip, unzips, then copies odm-ondocker into install/
- Uses DOCKER_BUILDKIT=1 for all builds (required for multi-stage Dockerfiles)
- Three separate compose files: docker-compose.yml (standard), odm-standalone.yml, odm-cluster.yml - build all three
- Build downloads ODM from Artifactory using credentials in env vars: ODM_URL, ARTIFACTORY_USER, ARTIFACTORY_PASSWORD

## Testing (Critical Patterns)

- Test suite (test/suite.sh) uses `wait_for_url()` with 10 retries, 15s intervals, 180s timeout
- Tests check BOTH HTTP endpoints AND internal Docker network connectivity (ping between containers)
- Container names follow pattern: `odm-ondocker-odm-{component}-1` (e.g., odm-ondocker-odm-decisionrunner-1)
- Default credentials: resExecutor/resExecutor, resAdmin/resAdmin, rtsAdmin/rtsAdmin

## Docker Architecture (Hidden Dependencies)

- All Dockerfiles use 3-stage builds: builder (Maven), oidc-liberty-builder (Liberty config), final (runtime)
- Context is ALWAYS `../` (parent directory), not current directory
- ODMDOCKERDIR arg points to odm-ondocker subdirectory within extracted ODM distribution
- Scripts injected into Liberty's docker-server.sh via sed: `sed -i 's|# Pass on to the real server run|. /script/run.sh|'`

## Configuration Initialization (Non-Obvious Flow)

- Each component has run script (rundc.sh, run.sh) that checks `/config/initialized` flag file
- Initialization runs ONLY on first start - creates flag file at end
- Scripts source from `/script/init/container.env` if exists (undocumented extension point)
- Custom hooks: customStart.sh and customEnd.sh sourced if present (not documented in main docs)

## Database Configuration (Critical Gotchas)

- DB_DRIVER_URL supports comma-separated URLs - downloads and extracts (zip/tar) automatically
- Default ports hardcoded by DB_TYPE if DB_PORT_NUMBER not set (postgres=5432, db2=50000, oracle=1521, etc.)
- Driver replacement logic in configureDatabase.sh moves files from /config/resources/jdbc/{dbtype}/* to /config/resources/
- Datasource.xml uses placeholder `dbserver` replaced by DB_SERVER_NAME, `odmdb` replaced by DB_NAME

## Security Configuration (Hidden Behavior)

- FIPS mode changes BOTH tlsSecurity.xml AND ltpa.xml files (uses FIPS-specific versions)
- Default passwords: keystore=changeme, truststore=changeme (changes to changeit if using /shared/tls/)
- Secrets can be mounted volumes OR env vars - scripts check both: `[ -f /config/secrets/path ] && export VAR=$(cat /config/secrets/path)`
- LTPA keys shared across components from common/security/ - critical for SSO

## OIDC Configuration (Undocumented Requirements)

- DISABLE_LOGIN_PANEL replaces login.jsp with redirect: `<%response.sendRedirect("/decisioncenter");%>`
- openIdParameters.properties uses __PLACEHOLDER__ pattern for sed replacement
- OPENID_MODE presence (any value) removes client secret from config entirely
- Token format and grant type are optional - sed deletes lines if env vars not set

## Liberty Configuration (Non-Standard)

- PACKAGELIST in .env defines Liberty features - space-separated, must include servlet-6.0, jdbc-4.3, etc.
- Features installed in oidc-liberty-builder stage via installFeatures.sh
- JVM options in common/config/jvm/jvm.options copied to /config/configDropins/overrides/
- Port initialization via initVariables.sh: DC=9060/9453, DSC=9080/9443, DSR=9090/9453

## Code Style (From CONTRIBUTING.md)

- Apache license header required in all files
- Indent: 4 spaces, no tabs
- Opening brace on same line as if/for/function
- Sign commits with real name: `git commit -s`