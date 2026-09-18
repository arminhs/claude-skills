# Design

## Context

See proposal.md. All four defects are local to the skill's audit script, workflow text, and conventions. No structural change.

## Goals / Non-Goals

**Goals:** fix the four observed defects without changing the skill's install path, frontmatter, or step order.

**Non-Goals:** auditing directories other than the root, `modules/**`, and `examples/*`; supporting per-directory terraform-docs configs.

## Decisions

- **Recursive module discovery with `find`.** Replace the `modules/*/` glob with `find modules -type d` filtered to directories containing `.tf` files, skipping `.terraform`. Alternative: a fixed two-level glob. Rejected because nesting depth is not bounded.
- **Config column becomes `n/a` for subdirectories.** Keeps the table shape stable while removing the misleading `no`. Alternative: drop the column and report only in the footer. Rejected to keep the root row self-describing.
- **Underscore rule lives in conventions and templates.** The skill cannot change how terraform-docs escapes; the fix is to write headings that do not need escaping. The templates gain a comment showing the backtick form.
- **Generate step iterates the gate list, not the missing list.** Step 4 text changes from "for the root and each allowed directory" to an explicit loop over every row not classified hand-maintained, and the summary distinguishes Created from Modified by whether the README existed before.

## Risks / Trade-offs

- [Recursive discovery picks up vendored or test fixture directories under `modules/`] → only directories containing `.tf` files are listed, and the user sees the table before any write.
