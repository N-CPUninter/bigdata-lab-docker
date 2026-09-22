#!/usr/bin/env bash
# Trabalho: HDFS + spark-submit (Spark 3) com um script de referência; exige data/imdb-reviews-pt-br.csv.
set -uo pipefail; cd "$(dirname "$0")/../.."; source tests/smoke/common.sh
[ -f data/imdb-reviews-pt-br.csv ] || { echo "SKIP: data/imdb-reviews-pt-br.csv ausente"; exit 0; }
SB "lab aula trabalho --quiet" || fail "lab aula trabalho"
SBU "hdfs dfs -put -f ~/data-host/imdb-reviews-pt-br.csv /user/maria_dev/ && hdfs dfs -copyToLocal -f /user/maria_dev/imdb-reviews-pt-br.csv ~/ && ls -la ~/imdb-reviews-pt-br.csv" | expect_grep "CSV via HDFS" 'imdb-reviews-pt-br.csv'
docker compose cp tests/smoke/trabalho_ref.py sandbox:/home/maria_dev/trabalho_ref.py >/dev/null
SBU "bash aulas/trabalho/verifica.sh ~/trabalho_ref.py ~/imdb-reviews-pt-br.csv" | expect_grep "respostas do trabalho" 'Tudo certo'
