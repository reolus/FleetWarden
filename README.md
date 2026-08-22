# FleetWarden

FleetWarden is a fleet and equipment management platform by McCartney Systems, LLC.

Current release: **0.38.0-fleet.3 - Preventive Maintenance**

This release includes the 0.37 cleanup/hardening work plus Milestone 3 preventive maintenance: reusable maintenance templates, calendar/odometer/engine-hour/usage triggers, due evaluation, automatic work-order generation, service checklists, completion baseline resets, notifications, worker health, and fleet dashboard integration.

## Upgrade

```bash
cd /var/www/fleetwarden
php scripts/migrate.php status
php scripts/migrate.php migrate
php scripts/migrate.php status
php tests/phase38_0_regression.php
php tests/route_validation.php
php tests/smoke.php
php scripts/maintenance-due.php
```

See `docs/FLEETWARDEN_0_37_CLEANUP.md`, `docs/FLEETWARDEN_M3_ARCHITECTURE.md`, and `docs/FLEETWARDEN_M3_UPGRADE.md`.
