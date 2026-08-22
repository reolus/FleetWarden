# FleetWarden 0.40.0-fleet.5 Upgrade

## Before upgrade

1. Back up the FleetWarden application directory.
2. Back up the MySQL database.
3. Preserve `.env` and runtime `storage` content when replacing release files.
4. Verify the Apache/PHP user can write to `storage/uploads`.

## Upgrade

```bash
cd /var/www/fleetwarden
php scripts/migrate.php status
php scripts/migrate.php migrate
php scripts/migrate.php status
```

The release adds `migrate_phase40_0.sql`.

## Validation

```bash
php tests/phase40_0_regression.php
php tests/phase39_1_regression.php
php tests/phase39_0_regression.php
php tests/phase38_0_regression.php
php tests/route_validation.php
php tests/smoke.php
php scripts/compliance-due.php
```

## Cron

Add the daily compliance evaluator. A daily run is sufficient because most compliance/warranty date changes occur at day granularity; meter-limited warranties are also evaluated immediately when meter readings are entered.

```cron
40 6 * * * www-data cd /var/www/fleetwarden && /usr/bin/php scripts/compliance-due.php >> storage/logs/compliance-due.log 2>&1
```

## Storage

```bash
sudo mkdir -p /var/www/fleetwarden/storage/uploads/compliance
sudo chown -R www-data:www-data /var/www/fleetwarden/storage
sudo find /var/www/fleetwarden/storage -type d -exec chmod 770 {} \;
sudo find /var/www/fleetwarden/storage -type f -exec chmod 660 {} \;
```

## Rollback

The Milestone 5 migration is additive. For source rollback, restore the pre-upgrade application tree and leave the new tables in place. For a full database rollback, restore the pre-upgrade MySQL backup. Destructive rollback SQL is not supplied because it would delete warranty, claim, recall, compliance, and document history created after upgrade.

## Live database note

Release validation includes PHP syntax, route resolution, regression tests, migration-pattern compatibility checks, and schema reconciliation. The build environment does not contain a live MySQL server/client, so the supplied migration must still be executed against a backed-up FleetWarden MySQL instance during deployment.
