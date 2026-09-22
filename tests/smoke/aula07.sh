#!/usr/bin/env bash
# Aula 7: Pig (local e Tez) e Oozie (workflow Sqoop + Hive).
set -uo pipefail; cd "$(dirname "$0")/../.."; source tests/smoke/common.sh
SB "lab aula 7 --quiet" || fail "lab aula 7"
SBU "hdfs dfs -ls /user/maria_dev/ml-100k" | expect_grep "ml-100k no HDFS" 'u\.data'
SBU "cd aulas/aula07/Pig_exercise && pig MostRatedFiveStarMovie.pig 2>/dev/null" | expect_grep "Pig Tez/YARN (MostRated)" 'Star Wars'
SBU "cd aulas/aula07/Pig_exercise && pig OldestFiveStarMovie.pig 2>/dev/null" | expect_grep "Pig Tez/YARN (Oldest)" '\(.*,.*,[0-9]+\)'
SBU "cd aulas/aula07/Pig_exercise && sed 's#/user/maria_dev/ml-100k#/home/maria_dev/data/ml-100k#' MostRatedFiveStarMovie.pig > /tmp/local.pig && pig -x local /tmp/local.pig 2>/dev/null" | expect_grep "Pig local (arquivos locais)" 'Star Wars'
SBU "cd aulas/aula07/Oozie_exercise && hdfs dfs -put -f workflow.xml oldmovies.sql /user/maria_dev/ && oozie job -oozie http://localhost:11000/oozie -config job.properties -run" > /tmp/oozie.out
job=$(grep -oE '[0-9]+-[0-9]+-oozie-oozi-W' /tmp/oozie.out | head -1); [ -n "$job" ] || { cat /tmp/oozie.out; fail "oozie job -run"; }
for _ in $(seq 1 60); do st=$(SBU "oozie job -oozie http://localhost:11000/oozie -info $job" | grep -E '^Status' | awk '{print $NF}'); [ "$st" = RUNNING ] || [ "$st" = PREP ] || break; sleep 10; done
[ "$st" = SUCCEEDED ] && pass "Oozie workflow $job SUCCEEDED" || fail "Oozie workflow terminou em $st"
SBU "hdfs dfs -cat /user/maria_dev/oldmovies/* | head -3" | expect_grep "saída do Hive via Oozie" '19[0-3][0-9]'
