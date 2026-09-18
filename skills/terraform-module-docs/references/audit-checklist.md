# Audit checklist

Run every item for the root module, each directory under `modules/`, and each directory under `examples/`. Record the result before writing anything. `scripts/audit.sh` produces this table automatically.

| # | Item | How to check | Spec scenario |
|---|------|--------------|---------------|
| 1 | `.header.md` present | `test -f <dir>/.header.md` | Example without README is reported (header part) |
| 2 | `README.md` present | `test -f <dir>/README.md` | Example without README is reported |
| 3 | README classification | absent / generated (has `<!-- BEGIN_TF_DOCS -->` and `<!-- END_TF_DOCS -->`) / minimal (after removing the marker block: fewer than 15 non-blank lines and no `##` heading) / hand-maintained (anything else without markers) | Minimal README is treated as generated; Substantial hand-written README is out of scope |
| 4 | Variables without `description` | parse every `variable "<name>" {` block in `*.tf`; report `file:name` when no `description` attribute is present | Undocumented variables are reported by file and name |
| 5 | Outputs without `description` | same as 4 for `output "<name>" {` blocks | Undocumented variables are reported by file and name |
| 6 | `.terraform-docs.yaml` present at the module root | `test -f .terraform-docs.yaml` or `.terraform-docs.yml` | Config is created when absent |
| 7 | terraform-docs version pinned in CI | grep `.github/workflows/*.yml` for `terraform-docs` and a `v0.x.y` tag; also `.pre-commit-config.yaml` | Pinned CI version is honoured |
| 8 | terraform-docs binary available | `terraform-docs --version` | terraform-docs is unavailable |
| 9 | Every example covered | every `examples/*/` containing `*.tf` appears in the table | Example without README is reported |
| 10 | Existing upgrade guides | `ls docs/UPGRADE-GUIDE-*.md` and the italic note in the root `.header.md` | Upgrade guide is linked from the header |

Write gate derived from item 3:

- absent, minimal, generated: write `.header.md`, fill descriptions, regenerate `README.md`.
- hand-maintained: fill descriptions only. Report the README as skipped with its line count. Regenerate only if the user explicitly asks to migrate the prose into `.header.md`.
