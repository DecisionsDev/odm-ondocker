# Advance Mode Rules (Non-Obvious Only)

## Multi-Stage Build Architecture

- Three stages required: builder (Maven), oidc-liberty-builder (Liberty), final (runtime)
- Context MUST be `../` (parent dir), not `.` - Dockerfiles expect ODM distribution extracted above
- ODMDOCKERDIR arg points to subdirectory within extracted distribution (not absolute path)
- Copy operations use $ODMDOCKERDIR prefix: `COPY $ODMDOCKERDIR/common/script $SCRIPT`

## Build Order Dependencies

- Must build from parent directory: `cd ..` before docker compose build
- ODM distribution downloaded/extracted BEFORE copying odm-ondocker into install/
- Three compose files built separately: docker-compose.yml, odm-standalone.yml, odm-cluster.yml
- DOCKER_BUILDKIT=1 required (not optional) - multi-stage builds fail without it

## Liberty Configuration Injection

- Liberty features installed in oidc-liberty-builder stage via installFeatures.sh
- JVM options copied to /config/configDropins/overrides/ (not /config/jvm/)
- LTPA keys copied from common/security/ to /config/resources/security/
- Keystore/truststore copied to /config/security/ (not /config/resources/)

## Script Injection Pattern

- Scripts injected into Liberty's docker-server.sh via sed replacement
- Pattern: `sed -i 's|# Pass on to the real server run|. /script/run.sh|'`
- Injection point is comment line, not function call
- Must use dot-space sourcing (`. /script/run.sh`) not direct execution

## Database Configuration Flow

- configureDatabase.sh downloads drivers from DB_DRIVER_URL (comma-separated)
- Drivers auto-extracted if zip/tar format, moved to /config/resources/
- updateDatasource.sh replaces placeholders: dbserver→DB_SERVER_NAME, odmdb→DB_NAME
- Default ports set by DB_TYPE if DB_PORT_NUMBER not provided

## OIDC Configuration Mechanics

- openIdParameters.properties uses __PLACEHOLDER__ pattern (double underscore)
- OPENID_MODE presence (any value) triggers client secret line deletion
- Optional params (token format, grant type) deleted if env vars not set
- DISABLE_LOGIN_PANEL replaces entire login.jsp with redirect JSP

## Testing Infrastructure

- Tests use wait_for_url() with 10 retries, 15s sleep, 180s timeout
- Container names: odm-ondocker-odm-{component}-1 (note the -1 suffix)
- Tests verify BOTH HTTP endpoints AND internal network connectivity (ping)
- Default test credentials: resExecutor/resExecutor, resAdmin/resAdmin, rtsAdmin/rtsAdmin

## Secret Management

- Secrets support dual pattern: env vars OR mounted files at /config/secrets/
- Pattern: `[ -f /config/secrets/path ] && export VAR=$(cat /config/secrets/path)`
- OIDC secrets: /config/secrets/oidc-config/clientId, clientSecret
- DB secrets: /config/secrets/dba-env-context/sslKeystorePassword, sslTruststorePassword