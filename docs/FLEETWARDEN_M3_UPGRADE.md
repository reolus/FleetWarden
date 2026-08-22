# FleetWarden 0.38.0-fleet.3 Upgrade

## From 0.37.0-fleet.2
1. Back up the database and application directory.
2. Replace application files with the 0.38.0 release.
3. Run migrations before allowing users back into the portal:

```bash
cd /var/www/fleetwarden
php scripts/migrate.php status
php scripts/migrate.php migrate
php scripts/migrate.php status
```

4. Validate:

```bash
php tests/phase38_0_regression.php
php tests/phase37_0_regression.php
php tests/phase36_2_regression.php
php tests/phase36_0_regression.php
php tests/phase35_0_regression.php
php tests/route_validation.php
php tests/smoke.php
```

5. Run the evaluator once manually:

```bash
php scripts/maintenance-due.php
```

6. Recommended cron example:

```cron
*/15 * * * * cd /var/www/fleetwarden && /usr/bin/php scripts/maintenance-due.php >> storage/logs/maintenance-due.log 2>&1
```

The worker is protected by `flock`, so overlapping cron executions exit without starting a second evaluator.

## Demo only
After the migration, the fictional Brighthaven demo may optionally load `database/demo/seed_fleetwarden_m3_brighthaven.sql`, then run the evaluator.

## Rollback
Application rollback to 0.37.0 is possible without dropping the new tables. Do not drop Milestone 3 tables unless the records have been exported and you are certain no 0.38 work orders reference them. The migration is additive and historical maintenance work orders remain intact.

## Validation limitation
Static regression, PHP syntax, routes, migration-content checks, and archive validation were completed in the build environment. Actual DDL execution must be validated against the deployment MySQL instance.
