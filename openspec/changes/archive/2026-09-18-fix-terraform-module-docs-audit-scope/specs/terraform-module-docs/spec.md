# Spec Delta

## MODIFIED Requirements

### Requirement: Audit reports documentation gaps before writing
When invoked on a module directory, the skill SHALL first produce an audit that lists, for the root module, every module directory under `modules/` at any depth, and every directory under `examples/`: whether a `.header.md` exists, whether a `README.md` exists and carries terraform-docs markers, and which variables and outputs lack a description. The audit SHALL report whether a `.terraform-docs.yaml` exists at the module root only, since subdirectories are generated with the root configuration.

#### Scenario: Example without README is reported
- **WHEN** an example directory contains `main.tf` but no `README.md`
- **THEN** the audit lists that example as missing a README and, if it also lacks `.header.md`, as missing a header

#### Scenario: Nested module is audited
- **WHEN** a module directory exists at `modules/<a>/modules/<b>/` containing `.tf` files
- **THEN** the audit lists `modules/<a>/modules/<b>` as its own row with the same columns as a top-level module

#### Scenario: Config presence is reported for the root only
- **WHEN** the module root has a `.terraform-docs.yaml` and its examples do not
- **THEN** the audit reports the config as present once for the root and shows subdirectory rows as not applicable rather than missing

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
The skill SHALL write all narrative documentation (title, summary, usage example, feature sections, common errors, contributing link) into `.header.md` at the module or example root, and SHALL treat `README.md` as generated output only. Headings SHALL NOT contain bare underscores, because terraform-docs escapes them in the generated README; a name containing underscores is written in backticks or spelled with spaces.

#### Scenario: Root header follows the established outline
- **WHEN** the skill creates a root `.header.md` for a module that has none
- **THEN** the file contains, in order: an H1 title, a one paragraph summary linking to the examples directory, a `## Usage` section with a complete `module` block using the registry source and a version constraint, and a final `# Contributing` or `## Contributing` section linking to the contributing guide if one exists

#### Scenario: Example header uses the module example title format
- **WHEN** the skill creates `.header.md` for a directory under `examples/`
- **THEN** its H1 reads `# <Module title> - Example: <Example name>` followed by one sentence and a nested bullet list of what the example builds

#### Scenario: Submodule heading with an underscore in its name
- **WHEN** the skill creates `.header.md` for a module directory named with underscores, such as `flow_logs`
- **THEN** the H1 renders the name in backticks (`# VPC module - Submodule: \`flow_logs\``) or with spaces, and the generated README contains no `\_` sequence in any heading

#### Scenario: Code samples are fenced as HCL
- **WHEN** the skill writes a Terraform snippet into any `.header.md`
- **THEN** the fence is labelled `hcl`, and inline comments explain non-obvious option values

### Requirement: READMEs are regenerated with terraform-docs and verified against CI
The skill SHALL regenerate the `README.md` of every directory the write gate allows, including directories whose README is already classified `generated`, by running terraform-docs with the module's `.terraform-docs.yaml`, using the version pinned in the module's CI workflow when one is pinned, and SHALL verify the result the same way CI does by checking that a second run produces no diff.

#### Scenario: Config is created when absent
- **WHEN** the module has no `.terraform-docs.yaml`
- **THEN** the skill creates one from its bundled template with markdown formatter, `header-from: .header.md`, output file `README.md` in replace mode, and inputs sorted by required

#### Scenario: Stale generated README is refreshed
- **WHEN** an example already has a README with terraform-docs markers whose tables no longer match the example's source
- **THEN** the skill regenerates it and lists it under Modified in the run summary

#### Scenario: Pinned CI version is honoured
- **WHEN** a workflow under `.github/workflows/` pins a terraform-docs release tag
- **THEN** the skill runs that exact version, or reports the mismatch when only a different version is available locally

#### Scenario: terraform-docs is unavailable
- **WHEN** no terraform-docs binary can be run in the environment
- **THEN** the skill still writes `.header.md` and source descriptions, states plainly that README generation was skipped, and prints the command the user must run

#### Scenario: Regenerated README is idempotent
- **WHEN** the skill has regenerated a README
- **THEN** running terraform-docs again produces no change to the file
