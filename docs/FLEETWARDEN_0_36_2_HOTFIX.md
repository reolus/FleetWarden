# FleetWarden 0.36.2-fleet.2 MySQL Constraint Hotfix

## Problem

MySQL error 3823 occurs because `migrate_phase36_0.sql` used `target_*` columns in `chk_asset_assignments_target` while also declaring explicit `ON DELETE SET NULL` actions on foreign keys using those same columns. MySQL prohibits referential actions on columns used by a `CHECK` constraint.

## Resolution

The five assignment-target foreign keys retain referential integrity but omit explicit `ON DELETE`/`ON UPDATE` actions. MySQL therefore applies its default restrictive behavior. This also better preserves historical assignment references.

This release also includes the Phase 35 compatibility fix from 0.36.1.

## Recovery

Do not remove Phase 35 objects. Replace `database/migrate_phase36_0.sql` with the corrected file and run:

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

The failed `CREATE TABLE asset_assignments` statement is atomic; normally the table was not created by the failed Phase 36 attempt. `CREATE TABLE IF NOT EXISTS` also makes the corrected migration safe if the table already exists for some other reason.
