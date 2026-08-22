-- FleetWarden Milestone 3: Preventive Maintenance
-- Target: MySQL 8.x, FleetWarden 0.37.0-fleet.2 baseline
-- Additive, resumable where practical, and preserves legacy maintenance fields.

CREATE TABLE IF NOT EXISTS maintenance_templates (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(190) NOT NULL,
    asset_type_scope VARCHAR(40) NOT NULL DEFAULT 'all',
    category VARCHAR(100) NULL,
    description TEXT NULL,
    default_priority VARCHAR(20) NOT NULL DEFAULT 'normal',
    default_duration_minutes INT UNSIGNED NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_by BIGINT UNSIGNED NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_maintenance_templates_active (active,asset_type_scope),
    CONSTRAINT fk_maintenance_templates_created_by FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS maintenance_template_tasks (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    maintenance_template_id BIGINT UNSIGNED NOT NULL,
    task_label VARCHAR(255) NOT NULL,
    instructions TEXT NULL,
    required TINYINT(1) NOT NULL DEFAULT 1,
    sort_order INT NOT NULL DEFAULT 100,
    PRIMARY KEY (id),
    KEY idx_maintenance_template_tasks (maintenance_template_id,sort_order),
    CONSTRAINT fk_maintenance_template_tasks_template FOREIGN KEY (maintenance_template_id) REFERENCES maintenance_templates(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS maintenance_schedules (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    asset_id BIGINT UNSIGNED NOT NULL,
    maintenance_template_id BIGINT UNSIGNED NOT NULL,
    name_override VARCHAR(190) NULL,
    trigger_logic VARCHAR(10) NOT NULL DEFAULT 'any',
    auto_create_work_order TINYINT(1) NOT NULL DEFAULT 1,
    active TINYINT(1) NOT NULL DEFAULT 1,
    start_date DATE NULL,
    due_status VARCHAR(20) NOT NULL DEFAULT 'unknown',
    last_completed_at DATETIME NULL,
    last_completed_work_order_id BIGINT UNSIGNED NULL,
    last_evaluated_at DATETIME NULL,
    created_by BIGINT UNSIGNED NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_maintenance_schedule_asset_template (asset_id,maintenance_template_id),
    KEY idx_maintenance_schedule_due (active,due_status),
    CONSTRAINT fk_maintenance_schedule_asset FOREIGN KEY (asset_id) REFERENCES assets(id),
    CONSTRAINT fk_maintenance_schedule_template FOREIGN KEY (maintenance_template_id) REFERENCES maintenance_templates(id),
    CONSTRAINT fk_maintenance_schedule_created_by FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS maintenance_schedule_rules (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    maintenance_schedule_id BIGINT UNSIGNED NOT NULL,
    rule_type VARCHAR(30) NOT NULL,
    interval_value DECIMAL(14,2) NOT NULL,
    lead_value DECIMAL(14,2) NOT NULL DEFAULT 0,
    baseline_at DATETIME NULL,
    baseline_meter_value DECIMAL(14,2) NULL,
    next_due_at DATETIME NULL,
    next_due_value DECIMAL(14,2) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'unknown',
    last_evaluated_value DECIMAL(14,2) NULL,
    last_evaluated_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_maintenance_rule_schedule (maintenance_schedule_id),
    KEY idx_maintenance_rule_status (status),
    CONSTRAINT fk_maintenance_rule_schedule FOREIGN KEY (maintenance_schedule_id) REFERENCES maintenance_schedules(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS maintenance_work_order_tasks (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    maintenance_work_order_id BIGINT UNSIGNED NOT NULL,
    maintenance_template_task_id BIGINT UNSIGNED NULL,
    task_label VARCHAR(255) NOT NULL,
    instructions TEXT NULL,
    required TINYINT(1) NOT NULL DEFAULT 1,
    completed TINYINT(1) NOT NULL DEFAULT 0,
    completed_by BIGINT UNSIGNED NULL,
    completed_at DATETIME NULL,
    notes TEXT NULL,
    sort_order INT NOT NULL DEFAULT 100,
    PRIMARY KEY (id),
    KEY idx_mwo_tasks_order (maintenance_work_order_id,sort_order),
    CONSTRAINT fk_mwo_tasks_order FOREIGN KEY (maintenance_work_order_id) REFERENCES maintenance_work_orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_mwo_tasks_template_task FOREIGN KEY (maintenance_template_task_id) REFERENCES maintenance_template_tasks(id) ON DELETE SET NULL,
    CONSTRAINT fk_mwo_tasks_completed_by FOREIGN KEY (completed_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS maintenance_worker_runs (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    started_at DATETIME NOT NULL,
    completed_at DATETIME NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'running',
    schedules_evaluated INT UNSIGNED NOT NULL DEFAULT 0,
    work_orders_created INT UNSIGNED NOT NULL DEFAULT 0,
    errors INT UNSIGNED NOT NULL DEFAULT 0,
    detail TEXT NULL,
    PRIMARY KEY (id),
    KEY idx_maintenance_worker_completed (completed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `maintenance_work_orders` ADD COLUMN `asset_id` BIGINT UNSIGNED NULL AFTER `inventory_item_id`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='maintenance_work_orders' AND COLUMN_NAME='asset_id'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `maintenance_work_orders` ADD COLUMN `maintenance_template_id` BIGINT UNSIGNED NULL AFTER `asset_id`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='maintenance_work_orders' AND COLUMN_NAME='maintenance_template_id'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `maintenance_work_orders` ADD COLUMN `maintenance_schedule_id` BIGINT UNSIGNED NULL AFTER `maintenance_template_id`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='maintenance_work_orders' AND COLUMN_NAME='maintenance_schedule_id'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `maintenance_work_orders` ADD COLUMN `generated_by` VARCHAR(40) NOT NULL DEFAULT ''manual'' AFTER `maintenance_schedule_id`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='maintenance_work_orders' AND COLUMN_NAME='generated_by'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `maintenance_work_orders` ADD COLUMN `due_reason` VARCHAR(255) NULL AFTER `generated_by`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='maintenance_work_orders' AND COLUMN_NAME='due_reason'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `maintenance_work_orders` ADD COLUMN `due_at` DATETIME NULL AFTER `due_reason`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='maintenance_work_orders' AND COLUMN_NAME='due_at'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `maintenance_work_orders` ADD COLUMN `due_meter_type` VARCHAR(30) NULL AFTER `due_at`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='maintenance_work_orders' AND COLUMN_NAME='due_meter_type'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `maintenance_work_orders` ADD COLUMN `due_meter_value` DECIMAL(14,2) NULL AFTER `due_meter_type`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='maintenance_work_orders' AND COLUMN_NAME='due_meter_value'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `maintenance_work_orders` ADD COLUMN `started_at` DATETIME NULL AFTER `due_meter_value`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='maintenance_work_orders' AND COLUMN_NAME='started_at'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `maintenance_work_orders` ADD COLUMN `completed_at` DATETIME NULL AFTER `started_at`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='maintenance_work_orders' AND COLUMN_NAME='completed_at'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;

UPDATE maintenance_work_orders m JOIN vehicles v ON v.id=m.vehicle_id SET m.asset_id=v.asset_id WHERE m.asset_id IS NULL AND m.asset_type='vehicle' AND v.asset_id IS NOT NULL;
UPDATE maintenance_work_orders m JOIN equipment_assets ea ON ea.inventory_item_id=m.inventory_item_id SET m.asset_id=ea.asset_id WHERE m.asset_id IS NULL AND m.asset_type='equipment' AND ea.asset_id IS NOT NULL;

INSERT INTO fleet_permissions(permission_key,name,description) VALUES
('maintenance.schedule','Manage Preventive Maintenance','Create templates, schedules, and maintenance rules.'),
('maintenance.evaluate','Run Maintenance Evaluation','Evaluate due rules and generate scheduled work orders.')
ON DUPLICATE KEY UPDATE name=VALUES(name),description=VALUES(description);

INSERT IGNORE INTO fleet_role_permissions(role_id,permission_id)
SELECT r.id,p.id FROM fleet_roles r CROSS JOIN fleet_permissions p
WHERE r.role_key IN ('fleet_administrator','system_administrator','fleet_manager') AND p.permission_key IN ('maintenance.schedule','maintenance.evaluate');
