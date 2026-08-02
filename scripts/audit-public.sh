#!/usr/bin/env bash
set -euo pipefail

if ! command -v rg >/dev/null 2>&1; then
  echo "This audit requires ripgrep (rg)." >&2
  exit 2
fi

failed=0

check() {
  local label="$1"
  local pattern="$2"

  if rg --hidden --glob '!.git/**' --glob '!scripts/audit-public.sh' \
      --line-number --pcre2 -- "$pattern" .; then
    echo "Review required: $label" >&2
    failed=1
  fi
}

check "possible private key" \
  '-----BEGIN (?:OPENSSH|RSA|EC|DSA|PRIVATE) PRIVATE KEY-----'
check "possible credential assignment" \
  '(?i)(?:password|passwd|secret|token|api[_-]?key)\s*[:=]\s*(?!replace_me|example|placeholder)\S{8,}'
check "possible MAC address" \
  '(?i)\b(?:[0-9a-f]{2}:){5}[0-9a-f]{2}\b'
check "literal private IPv4 address" \
  '\b(?:10\.(?:\d{1,3}\.){2}\d{1,3}|192\.168\.(?:\d{1,3}\.)\d{1,3}|172\.(?:1[6-9]|2\d|3[01])\.(?:\d{1,3}\.)\d{1,3})\b'
check "possible email address" \
  '\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b'

if (( failed )); then
  echo "Public audit found values that require manual review." >&2
  exit 1
fi

echo "No obvious secrets or personal network identifiers found."
echo "Manual review is still required before publishing."
