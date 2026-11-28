-- Local Development Seed Data (Synthetic Only)
-- Demonstrates the ShopSphere scenario from the specification + a second tenant (NimbusPay) for isolation testing.
-- Password hashes below are NON-FUNCTIONAL development placeholders; Phase 3 auth tests/registration create real Argon2id/bcrypt hashes.

START TRANSACTION;

-- 1. Organizations
INSERT INTO organizations (id, name, slug, plan_tier) VALUES
  (1, 'ShopSphere Commerce', 'shopsphere', 'PRO'),
  (2, 'NimbusPay Fintech', 'nimbuspay', 'FREE')
ON DUPLICATE KEY UPDATE name = VALUES(name), plan_tier = VALUES(plan_tier);

-- 2. Platform Users
INSERT INTO platform_users (id, email, password_hash, full_name, is_active) VALUES
  (1, 'admin@shopsphere.local', '$2b$10$DEVONLYPLACEHOLDERHASH0000000000000000000000000000001', 'Asha Patel (Admin)', TRUE),
  (2, 'dev@shopsphere.local', '$2b$10$DEVONLYPLACEHOLDERHASH0000000000000000000000000000002', 'Rohan Verma (Developer)', TRUE),
  (3, 'viewer@shopsphere.local', '$2b$10$DEVONLYPLACEHOLDERHASH0000000000000000000000000000003', 'Meera Nair (Viewer)', TRUE),
  (4, 'admin@nimbuspay.local', '$2b$10$DEVONLYPLACEHOLDERHASH0000000000000000000000000000004', 'Kabir Shah (Nimbus Admin)', TRUE)
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name);

-- 3. Organization Memberships (RBAC)
INSERT INTO organization_memberships (id, organization_id, platform_user_id, role, invited_by) VALUES
  (1, 1, 1, 'ADMIN', NULL),
  (2, 1, 2, 'DEVELOPER', 1),
  (3, 1, 3, 'VIEWER', 1),
  (4, 2, 4, 'ADMIN', NULL)
ON DUPLICATE KEY UPDATE role = VALUES(role);

-- 4. Projects
INSERT INTO projects (id, organization_id, name, project_key, description, created_by) VALUES
  (1, 1, 'ShopSphere Web Store', 'shopsphere-web', 'Main e-commerce storefront and checkout service', 1),
  (2, 1, 'ShopSphere Mobile API', 'shopsphere-mobile', 'Backend-for-frontend serving iOS and Android apps', 2),
  (3, 2, 'NimbusPay Core Gateway', 'nimbuspay-core', 'Separate tenant project for isolation testing', 4)
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description);

-- 5. Environments
INSERT INTO environments (id, organization_id, project_id, name, env_key, is_production, sort_order, config_version) VALUES
  (1, 1, 1, 'Development', 'development', FALSE, 1, 2),
  (2, 1, 1, 'Staging', 'staging', FALSE, 2, 2),
  (3, 1, 1, 'Production', 'production', TRUE, 3, 4),
  (4, 1, 2, 'Development', 'development', FALSE, 1, 1),
  (5, 1, 2, 'Production', 'production', TRUE, 2, 1),
  (6, 2, 3, 'Production', 'production', TRUE, 1, 1)
ON DUPLICATE KEY UPDATE name = VALUES(name), is_production = VALUES(is_production);

-- 6. Application Users (End users evaluated by SDKs)
INSERT INTO application_users (id, organization_id, project_id, external_user_id, attributes_json) VALUES
  (1, 1, 1, 'customer_1001', JSON_OBJECT('plan', 'premium', 'country', 'India', 'appVersion', '2.4.0')),
  (2, 1, 1, 'customer_1002', JSON_OBJECT('plan', 'free', 'country', 'India', 'appVersion', '2.4.0')),
  (3, 1, 1, 'customer_1003', JSON_OBJECT('plan', 'premium', 'country', 'Singapore', 'appVersion', '2.5.0')),
  (4, 1, 1, 'internal_tester_01', JSON_OBJECT('plan', 'enterprise', 'country', 'India', 'internal', TRUE)),
  (5, 2, 3, 'nimbus_acct_9001', JSON_OBJECT('tier', 'gold', 'country', 'India'))
ON DUPLICATE KEY UPDATE attributes_json = VALUES(attributes_json);

-- 7. User Groups & Group Memberships
INSERT INTO user_groups (id, organization_id, project_id, group_key, name, description, created_by) VALUES
  (1, 1, 1, 'beta_testers', 'Beta Testers', 'Internal QA and early-access shoppers', 2),
  (2, 1, 1, 'vip_india', 'VIP India Cohort', 'High-value Indian shoppers', 1)
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT IGNORE INTO group_memberships (id, organization_id, project_id, group_id, application_user_id) VALUES
  (1, 1, 1, 1, 4),
  (2, 1, 1, 1, 1),
  (3, 1, 1, 2, 1);

-- 8. Feature Flags (ShopSphere + NimbusPay)
INSERT INTO feature_flags (
  id, organization_id, project_id, environment_id, flag_key, name, description,
  flag_type, default_value_json, enabled_value_json, is_enabled, rollout_percentage,
  rollout_salt, targeting_rules_json, prerequisite_flag_id, is_permanent, stale_after_days,
  config_version, created_by, updated_by
) VALUES
  (
    1, 1, 1, 1, 'new_checkout', 'Redesigned Checkout Flow',
    'New streamlined single-page checkout experience',
    'BOOLEAN', CAST('false' AS JSON), CAST('true' AS JSON), TRUE, 100.00,
    'v1', NULL, NULL, FALSE, 30, 2, 2, 2
  ),
  (
    2, 1, 1, 3, 'new_checkout', 'Redesigned Checkout Flow',
    'Gradual production rollout for premium users in India/Singapore',
    'BOOLEAN', CAST('false' AS JSON), CAST('true' AS JSON), TRUE, 25.00,
    'v1',
    JSON_OBJECT(
      'operator', 'AND',
      'rules', JSON_ARRAY(
        JSON_OBJECT('attribute', 'plan', 'operator', 'EQUALS', 'value', 'premium'),
        JSON_OBJECT('attribute', 'country', 'operator', 'IN', 'value', JSON_ARRAY('India', 'Singapore'))
      )
    ),
    NULL, FALSE, 30, 4, 1, 2
  ),
  (
    3, 1, 1, 3, 'one_click_checkout', 'One-Click Express Pay',
    'Requires new_checkout to be enabled as a prerequisite',
    'BOOLEAN', CAST('false' AS JSON), CAST('true' AS JSON), TRUE, 50.00,
    'v1',
    JSON_OBJECT(
      'operator', 'AND',
      'rules', JSON_ARRAY(
        JSON_OBJECT('attribute', 'group', 'operator', 'IN_GROUP', 'value', 'beta_testers')
      )
    ),
    2, FALSE, 30, 1, 2, 2
  ),
  (
    4, 1, 1, 3, 'checkout_banner_copy', 'Checkout Promo Banner Text',
    'String flag demonstrating typed configuration',
    'STRING', CAST('"Standard Checkout"' AS JSON), CAST('"Fast Express Checkout"' AS JSON), TRUE, 100.00,
    'v1', NULL, NULL, TRUE, 90, 1, 1, 1
  ),
  (
    5, 2, 3, 6, 'instant_upi_settlement', 'Instant UPI Settlement',
    'Tenant-isolated flag belonging exclusively to NimbusPay',
    'BOOLEAN', CAST('false' AS JSON), CAST('true' AS JSON), FALSE, 0.00,
    'v1', NULL, NULL, FALSE, 30, 1, 4, 4
  )
ON DUPLICATE KEY UPDATE
  is_enabled = VALUES(is_enabled),
  rollout_percentage = VALUES(rollout_percentage),
  targeting_rules_json = VALUES(targeting_rules_json);

-- 9. Rollout History
INSERT IGNORE INTO flag_rollouts (
  id, organization_id, environment_id, feature_flag_id, config_version,
  previous_enabled, new_enabled, previous_percentage, new_percentage,
  previous_targeting_json, new_targeting_json, change_reason, changed_by
) VALUES
  (1, 1, 3, 2, 2, FALSE, TRUE, 0.00, 10.00, NULL, NULL, 'Initial 10% canary launch in production', 1),
  (2, 1, 3, 2, 4, TRUE, TRUE, 10.00, 25.00, NULL, NULL, 'Healthy error rates; expanding rollout to 25%', 2);

-- 10. Sample Evaluations, Telemetry Events & Audit Logs
INSERT IGNORE INTO flag_evaluations (
  id, organization_id, project_id, environment_id, feature_flag_id, application_user_id,
  external_user_id, evaluated_value_json, reason_code, config_version, bucket, latency_ms
) VALUES
  (1, 1, 1, 3, 2, 1, 'customer_1001', CAST('true' AS JSON), 'TARGETING_MATCH_AND_ROLLOUT_INCLUDED', 4, 1420, 1.850),
  (2, 1, 1, 3, 2, 2, 'customer_1002', CAST('false' AS JSON), 'TARGETING_NO_MATCH', 4, NULL, 1.120),
  (3, 1, 1, 3, 2, 3, 'customer_1003', CAST('false' AS JSON), 'ROLLOUT_EXCLUDED', 4, 6840, 1.440);

INSERT IGNORE INTO telemetry_events (
  id, event_uuid, organization_id, project_id, environment_id, feature_flag_id, flag_key,
  event_type, external_user_id, session_id, event_name, value_json, properties_json,
  sdk_name, sdk_version, occurred_at
) VALUES
  (1, '11111111-1111-4111-8111-111111111101', 1, 1, 3, 2, 'new_checkout', 'EVALUATION', 'customer_1001', 'sess_01', NULL, CAST('true' AS JSON), NULL, '@ff/js-sdk', '0.1.0', NOW()),
  (2, '11111111-1111-4111-8111-111111111102', 1, 1, 3, 2, 'new_checkout', 'EXPOSURE', 'customer_1001', 'sess_01', NULL, CAST('true' AS JSON), JSON_OBJECT('page', '/checkout'), '@ff/js-sdk', '0.1.0', NOW()),
  (3, '11111111-1111-4111-8111-111111111103', 1, 1, 3, 2, 'new_checkout', 'CONVERSION', 'customer_1001', 'sess_01', 'checkout_completed', NULL, JSON_OBJECT('orderTotal', 1499, 'currency', 'INR'), '@ff/js-sdk', '0.1.0', NOW());

INSERT IGNORE INTO audit_logs (
  id, organization_id, project_id, environment_id, actor_user_id,
  action, resource_type, resource_id, reason, metadata_json
) VALUES
  (1, 1, 1, 3, 1, 'FLAG_CREATED', 'FEATURE_FLAG', 2, 'Created production checkout rollout flag', JSON_OBJECT('flagKey', 'new_checkout')),
  (2, 1, 1, 3, 2, 'FLAG_ROLLOUT_UPDATED', 'FEATURE_FLAG', 2, 'Increased production rollout from 10% to 25%', JSON_OBJECT('from', 10, 'to', 25));

COMMIT;
