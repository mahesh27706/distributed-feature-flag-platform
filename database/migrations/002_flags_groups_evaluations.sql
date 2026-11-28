-- Migration 002: SDK Keys, Application Users, User Groups, Feature Flags, Rollouts & Evaluations
-- Enforces composite tenant-isolation foreign keys across organizations, projects, and environments.

CREATE TABLE IF NOT EXISTS sdk_keys (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  organization_id BIGINT UNSIGNED NOT NULL,
  project_id BIGINT UNSIGNED NOT NULL,
  environment_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(100) NOT NULL,
  key_type ENUM('SERVER', 'CLIENT') NOT NULL DEFAULT 'SERVER',
  key_prefix VARCHAR(20) NOT NULL,
  key_hash CHAR(64) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  expires_at TIMESTAMP NULL DEFAULT NULL,
  last_used_at TIMESTAMP NULL DEFAULT NULL,
  created_by BIGINT UNSIGNED NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_sdk_keys_hash (key_hash),
  KEY idx_sdk_keys_env_active (environment_id, is_active),
  KEY idx_sdk_keys_org (organization_id),
  CONSTRAINT fk_sdk_keys_env_scope
    FOREIGN KEY (environment_id, project_id, organization_id)
    REFERENCES environments (id, project_id, organization_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_sdk_keys_created_by
    FOREIGN KEY (created_by) REFERENCES platform_users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS application_users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  organization_id BIGINT UNSIGNED NOT NULL,
  project_id BIGINT UNSIGNED NOT NULL,
  external_user_id VARCHAR(191) NOT NULL,
  attributes_json JSON NOT NULL,
  first_seen_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_seen_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_app_users_project_ext (project_id, external_user_id),
  UNIQUE KEY uq_app_users_id_org_proj (id, organization_id, project_id),
  KEY idx_app_users_org_last_seen (organization_id, last_seen_at),
  CONSTRAINT fk_app_users_project_org
    FOREIGN KEY (project_id, organization_id) REFERENCES projects (id, organization_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_groups (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  organization_id BIGINT UNSIGNED NOT NULL,
  project_id BIGINT UNSIGNED NOT NULL,
  group_key VARCHAR(80) NOT NULL,
  name VARCHAR(120) NOT NULL,
  description VARCHAR(500) NULL DEFAULT NULL,
  created_by BIGINT UNSIGNED NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_user_groups_project_key (project_id, group_key),
  UNIQUE KEY uq_user_groups_id_org_proj (id, organization_id, project_id),
  CONSTRAINT fk_user_groups_project_org
    FOREIGN KEY (project_id, organization_id) REFERENCES projects (id, organization_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_user_groups_created_by
    FOREIGN KEY (created_by) REFERENCES platform_users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS group_memberships (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  organization_id BIGINT UNSIGNED NOT NULL,
  project_id BIGINT UNSIGNED NOT NULL,
  group_id BIGINT UNSIGNED NOT NULL,
  application_user_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_group_membership (group_id, application_user_id),
  KEY idx_group_memberships_user (application_user_id),
  CONSTRAINT fk_group_memberships_group_scope
    FOREIGN KEY (group_id, organization_id, project_id)
    REFERENCES user_groups (id, organization_id, project_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_group_memberships_user_scope
    FOREIGN KEY (application_user_id, organization_id, project_id)
    REFERENCES application_users (id, organization_id, project_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS feature_flags (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  organization_id BIGINT UNSIGNED NOT NULL,
  project_id BIGINT UNSIGNED NOT NULL,
  environment_id BIGINT UNSIGNED NOT NULL,
  flag_key VARCHAR(100) NOT NULL,
  name VARCHAR(150) NOT NULL,
  description VARCHAR(500) NULL DEFAULT NULL,
  flag_type ENUM('BOOLEAN', 'STRING', 'NUMBER', 'JSON') NOT NULL DEFAULT 'BOOLEAN',
  default_value_json JSON NOT NULL,
  enabled_value_json JSON NOT NULL,
  is_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  rollout_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  rollout_salt VARCHAR(64) NOT NULL DEFAULT 'v1',
  targeting_rules_json JSON NULL DEFAULT NULL,
  prerequisite_flag_id BIGINT UNSIGNED NULL DEFAULT NULL,
  is_permanent BOOLEAN NOT NULL DEFAULT FALSE,
  stale_after_days INT UNSIGNED NOT NULL DEFAULT 30,
  config_version BIGINT UNSIGNED NOT NULL DEFAULT 1,
  archived_at TIMESTAMP NULL DEFAULT NULL,
  created_by BIGINT UNSIGNED NULL DEFAULT NULL,
  updated_by BIGINT UNSIGNED NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_flags_env_key (environment_id, flag_key),
  UNIQUE KEY uq_flags_id_org_env (id, organization_id, environment_id),
  KEY idx_flags_org_proj_archived (organization_id, project_id, archived_at),
  KEY idx_flags_env_enabled (environment_id, is_enabled, archived_at),
  CONSTRAINT chk_flags_rollout_pct
    CHECK (rollout_percentage >= 0.00 AND rollout_percentage <= 100.00),
  CONSTRAINT fk_flags_env_scope
    FOREIGN KEY (environment_id, project_id, organization_id)
    REFERENCES environments (id, project_id, organization_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_flags_prereq
    FOREIGN KEY (prerequisite_flag_id) REFERENCES feature_flags (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_flags_created_by
    FOREIGN KEY (created_by) REFERENCES platform_users (id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_flags_updated_by
    FOREIGN KEY (updated_by) REFERENCES platform_users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS flag_rollouts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  organization_id BIGINT UNSIGNED NOT NULL,
  environment_id BIGINT UNSIGNED NOT NULL,
  feature_flag_id BIGINT UNSIGNED NOT NULL,
  config_version BIGINT UNSIGNED NOT NULL,
  previous_enabled BOOLEAN NOT NULL,
  new_enabled BOOLEAN NOT NULL,
  previous_percentage DECIMAL(5,2) NOT NULL,
  new_percentage DECIMAL(5,2) NOT NULL,
  previous_targeting_json JSON NULL DEFAULT NULL,
  new_targeting_json JSON NULL DEFAULT NULL,
  change_reason VARCHAR(500) NULL DEFAULT NULL,
  changed_by BIGINT UNSIGNED NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_rollouts_flag_created (feature_flag_id, created_at),
  KEY idx_rollouts_org_created (organization_id, created_at),
  CONSTRAINT chk_rollouts_prev_pct CHECK (previous_percentage >= 0.00 AND previous_percentage <= 100.00),
  CONSTRAINT chk_rollouts_new_pct CHECK (new_percentage >= 0.00 AND new_percentage <= 100.00),
  CONSTRAINT fk_rollouts_flag_scope
    FOREIGN KEY (feature_flag_id, organization_id, environment_id)
    REFERENCES feature_flags (id, organization_id, environment_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_rollouts_changed_by
    FOREIGN KEY (changed_by) REFERENCES platform_users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS flag_evaluations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  organization_id BIGINT UNSIGNED NOT NULL,
  project_id BIGINT UNSIGNED NOT NULL,
  environment_id BIGINT UNSIGNED NOT NULL,
  feature_flag_id BIGINT UNSIGNED NOT NULL,
  application_user_id BIGINT UNSIGNED NULL DEFAULT NULL,
  external_user_id VARCHAR(191) NOT NULL,
  evaluated_value_json JSON NOT NULL,
  reason_code VARCHAR(64) NOT NULL,
  config_version BIGINT UNSIGNED NOT NULL,
  bucket SMALLINT UNSIGNED NULL DEFAULT NULL,
  latency_ms DECIMAL(8,3) NULL DEFAULT NULL,
  evaluated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_evals_flag_time (feature_flag_id, evaluated_at),
  KEY idx_evals_org_time (organization_id, evaluated_at),
  KEY idx_evals_env_time (environment_id, evaluated_at),
  KEY idx_evals_proj_user_time (project_id, external_user_id, evaluated_at),
  CONSTRAINT fk_evals_flag_scope
    FOREIGN KEY (feature_flag_id, organization_id, environment_id)
    REFERENCES feature_flags (id, organization_id, environment_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_evals_app_user
    FOREIGN KEY (application_user_id) REFERENCES application_users (id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO schema_migrations (filename) VALUES ('002_flags_groups_evaluations.sql');
