#!/usr/bin/env bash
# Aula 12: Flume (avro) -> Spark2 Streaming; Structured Streaming no Spark 3.
set -uo pipefail; cd "$(dirname "$0")/../.."; source tests/smoke/common.sh
SB "lab aula 12 --quiet" >/dev/null
SBU "cp aulas/aula12/SparkStreaming/sparkstreamingflume.conf ~/ && rm -rf ~/spool/* ~/checkpoint/* && \
     (cd aulas/aula12/SparkStreaming && SPARK_MAJOR_VERSION=2 timeout 150 spark-submit --packages org.apache.spark:spark-streaming-flume_2.12:2.4.8 SparkFlume.py > /tmp/sparkflume.out 2>/dev/null &) ; \
     sleep 45; (timeout 100 flume-ng agent --conf /usr/hdp/current/flume-server/conf --conf-file ~/sparkstreamingflume.conf --name a1 > /tmp/flume2.out 2>&1 &) ; \
     sleep 15; cp ~/data/access_log_small.txt ~/spool/log.txt; sleep 40; grep -m1 -E \"u'/|\\('/\" /tmp/sparkflume.out || tail -5 /tmp/sparkflume.out" \
  | expect_grep "Flume avro -> Spark2 DStream contou URLs" "/"
SBU "cd aulas/aula12/SparkStreaming && hdfs dfs -rm -r -f logs; hdfs dfs -mkdir -p logs && (SPARK_MAJOR_VERSION=3 timeout 90 spark-submit structured-streaming.py > /tmp/ss.out 2>/dev/null &) ; sleep 30; hdfs dfs -put ~/data/access_log_small.txt logs/; sleep 40; grep -E '\\|\\s*200\\s*\\|' /tmp/ss.out | head -1" \
  | expect_grep "Structured Streaming contou status 200" '200'
