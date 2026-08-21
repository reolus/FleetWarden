# FleetWarden Milestone 2 Upgrade Guide

## Supported baseline

Upgrade from **FleetWarden 0.35.0-fleet.1** after `database/migrate_phase35_0.sql` has completed successfully.

## Before upgrade

1. Back up the application directory and MySQL database.
2. Run `php scripts/migrate.php status` and resolve unrelated migration problems.
3. Confirm Milestone 1 Fleet Dashboard, Assets, and Vehicles pages are operational.
4. Review local/custom schema changes before applying Phase 36.

## Deploy and migrate

Apply the 0.36.0-fleet.2 full package or changes-only package, then run:

```bash
php scripts/migrate.php status
php scripts/migrate.php migrate
php scripts/migrate.php status
```

The new migration is `database/migrate_phase36_0.sql`. It creates `asset_assignments` and `asset_events`, adds assignment permissions, imports current vehicle department/location/operator relationships, imports equipment ownership/location, migrates compatible legacy custody records, and bridges existing asset activity into canonical events. It does not drop inherited tables or compatibility columns.

## Optional demo seed

For the fictional Brighthaven demo only, after Phase 36 succeeds:

```bash
mysql -u <user> -p <database> < database/demo/seed_fleetwarden_m2_brighthaven.sql
```

Do not load this demo seed in a production customer database.

## Post-upgrade verification

1. Open `/portal/assignments` and verify current assignments.
2. Change a vehicle operator and confirm the prior assignment closes rather than disappearing.
3. Change a vehicle home location and confirm history is preserved.
4. Create serialized equipment and assign it to a vehicle.
5. Add concurrent user custody and confirm both placement and custody remain active.
6. Return the equipment and verify condition/return notes.
7. Scan a FleetWarden QR label and verify the canonical asset opens.
8. Open `/portal/mobile` and verify the FleetWarden `My Fleet` interface.
9. Verify overdue temporary assignments appear in dashboard/filtering.
10. Open System Health and verify the assignment engine check.

## Validation

```bash
php tests/phase36_0_regression.php
php tests/phase35_0_regression.php
php tests/phase34_0_regression.php
php tests/route_validation.php
php tests/smoke.php
```

Release-build validation completed: 433 PHP files linted cleanly, Milestone 2/Milestone 1/inherited Phase 34 regressions passed, 362 route declarations validated, and the smoke test passed.

A MySQL server/client was not available in the build environment. Live execution of Phase 36, foreign-key/check-constraint behavior, Entra/Graph integration, browser camera permissions, and QR camera detection must therefore be verified on the target deployment.

## Rollback

Preferred rollback is to redeploy 0.35.0-fleet.1 source while leaving the additive `asset_assignments` and `asset_events` tables in place. If database-level rollback is mandatory, restore the pre-upgrade database backup. A destructive drop-table rollback is intentionally not supplied because it could erase assignment history created after deployment.
