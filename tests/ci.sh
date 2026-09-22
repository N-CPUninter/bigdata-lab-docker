#!/usr/bin/env bash
# Sobe a sandbox e roda os testes de fumaça pedidos (padrão: aula10). Uso: tests/ci.sh [aula10 aula07 ...]
set -uo pipefail; cd "$(dirname "$0")/.."
export MSYS_NO_PATHCONV=1
tests="${*:-aula10}"
docker compose up -d sandbox
docker compose exec -T sandbox lab wait-ambari || { docker compose logs sandbox | tail -100; exit 1; }
rc=0
for t in $tests; do
  echo "===== $t ====="
  bash "tests/smoke/$t.sh" || rc=1
done
exit $rc
