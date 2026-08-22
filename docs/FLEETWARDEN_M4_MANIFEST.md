# FleetWarden Milestone 4 Release Manifest

Version: `0.39.0-fleet.4`

## Database
- `database/migrate_phase39_0.sql`
- `database/demo/seed_fleetwarden_m4_brighthaven.sql`

## Services
- `app/services/FleetInspectionService.php`
- `app/services/InspectionDueService.php`
- `app/services/InspectionPacketService.php` (updated)

## Controllers
- `app/controllers/InspectionController.php` (FleetWarden rewrite)
- `app/controllers/InspectionTemplateController.php` (FleetWarden rewrite)
- `app/controllers/InspectionScheduleController.php`
- `app/controllers/InspectionDefectController.php`
- `app/controllers/AssetController.php` (inspection integration)
- `app/controllers/MobileController.php` (mobile inspection integration)
- `app/controllers/FleetDashboardController.php` (inspection metrics)
- `app/controllers/HealthController.php` (inspection worker/schema health)
- `app/controllers/EquipmentLabelController.php` (QR inspection anchor)

## Views
- `app/views/portal/inspections/index.php`
- `app/views/portal/inspections/show.php`
- `app/views/portal/inspection-templates/index.php`
- `app/views/portal/inspection-templates/show.php`
- `app/views/portal/inspection-defects/index.php`
- `app/views/portal/mobile/inspect-asset.php`
- `app/views/portal/mobile/dashboard.php` (updated)
- `app/views/portal/assets/show.php` (updated)
- `app/views/portal/fleet-dashboard/index.php` (updated)
- `app/views/partials/portal-sidebar.php` (updated)
- `app/views/pdf/inspection-packet.php` (FleetWarden rewrite)

## Router / workers
- `public/index.php`
- `scripts/inspection-due.php`

## Tests
- `tests/phase39_0_regression.php`

## Release metadata/documentation
- `VERSION`
- `release.json`
- `README.md`
- `CHANGELOG-FLEETWARDEN.md`
- `docs/FLEETWARDEN_M4_ARCHITECTURE.md`
- `docs/FLEETWARDEN_M4_UPGRADE.md`
- `docs/FLEETWARDEN_M4_MANIFEST.md`
