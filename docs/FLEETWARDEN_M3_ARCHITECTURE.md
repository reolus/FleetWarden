# FleetWarden Milestone 3 - Preventive Maintenance Architecture

## Purpose
Milestone 3 replaces the inherited single `next_service_date` concept with reusable preventive-maintenance templates and per-asset schedules evaluated from calendar and asset-meter history.

## Core model
- `maintenance_templates`: reusable service definitions.
- `maintenance_template_tasks`: checklist items copied into generated work orders.
- `maintenance_schedules`: binds one template to one canonical asset.
- `maintenance_schedule_rules`: one or more trigger rules per schedule.
- `maintenance_work_order_tasks`: execution-time checklist state.
- `maintenance_worker_runs`: observable worker execution history.

Existing `maintenance_work_orders` remains the work execution record and receives canonical FleetWarden columns for asset/template/schedule identity and due metadata. Legacy vehicle/inventory columns remain for compatibility.

## Trigger types
- `calendar`: interval and warning lead are expressed in days.
- `odometer`: interval and warning lead use the canonical odometer meter.
- `engine_hours`: interval and lead use engine hours.
- `usage`: interval and lead use the generic usage counter.

A schedule may use `any` logic (whichever rule becomes due first) or `all` logic. `any` is the default and is appropriate for rules such as 5,000 miles OR 180 days.

## Evaluation
`MaintenanceDueService` reads the latest canonical meter readings, evaluates each rule, stores next-due values/status, calculates the schedule status, and optionally creates a work order. It never creates a duplicate work order while another non-final work order exists for the same schedule.

## Completion
When a scheduled work order is completed, the schedule records the completion and each rule receives a new baseline. Calendar rules use the completion timestamp; meter rules use the latest current reading. The schedule is immediately reevaluated without creating another work order.

## Notifications
Automatic work-order generation emits `maintenance.due` through the existing configurable `NotificationRouteService`.

## Background worker
`scripts/maintenance-due.php` uses `flock` and may be run from cron. Every execution is recorded in `maintenance_worker_runs` and surfaced in System Health.

## Deliberate scope boundaries
Milestone 3 does not yet add warranty adjudication, fleet-native inspections, vendor/parts labor costing, calendar synchronization, recalls, reservations, fuel/EV, or telematics ingestion. Those build on this maintenance foundation in later milestones.
