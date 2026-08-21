# FleetWarden Milestone 1 Upgrade Guide

## Supported baseline

This release was developed against the supplied FieldWarden 0.34.0 source archive and the supplied MySQL 8.4.7 `servicewarden` demo dump.

## Before upgrade

1. Back up the application directory and MySQL database.
2. Confirm PHP 8.2+ and MySQL 8.x.
3. Confirm the current migration ledger is healthy with `php scripts/migrate.php status`.
4. Review `.env` and set `APP_NAME=FleetWarden` where desired.
5. Place the release files as direct replacements/new files. Do not use source-patching installers.

## Database migration

Run:

```bash
php scripts/migrate.php status
php scripts/migrate.php migrate
php scripts/migrate.php status
```

The new migration is `database/migrate_phase35_0.sql`.

The migration is additive. It creates FleetWarden core tables, extends `vehicles` and `users`, normalizes existing department names, creates canonical asset records for existing vehicles, links those records back to vehicles, and imports legacy odometer values into meter history.

Existing vehicle tags, QR tokens, odometer values, service dates, user roles, and free-text department values are preserved.

## Post-upgrade checks

1. Browse `/`; it should render FleetWarden sign-in.
2. Sign in locally and, if configured, through Microsoft 365.
3. Open `/portal`; it should render Fleet Dashboard.
4. Open Vehicles and confirm every existing vehicle links to a canonical asset record.
5. Open All Assets and verify asset tags/QR identities.
6. Open Departments and confirm existing user department strings were normalized.
7. Open Equipment & Tools and create one serialized test asset.
8. Add a meter reading from an asset record.
9. Open QR Labels and verify scanning routes directly to the asset record.
10. Open System Health and confirm `FleetWarden Core Schema` is OK.

## Validation performed in the development environment

- PHP syntax validation for application/public/script/test PHP files.
- FleetWarden phase regression/static checks.
- Route-to-controller/method static validation.
- Source/schema reconciliation against the supplied SQL dump.
- Legacy FieldWarden 0.34 regression test.

## Validation NOT performed here

No MySQL server is available in the artifact environment. The migration has therefore not been executed against your live/demo MySQL instance here. Database execution, foreign-key enforcement, live login, Entra callback, Graph, QR image generation, and browser UI behavior require deployment testing on the target environment.

## Rollback

The preferred rollback is source rollback while leaving the additive Milestone 1 tables/columns in place. Older FieldWarden code ignores them, and preserving them avoids destroying any new asset or meter data created after upgrade.

If a full database rollback is mandatory, restore the pre-upgrade database backup rather than dropping tables containing new FleetWarden data.
