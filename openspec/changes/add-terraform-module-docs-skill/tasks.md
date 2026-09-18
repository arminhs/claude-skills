# Tasks

## 1. Skill scaffold

- [ ] 1.1 Create `skills/terraform-module-docs/` with `SKILL.md` frontmatter (`name`, `description` naming the trigger phrasings from the spec, `allowed-tools`, `license`, `metadata`) and verify the frontmatter parses as YAML and the name matches the directory
- [ ] 1.2 Create `references/conventions.md` capturing the aws-ia style: `.header.md` outline, example title format, section order of generated READMEs, `hcl` fences, description sentence style, banner comments, `docs/UPGRADE-GUIDE-<major>.0.md` naming; verify each item cites the file in `terraform-aws-vpc` it was observed in
- [ ] 1.3 Create `references/audit-checklist.md` listing the audit items from the spec (header present, README present with markers, undocumented variables and outputs, `.terraform-docs.yaml` present, examples covered) and verify every spec audit scenario maps to an item
- [ ] 1.4 Create `templates/terraform-docs.yaml` (markdown formatter, `header-from: .header.md`, replace mode, sort by required) and `templates/header.md` (title, summary, Usage, Contributing placeholders) and verify the yaml template is byte-comparable in structure to the one in `terraform-aws-vpc`

## 2. Skill workflow

- [ ] 2.1 Write the audit step in `SKILL.md` with shell commands that find root, `modules/*`, and `examples/*` directories, detect markers, and list variables and outputs without a `description`; verify by running the commands against `terraform-aws-vpc` and confirming they report `examples/ipam_secondary_cidr` and `examples/nat_byoip` as missing a README
- [ ] 2.2 Write the hand-maintained README guard: when markers are absent, stop and ask before regenerating; verify by running the audit on a scratch copy whose README has no markers and confirming the instruction path leads to a report, not a rewrite
- [ ] 2.3 Write the `.header.md` authoring step for root and examples, referencing `conventions.md` and the header template; verify by drafting `examples/nat_byoip/README.md` prose for the reference module and checking it matches the example title format
- [ ] 2.4 Write the description-filling step, including the sampling rule for `(Optional)` prefix and sentence style and the rule to leave existing descriptions alone; verify on a scratch `variables.tf` with one undocumented variable that only that variable changes
- [ ] 2.5 Write the generate-and-verify step: pick the terraform-docs version from `.github/workflows/*.yml`, create the config from the template when missing, run terraform-docs, run it a second time and require an empty diff; include the fallback message and command when the binary is unavailable; verify both branches by reading the step against the spec scenarios
- [ ] 2.6 Write the upgrade guide step (`docs/UPGRADE-GUIDE-<major>.0.md` with Preparation, Overview, numbered steps, and the italic note in the root header) and the final run summary format; verify the summary lists created, modified, skipped, and remaining items

## 3. Validation against the reference module

- [ ] 3.1 Install the skill into a scratch copy of `terraform-aws-vpc` via symlink into `.claude/skills/` and verify Claude Code lists `terraform-module-docs`
- [ ] 3.2 Run the full skill workflow on the scratch copy and verify it produces `.header.md` files for `ipam_secondary_cidr` and, if terraform-docs is available, READMEs for both missing examples with markers; otherwise verify the fallback message names the exact command
- [ ] 3.3 Where terraform-docs v0.19.0 is available, run it twice on the scratch root and verify `git diff --exit-code README.md` passes after the second run

## 4. Repository catalog

- [ ] 4.1 Create root `README.md` with a skills table (name, description from frontmatter, link) and an installation section for project and user scope, plus a note that changes are planned with OpenSpec; verify the table has exactly one row per directory under `skills/` and the description text equals the `SKILL.md` frontmatter description
- [ ] 4.2 Commit with a conventional commit message (`feat: add terraform-module-docs skill`) and verify `git log -1` shows the message and no model identifiers
