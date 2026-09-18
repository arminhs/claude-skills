# Audit checklist

Run every item for the root module, each module directory under `modules/` at any depth (nested modules included), and each directory under `examples/`. Record the result before writing anything. `scripts/audit.sh` produces this table automatically.

| # | Item | How to check | Spec scenario |
|---|------|--------------|---------------|
| 1 | `.header.md` present | `test -f <dir>/.header.md` | Example without README is reported (header part) |
| 2 | `README.md` present | `test -f <dir>/README.md` | Example without README is reported |
| 3 | README classification | remove the marker block, then count what is left: fewer than 15 non-blank lines and no `##` heading is `generated` (markers present) or `minimal` (no markers); anything more is `hand-maintained`, with or without markers | Minimal README is treated as generated; Marker file with substantial prose outside the markers is hand-maintained; Substantial hand-written README is out of scope |
| 4 | Variables without `description` | parse every `variable "<name>" {` block in `*.tf` (CRLF tolerated, heredoc bodies skipped); report `file:name` when no `description` attribute is present, or `file:name(placeholder)` when it matches a scaffold placeholder (`(optional) describe your variable`, `TODO...`, `tbd`, `description`, `n/a`, `placeholder`, empty). Extend the list in `scripts/audit.sh` for project-specific placeholders | Undocumented variables are reported by file and name; Placeholder description is reported; File with CRLF line endings is parsed; Heredoc with unbalanced braces does not corrupt parsing |
| 5 | Outputs without `description` | same as 4 for `output "<name>" {` blocks | Undocumented variables are reported by file and name |
| 6 | `.terraform-docs.yaml` present at the module root only; subdirectories are generated with the root config and show `n/a` | `test -f .terraform-docs.yaml` or `.terraform-docs.yml` at the root | Config is created when absent; Config presence is reported for the root only |
| 7 | terraform-docs version pinned in CI | grep `.github/workflows/*.yml` for `terraform-docs` and a `v0.x.y` tag; also `.pre-commit-config.yaml` | Pinned CI version is honoured |
| 8 | terraform-docs binary available | `terraform-docs --version` | terraform-docs is unavailable |
| 9 | Every example and module covered | every `examples/*/` and every directory under `modules/` (recursively) containing `*.tf` or `*.tf.json` appears in the table | Example without README is reported; Nested module is audited |
| 10 | Existing upgrade guides | `ls docs/UPGRADE-GUIDE-*.md` and the italic note in the root `.header.md` | Upgrade guide is linked from the header |

Write gate derived from item 3:

- absent, minimal, generated: write `.header.md`, fill descriptions, regenerate `README.md`.
- hand-maintained: fill descriptions only. Report the README as skipped with its line count. Regenerate only if the user explicitly asks to migrate the prose into `.header.md`.
