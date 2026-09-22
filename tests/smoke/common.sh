#!/usr/bin/env bash
# Funções comuns dos testes de fumaça. Rodam NO HOST e executam comandos dentro da sandbox.
export MSYS_NO_PATHCONV=1
SB() { docker compose exec -T sandbox bash -lc "$*"; }
SBU() { docker compose exec -T -u maria_dev sandbox bash -lc "cd /home/maria_dev && $*"; }
pass() { echo "PASS: $*"; }
fail() { echo "FAIL: $*" >&2; exit 1; }
expect_grep() { # expect_grep "descrição" "regex" <<< "$saida"
  local desc="$1" re="$2" out; out="$(cat)"
  if grep -qE "$re" <<< "$out"; then pass "$desc"; else echo "$out" | tail -40; fail "$desc (esperado /$re/)"; fi
}
