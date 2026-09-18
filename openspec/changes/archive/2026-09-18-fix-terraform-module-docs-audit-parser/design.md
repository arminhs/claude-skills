# Design

## Context

See proposal.md. Changes are confined to the audit script, the workflow text, and the frontmatter.

## Goals / Non-Goals

**Goals:** eliminate the silent false negatives and the false idempotence failure; make the write gate safe for marker files with prose.

**Non-Goals:** parsing `.tf.json` variable blocks (the directory is listed; description checks apply to `.tf` only); a full HCL parser.

## Decisions

- **awk gains heredoc awareness.** On a line matching `<<-?IDENT`, record the terminator and skip lines until one whose trimmed content equals it. Braces inside are ignored. Carriage returns are stripped with `sub(/\r$/, "")` on every line. Alternative: parse with `hcl2json`. Rejected because it adds a dependency to a read-only audit.
- **Placeholder list is a regex in the script**, matched case-insensitively against the whole description string: `\(optional\) describe your variable`, `^todo`, `^tbd$`, `^description$`, `^n/a$`, `^placeholder$`, and an empty string. Reported as `file:name(placeholder)`. Alternative: flag all descriptions under N characters. Rejected as too noisy.
- **Classification measures prose outside the marker block for every file.** The marker-first branch that returned `generated` is removed; the existing line-and-heading heuristic applies to the remainder, and a file with markers and little prose is reported as `generated` so the summary stays informative.
- **Idempotence procedure: run, `git add`, run, `git diff --exit-code`.** Explicit staging is simpler than checksums and matches how CI checks. The text says why.
- **`allowed-tools` becomes a comma-separated list** and the bash grant is `Bash(bash *scripts/audit.sh*)`.

## Risks / Trade-offs

- [Placeholder regex misses a project's own placeholder wording] → It is a list; the checklist tells the user to extend it.
- [Staging during Step 4 surprises a user with other unstaged work] → The step says to stage only the README files it generated.
