# FleetWarden

FleetWarden is a fleet and equipment management platform by McCartney Systems, LLC.

Current release: **0.40.0-fleet.5 - Warranty, Recall & Compliance**

This cumulative release adds date/meter-based warranty tracking, warranty claims, registration/insurance/permit and other compliance records, recall management with corrective work orders, organization-defined compliance rules, protected compliance documents, dashboard/asset-profile integration, notifications, and a daily compliance evaluator. It includes all FleetWarden Milestones 1-4 plus the 0.39 dashboard and vehicle-profile improvements.

## Upgrade

```bash
cd /var/www/fleetwarden
php scripts/migrate.php status
php scripts/migrate.php migrate
php scripts/migrate.php status
php tests/phase40_0_regression.php
php tests/phase39_1_regression.php
php tests/phase39_0_regression.php
php tests/phase38_0_regression.php
php tests/route_validation.php
php tests/smoke.php
php scripts/compliance-due.php
```

## Core FleetWarden workers

```cron
2-59/15 * * * * www-data cd /var/www/fleetwarden && /usr/bin/php scripts/maintenance-due.php >> storage/logs/maintenance-due.log 2>&1
7-59/15 * * * * www-data cd /var/www/fleetwarden && /usr/bin/php scripts/inspection-due.php >> storage/logs/inspection-due.log 2>&1
40 6 * * * www-data cd /var/www/fleetwarden && /usr/bin/php scripts/compliance-due.php >> storage/logs/compliance-due.log 2>&1
```

Compliance attachments are stored below `storage/uploads/compliance`; ensure the FleetWarden PHP/Apache user can write to `storage`.

See `docs/FLEETWARDEN_M5_ARCHITECTURE.md`, `docs/FLEETWARDEN_M5_UPGRADE.md`, and `docs/FLEETWARDEN_M5_MANIFEST.md`.
