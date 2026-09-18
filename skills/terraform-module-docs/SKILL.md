---
name: terraform-module-docs
description: Document a Terraform module in the aws-ia style (terraform-docs plus .header.md). Use when the user asks to document a Terraform module, generate or regenerate a module README, update the README for this module, write or fix .header.md, document the variables or outputs, add missing variable or output descriptions, add a README to an example, or write an upgrade guide. Targets undocumented modules and modules whose README is empty, minimal, or terraform-docs output; hand-maintained READMEs are reported, not rewritten.
allowed-tools: Bash(terraform-docs:*), Bash(terraform fmt:*), Bash(terraform validate:*), Bash(bash *scripts/audit.sh*), Bash(git diff:*), Bash(git add:*), Read, Grep, Glob
license: MIT
compatibility: Requires the terraform-docs CLI for README generation. Without it the skill still writes .header.md and source descriptions.
metadata:
  author: arminhs
  version: "1.0"
---

# Terraform module documentation

Produce documentation for a Terraform module that passes a terraform-docs CI check: prose in `.header.md`, generated `README.md`, and a `description` on every variable and output. Work through the steps in order. Never skip the audit.

Reference files in this skill:

- `references/conventions.md`: the style rules. Read it before writing any header or description.
- `references/audit-checklist.md`: what the audit checks and the write gate it produces.
- `templates/`: `terraform-docs.yaml`, `header.md`, `example-header.md`, `upgrade-guide.md`.
- `scripts/audit.sh`: the audit, read-only.

## Step 1: Audit

Run the audit from the module root and paste its table into your reply before changing anything:

```bash
bash <skill-dir>/scripts/audit.sh <module-root>
```

It lists the root, every module directory under `modules/` at any depth, and every `examples/*` directory containing `.tf` files, with: header present, README classification, terraform-docs config present (root row only, `n/a` elsewhere), and every `file:name` for variables and outputs without a `description`. A description that is a scaffold placeholder (for example `(optional) describe your variable`, `TODO`, `tbd`) is listed as `file:name(placeholder)` and counts as missing. Below the table it reports the terraform-docs version pinned in CI, the version available locally, and existing upgrade guides.

README classification decides what you may write:

| Classification | Meaning | Allowed writes |
|----------------|---------|----------------|
| `absent` | no README | header, descriptions, generate README |
| `generated` | has `BEGIN_TF_DOCS` and `END_TF_DOCS` markers and little prose outside them | header, descriptions, generate README |
| `minimal(N lines)` | no markers, fewer than 15 non-blank lines, no `##` heading | header (carry over title and paragraph), descriptions, generate README |
| `hand-maintained(N lines, M h2)` | more prose than that outside any marker block, with or without markers | descriptions only |

For a `hand-maintained` README: do not regenerate it. Fill descriptions, then report the README as skipped with its line count. Only migrate its prose into `.header.md` and regenerate if the user explicitly asks for that.

## Step 2: Write `.header.md` files

For every directory the gate allows, create or complete `.header.md`. Follow `references/conventions.md`.

Root module, from `templates/header.md`:

1. `# <Module title>`.
2. One paragraph summary ending with a link to `examples/`. For a `minimal` README, carry its existing title into the H1 and its first paragraph here, verbatim, before adding anything.
3. If `docs/UPGRADE-GUIDE-*.md` exists, an italic note linking to the highest major version.
4. `## Usage` with one or two sentences and a complete `module` block. Derive the registry `source` from the repository name (`terraform-<provider>-<name>` becomes `<namespace>/<name>/<provider>`) and use `version = ">= <current major>.<minor>.0"`. Include every required input and the most common optional ones. Comment non-obvious values with `# options: ...`.
5. One `##` section per major feature you can identify from `variables.tf` and `main.tf` banners, each with an `hcl` snippet.
6. `## Contributing` linking to `contributing.md` or `CONTRIBUTING.md` when one exists. Omit the section when neither exists.

Examples, from `templates/example-header.md`: title `# <Module title> - Example: <Example name>`, one sentence, then a nested bullet list of what `main.tf` builds. Read the example's `main.tf` and list real resources and options, not generic text.

Child modules under `modules/` (nested ones included): same as the root outline without the upgrade note, and with the `module` block using a relative source `./modules/<name>`.

Fence every Terraform snippet as `hcl`. Do not put bare underscores in headings: terraform-docs escapes them to `\_`. Write `# VPC module - Submodule: \`flow_logs\`` or spell the name with spaces.

## Step 3: Fill missing descriptions

For each `file:name` the audit listed, including those marked `(placeholder)`, whose existing description you replace:

1. Sample the existing descriptions in that file. Note whether they end with a period, whether optional inputs use the `(Optional)` prefix, and whether other inputs are referenced as `var.<name>` or in backticks. Match what you find. With no existing descriptions, use the defaults in `references/conventions.md`.
2. Read where the variable or output is used in the module source to learn what it controls.
3. Write one full sentence stating what the value does, its default behaviour, and any incompatibility with other inputs. For outputs that return a map or object, use a heredoc with an `Example:` block.
4. Insert only the `description` attribute. Keep the block's other attributes and their order unchanged. Do not touch blocks that already have a description unless the user asked for a style pass.
5. Run `terraform fmt` on the changed files.

List every description you generated in the final summary so the user can review the wording.

## Step 4: Generate READMEs

Skip this step for `hand-maintained` directories.

1. If the module root has no `.terraform-docs.yaml`, copy `templates/terraform-docs.yaml` there.
2. Pick the version: use the tag the audit found in CI. If the local binary is a different version, still run it but state the mismatch in the summary, because table formatting differs between releases and the CI diff check is strict.
3. From the module root, run terraform-docs for every row in the audit table that is not `hand-maintained`. Include rows already classified `generated`: their tables may be stale, and regenerating is the only way to find out.

   ```bash
   terraform-docs --config .terraform-docs.yaml .
   terraform-docs --config .terraform-docs.yaml modules/<name>
   terraform-docs --config .terraform-docs.yaml examples/<name>
   ```

   Record which READMEs existed before the run. Those go under Modified in the summary when their content changed; new files go under Created.

4. Stage the READMEs the first run produced, then run the same commands a second time and compare against that staged snapshot. Comparing against the committed state would fail whenever the first run changed anything, which is not an idempotence failure.

   ```bash
   git add -- README.md '**/README.md'
   # ... second terraform-docs pass over the same directories ...
   git diff --exit-code -- README.md '**/README.md'
   ```

   A non-empty diff here means the header or a description contains something terraform-docs rewrites on each pass (usually trailing whitespace or an unescaped underscore); fix the source, not the README.

If `terraform-docs` is not available, do not hand-write the README. Say so plainly, keep the `.header.md` and description changes, and give the user the exact command to run:

```
README generation skipped: terraform-docs is not installed. Run from the module root:
  terraform-docs --config .terraform-docs.yaml .
  terraform-docs --config .terraform-docs.yaml modules/<name>     # once per module row in the audit
  terraform-docs --config .terraform-docs.yaml examples/<name>    # once per example row
```

## Step 5: Upgrade guide (only when asked, or on a major version bump)

Create `docs/UPGRADE-GUIDE-<major>.0.md` from `templates/upgrade-guide.md` with the Preparation, Overview, and numbered step sections. Then replace the italic note in the root `.header.md` so it links to the new guide only, and regenerate the root README.

## Step 6: Report

End with a summary in this shape:

```
Created:   <files>
Modified:  <files>
Generated descriptions (please review): <file:name> ...
Skipped:   <dir>/README.md (hand-maintained, N lines) ...
Remaining: <gaps the run could not close, each with a reason>
Run next:  <commands the user still has to run, if any>
```

Every step that was not completed appears under Skipped or Remaining with its reason. Do not omit a skipped step.
