# terraform-module-docs

## Purpose

A Claude Code skill that documents undocumented or minimally documented Terraform modules using the terraform-docs plus `.header.md` convention, so that READMEs, examples, and input/output descriptions become complete and stay consistent with a terraform-docs CI check.

## Requirements

### Requirement: Skill is discoverable and triggers on Terraform documentation tasks
The skill SHALL be a directory containing a `SKILL.md` whose frontmatter declares `name` and a `description` that names the triggering situations: documenting a Terraform module, generating or regenerating a module README, writing `.header.md`, adding variable or output descriptions, and documenting a module example.

#### Scenario: Skill loads from the standard location
- **WHEN** the skill directory is copied or symlinked into a project's or user's `.claude/skills/` directory
- **THEN** Claude Code lists it under the name `terraform-module-docs` and invokes it when the user asks to document a Terraform module

#### Scenario: Description names concrete triggers
- **WHEN** a user asks to "update the README for this module", "document the variables", or "add a README to the example"
- **THEN** the description text matches those phrasings so the skill is selected without the user naming it

### Requirement: Audit reports documentation gaps before writing
When invoked on a module directory, the skill SHALL first produce an audit that lists, for the root module, every child module under `modules/`, and every directory under `examples/`: whether a `.header.md` exists, whether a `README.md` exists and carries terraform-docs markers, which variables and outputs lack a description, and whether a `.terraform-docs.yaml` exists.

#### Scenario: Example without README is reported
- **WHEN** an example directory contains `main.tf` but no `README.md`
- **THEN** the audit lists that example as missing a README and, if it also lacks `.header.md`, as missing a header

#### Scenario: Undocumented variables are reported by file and name
- **WHEN** a `variables.tf` contains a variable block with no `description` attribute
- **THEN** the audit names the file and the variable so the user can locate it

#### Scenario: Minimal README is treated as generated
- **WHEN** a `README.md` exists that is empty, contains only a title and one paragraph, or consists only of terraform-docs output with or without markers
- **THEN** the audit classifies it as minimal and the skill proceeds to replace it, carrying any existing title and paragraph into `.header.md`

#### Scenario: Substantial hand-written README is out of scope
- **WHEN** a `README.md` exists without terraform-docs markers and contains more than a title and a short introduction, for example several sections or code samples
- **THEN** the audit flags it as hand-maintained, the skill MUST NOT regenerate it, and the skill limits its changes on that module to variable and output descriptions unless the user explicitly asks to migrate the prose into `.header.md`

### Requirement: Prose documentation is written to `.header.md`, never into the generated README
The skill SHALL write all narrative documentation (title, summary, usage example, feature sections, common errors, contributing link) into `.header.md` at the module or example root, and SHALL treat `README.md` as generated output only.

#### Scenario: Root header follows the established outline
- **WHEN** the skill creates a root `.header.md` for a module that has none
- **THEN** the file contains, in order: an H1 title, a one paragraph summary linking to the examples directory, a `## Usage` section with a complete `module` block using the registry source and a version constraint, and a final `# Contributing` or `## Contributing` section linking to the contributing guide if one exists

#### Scenario: Example header uses the module example title format
- **WHEN** the skill creates `.header.md` for a directory under `examples/`
- **THEN** its H1 reads `# <Module title> - Example: <Example name>` followed by one sentence and a nested bullet list of what the example builds

#### Scenario: Code samples are fenced as HCL
- **WHEN** the skill writes a Terraform snippet into any `.header.md`
- **THEN** the fence is labelled `hcl`, and inline comments explain non-obvious option values

### Requirement: Source descriptions are complete and consistently styled
The skill SHALL add a `description` to every variable and output that lacks one, and SHALL follow the style already used in the module: a full sentence ending in a period, other inputs referenced as `var.<name>` or in backticks, optional inputs prefixed with `(Optional)` when the module already uses that prefix, and long output descriptions written as a heredoc with an example value.

#### Scenario: Missing variable description is added
- **WHEN** a variable has a `type` and `default` but no `description`
- **THEN** the skill adds a `description` sentence derived from the variable name, type, default, and its usage in the module source, and preserves the existing attribute order in that file

#### Scenario: Existing descriptions are left unchanged
- **WHEN** a variable already has a `description`
- **THEN** the skill does not rewrite it unless the user asks for a style pass

### Requirement: READMEs are regenerated with terraform-docs and verified against CI
The skill SHALL regenerate every `README.md` by running terraform-docs with the module's `.terraform-docs.yaml`, using the version pinned in the module's CI workflow when one is pinned, and SHALL verify the result the same way CI does by checking that a second run produces no diff.

#### Scenario: Config is created when absent
- **WHEN** the module has no `.terraform-docs.yaml`
- **THEN** the skill creates one from its bundled template with markdown formatter, `header-from: .header.md`, output file `README.md` in replace mode, and inputs sorted by required

#### Scenario: Pinned CI version is honoured
- **WHEN** a workflow under `.github/workflows/` pins a terraform-docs release tag
- **THEN** the skill runs that exact version, or reports the mismatch when only a different version is available locally

#### Scenario: terraform-docs is unavailable
- **WHEN** no terraform-docs binary can be run in the environment
- **THEN** the skill still writes `.header.md` and source descriptions, states plainly that README generation was skipped, and prints the command the user must run

#### Scenario: Regenerated README is idempotent
- **WHEN** the skill has regenerated a README
- **THEN** running terraform-docs again produces no change to the file

### Requirement: Supplementary docs follow the module's naming conventions
When the user asks for an upgrade guide or the skill detects a major version bump, the skill SHALL create `docs/UPGRADE-GUIDE-<major>.0.md` with Preparation, Overview, and numbered step sections, and SHALL link it from the root `.header.md` note near the top.

#### Scenario: Upgrade guide is linked from the header
- **WHEN** a new `docs/UPGRADE-GUIDE-5.0.md` is created
- **THEN** the root `.header.md` contains an italic note pointing to it, replacing any note for the previous major version

### Requirement: Skill reports what it changed and what remains
At the end of a run the skill SHALL summarize the files created or modified, the gaps that remain unresolved, and any commands the user still needs to run.

#### Scenario: Partial run is reported honestly
- **WHEN** the skill could not complete a step, for example because terraform-docs was unavailable or a README was hand-maintained
- **THEN** the summary lists that step as not done with the reason, rather than omitting it
