# FleetWarden

FleetWarden is a fleet and equipment management platform by McCartney Systems, LLC.

Current release: **0.39.0-fleet.4 - Fleet Inspections & Corrective Actions**

Milestone 4 extends the existing inspection foundation into a FleetWarden-native asset inspection system. It includes reusable vehicle/equipment templates, Pass/Fail/N/A evaluation, pre-trip/post-trip and recurring schedules, mobile operator workflows, inspection photos and signatures, defect severity, automatic out-of-service decisions, corrective maintenance work-order generation, defect resolution, notifications, QR-assisted inspection access, dashboard status, PDF packets, and a background inspection-due evaluator.

## Upgrade

```bash
cd /var/www/fleetwarden
php scripts/migrate.php status
php scripts/migrate.php migrate
php scripts/migrate.php status
php tests/phase39_0_regression.php
php tests/phase38_0_regression.php
php tests/route_validation.php
php tests/smoke.php
php scripts/inspection-due.php
```

Recommended cron:

```cron
*/15 * * * * cd /var/www/fleetwarden && /usr/bin/php scripts/inspection-due.php >> storage/logs/inspection-due.log 2>&1
```

For the fictional Brighthaven demo only, load `database/demo/seed_fleetwarden_m4_brighthaven.sql` after the migration.

See `docs/FLEETWARDEN_M4_UPGRADE.md`, `docs/FLEETWARDEN_M4_ARCHITECTURE.md`, and `docs/FLEETWARDEN_M4_MANIFEST.md`.
