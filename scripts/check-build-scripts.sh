#!/usr/bin/env bash
set -euo pipefail

ROOTS=(
  build_files/base
  build_files/shared
)

fail=0

for root in "${ROOTS[@]}"; do
  while IFS= read -r -d '' file; do
    echo "Checking $file"

    # Executable
    if [[ ! -x "$file" ]]; then
      echo "  ❌ not executable"
      fail=1
    fi

    # Shebang
    if ! head -n1 "$file" | grep -q '^#!'; then
      echo "  ❌ missing shebang"
      fail=1
    fi

    # CRLF
    if file "$file" | grep -q CRLF; then
      echo "  ❌ CRLF line endings"
      fail=1
    fi

    # Optional shellcheck
    if command -v shellcheck >/dev/null 2>&1; then
      if ! shellcheck "$file"; then
        echo "  ❌ shellcheck warnings"
        fail=1
      fi
    else
      echo "  ℹ️  shellcheck not installed"
    fi

    echo
  done < <(find "$root" -type f -name '*.sh' -print0)
done

if [[ "$fail" -ne 0 ]]; then
  echo "One or more script checks failed"
  exit 1
fi

echo "All build scripts look good"