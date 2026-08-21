# FleetWarden

FleetWarden is a fleet and equipment management platform by McCartney Systems, LLC, built from the FieldWarden application platform.

Current release branch: `release/fieldwarden-fleet`

Current milestone: **0.36.2-fleet.2 - Assignments & Custody (MySQL constraint hotfix)**

Milestone 2 adds canonical assignment history for vehicles and serialized equipment, vehicle/equipment/user/location/department/crew targets, transfers and returns, overdue custody tracking, FleetWarden mobile `My Fleet`, QR scanning, canonical asset events, and assignment health monitoring.

## 0.36.2 hotfix

This release fixes MySQL error 3823 in `migrate_phase36_0.sql`. Columns used by `chk_asset_assignments_target` no longer declare explicit `ON DELETE`/`ON UPDATE` referential actions. MySQL therefore applies its default restrictive behavior while retaining the database-level target validation check.

It also includes the 0.36.1 Phase 35 resumable migration compatibility fix.

## Upgrade / recovery

Back up the application and database, deploy the 0.36.2 release files, then run:

```bash
php scripts/migrate.php status
php scripts/migrate.php migrate
php scripts/migrate.php status
php tests/phase36_2_regression.php
php tests/phase36_1_regression.php
php tests/phase36_0_regression.php
php tests/phase35_0_regression.php
php tests/route_validation.php
php tests/smoke.php
```

See `docs/FLEETWARDEN_0_36_2_HOTFIX.md` for recovery details.
