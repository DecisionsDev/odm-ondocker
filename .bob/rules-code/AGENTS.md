# Code Mode Rules (Non-Obvious Only)

## Script Modification Patterns

- Liberty startup injection uses sed on docker-server.sh: `sed -i 's|# Pass on to the real server run|. /script/run.sh|'`
- Configuration scripts use sed with pipe delimiters: `sed -i 's|old|new|g'` (not forward slashes)
- Placeholder replacement pattern: `__VARIABLE__` in templates, replaced via sed
- Optional config lines deleted if env var not set: `sed -i '/PATTERN/d'` (not commented out)

## Initialization Flag Pattern

- MUST check `/config/initialized` flag before running init scripts
- Flag created with `touch /config/initialized` at end of init sequence
- Re-initialization prevented by flag check: `if [ ! -f /config/initialized ]`
- Custom hooks run INSIDE flag check (customStart.sh before init, customEnd.sh after)

## Secret Handling (Dual Pattern)

- Secrets support BOTH env vars AND mounted files
- Pattern: `[ -f /config/secrets/path ] && export VAR=$(cat /config/secrets/path)`
- Check file first, then use env var as fallback
- Paths: /config/secrets/oidc-config/, /config/secrets/dba-env-context/

## Database Driver Management

- DB_DRIVER_URL accepts comma-separated URLs (not array)
- Auto-extracts zip/tar/tgz/tar.gz/tar.bz2/tar.xz archives
- Moves drivers from /config/resources/jdbc/{dbtype}/* to /config/resources/
- Deletes old drivers before moving new ones (rm then mv pattern)

## Configuration File Sourcing

- Use `. script.sh` (dot space) not `source script.sh` for POSIX compatibility
- Scripts in /script/init/container.env auto-sourced if exists
- Use `set -o allexport` before sourcing env files, `set +o allexport` after

## Liberty Feature Installation

- Features defined in PACKAGELIST env var (space-separated string, not array)
- Installed in oidc-liberty-builder stage, not final stage
- Must include: servlet-6.0, jdbc-4.3, appSecurity-5.0, concurrent-3.0, jndi-1.0

## Port Configuration

- Ports set via initVariables.sh with positional args: `initVariables.sh HTTP_PORT HTTPS_PORT`
- DecisionCenter: 9060/9453, DecisionServerConsole: 9080/9443, DecisionServerRuntime: 9090/9453
- Ports NOT configurable via env vars (hardcoded in init scripts)