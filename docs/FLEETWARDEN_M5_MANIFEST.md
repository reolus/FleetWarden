# FleetWarden Milestone 5 Manifest

Release: `0.40.0-fleet.5`

## New files

- `database/migrate_phase40_0.sql`
- `database/demo/seed_fleetwarden_m5_brighthaven.sql`
- `app/services/ComplianceDueService.php`
- `app/services/ComplianceAttachmentService.php`
- `app/controllers/WarrantyController.php`
- `app/controllers/RecallController.php`
- `app/controllers/ComplianceController.php`
- `app/controllers/ComplianceAttachmentController.php`
- `app/views/portal/warranties/index.php`
- `app/views/portal/recalls/index.php`
- `app/views/portal/compliance/index.php`
- `scripts/compliance-due.php`
- `tests/phase40_0_regression.php`
- `docs/FLEETWARDEN_M5_ARCHITECTURE.md`
- `docs/FLEETWARDEN_M5_UPGRADE.md`
- `docs/FLEETWARDEN_M5_MANIFEST.md`

## Replaced/updated files

- `public/index.php`
- `app/controllers/AssetController.php`
- `app/controllers/FleetDashboardController.php`
- `app/controllers/HealthController.php`
- `app/controllers/MaintenanceController.php`
- `app/controllers/MeterReadingController.php`
- `app/controllers/SearchController.php`
- `app/views/portal/assets/show.php`
- `app/views/portal/fleet-dashboard/index.php`
- `app/views/portal/maintenance/show.php`
- `app/views/partials/portal-sidebar.php`
- `README.md`
- `CHANGELOG-FLEETWARDEN.md`
- `VERSION`
- `release.json`

## Database additions

- `asset_warranties`
- `warranty_claims`
- `asset_compliance_records`
- `asset_recalls`
- `compliance_rules`
- `compliance_rule_evaluations`
- `compliance_attachments`
- `compliance_worker_runs`

No existing FleetWarden table is dropped by Milestone 5.
