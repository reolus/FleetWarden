# FleetWarden Changelog

## 0.39.0-fleet.4 - 2026-08-21

### Added
- Fleet-native inspection execution linked to canonical `assets`.
- Reusable inspection kinds for pre-trip, post-trip, safety, DOT/regulatory, equipment, and general inspections.
- Pass / Fail / N/A checklist evaluation with required-item enforcement.
- Per-item failure severity, required failure photos, explicit out-of-service behavior, and corrective-work-order behavior.
- Typed operator acknowledgment and captured signature support.
- Recurring, pre-trip, and post-trip inspection schedules.
- `inspection-due.php` background evaluator with `flock` concurrency protection and worker-run history.
- Normalized `inspection_defects` records with severity, status, resolution notes, and corrective-maintenance linkage.
- Automatic one-work-order-per-failed-inspection corrective maintenance generation.
- Automatic out-of-service transitions for unsafe inspection failures.
- Defect resolution with guarded return-to-service behavior.
- Mobile/PWA asset inspection selection and execution from My Fleet.
- QR scans now land directly on the asset inspection section.
- Fleet dashboard inspection-due and open-defect indicators.
- Fleet inspection worker status in System Health.
- FleetWarden-branded asset inspection PDF packets.
- Optional Brighthaven Milestone 4 demo inspection templates and schedules.

### Changed
- Existing generic FieldWarden inspection tables are extended rather than replaced, preserving historical inspections, photos, signatures, and packet archives.
- Asset detail pages now show applicable inspection templates, schedules, recent inspections, and open defects.
- Maintenance & Compliance navigation now includes Fleet Inspections, Inspection Templates, and Inspection Defects.

### Migration
- Adds `migrate_phase39_0.sql`.
- Uses guarded `INFORMATION_SCHEMA` column additions for resumable MySQL-compatible DDL.
- Does not use `ADD COLUMN IF NOT EXISTS`.
- Introduces no new `CHECK` constraints, avoiding the MySQL CHECK/FK referential-action conflict encountered in Milestone 2.
- Historical vehicle/equipment inspections are linked to canonical assets where the relationship can be reconciled safely.

## 0.38.0-fleet.3 - 2026-08-21

### Added
- Reusable preventive-maintenance templates and checklist tasks.
- Per-asset maintenance schedules with ANY/ALL trigger logic.
- Calendar, odometer, engine-hour, and usage triggers with due-soon lead thresholds.
- Maintenance due evaluator and `flock`-protected background worker.
- Automatic non-duplicating work-order generation for due schedules.
- Work-order checklist task state and completion tracking.
- Schedule baseline reset after completed preventive maintenance.
- `maintenance.due` notification event integration.
- Preventive Maintenance dashboard, template editor, schedule assignment, trigger management, and manual evaluation.
- Preventive-maintenance worker status in System Health.
- Optional Brighthaven preventive-maintenance demo seed.

### Changed
- Maintenance work orders now use canonical `asset_id` while retaining legacy vehicle/inventory compatibility fields.
- Fleet Dashboard service indicators use the preventive-maintenance engine rather than `vehicles.next_service_date`.
- Work orders identify whether they were created manually or by a maintenance schedule.

### Migration
- Adds `migrate_phase38_0.sql`.
- Migration uses guarded `INFORMATION_SCHEMA` column additions and does not use `ADD COLUMN IF NOT EXISTS`.
- No new CHECK constraints are introduced.

## 0.37.0-fleet.2 - 2026-08-21

### Removed
- Stripe runtime integration, configuration, health status, payment service/controller, and webhook route.
- Active FieldWarden customer, estimate, invoice/payment, service-job, marketing, scheduling, accounting, QuickBooks, collections, service catalog, and customer API routes.
- Legacy equipment-custody write routes and archived pre-0.33 front controllers.

### Changed
- Rebuilt the application front controller as an explicit FleetWarden-only route surface.
- Global search now searches fleet assets, vehicles, equipment, work orders, people, departments, and fleet locations.
- Workforce management now focuses on crews, default vehicles, operators, skills, and qualifications.
- Optional integrations shown in System Health are limited to integrations actually retained by FleetWarden.
- Fresh environment example uses `fleetwarden` as the default database name.

### Included fixes
- Phase 35 resumable MySQL migration compatibility fix.
- Phase 36 MySQL CHECK/FK compatibility fix.
- Portal sidebar JavaScript/collapse/accordion fix.

### Database
No destructive cleanup is performed. Historical FieldWarden business tables remain available for rollback/archive purposes but are no longer exposed by the FleetWarden runtime.

## 0.36.2-fleet.2 - 2026-08-21

### Fixed
- Removed explicit `ON DELETE` referential actions from `asset_assignments` target foreign keys used by `chk_asset_assignments_target`, resolving MySQL error 3823.
- Target foreign keys now use MySQL's default restrictive behavior, preserving assignment-history targets instead of nulling them.
- Added regression coverage for MySQL's prohibition on referential actions involving columns used by `CHECK` constraints.
- Includes the 0.36.1 Phase 35 resumable migration compatibility fix.

## 0.36.1-fleet.2 - 2026-08-21

### Fixed
- Replaced unsupported `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` syntax in `migrate_phase35_0.sql` with MySQL-compatible `INFORMATION_SCHEMA` guards and prepared DDL.
- Phase 35 can now resume safely after a partially committed failed run; previously created tables and columns are detected and retained.
- Added regression coverage preventing unsupported conditional `ALTER TABLE` syntax from returning to active FleetWarden migrations.

## 0.36.0-fleet.2 - 2026-08-21

### Added
- Canonical `asset_assignments` model with complete dated assignment history.
- Placement, custody, ownership, operator, and crew assignment scopes.
- Vehicle, asset, user, location, department, and crew assignment targets.
- Permanent, temporary, checkout, mounted, home, primary, pool, and storage assignment modes.
- Expected-return tracking and overdue-return dashboard indicators.
- Asset assignment/transfer/return portal with filters and history.
- Canonical `asset_events` timeline and compatibility bridge from legacy `asset_activity`.
- FleetWarden mobile `My Fleet` dashboard and QR scanner foundation.

## 0.35.0-fleet.1 - 2026-08-21

### Added
- Canonical serialized asset model, equipment assets, meter history, departments/locations, FleetWarden RBAC foundation, fleet dashboard, expanded vehicles, QR routing, and FleetWarden portal shell.
