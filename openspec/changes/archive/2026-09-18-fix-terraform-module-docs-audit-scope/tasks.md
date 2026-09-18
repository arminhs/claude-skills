# Tasks

## 1. Audit script

- [x] 1.1 Replace the `modules/*/` glob in `scripts/audit.sh` with recursive discovery of module directories containing `.tf` files; verify the audit on `terraform-aws-vpc` lists `modules/flow_logs/modules/s3_log_bucket`
- [x] 1.2 Report the terraform-docs config only for the root row and print `n/a` for subdirectory rows; verify on `terraform-aws-vpc` that only the root row shows `yes`
- [x] 1.3 Update `references/audit-checklist.md` items 6 and 9 to match; verify the checklist maps the two new spec scenarios

## 2. Workflow and conventions

- [x] 2.1 Rewrite Step 4 in `SKILL.md` to regenerate every directory the gate allows and to report pre-existing READMEs under Modified; verify the text names the `generated` classification explicitly
- [x] 2.2 Add the no-bare-underscores heading rule to `references/conventions.md` and show the backtick form in `templates/header.md` and `templates/example-header.md`; verify by generating a README from a header titled with a backticked `flow_logs` and confirming no `\_` appears in any heading

## 3. Validation

- [x] 3.1 Re-run the full audit and generate steps on a scratch copy of `terraform-aws-vpc` at the commit before the docs fix and verify the run reports `examples/cloud_wan/README.md` and `examples/transit_gateway/README.md` as Modified
- [x] 3.2 Commit with a conventional commit message and push
