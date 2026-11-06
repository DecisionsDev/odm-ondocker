# Ask Mode Rules (Non-Obvious Only)

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