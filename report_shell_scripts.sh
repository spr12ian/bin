#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

FILES=(scripts/**/*.sh scripts/*.sh *.sh)
OUTDIR=reports
mkdir -p "$OUTDIR"

# 1) Format diff (don’t modify) — enforce a consistent style
shfmt -i 2 -ci -sr -kp -d "${FILES[@]}" > "$OUTDIR/shfmt.diff" || true

# 2) ShellCheck JSON + summary
shellcheck -S style -f json "${FILES[@]}" > "$OUTDIR/shellcheck.json" || true
jq -r '
  (["File","Line","SC","Level","Message"] | @tsv),
  (.[] | [.file, (.line|tostring), .code, .level, (.message|gsub("\n"; " "))] | @tsv)
' "$OUTDIR/shellcheck.json" > "$OUTDIR/shellcheck.tsv" || true

# 3) Bashate (style)
if command -v bashate >/dev/null 2>&1; then
  bashate -i E006,E010 "${FILES[@]}" > "$OUTDIR/bashate.txt" || true
fi

# 4) Check for non-portable bashisms (if you care about /bin/sh portability)
if command -v checkbashisms >/dev/null 2>&1; then
  checkbashisms -n -x "${FILES[@]}" > "$OUTDIR/bashisms.txt" || true
fi

# 5) Codespell for typos in comments/strings
if command -v codespell >/dev/null 2>&1; then
  codespell -L fo,teh --skip="*.min.js,*.png,*.jpg" "${FILES[@]}" > "$OUTDIR/codespell.txt" || true
fi

# 6) Simple grep checks for common footguns
{
  echo "Suspicious patterns:"
  grep -R --line-number -E '(^|[^[:alnum:]_])echo[[:space:]]+-e[[:space:]]' "${FILES[@]}" || true
  grep -R --line-number -E 'read[[:space:]]+-p' "${FILES[@]}" || true
  grep -R --line-number -E 'rm[[:space:]]+-rf[[:space:]]+/( |$)' "${FILES[@]}" || true
  grep -R --line-number -E 'curl[[:space:]].*\|[[:space:]]*sh' "${FILES[@]}" || true
} > "$OUTDIR/greps.txt"

# 7) Assemble a Markdown dashboard
MD="$OUTDIR/summary.md"
{
  echo "# Shell Scripts QA Summary"
  echo
  echo "Scripts scanned: ${#FILES[@]}"
  echo
  echo "## Formatting diff (shfmt)"
  echo
  if [ -s "$OUTDIR/shfmt.diff" ]; then
    echo "There are formatting changes proposed. See \`reports/shfmt.diff\`."
  else
    echo "No formatting changes needed."
  fi
  echo
  echo "## ShellCheck findings"
  if [ -s "$OUTDIR/shellcheck.tsv" ]; then
    echo ""
    echo "Top 50 issues:"
    echo ""
    echo '```text'
    head -n 51 "$OUTDIR/shellcheck.tsv"
    echo '```'
  else
    echo "No ShellCheck findings."
  fi
  echo
  echo "## Bashate"
  [ -s "$OUTDIR/bashate.txt" ] && echo "See \`reports/bashate.txt\`" || echo "No bashate output."
  echo
  echo "## Bashisms"
  [ -s "$OUTDIR/bashisms.txt" ] && echo "See \`reports/bashisms.txt\`" || echo "No bashisms report."
  echo
  echo "## Codespell"
  [ -s "$OUTDIR/codespell.txt\" ] && echo "See \`reports/codespell.txt\`" || echo "No typos found."
  echo
  echo "## Grep checks"
  [ -s "$OUTDIR/greps.txt" ] && echo "See \`reports/greps.txt\`" || echo "No suspicious patterns."
} > "$MD"

echo "Done. Open $MD"
