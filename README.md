# FleetWarden

FleetWarden is a fleet and equipment management platform by McCartney Systems, LLC.

Current release: **0.41.0-fleet.6 - Calendar, Notifications & Operational Scheduling**

Milestone 6 adds the unified Fleet Calendar, shop/resource scheduling, timed maintenance work orders, queued notification delivery, wildcard notification routing, per-user notification preferences, Microsoft 365 calendar projection, dashboard upcoming-operations visibility, and calendar/notification worker health.

## Upgrade

```bash
cd /var/www/fleetwarden
php scripts/migrate.php status
php scripts/migrate.php migrate
php scripts/migrate.php status
php tests/phase41_0_regression.php
php tests/phase40_0_regression.php
php tests/route_validation.php
php tests/smoke.php
```

## Core FleetWarden workers

```cron
2-59/15 * * * * www-data cd /var/www/fleetwarden && /usr/bin/php scripts/maintenance-due.php >> storage/logs/maintenance-due.log 2>&1
7-59/15 * * * * www-data cd /var/www/fleetwarden && /usr/bin/php scripts/inspection-due.php >> storage/logs/inspection-due.log 2>&1
*/5 * * * * www-data cd /var/www/fleetwarden && /usr/bin/php scripts/notification-dispatch.php >> storage/logs/notification-dispatch.log 2>&1
*/5 * * * * www-data cd /var/www/fleetwarden && /usr/bin/php scripts/calendar-sync.php >> storage/logs/calendar-sync.log 2>&1
40 6 * * * www-data cd /var/www/fleetwarden && /usr/bin/php scripts/compliance-due.php >> storage/logs/compliance-due.log 2>&1
```

For Microsoft 365 projection, set `M365_FLEET_CALENDAR_ID` or allow FleetWarden to fall back to `M365_CALENDAR_ID`. FleetWarden remains the authoritative scheduling source.

See `docs/FLEETWARDEN_M6_ARCHITECTURE.md`, `docs/FLEETWARDEN_M6_UPGRADE.md`, and `docs/FLEETWARDEN_M6_MANIFEST.md`.
