# Proposal

## Why

Running the skill on `terraform-aws-vpc` exposed four defects: nested modules are never audited, the terraform-docs config column is reported per directory although only the root config matters, headings with underscores are escaped by terraform-docs, and the generate step only regenerated directories that lacked a README, which is how two stale example READMEs were found by hand rather than by the skill.

## What Changes

- Audit walks `modules/**` recursively, so nested modules such as `modules/flow_logs/modules/s3_log_bucket` are listed.
- Audit reports the terraform-docs config once for the root and marks subdirectories as not applicable.
- Conventions and templates avoid underscores in headings; names with underscores go in backticks.
- Generate step regenerates every directory the write gate allows, including those already classified `generated`, so stale tables are refreshed.

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `terraform-module-docs`: audit scope (nested modules, root-only config check), heading style (no bare underscores), and regeneration scope (all allowed directories).

## Impact

- `skills/terraform-module-docs/scripts/audit.sh`, `SKILL.md`, `references/conventions.md`, `references/audit-checklist.md`, `templates/*.md`.
- No change to the skill's frontmatter or install path.
