#!/usr/bin/env bash
# Aula 10/11: PySpark local nas duas versões do Spark.
set -uo pipefail; cd "$(dirname "$0")/../.."; source tests/smoke/common.sh
SB "lab aula 10 --quiet" >/dev/null
for v in 3 2; do
  SBU "export SPARK_MAJOR_VERSION=$v; cd aulas/aula10/01-RatingsCounter && spark-submit ratings-counter.py 2>/dev/null" \
    | expect_grep "Spark $v ratings-counter (5 notas)" '^5 [0-9]+'
done
SBU "cd aulas/aula10/04-SparkSQL && spark-submit spark-sql.py 2>/dev/null" | expect_grep "Spark SQL customer orders" 'comanda_id'
SBU "cd aulas/aula10/05-MLLib && spark-submit movie-recommendations-als.py 50 2>/dev/null" | expect_grep "MLlib ALS recomendações" 'score [0-9]'
