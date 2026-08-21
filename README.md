# FleetWarden

FleetWarden is a fleet and equipment management platform by McCartney Systems, LLC, built from the FieldWarden application platform.

Current release branch: `release/fieldwarden-fleet`

Current milestone: **0.36.0-fleet.2 - Assignments & Custody**

Milestone 2 adds canonical assignment history for vehicles and serialized equipment, vehicle/equipment/user/location/department/crew targets, transfers and returns, overdue custody tracking, FleetWarden mobile `My Fleet`, QR scanning, canonical asset events, and assignment health monitoring.

## Release package in this branch

The complete Milestone 2 source delta is stored at:

`releases/FleetWarden-0.36.0-fleet.2-milestone-files.tar.gz`

The archive is intended to be applied over FleetWarden `0.35.0-fleet.1`. Full deployable ZIP/TAR packages are also produced with the release artifacts outside GitHub.

## Upgrade

Back up the application and database, apply the release files, then run:

```bash
php scripts/migrate.php status
php scripts/migrate.php migrate
php scripts/migrate.php status
php tests/phase36_0_regression.php
php tests/phase35_0_regression.php
php tests/route_validation.php
php tests/smoke.php
```

For the fictional Brighthaven demo only, `database/demo/seed_fleetwarden_m2_brighthaven.sql` may be loaded after migrations.

See the Milestone 2 architecture, upgrade guide, manifest, and changelog in this branch for details.
