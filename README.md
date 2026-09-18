# claude-skills

A collection of reusable [Claude Code](https://claude.ai/code) agent skills. Each skill lives in its own directory under `skills/` with a `SKILL.md` and any references, templates, or scripts it needs.

## Skills

| Skill | Description |
|-------|-------------|
| [terraform-module-docs](skills/terraform-module-docs/) | Document a Terraform module in the aws-ia style (terraform-docs plus .header.md). Use when the user asks to document a Terraform module, generate or regenerate a module README, update the README for this module, write or fix .header.md, document the variables or outputs, add missing variable or output descriptions, add a README to an example, or write an upgrade guide. Targets undocumented modules and modules whose README is empty, minimal, or terraform-docs output; hand-maintained READMEs are reported, not rewritten. |

## Installation

Claude Code loads skills from a `.claude/skills/<name>/SKILL.md` path. Copy or symlink a skill directory there.

Project scope (one repository):

```shell
mkdir -p .claude/skills
ln -s /path/to/claude-skills/skills/terraform-module-docs .claude/skills/terraform-module-docs
```

User scope (every project on this machine):

```shell
mkdir -p ~/.claude/skills
ln -s /path/to/claude-skills/skills/terraform-module-docs ~/.claude/skills/terraform-module-docs
```

Use `cp -r` instead of `ln -s` to vendor a copy. After installing, the skill appears in Claude Code's skill list and triggers on the situations named in its description.

## Contributing

Changes to this repository are planned with [OpenSpec](https://github.com/Fission-AI/OpenSpec). Start a change with `/opsx:propose`, implement it with `/opsx:apply`, and archive it with `/opsx:archive`. Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/).
