# FleetWarden 0.36.0-fleet.2 Release Manifest

Milestone: Assignments & Custody  
Target branch: `release/fieldwarden-fleet`  
Publisher: McCartney Systems, LLC

## New source

- `app/controllers/AssignmentController.php`
- `app/services/AssetAssignmentService.php`
- `app/services/FleetAssetEventService.php`
- `app/views/portal/assignments/index.php`
- `app/views/portal/assignments/form.php`
- `app/views/portal/mobile/scanner.php`
- `database/migrate_phase36_0.sql`
- `database/demo/seed_fleetwarden_m2_brighthaven.sql`
- `tests/phase36_0_regression.php`

## Direct replacements / modified source

- `public/index.php`
- `app/controllers/AssetController.php`
- `app/controllers/EquipmentAssetController.php`
- `app/controllers/EquipmentCustodyController.php`
- `app/controllers/EquipmentLabelController.php`
- `app/controllers/FleetController.php`
- `app/controllers/FleetDashboardController.php`
- `app/controllers/HealthController.php`
- `app/controllers/MobileController.php`
- `app/services/AssetActivityService.php`
- `app/views/layouts/mobile.php`
- `app/views/partials/portal-sidebar.php`
- `app/views/portal/assets/index.php`
- `app/views/portal/assets/show.php`
- `app/views/portal/equipment-assets/index.php`
- `app/views/portal/fleet/index.php`
- `app/views/portal/fleet-dashboard/index.php`
- `app/views/portal/mobile/dashboard.php`
- `scripts/migrate.php`
- `VERSION`
- `release.json`
- `README.md`
- `CHANGELOG-FLEETWARDEN.md`

## Git release payload

The branch contains `releases/FleetWarden-0.36.0-fleet.2-milestone-files.tar.gz` plus its SHA-256 file. This archive contains the complete changed/new source delta for Milestone 2 and applies over FleetWarden 0.35.0-fleet.1.

## Compatibility

The inherited `equipment_custody` table is retained but new writes are redirected to FleetWarden Assignments. `asset_activity` remains available to inherited modules and bridges to canonical `asset_events` when a corresponding canonical asset exists. Milestone 1 current-value compatibility fields remain synchronized by the assignment service.

## Not included

Preventive-maintenance scheduling and trigger rules are intentionally deferred to Milestone 3. The build environment did not contain a live MySQL server, so the manifest does not claim live Phase 36 migration execution.
