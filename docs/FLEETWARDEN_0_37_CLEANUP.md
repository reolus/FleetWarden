# FleetWarden 0.37.0 - Platform Cleanup & Hardening

This release establishes the clean FleetWarden runtime baseline before Preventive Maintenance.

## Removed from active FleetWarden runtime
- Stripe configuration, health checks, checkout service, payment controller, and Stripe webhook route.
- Public customer registration/account workflows.
- Public estimates, invoices, payments, appointments, self-scheduling, agreements, and customer portal routes.
- Portal customer, estimate, invoice, billing, accounting, collections, marketing, lead, service-job, dispatch, service catalog, recurring-service, QuickBooks, tax, and job-cost routes.
- Field-service mobile job and technician routes.
- Customer/job REST endpoints.
- Legacy equipment-custody write routes superseded by canonical `asset_assignments`.
- Archived pre-0.33 application front controllers.

Historical database tables are intentionally retained for upgrade/rollback compatibility. This release does not destructively DROP legacy business data.

## Retained platform capabilities
- Fleet assets, vehicles, serialized equipment, assignments, meters, QR labels.
- Inventory and purchasing.
- Users, Entra ID, crews, skills, certifications.
- Microsoft Graph, SharePoint, Teams, communication providers.
- Notifications, mapping-provider configuration, GPS policy, backups, upgrades, system health.
- Asset replacement planning and alerts.

## Additional hardening
- Fleet-only global search replaces the FieldWarden customer/job search.
- Workforce screen no longer depends on service territories or field-service availability workflows.
- Cumulative Phase 35 and Phase 36 MySQL migration fixes are included.
- Cumulative portal sidebar JavaScript repair is included.

No database migration is required for 0.37.0.
