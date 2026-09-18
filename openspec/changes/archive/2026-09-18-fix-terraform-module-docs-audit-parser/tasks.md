# Tasks

## 1. Audit script

- [x] 1.1 Strip `\r` and skip heredoc bodies in the awk block parser; verify the CRLF and unbalanced-heredoc scratch cases each report the undocumented block
- [x] 1.2 Flag placeholder descriptions as `file:name(placeholder)`; verify on `terraform-aws-vpc` main that `modules/flow_logs/modules/s3_log_bucket/variables.tf:name(placeholder)` is reported
- [x] 1.3 Classify marker files by the prose outside the markers; verify a marker file with 30 lines of sections is `hand-maintained` and the reference module's marker files remain `generated`
- [x] 1.4 Discover directories containing `*.tf.json`; verify a scratch `modules/json/main.tf.json` directory is listed

## 2. Workflow text

- [x] 2.1 Rewrite the Step 4 idempotence check to stage the first run before the second and explain why; verify by following it literally on a stale README and getting no diff
- [x] 2.2 Add `modules/<name>` to the fallback message and add placeholders to Step 3; verify by reading the step against the spec scenarios
- [x] 2.3 Change `allowed-tools` to a comma-separated list with the bash grant scoped to the audit script; verify the frontmatter parses
- [x] 2.4 Update `references/audit-checklist.md` with the placeholder item and the new classification rule; verify each new spec scenario maps to an item

## 3. Validation

- [x] 3.1 Re-run the skill on the `test/terraform-module-docs-skill` branch of `terraform-aws-vpc` and verify the placeholder is reported, Step 3 replaces it, and the idempotence check passes as written
- [x] 3.2 Sync the spec, archive the change, commit with a conventional message, and push
