-- Migration 003: Telemetry Events, Audit Logs, and Environment Webhooks
-- Supports separated Evaluation/Exposure/Conversion analytics, org/project health insights, and compliance trails.

CREATE TABLE IF NOT EXISTS telemetry_events (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  event_uuid CHAR(36) NOT NULL,
  organization_id BIGINT UNSIGNED NOT NULL,
  project_id BIGINT UNSIGNED NOT NULL,
  environment_id BIGINT UNSIGNED NOT NULL,
  feature_flag_id BIGINT UNSIGNED NULL DEFAULT NULL,
  flag_key VARCHAR(100) NULL DEFAULT NULL,
  event_type ENUM('EVALUATION', 'EXPOSURE', 'CONVERSION') NOT NULL,
  external_user_id VARCHAR(191) NOT NULL,
  session_id VARCHAR(128) NULL DEFAULT NULL,
  event_name VARCHAR(120) NULL DEFAULT NULL,
  value_json JSON NULL DEFAULT NULL,
  properties_json JSON NULL DEFAULT NULL,
  sdk_name VARCHAR(64) NULL DEFAULT NULL,
  sdk_version VARCHAR(32) NULL DEFAULT NULL,
  occurred_at TIMESTAMP NOT NULL,
  received_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_telemetry_event_uuid (event_uuid),
  KEY idx_telemetry_org_type_time (organization_id, event_type, occurred_at),
  KEY idx_telemetry_proj_type_time (project_id, event_type, occurred_at),
  KEY idx_telemetry_env_flag_time (environment_id, flag_key, event_type, occurred_at),
  KEY idx_telemetry_user_time (project_id, external_user_id, occurred_at),
  CONSTRAINT fk_telemetry_env_scope
    FOREIGN KEY (environment_id, project_id, organization_id)
    REFERENCES environments (id, project_id, organization_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_telemetry_flag
    FOREIGN KEY (feature_flag_id) REFERENCES feature_flags (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  organization_id BIGINT UNSIGNED NOT NULL,
  project_id BIGINT UNSIGNED NULL DEFAULT NULL,
  environment_id BIGINT UNSIGNED NULL DEFAULT NULL,
  actor_user_id BIGINT UNSIGNED NULL DEFAULT NULL,
  action VARCHAR(80) NOT NULL,
  resource_type VARCHAR(64) NOT NULL,
  resource_id BIGINT UNSIGNED NULL DEFAULT NULL,
  reason VARCHAR(500) NULL DEFAULT NULL,
  metadata_json JSON NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_audit_org_time (organization_id, created_at),
  KEY idx_audit_proj_time (project_id, created_at),
  KEY idx_audit_actor_time (actor_user_id, created_at),
  CONSTRAINT fk_audit_org
    FOREIGN KEY (organization_id) REFERENCES organizations (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_audit_project
    FOREIGN KEY (project_id) REFERENCES projects (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_audit_env
    FOREIGN KEY (environment_id) REFERENCES environments (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_audit_actor
    FOREIGN KEY (actor_user_id) REFERENCES platform_users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS environment_webhooks (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  organization_id BIGINT UNSIGNED NOT NULL,
  project_id BIGINT UNSIGNED NOT NULL,
  environment_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  target_url VARCHAR(500) NOT NULL,
  secret_hash CHAR(64) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  last_triggered_at TIMESTAMP NULL DEFAULT NULL,
  created_by BIGINT UNSIGNED NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_webhooks_env_active (environment_id, is_active),
  CONSTRAINT fk_webhooks_env_scope
    FOREIGN KEY (environment_id, project_id, organization_id)
    REFERENCES environments (id, project_id, organization_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_webhooks_created_by
    FOREIGN KEY (created_by) REFERENCES platform_users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO schema_migrations (filename) VALUES ('003_telemetry_audit_webhooks.sql');
