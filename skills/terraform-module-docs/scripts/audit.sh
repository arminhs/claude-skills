#!/usr/bin/env bash
# Audit a Terraform module's documentation state. Read-only.
# Usage: audit.sh [module-root]   (defaults to the current directory)
set -euo pipefail

root="${1:-.}"
root="$(cd "$root" && pwd)"

classify_readme() {
  local f="$1"
  [ -f "$f" ] || { echo "absent"; return; }
  local markers=no body lines h2
  if grep -q 'BEGIN_TF_DOCS' "$f" && grep -q 'END_TF_DOCS' "$f"; then markers=yes; fi
  body="$(sed '/BEGIN_TF_DOCS/,/END_TF_DOCS/d' "$f" | tr -d '\r')"
  lines="$(printf '%s\n' "$body" | grep -c '[^[:space:]]' || true)"
  h2="$(printf '%s\n' "$body" | grep -c '^## ' || true)"
  if [ "$lines" -lt 15 ] && [ "$h2" -eq 0 ]; then
    [ "$markers" = yes ] && echo "generated" || echo "minimal(${lines} lines)"
  else
    echo "hand-maintained(${lines} lines, ${h2} h2)"
  fi
}

# Print "file:name" for every variable/output block lacking a description.
undocumented() {
  local kind="$1" dir="$2"
  for f in "$dir"/*.tf; do
    [ -f "$f" ] || continue
    awk -v kind="$kind" -v file="${f#$root/}" '
      { sub(/\r$/, "") }
      inhd { if ($0 ~ ("^[ \t]*" hd "[ \t]*$")) inhd=0; next }
      !inblk && $1 == kind && $3 == "{" {
        name=$2; gsub(/"/,"",name); depth=0; inblk=1; has=0; ph=0
        if ($0 ~ /description[ \t]*=/) { has=1; ph=isph($0) }
      }
      inblk {
        if (depth == 1 && $1 == "description") { has=1; ph=isph($0) }
        if (match($0, /<<-?[A-Za-z_][A-Za-z0-9_]*/)) {
          hd=substr($0, RSTART, RLENGTH); sub(/^<<-?/, "", hd); inhd=1
          if (has && $1 == "description" && depth == 1) ph=0
        }
        n=gsub(/{/,"{"); m=gsub(/}/,"}"); depth += n - m
        if (depth <= 0) {
          if (!has) printf "%s:%s\n", file, name
          else if (ph) printf "%s:%s(placeholder)\n", file, name
          inblk=0
        }
      }
      function isph(line,   v) {
        v=line; sub(/^[^=]*=[ \t]*/, "", v); gsub(/^"|"[ \t]*$/, "", v); v=tolower(v)
        return (v == "" || v ~ /\(optional\) describe your variable/ || v ~ /^todo/ || v == "tbd" || v == "description" || v == "n\/a" || v == "placeholder")
      }' "$f"
  done
}

dirs=("$root")
if [ -d "$root/modules" ]; then
  while IFS= read -r d; do
    { ls "$d"/*.tf >/dev/null 2>&1 || ls "$d"/*.tf.json >/dev/null 2>&1; } && dirs+=("$d")
  done < <(find "$root/modules" -type d -not -path '*/.terraform*' | sort)
fi
for d in "$root"/examples/*/; do
  [ -d "$d" ] || continue
  { ls "$d"*.tf >/dev/null 2>&1 || ls "$d"*.tf.json >/dev/null 2>&1; } && dirs+=("${d%/}")
done

printf '%-40s %-8s %-32s %-8s %s\n' "DIR" "HEADER" "README" "TFDOCS" "UNDOCUMENTED"
for d in "${dirs[@]}"; do
  rel="${d#$root}"; rel="${rel#/}"; [ -n "$rel" ] || rel="."
  header=$([ -f "$d/.header.md" ] && echo yes || echo no)
  readme="$(classify_readme "$d/README.md")"
  if [ "$d" = "$root" ]; then
    cfg=$([ -f "$d/.terraform-docs.yaml" ] || [ -f "$d/.terraform-docs.yml" ] && echo yes || echo no)
  else
    cfg="n/a"
  fi
  undoc="$( { undocumented variable "$d"; undocumented output "$d"; } | tr '\n' ' ')"
  printf '%-40s %-8s %-32s %-8s %s\n' "$rel" "$header" "$readme" "$cfg" "${undoc:--}"
done

echo
pinned="$( { cat "$root"/.github/workflows/*.yml "$root"/.pre-commit-config.yaml 2>/dev/null || true; } \
  | awk '/terraform-docs/ {hit=3} hit>0 { if ($0 !~ /@v/ && match($0,/v[0-9]+\.[0-9]+\.[0-9]+/)) print substr($0,RSTART,RLENGTH); hit-- }' \
  | sort -u | tr '\n' ' ')"
echo "terraform-docs pinned in CI: ${pinned:-none}"
if command -v terraform-docs >/dev/null 2>&1; then
  echo "terraform-docs available:    $(terraform-docs --version | awk '{print $3}')"
else
  echo "terraform-docs available:    no"
fi
guides="$(for g in "$root"/docs/UPGRADE-GUIDE-*.md; do [ -f "$g" ] || continue; basename "$g"; done | tr '\n' ' ')"
echo "upgrade guides:              ${guides:-none}"
