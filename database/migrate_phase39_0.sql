-- FleetWarden Milestone 4: Fleet Inspections & Corrective Actions
-- Target: MySQL 8.x, FleetWarden 0.38.0-fleet.3 baseline
-- Extends the inherited generic inspection tables instead of creating a parallel inspection engine.

CREATE TABLE IF NOT EXISTS inspection_schedules (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    asset_id BIGINT UNSIGNED NOT NULL,
    inspection_template_id BIGINT UNSIGNED NOT NULL,
    schedule_type VARCHAR(30) NOT NULL DEFAULT 'recurring',
    interval_days INT UNSIGNED NULL,
    warning_days INT UNSIGNED NOT NULL DEFAULT 3,
    next_due_at DATETIME NULL,
    due_status VARCHAR(20) NOT NULL DEFAULT 'unknown',
    last_completed_at DATETIME NULL,
    last_inspection_id BIGINT UNSIGNED NULL,
    last_notified_at DATETIME NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_by BIGINT UNSIGNED NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_inspection_schedule_asset_template_type (asset_id,inspection_template_id,schedule_type),
    KEY idx_inspection_schedule_due (active,due_status,next_due_at),
    CONSTRAINT fk_inspection_schedule_asset FOREIGN KEY (asset_id) REFERENCES assets(id),
    CONSTRAINT fk_inspection_schedule_template FOREIGN KEY (inspection_template_id) REFERENCES inspection_templates(id),
    CONSTRAINT fk_inspection_schedule_last_inspection FOREIGN KEY (last_inspection_id) REFERENCES inspections(id) ON DELETE SET NULL,
    CONSTRAINT fk_inspection_schedule_created_by FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS inspection_defects (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    inspection_id BIGINT UNSIGNED NOT NULL,
    inspection_response_id BIGINT UNSIGNED NULL,
    inspection_template_item_id BIGINT UNSIGNED NOT NULL,
    asset_id BIGINT UNSIGNED NOT NULL,
    severity VARCHAR(20) NOT NULL DEFAULT 'minor',
    title VARCHAR(255) NOT NULL,
    description TEXT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'open',
    out_of_service TINYINT(1) NOT NULL DEFAULT 0,
    corrective_work_order_id BIGINT UNSIGNED NULL,
    created_by BIGINT UNSIGNED NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_by BIGINT UNSIGNED NULL,
    resolved_at DATETIME NULL,
    resolution_notes TEXT NULL,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_inspection_defect_asset_status (asset_id,status,severity),
    KEY idx_inspection_defect_inspection (inspection_id),
    KEY idx_inspection_defect_work_order (corrective_work_order_id),
    CONSTRAINT fk_inspection_defect_inspection FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE,
    CONSTRAINT fk_inspection_defect_response FOREIGN KEY (inspection_response_id) REFERENCES inspection_responses(id) ON DELETE SET NULL,
    CONSTRAINT fk_inspection_defect_item FOREIGN KEY (inspection_template_item_id) REFERENCES inspection_template_items(id),
    CONSTRAINT fk_inspection_defect_asset FOREIGN KEY (asset_id) REFERENCES assets(id),
    CONSTRAINT fk_inspection_defect_work_order FOREIGN KEY (corrective_work_order_id) REFERENCES maintenance_work_orders(id) ON DELETE SET NULL,
    CONSTRAINT fk_inspection_defect_created_by FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_inspection_defect_resolved_by FOREIGN KEY (resolved_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS inspection_worker_runs (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    started_at DATETIME NOT NULL,
    completed_at DATETIME NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'running',
    schedules_evaluated INT UNSIGNED NOT NULL DEFAULT 0,
    schedules_due INT UNSIGNED NOT NULL DEFAULT 0,
    notifications_sent INT UNSIGNED NOT NULL DEFAULT 0,
    errors INT UNSIGNED NOT NULL DEFAULT 0,
    detail TEXT NULL,
    PRIMARY KEY (id),
    KEY idx_inspection_worker_completed (completed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Extend templates with fleet inspection behavior.
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspection_templates` ADD COLUMN `inspection_kind` VARCHAR(40) NOT NULL DEFAULT ''general'' AFTER `entity_type`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspection_templates' AND COLUMN_NAME='inspection_kind'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspection_templates` ADD COLUMN `asset_type_scope` VARCHAR(40) NOT NULL DEFAULT ''all'' AFTER `inspection_kind`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspection_templates' AND COLUMN_NAME='asset_type_scope'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspection_templates` ADD COLUMN `requires_signature` TINYINT(1) NOT NULL DEFAULT 0 AFTER `description`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspection_templates' AND COLUMN_NAME='requires_signature'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspection_templates` ADD COLUMN `auto_out_of_service_severity` VARCHAR(20) NOT NULL DEFAULT ''critical'' AFTER `requires_signature`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspection_templates' AND COLUMN_NAME='auto_out_of_service_severity'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;

-- Extend inspection checklist items with pass/fail behavior and corrective-action rules.
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspection_template_items` ADD COLUMN `evaluation_type` VARCHAR(30) NOT NULL DEFAULT ''legacy'' AFTER `field_type`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspection_template_items' AND COLUMN_NAME='evaluation_type'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspection_template_items` ADD COLUMN `help_text` VARCHAR(500) NULL AFTER `label`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspection_template_items' AND COLUMN_NAME='help_text'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspection_template_items` ADD COLUMN `failure_severity` VARCHAR(20) NOT NULL DEFAULT ''minor'' AFTER `evaluation_type`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspection_template_items' AND COLUMN_NAME='failure_severity'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspection_template_items` ADD COLUMN `out_of_service_on_fail` TINYINT(1) NOT NULL DEFAULT 0 AFTER `failure_severity`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspection_template_items' AND COLUMN_NAME='out_of_service_on_fail'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspection_template_items` ADD COLUMN `create_corrective_work_order` TINYINT(1) NOT NULL DEFAULT 1 AFTER `out_of_service_on_fail`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspection_template_items' AND COLUMN_NAME='create_corrective_work_order'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspection_template_items` ADD COLUMN `requires_photo_on_fail` TINYINT(1) NOT NULL DEFAULT 0 AFTER `create_corrective_work_order`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspection_template_items' AND COLUMN_NAME='requires_photo_on_fail'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;

-- Extend inspection executions with canonical asset identity and outcome state.
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspections` ADD COLUMN `asset_id` BIGINT UNSIGNED NULL AFTER `entity_id`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspections' AND COLUMN_NAME='asset_id'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspections` ADD COLUMN `inspection_schedule_id` BIGINT UNSIGNED NULL AFTER `asset_id`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspections' AND COLUMN_NAME='inspection_schedule_id'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspections` ADD COLUMN `inspection_kind` VARCHAR(40) NOT NULL DEFAULT ''general'' AFTER `inspection_schedule_id`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspections' AND COLUMN_NAME='inspection_kind'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspections` ADD COLUMN `source` VARCHAR(30) NOT NULL DEFAULT ''portal'' AFTER `inspection_kind`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspections' AND COLUMN_NAME='source'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspections` ADD COLUMN `started_by` BIGINT UNSIGNED NULL AFTER `source`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspections' AND COLUMN_NAME='started_by'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspections` ADD COLUMN `started_at` DATETIME NULL AFTER `started_by`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspections' AND COLUMN_NAME='started_at'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspections` ADD COLUMN `result` VARCHAR(20) NOT NULL DEFAULT ''pending'' AFTER `status`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspections' AND COLUMN_NAME='result'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspections` ADD COLUMN `overall_severity` VARCHAR(20) NULL AFTER `result`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspections' AND COLUMN_NAME='overall_severity'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspections` ADD COLUMN `out_of_service` TINYINT(1) NOT NULL DEFAULT 0 AFTER `overall_severity`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspections' AND COLUMN_NAME='out_of_service'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspections` ADD COLUMN `corrective_work_order_id` BIGINT UNSIGNED NULL AFTER `out_of_service`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspections' AND COLUMN_NAME='corrective_work_order_id'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspections` ADD COLUMN `operator_name` VARCHAR(190) NULL AFTER `notes`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspections' AND COLUMN_NAME='operator_name'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspections` ADD COLUMN `operator_signed_at` DATETIME NULL AFTER `operator_name`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspections' AND COLUMN_NAME='operator_signed_at'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspections` ADD COLUMN `meter_type` VARCHAR(30) NULL AFTER `operator_signed_at`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspections' AND COLUMN_NAME='meter_type'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspections` ADD COLUMN `meter_value` DECIMAL(14,2) NULL AFTER `meter_type`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspections' AND COLUMN_NAME='meter_value'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;

-- Extend responses with normalized outcome/defect detail while retaining legacy response_text/response_json.
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspection_responses` ADD COLUMN `outcome` VARCHAR(20) NULL AFTER `response_json`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspection_responses' AND COLUMN_NAME='outcome'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspection_responses` ADD COLUMN `defect_severity` VARCHAR(20) NULL AFTER `outcome`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspection_responses' AND COLUMN_NAME='defect_severity'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;
SET @fw_sql=(SELECT IF(COUNT(*)=0,'ALTER TABLE `inspection_responses` ADD COLUMN `defect_note` TEXT NULL AFTER `defect_severity`','SET @fw_migration_noop=1') FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='inspection_responses' AND COLUMN_NAME='defect_note'); PREPARE fw_stmt FROM @fw_sql; EXECUTE fw_stmt; DEALLOCATE PREPARE fw_stmt;

UPDATE inspection_templates SET asset_type_scope='vehicle' WHERE entity_type='vehicle' AND asset_type_scope='all';
UPDATE inspection_templates SET asset_type_scope='equipment' WHERE entity_type='equipment' AND asset_type_scope='all';

UPDATE inspections i JOIN vehicles v ON i.entity_type='vehicle' AND v.id=i.entity_id SET i.asset_id=v.asset_id WHERE i.asset_id IS NULL AND v.asset_id IS NOT NULL;
UPDATE inspections i JOIN equipment_assets ea ON i.entity_type='equipment' AND ea.id=i.entity_id SET i.asset_id=ea.asset_id WHERE i.asset_id IS NULL;
UPDATE inspections i JOIN equipment_assets ea ON i.entity_type='equipment' AND ea.inventory_item_id=i.entity_id SET i.asset_id=ea.asset_id WHERE i.asset_id IS NULL AND ea.inventory_item_id IS NOT NULL;

INSERT INTO fleet_permissions(permission_key,name,description) VALUES
('inspection.resolve','Resolve Inspection Defects','Resolve defects and return eligible assets to service.'),
('inspection.schedule','Manage Inspection Schedules','Create recurring and operational inspection schedules.')
ON DUPLICATE KEY UPDATE name=VALUES(name),description=VALUES(description);

INSERT IGNORE INTO fleet_role_permissions(role_id,permission_id)
SELECT r.id,p.id FROM fleet_roles r CROSS JOIN fleet_permissions p
WHERE r.role_key IN ('fleet_administrator','system_administrator','fleet_manager','shop_supervisor')
  AND p.permission_key IN ('inspection.resolve','inspection.schedule');
