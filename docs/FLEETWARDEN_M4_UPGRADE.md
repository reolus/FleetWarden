# FleetWarden 0.39.0-fleet.4 Upgrade

## Baseline

Upgrade from FleetWarden `0.38.0-fleet.3`.

Back up both the application tree and database before deployment.

```bash
cd /var/www
sudo cp -a fleetwarden fleetwarden-backup-$(date +%Y%m%d-%H%M)
mysqldump -u YOUR_DB_USER -p YOUR_DATABASE > ~/fleetwarden-before-039.sql
```

Preserve the existing production `.env` and runtime uploads/storage when replacing files.

## File permissions

After extraction, normalize permissions so Apache can read application code and write runtime storage:

```bash
sudo chown -R root:www-data /var/www/fleetwarden
sudo find /var/www/fleetwarden -type d -exec chmod 750 {} \;
sudo find /var/www/fleetwarden -type f -exec chmod 640 {} \;
sudo chown -R www-data:www-data /var/www/fleetwarden/storage
sudo find /var/www/fleetwarden/storage -type d -exec chmod 770 {} \;
sudo find /var/www/fleetwarden/storage -type f -exec chmod 660 {} \;
sudo chown root:www-data /var/www/fleetwarden/.env
sudo chmod 640 /var/www/fleetwarden/.env
```

If a separate uploads path is configured, keep that path writable by the Apache user as well.

## Database migration

```bash
cd /var/www/fleetwarden
php scripts/migrate.php status
php scripts/migrate.php migrate
php scripts/migrate.php status
```

`migrate_phase39_0.sql` should show as applied.

The migration is additive. It extends existing inspection tables and creates `inspection_schedules`, `inspection_defects`, and `inspection_worker_runs`. Historical inspection data is retained.

## Validation

```bash
php tests/phase39_0_regression.php
php tests/phase38_0_regression.php
php tests/phase37_0_regression.php
php tests/phase36_2_regression.php
php tests/phase36_1_regression.php
php tests/phase36_0_regression.php
php tests/phase35_0_regression.php
php tests/route_validation.php
php tests/smoke.php
```

Then run the worker once:

```bash
php scripts/inspection-due.php
```

With no recurring inspection schedules, a zero-due result is normal.

## Cron

```cron
*/15 * * * * cd /var/www/fleetwarden && /usr/bin/php scripts/inspection-due.php >> storage/logs/inspection-due.log 2>&1
```

## Browser validation

Check `/portal`, `/portal/assets`, one asset's `#inspections` section, `/portal/inspections`, `/portal/inspection-templates`, `/portal/inspection-defects`, `/portal/mobile`, and `/portal/health`.

Create a test template and verify a passing inspection, a failed inspection with corrective maintenance, out-of-service handling, defect resolution, and explicit return to service.

## Demo data

For the fictional Brighthaven environment only:

```bash
mysql -u YOUR_DB_USER -p YOUR_DATABASE < database/demo/seed_fleetwarden_m4_brighthaven.sql
```

Do not load the demo seed into a production customer database.

## Rollback

Application rollback: restore the pre-0.39 application backup. The additive Phase 39 tables/columns may remain in the database without affecting 0.38 code.

For a complete database rollback, restore the pre-upgrade database backup. A destructive DOWN migration is intentionally not provided because it would delete inspection defects, schedule state, and inspection outcome data created after the upgrade.
