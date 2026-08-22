# FleetWarden Milestone 3 Release Manifest

Version: `0.38.0-fleet.3`

## New
- `database/migrate_phase38_0.sql`
- `database/demo/seed_fleetwarden_m3_brighthaven.sql`
- `app/services/MaintenanceDueService.php`
- `app/controllers/PreventiveMaintenanceController.php`
- `app/views/portal/preventive-maintenance/index.php`
- `app/views/portal/maintenance/show.php`
- `scripts/maintenance-due.php`
- `tests/phase38_0_regression.php`
- Milestone 3 architecture/upgrade/manifest documentation.

## Replaced/updated
- `public/index.php`
- `app/controllers/MaintenanceController.php`
- `app/controllers/FleetDashboardController.php`
- `app/controllers/HealthController.php`
- `app/views/portal/maintenance/index.php`
- `app/views/portal/fleet-dashboard/index.php`
- `app/views/partials/portal-sidebar.php`
- `VERSION`, `release.json`, `README.md`, `CHANGELOG-FLEETWARDEN.md`.

## Database objects
Creates maintenance templates, template tasks, schedules, schedule rules, work-order tasks, worker-run history, and additive compatibility columns on `maintenance_work_orders`.
