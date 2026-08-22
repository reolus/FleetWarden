# FleetWarden Milestone 4 Architecture

## Fleet Inspections & Corrective Actions

Version: `0.39.0-fleet.4`

Milestone 4 makes inspections a first-class FleetWarden workflow while retaining the inspection foundation inherited from FieldWarden. The design intentionally extends the existing `inspection_templates`, `inspection_template_items`, `inspections`, `inspection_responses`, `inspection_attachments`, and inspection packet archive tables instead of creating a second competing inspection subsystem.

## Design goals

The inspection engine supports vehicle and serialized-equipment inspections, mobile operator use, QR-assisted access, reusable checklists, pre-trip/post-trip workflows, recurring inspection schedules, photos, acknowledgment/signatures, explicit defect severity, corrective work, out-of-service decisions, notifications, and durable audit history.

Inspection execution is centered on canonical FleetWarden `assets`. Legacy `entity_type` / `entity_id` values are still populated so historical packet/archive and compatibility code can continue to identify the vehicle/equipment extension record.

## Data model

### Existing tables extended

`inspection_templates`
- `inspection_kind`: pre-trip, post-trip, safety, DOT/regulatory, equipment, general, or future values.
- `asset_type_scope`: vehicle, equipment, or all.
- `requires_signature`: requires typed acknowledgment or captured signature at completion.
- `auto_out_of_service_severity`: threshold that causes a failed inspection to remove an asset from service. `never` disables threshold-based OOS behavior.

`inspection_template_items`
- `evaluation_type`: `pass_fail_na`, `value`, or inherited `legacy` behavior.
- `help_text`: inspector guidance.
- `failure_severity`: minor, major, or critical.
- `out_of_service_on_fail`: forces OOS regardless of template threshold.
- `create_corrective_work_order`: includes the failure in corrective maintenance generation.
- `requires_photo_on_fail`: blocks completion until a photo is attached to the failed checklist item.

`inspections`
- canonical `asset_id`.
- optional `inspection_schedule_id`.
- inspection kind and source.
- started-by / started-at metadata.
- normalized result, severity, OOS flag, and corrective work-order link.
- operator acknowledgment metadata and optional meter snapshot fields.

`inspection_responses`
- normalized outcome: pass, fail, or N/A.
- defect severity and defect note while preserving legacy response fields.

### New tables

`inspection_schedules` associates a template with a canonical asset. It supports recurring, pre-trip, and post-trip modes. Recurring schedules track interval days, warning days, next due time, due status, and last completion. Pre/post-trip schedules are on-demand operational requirements rather than fabricated calendar recurrence.

`inspection_defects` creates one normalized defect per failed inspection item and records severity, OOS effect, lifecycle status, resolution actor/time, resolution notes, and optional corrective work-order linkage.

`inspection_worker_runs` stores operational history for the due evaluator and feeds System Health.

## Execution flow

```text
Asset / My Fleet / QR
        |
        v
Applicable inspection template
        |
        v
Draft inspection
        |
        +--> photos / signature / notes
        |
        v
Complete inspection
        |
        +--> PASS -----------------------> asset event + schedule reset
        |
        +--> FAIL
                |
                +--> normalized defects
                +--> severity calculation
                +--> optional asset OOS
                +--> one corrective maintenance work order
                +--> inspection.failed notification
                +--> inspection.out_of_service notification when applicable
```

## Corrective maintenance behavior

A completed failed inspection creates at most one corrective maintenance work order. Every failed item configured for corrective work is listed in that work order, and all resulting defect records reference the same work order. Work-order priority is derived from the highest failure severity: critical to urgent, major to high, and minor to normal.

## Out-of-service behavior

An asset is placed out of service when either a failed checklist item explicitly has `out_of_service_on_fail=1`, or the maximum failure severity meets or exceeds the template `auto_out_of_service_severity` threshold. For vehicles, both `assets.status` and `vehicles.status` are set to `out_of_service`. For equipment, the canonical asset is out of service and equipment condition becomes `needs_service`.

Defect resolution can request return-to-service. FleetWarden only restores the asset when no other open OOS inspection defects remain.

## Mobile/PWA workflow

My Fleet exposes an Inspect action for assigned assets. Non-manager users may inspect only assets actively assigned to themselves or one of their active crews. The mobile inspection screen supports Pass/Fail/N/A, photos, notes, acknowledgment, and signature capture.

## QR workflow

QR scanning continues to resolve the canonical asset and now lands on the asset inspection section for immediate access to applicable templates.

## Scheduling and worker

Run:

```bash
php scripts/inspection-due.php
```

The worker uses `flock` and records every run. Recurring schedules become `due_soon`, `due`, or `overdue`. Notifications are rate-limited per schedule through `last_notified_at`.

Recommended cadence:

```cron
*/15 * * * * cd /var/www/fleetwarden && /usr/bin/php scripts/inspection-due.php >> storage/logs/inspection-due.log 2>&1
```

## Notifications

Events emitted:
- `inspection.due`
- `inspection.failed`
- `inspection.out_of_service`

They use the existing FleetWarden notification-routing infrastructure.

## Deferred

Milestone 4 does not attempt full DOT regulatory rule automation, external state/federal inspection-system submission, OCR of inspection documents, or telematics-triggered inspections. Those can be layered on this canonical inspection/defect model later.
