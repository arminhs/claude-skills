# skill-catalog

## Purpose

The repository README that lists every published skill with its trigger description and shows how to install a skill, so users can discover and adopt skills from this repository.

## Requirements

### Requirement: Repository README lists every published skill
The root `README.md` SHALL contain a table with one row per directory under `skills/`, giving the skill name, its one-line description taken from the `SKILL.md` frontmatter, and a relative link to the skill directory.

#### Scenario: New skill appears in the catalog
- **WHEN** a directory `skills/<name>/SKILL.md` exists
- **THEN** the README table has a row for `<name>` whose description matches the frontmatter description

#### Scenario: Catalog matches the filesystem
- **WHEN** a skill directory is removed or renamed
- **THEN** the README table no longer lists the old name

### Requirement: README explains installation
The root `README.md` SHALL describe how to install a skill into a project (copy or symlink into `.claude/skills/`) and into the user scope (`~/.claude/skills/`), and SHALL state that this repository uses OpenSpec for planning changes.

#### Scenario: User installs a skill from the instructions
- **WHEN** a user follows the installation section for `terraform-module-docs`
- **THEN** the resulting path is `.claude/skills/terraform-module-docs/SKILL.md` and Claude Code lists the skill
