# FleetWarden Milestone 2 - Assignments & Custody Architecture

Version: 0.36.0-fleet.2  
Publisher: McCartney Systems, LLC  
Source baseline: FleetWarden 0.35.0-fleet.1

## Purpose

Milestone 2 turns the Milestone 1 canonical asset model into an accountable fleet-placement and custody system. It is designed to answer what equipment is on a vehicle, who has an asset, where it is based, which department owns it, which operator is responsible for a vehicle, when it moved, and which temporary assignments are overdue.

## Canonical assignment model

`asset_assignments` is authoritative for serialized asset relationships. Each row contains an asset, assignment scope, mode, one target, effective dates, expected-return information, condition fields, audit actors, and source metadata.

Scopes are `ownership`, `placement`, `custody`, `operator`, and `crew`. Targets can be a vehicle/asset, user, fleet location, department, or crew. A generated active-slot constraint allows only one active assignment per scope while retaining unlimited history.

This intentionally permits independent relationships. For example, a drill can be owned by Facilities, mounted in Vehicle FW-101, and accountable to a technician simultaneously.

## Compatibility

Legacy current-value columns remain synchronized for inherited FieldWarden modules: department ownership projects to asset/vehicle department fields, home location projects to asset/vehicle location fields, and vehicle operator projects to the legacy operator/assigned-vehicle fields.

The inherited `equipment_custody` table remains for rollback/history, but new writes are disabled. Compatible rows are migrated only when their inventory item already maps to a serialized `equipment_asset`, preventing bulk inventory from being misclassified as serialized equipment.

## Canonical asset events

`asset_events` becomes the FleetWarden timeline. Assignment creation, transfer, return, QR scans, and bridged legacy `asset_activity` all correlate to the canonical asset identity.

## Portal and mobile

`/portal/assignments` provides active/history/overdue filtering, create/transfer, and return/end actions. Asset detail pages show current assignments, assignment history, equipment on a vehicle, meter history, and canonical events.

The inherited ServiceOS mobile landing experience is replaced by FleetWarden `My Fleet`, showing user/crew assigned assets, expected returns, overdue custody, asset detail links, return actions, notifications, and QR scanning.

The browser scanner uses `BarcodeDetector` where supported and accepts only same-origin FleetWarden `/asset/scan/...` URLs.

## Security and health

Milestone 2 seeds `assignment.view`, `assignment.edit`, `assignment.checkout`, and `assignment.return` permissions. Existing runtime role checks remain until the planned normalized FleetWarden RBAC cutover.

System Health verifies the assignment/event schema and reports overdue assignment counts without treating an overdue asset as an application failure.

## Deferred

Milestone 3 should build preventive-maintenance templates, mileage/hour/calendar/usage triggers, due-state calculation, generated work orders, completion/reset logic, parts/labor/downtime details, and maintenance workers on this asset/meter/assignment foundation.
