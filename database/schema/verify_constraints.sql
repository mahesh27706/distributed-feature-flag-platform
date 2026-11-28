-- Phase 1 Verification Queries
-- Run after applying migrations and seeds to verify schema integrity, tenant boundaries, and sample analytics queries.

-- 1. Verify all migrations were recorded
SELECT filename, applied_at
FROM schema_migrations
ORDER BY id;

-- 2. Verify all tables exist and have expected row counts
SELECT 'organizations' AS table_name, COUNT(*) AS row_count FROM organizations
UNION ALL SELECT 'platform_users', COUNT(*) FROM platform_users
UNION ALL SELECT 'organization_memberships', COUNT(*) FROM organization_memberships
UNION ALL SELECT 'projects', COUNT(*) FROM projects
UNION ALL SELECT 'environments', COUNT(*) FROM environments
UNION ALL SELECT 'application_users', COUNT(*) FROM application_users
UNION ALL SELECT 'user_groups', COUNT(*) FROM user_groups
UNION ALL SELECT 'group_memberships', COUNT(*) FROM group_memberships
UNION ALL SELECT 'feature_flags', COUNT(*) FROM feature_flags
UNION ALL SELECT 'flag_rollouts', COUNT(*) FROM flag_rollouts
UNION ALL SELECT 'flag_evaluations', COUNT(*) FROM flag_evaluations
UNION ALL SELECT 'telemetry_events', COUNT(*) FROM telemetry_events
UNION ALL SELECT 'audit_logs', COUNT(*) FROM audit_logs;

-- 3. Verify ShopSphere flags across environments (tenant-scoped join)
SELECT
  o.slug AS org_slug,
  p.project_key,
  e.env_key,
  f.flag_key,
  f.flag_type,
  f.is_enabled,
  f.rollout_percentage,
  f.config_version
FROM feature_flags f
JOIN environments e ON f.environment_id = e.id
JOIN projects p ON e.project_id = p.id
JOIN organizations o ON p.organization_id = o.id
WHERE o.slug = 'shopsphere'
  AND f.archived_at IS NULL
ORDER BY p.project_key, e.sort_order, f.flag_key;

-- 4. Verify Organization-level Intelligence summary (projects, members, flags, active app users)
SELECT
  o.id AS organization_id,
  o.name AS organization_name,
  COUNT(DISTINCT p.id) AS total_projects,
  COUNT(DISTINCT om.platform_user_id) AS team_members,
  COUNT(DISTINCT CASE WHEN f.archived_at IS NULL THEN f.id END) AS active_flags,
  COUNT(DISTINCT CASE WHEN f.is_enabled = TRUE AND f.archived_at IS NULL THEN f.id END) AS enabled_flags,
  COUNT(DISTINCT au.id) AS known_app_users
FROM organizations o
LEFT JOIN projects p ON p.organization_id = o.id AND p.archived_at IS NULL
LEFT JOIN organization_memberships om ON om.organization_id = o.id
LEFT JOIN feature_flags f ON f.organization_id = o.id
LEFT JOIN application_users au ON au.organization_id = o.id
GROUP BY o.id, o.name
ORDER BY o.id;

-- 5. Verify Funnel Separation (Evaluations vs Exposures vs Conversions) per flag
SELECT
  p.project_key,
  te.flag_key,
  SUM(CASE WHEN te.event_type = 'EVALUATION' THEN 1 ELSE 0 END) AS evaluations,
  SUM(CASE WHEN te.event_type = 'EXPOSURE' THEN 1 ELSE 0 END) AS exposures,
  SUM(CASE WHEN te.event_type = 'CONVERSION' THEN 1 ELSE 0 END) AS conversions
FROM telemetry_events te
JOIN projects p ON te.project_id = p.id
GROUP BY p.project_key, te.flag_key
ORDER BY p.project_key, te.flag_key;

-- 6. Negative constraint test (uncomment ONLY to manually confirm MySQL rejects invalid rollouts/cross-tenant FKs):
-- INSERT INTO feature_flags (organization_id, project_id, environment_id, flag_key, name, default_value_json, enabled_value_json, rollout_percentage)
-- VALUES (1, 1, 1, 'bad_rollout', 'Bad Rollout', CAST('false' AS JSON), CAST('true' AS JSON), 150.00);
-- Expected: ERROR 3819 (HY000): Check constraint 'chk_flags_rollout_pct' is violated.
