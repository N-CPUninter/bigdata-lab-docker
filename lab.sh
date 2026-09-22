#!/usr/bin/env bash
# Atalhos para a sandbox Big Data (Linux / macOS / Git Bash).
#   ./lab.sh up | down | nosql | aula <perfil> | status | stop-all | mem <8g|16g> | urls | shell | root | logs | build | reset
set -euo pipefail
cd "$(dirname "$0")"
[ -f .env ] || cp .env.example .env
export MSYS_NO_PATHCONV=1
sb() { docker compose exec sandbox lab "$@"; }
case "${1:-help}" in
  up)       docker compose up -d; echo "Aguardando o Ambari responder (2 a 4 minutos na primeira vez)..."; sb wait-ambari; sb urls
            echo; echo "Ambari no ar. Próximo passo: ./lab.sh aula <perfil>   (ex.: aula 10, aula trabalho, aula 7)"
            echo "Espere a mensagem PRONTO desse comando antes de usar o terminal, o SSH ou os comandos das aulas." ;;
  down)     docker compose --profile nosql down ;;
  nosql)    docker compose --profile nosql up -d mongo cassandra ;;
  aula)     shift; sb aula "$@" ;;
  status)   sb status ;;
  stop-all) sb stop-all ;;
  mem)      shift; sb mem "$@" ;;
  urls)     sb urls ;;
  shell)    docker compose exec -u maria_dev -w /home/maria_dev sandbox bash -l ;;
  root)     docker compose exec sandbox bash -l ;;
  logs)     docker compose logs -f sandbox ;;
  build)    docker compose build sandbox ;;
  reset)    read -r -p "Isto apaga HDFS, bancos e o home da maria_dev. Digite SIM para confirmar: " ok; [ "$ok" = "SIM" ] && docker compose --profile nosql down -v ;;
  *)        sed -n '2,3p' "$0" ;;
esac
