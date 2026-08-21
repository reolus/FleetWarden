# FleetWarden Changelog

## 0.36.0-fleet.2 - 2026-08-21

### Added
- Canonical `asset_assignments` model with complete dated assignment history.
- Placement, custody, ownership, operator, and crew assignment scopes.
- Vehicle, asset, user, location, department, and crew assignment targets.
- Permanent, temporary, checkout, mounted, home, primary, pool, and storage assignment modes.
- Expected-return tracking and overdue-return dashboard indicators.
- Asset assignment/transfer/return portal with filters and history.
- Vehicle and equipment detail views with current assignments and assignment history.
- Equipment-on-vehicle visibility and counts.
- Canonical `asset_events` timeline and compatibility bridge from legacy `asset_activity`.
- FleetWarden mobile `My Fleet` dashboard for assigned assets and returns.
- Mobile QR scanner using the browser BarcodeDetector API where supported, with safe fallback.
- QR scan audit event and direct asset detail experience.
- Assignment permissions in FleetWarden RBAC schema.
- Assignment System Health check.
- Optional Brighthaven Milestone 2 demo seed for serialized equipment and assignment scenarios.

### Changed
- Vehicle department, location, and operator edits now create/close canonical assignments rather than silently overwriting history.
- Equipment department and location edits now preserve assignment history.
- Fleet and equipment lists display canonical current placement/custodian/operator state.
- Fleet Dashboard now uses canonical asset events and surfaces equipment placement/overdue returns.
- Primary navigation now exposes Assignments and My Fleet, and removes legacy custody/history navigation.
- Mobile shell rebranded from the inherited ServiceOS field workflow to FleetWarden.

### Fixed
- Legacy asset activity now bridges into canonical FleetWarden asset events when a matching canonical asset exists.
- New custody records can no longer be created in the parallel legacy `equipment_custody` subsystem.
- Serialized equipment can be assigned directly to a vehicle, location, crew, department, or user without requiring an arbitrary employee custodian.
- Migration CLI no longer emits ineffective global `use PDO` / `use Throwable` warnings.
- Current placement, custody, and ownership each have independent active slots, allowing an asset to be mounted to a vehicle while also being accountable to a user or department.

### Migration
- Compatible legacy equipment-custody rows are imported only when their inventory item was already promoted to a serialized `equipment_asset`.
- Legacy vehicle department/location/operator values are imported as canonical current assignments.
- Existing `equipment_custody`, vehicle compatibility columns, and `asset_activity` are retained for rollback/read compatibility; new FleetWarden writes use the canonical assignment/event model.

### Deferred
Preventive-maintenance templates/triggers and maintenance scheduling remain Milestone 3. Warranties, fleet-native inspections, calendar abstraction, push delivery, fuel/EV, reservations, telematics, advanced RBAC runtime cutover, and analytics remain later milestones.

## 0.35.0-fleet.1 - 2026-08-21

### Added
- Canonical serialized `assets` model.
- Serialized `equipment_assets` separate from stock inventory.
- Asset meter history for odometer, engine hours, and usage.
- Normalized departments and fleet locations.
- FleetWarden RBAC schema foundation and seeded fleet roles/permissions.
- Fleet dashboard.
- Fleet asset list/detail pages.
- Expanded vehicle data and editing.
- Serialized equipment create/edit UI.
- Meter-reading entry and compatibility update to legacy vehicle odometer.
- Canonical QR label/scanning behavior.
- FleetWarden core schema System Health check.

### Changed
- Application root now presents FleetWarden portal sign-in instead of the commercial product site.
- Primary portal navigation is fleet-focused.
- Product metadata updated for FleetWarden by McCartney Systems, LLC.
- Existing vehicle records are linked to canonical assets without deleting legacy data.

### Fixed
- Mobile inspections now use the actual generic inspection entity schema.
- Legacy equipment maintenance activity no longer disappears because of asset-type naming mismatch.
- Duplicate AI System Health check removed.
- Authenticated portal no longer embeds Google Analytics.
