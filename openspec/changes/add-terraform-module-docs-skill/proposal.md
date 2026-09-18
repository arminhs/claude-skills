# Proposal

## Why

Documenting a Terraform module by hand is repetitive and drifts quickly: README tables go stale, examples lack READMEs, and variable descriptions are inconsistent. This repository exists to collect reusable Claude Code skills, and a skill that encodes the aws-ia style documentation workflow (terraform-docs, `.header.md`, per-example READMEs, descriptive `variables.tf` and `outputs.tf`) lets Claude produce and maintain module docs that pass the module's own CI check.

## What Changes

- Add a new agent skill `terraform-module-docs` under `skills/terraform-module-docs/` with a `SKILL.md` and supporting reference files.
- The skill instructs Claude to audit and generate documentation for a Terraform module: root and example `.header.md` prose, terraform-docs generated READMEs, variable and output descriptions, and supplementary docs such as upgrade guides.
- The skill ships a reference on the documentation conventions observed in `arminhs/terraform-aws-vpc` (section order, heading style, code fence usage, example header title format, banner comments) and a checklist used to audit a module.
- The skill ships a starter `.terraform-docs.yaml` template and a `.header.md` template.
- Add a top-level `README.md` for this repository listing the available skills and how to install them.

## Capabilities

### New Capabilities
- `terraform-module-docs`: a Claude Code skill that audits, generates, and regenerates documentation for a Terraform module following the terraform-docs plus `.header.md` convention, and reports gaps such as undocumented variables or examples without a README.
- `skill-catalog`: the repository README that lists each skill with its trigger description and installation instructions, so users can discover and install skills from this repo.

### Modified Capabilities
<!-- none: no existing specs in this repository -->

## Impact

- New files only: `skills/terraform-module-docs/**` and `README.md`. No existing files change.
- The skill depends on the `terraform-docs` CLI being available in the target environment. When it is missing, the skill must say so and fall back to writing `.header.md` and source descriptions only.
- Assumption: skills in this repository live under a top-level `skills/<name>/` directory, matching the Anthropic skills repository layout, and are installed by copying or symlinking into `.claude/skills/`. The `.claude/skills/openspec-*` directories are OpenSpec tooling, not published skills.
- Assumption: the target module conventions are the aws-ia ones observed in `terraform-aws-vpc`. Other layouts (for example a hand-maintained README with no terraform-docs markers) are handled by the audit step, which reports rather than rewrites.
