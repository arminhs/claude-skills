# Spec Delta

## MODIFIED Requirements

### Requirement: Audit reports documentation gaps before writing
When invoked on a module directory, the skill SHALL first produce an audit that lists, for the root module, every module directory under `modules/` at any depth, and every directory under `examples/` that contains `.tf` or `.tf.json` files: whether a `.header.md` exists, whether a `README.md` exists and carries terraform-docs markers, and which variables and outputs lack a description or carry a scaffold placeholder as their description. The audit SHALL report whether a `.terraform-docs.yaml` exists at the module root only, since subdirectories are generated with the root configuration. The audit SHALL parse source files regardless of line endings and SHALL NOT count braces inside heredoc strings.

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

#### Scenario: Placeholder description is reported
- **WHEN** a variable or output has a `description` whose text is a scaffold placeholder, such as `(optional) describe your variable`, `TODO`, `tbd`, or `description`
- **THEN** the audit lists it as `file:name(placeholder)` and the skill treats it as missing in Step 3

#### Scenario: File with CRLF line endings is parsed
- **WHEN** a `.tf` file uses `\r\n` line endings and contains a variable without a description
- **THEN** the audit reports that variable exactly as it would for an LF file

#### Scenario: Heredoc with unbalanced braces does not corrupt parsing
- **WHEN** an output's heredoc description contains an unmatched `{` and a later output in the same file lacks a description
- **THEN** the audit still reports the later output

#### Scenario: Minimal README is treated as generated
- **WHEN** a `README.md` exists that is empty, contains only a title and one paragraph, or consists only of terraform-docs output with or without markers
- **THEN** the audit classifies it as minimal and the skill proceeds to replace it, carrying any existing title and paragraph into `.header.md`

#### Scenario: Marker file with substantial prose outside the markers is hand-maintained
- **WHEN** a `README.md` has terraform-docs markers and, outside the marker block, more than a title and a short introduction
- **THEN** the audit classifies it as hand-maintained, because replace mode would delete that prose

#### Scenario: Substantial hand-written README is out of scope
- **WHEN** a `README.md` exists without terraform-docs markers and contains more than a title and a short introduction, for example several sections or code samples
- **THEN** the audit flags it as hand-maintained, the skill MUST NOT regenerate it, and the skill limits its changes on that module to variable and output descriptions unless the user explicitly asks to migrate the prose into `.header.md`

### Requirement: READMEs are regenerated with terraform-docs and verified against CI
The skill SHALL regenerate the `README.md` of every directory the write gate allows, including directories whose README is already classified `generated`, by running terraform-docs with the module's `.terraform-docs.yaml`, using the version pinned in the module's CI workflow when one is pinned, and SHALL verify the result by comparing the output of a second run against the first run, not against the committed state.

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
- **THEN** the skill still writes `.header.md` and source descriptions, states plainly that README generation was skipped, and prints the commands the user must run for the root, each module, and each example

#### Scenario: Regenerated README is idempotent
- **WHEN** the skill has regenerated a README and the first run's output has been staged or snapshotted
- **THEN** running terraform-docs again produces no difference from that snapshot, and a difference from the committed state alone is not a failure
