# FleetWarden Milestone 1 - Fleet Core Architecture

Version: 0.35.0-fleet.1  
Publisher: McCartney Systems, LLC  
Source baseline: FieldWarden 0.34.0  
Database baseline: servicewarden demo dump supplied 2026-08-21

## Purpose

Milestone 1 establishes FleetWarden as a fleet-first product while preserving the mature authentication, Microsoft 365, notification, inventory, inspection, audit, mapping, and System Health infrastructure already present in FieldWarden.

This milestone intentionally does not implement preventive-maintenance automation, generalized custody/assignment history, warranties, reservations, telematics adapters, fuel analytics, or replacement scoring. Those features depend on the canonical asset and meter model introduced here.

## Architectural decisions

### Application entry point

`public/index.php` is restored as the application front controller. `/` renders the FleetWarden sign-in experience. The commercial FieldWarden marketing homepage is no longer the application root.

### Canonical assets

`assets` is the common identity for serialized managed things. Vehicles and serialized equipment attach to it through type-specific extension tables.

- `vehicles.asset_id -> assets.id`
- `equipment_assets.asset_id -> assets.id`
- `inventory_items` remains the stock/parts/consumables model and is not promoted to a universal equipment table.

### Vehicle compatibility

Legacy vehicle tag, QR, odometer, and next-service fields are retained during transition. Existing vehicles receive canonical asset records during migration. Existing odometer values are imported into meter history as `legacy_import` records. Nothing is deleted.

### Meter model

`asset_meter_readings` supports independent odometer, engine-hour, and usage-count history. Each vehicle has a `primary_meter_type`.

### Serialized equipment versus inventory

`equipment_assets` stores individually identifiable tools/equipment with serial number, manufacturer/model, condition, warranty expiration, and replacement target. `inventory_items` continues to represent stock quantities such as filters, fluids, batteries, parts, and supplies.

### Organization model

Free-text `users.department` is preserved, while values are normalized into `departments` and linked through `users.department_id`. `fleet_locations` represents shops, garages, yards, facilities, and other asset locations.

### RBAC foundation

Milestone 1 creates FleetWarden role/permission tables and seeds fleet roles and permission keys. Legacy `users.role` remains authoritative for runtime authorization in this milestone to avoid a one-step identity cutover.

### QR behavior

QR labels now originate from canonical assets. Scans resolve directly to `/portal/assets/{id}` instead of dropping users on a generic Fleet or Inventory list.

## Core tables introduced

- `departments`
- `fleet_locations`
- `fleet_roles`
- `fleet_permissions`
- `fleet_role_permissions`
- `fleet_user_roles`
- `assets`
- `equipment_assets`
- `asset_meter_readings`

## Confirmed baseline defects corrected

1. The packaged commercial homepage replaced the application front controller. The portal router is restored and `/` now presents sign-in.
2. `MobileController` referenced nonexistent `inspections.job_id`. It now queries `entity_type='job' AND entity_id=?`.
3. Maintenance used asset type `equipment` while `AssetActivityService` accepted only `vehicle` and `inventory`; legacy equipment maintenance activity is now normalized so events are not silently dropped.
4. Duplicate AI System Health check removed.
5. System Health now checks FleetWarden core schema presence.
6. Authenticated portal Google Analytics tracking removed.

## Navigation

FleetWarden navigation is fleet-first: Fleet Dashboard; Fleet; Maintenance & Compliance; Inventory & Custody; Organization; Notifications; and System.

Older customer/job/sales/billing routes remain in source for compatibility but are intentionally removed from primary FleetWarden navigation. Removal should occur only after dependency analysis.

## Deferred to later milestones

- Generalized asset assignments/custody history
- Preventive-maintenance templates and trigger engine
- Full work-order redesign, labor/parts/downtime tables
- Inspection mobile workflow redesign
- Warranty and recall management
- Generic calendar-event abstraction
- Push delivery provider
- Fuel/EV usage
- Reservations
- Telematics provider abstraction
- TCO/utilization/replacement analytics
- Fleet-native mobile driver/mechanic shell
- Normalized RBAC runtime cutover
