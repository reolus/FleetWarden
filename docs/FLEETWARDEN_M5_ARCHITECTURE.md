# FleetWarden Milestone 5 Architecture

Version: `0.40.0-fleet.5`  
Milestone: Warranty, Recall & Compliance

## Purpose

Milestone 5 adds lifecycle obligations around canonical FleetWarden assets. It builds on the Milestone 1-4 asset, meter, assignment, maintenance, and inspection models rather than creating separate vehicle-only subsystems.

## Warranty model

`asset_warranties` stores manufacturer, extended, powertrain, component, battery, tire, repair/service, and other warranties. Coverage can expire by date, meter threshold, or both. The evaluator records `ok`, `due_soon`, `expired`, or `unknown` status. Meter-limited warranties are reevaluated immediately when a matching asset meter is recorded and again by the daily compliance worker.

`warranty_claims` tracks claims, linked maintenance work orders, claimed/approved/reimbursed amounts, deductible application, and resolution state. Maintenance work-order detail surfaces active warranties for the affected asset so potential coverage is visible before repair costs are finalized.

## Compliance records

`asset_compliance_records` stores registrations, insurance, titles, permits, regulatory inspections, emissions records, certifications, and organization-specific records. Expiration is evaluated with per-record warning lead time.

## Recall model

`asset_recalls` stores recall/campaign number, source, manufacturer, severity, remedy, status, service provider, and optional corrective maintenance work order. A recall can require the asset to remain out of service. Recall entry supports manual creation and CSV import keyed by canonical asset tag.

## Organization-defined rules

`compliance_rules` allows an organization to require a current compliance record type, an active inspection schedule based on an existing FleetWarden inspection template, or a named certification for the currently assigned operator. Rules can scope to all assets, vehicles, equipment, a vehicle class, an equipment category, or a department. `compliance_rule_evaluations` stores the latest per-asset outcome. A rule may optionally place a noncompliant asset out of service.

## Documents

`compliance_attachments` stores protected file metadata for warranty, warranty-claim, compliance-record, and recall documents. Files live under `storage/uploads/compliance` and are served through authenticated FleetWarden routes. PDF, JPG, PNG, WebP, and TXT are accepted up to 15 MB each.

## Evaluation worker

`scripts/compliance-due.php` uses `flock` and records runs in `compliance_worker_runs`. Each run evaluates warranties, expiring compliance records, organization rules, and open recalls. Notification events include `warranty.expiring`, `warranty.expired`, `compliance.expiring`, `compliance.expired`, `compliance.due_soon`, `compliance.noncompliant`, and `recall.open`.

## Dashboard and asset integration

Fleet Dashboard attention incorporates warranty/compliance/recall risk and includes a dedicated compliance-attention panel. Asset profiles expose warranty coverage, required records, open recalls, rule status, and compliance documents. Global FleetWarden search includes warranties, recalls, and compliance records.

## NHTSA / external recall APIs

Milestone 5 provides manual and CSV recall ingest plus an integration-ready normalized recall model. Direct NHTSA/OEM API synchronization is intentionally deferred to the integrations roadmap rather than coupling the core schema to a single external source.
