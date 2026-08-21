# FleetWarden Changelog

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

### Deferred
Preventive maintenance automation, generalized assignments, warranty management, fleet-native inspections, calendar abstraction, push delivery, telematics, reservations, fuel/EV, and fleet analytics remain later milestones.
