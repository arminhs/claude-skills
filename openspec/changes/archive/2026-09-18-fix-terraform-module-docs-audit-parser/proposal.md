# Proposal

## Why

A second audit of the skill and a clean test run on `terraform-aws-vpc` found nine defects. Two produce silent false negatives in the audit (CRLF files, heredocs with unbalanced braces), one lets replace mode delete prose (README with markers plus hand-written sections), one makes every user see a false idempotence failure, and one lets scaffold placeholder descriptions pass as documented.

## What Changes

- Audit parser strips carriage returns and skips heredoc bodies when counting braces.
- READMEs with terraform-docs markers are classified by the prose outside the marker block, so a marker file with substantial extra prose is `hand-maintained`.
- Audit flags descriptions that match common scaffold placeholders as undocumented, marked `(placeholder)`.
- Audit discovers directories containing `*.tf.json` as well as `*.tf`.
- Step 4 idempotence check stages the first run before comparing the second.
- Fallback message when terraform-docs is missing includes `modules/<name>`.
- Frontmatter `allowed-tools` uses comma separation and scopes the bash grant to the audit script.

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `terraform-module-docs`: audit correctness (line endings, heredocs, placeholder descriptions, marker files with prose) and the idempotence verification procedure.

## Impact

- `scripts/audit.sh`, `SKILL.md`, `references/audit-checklist.md`, `references/conventions.md`. No new files.
