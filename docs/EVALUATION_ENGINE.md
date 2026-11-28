# Evaluation Engine Design

This document defines the exact evaluation order, targeting operators, deterministic bucketing algorithm, and reason codes so backend evaluation and local SDK evaluation always produce identical results.

## 1. Evaluation Order

Given `(environmentId, flagKey, context)`:

1. **Flag lookup**: Find flag by `(environmentId, flagKey)` where flag is not archived.
   - If missing -> return `fallbackValue` with reason `FLAG_NOT_FOUND`.
2. **Kill switch / enabled check**:
   - If `flag.enabled === false` -> return `flag.defaultValue` with reason `FLAG_DISABLED`.
3. **Targeting rules & groups**:
   - Evaluate targeting rule groups/conditions against `context.userId`, `context.attributes`, and `context.groupKeys` (or resolved `GROUP_MEMBERSHIP`).
   - If targeting rules exist and the context does **not** match -> return `flag.defaultValue` with reason `TARGETING_NO_MATCH`.
4. **Deterministic percentage rollout**:
   - Compute bucket `0..9999` (represents `0.00%` to `99.99%`) from `sha256("${flagKey}:${rolloutSalt}:${userId}")`.
   - Convert `percentage` (`0..100`) to threshold `Math.round(percentage * 100)`.
   - If `bucket < threshold` -> return the active/enabled value with reason `TARGETING_MATCH_AND_ROLLOUT_INCLUDED` (or `ROLLOUT_INCLUDED` if no targeting rules).
   - Otherwise -> return `flag.defaultValue` with reason `ROLLOUT_EXCLUDED`.

## 2. Deterministic Bucketing Algorithm

```ts
// Pseudocode for consistent cross-platform bucketing (0..9999)
const hash = sha256Hex(`${flagKey}:${rolloutVersion}:${userId}`);
const int32 = parseInt(hash.slice(0, 8), 16); // unsigned 32-bit slice
const bucket = int32 % 10000;                // 0..9999
const included = bucket < Math.round(percentage * 100);
```

- `0%` -> threshold `0` -> never included.
- `100%` -> threshold `10000` -> always included.
- Missing `userId` -> cannot bucket deterministically; returns `flag.defaultValue` with reason `MISSING_USER_CONTEXT` unless rollout is `100%` or `0%`.

## 3. Supported Targeting Operators

| Operator | Expected attribute / rule value | Missing or mismatched type |
|---|---|---|
| `EQUALS` | Scalar (`string \| number \| boolean`) | Evaluates to `false` |
| `NOT_EQUALS` | Scalar | Evaluates to `false` if attribute missing |
| `IN` | Array of scalars | Evaluates to `false` |
| `NOT_IN` | Array of scalars | Evaluates to `false` if attribute missing |
| `CONTAINS` | String substring or array element | Evaluates to `false` |
| `GREATER_THAN` | Number | Evaluates to `false` |
| `LESS_THAN` | Number | Evaluates to `false` |
| `IN_GROUP` | Group key string | Checks group membership |

Malformed rules must be rejected by Zod validation at write time and never silently match at evaluation time.

## 4. Machine-Readable Reason Codes

- `FLAG_NOT_FOUND`
- `FLAG_ARCHIVED`
- `FLAG_DISABLED`
- `MISSING_USER_CONTEXT`
- `TARGETING_NO_MATCH`
- `TARGETING_MATCH_AND_ROLLOUT_INCLUDED`
- `ROLLOUT_INCLUDED`
- `ROLLOUT_EXCLUDED`
- `DEFAULT_RULE_MATCH`
- `ERROR_FALLBACK`
