#!/usr/bin/env bash
# Pré-baixa no host os tarballs usados no build (Pig, Flume, Storm, Drill, Presto, Flink, Python 3.7)
# para sandbox/build/downloads/. O Dockerfile copia a pasta e os scripts usam a cópia local se existir.
set -uo pipefail
mkdir -p "$(dirname "$0")/downloads"
cd "$(dirname "$0")/downloads"
urls=(
  https://dlcdn.apache.org/pig/pig-0.18.0/pig-0.18.0.tar.gz
  https://dlcdn.apache.org/flume/1.11.0/apache-flume-1.11.0-bin.tar.gz
  https://archive.apache.org/dist/storm/apache-storm-2.8.9/apache-storm-2.8.9.tar.gz
  https://dlcdn.apache.org/drill/1.21.2/apache-drill-1.21.2.tar.gz
  https://maven-central.storage-download.googleapis.com/maven2/com/facebook/presto/presto-server/0.235.1/presto-server-0.235.1.tar.gz
  https://maven-central.storage-download.googleapis.com/maven2/com/facebook/presto/presto-cli/0.235.1/presto-cli-0.235.1-executable.jar
  https://dlcdn.apache.org/flink/flink-1.20.5/flink-1.20.5-bin-scala_2.12.tgz
  https://www.python.org/ftp/python/3.7.17/Python-3.7.17.tgz
  https://maven-central.storage-download.googleapis.com/maven2/sqlline/sqlline/1.9.0/sqlline-1.9.0-jar-with-dependencies.jar
  https://maven-central.storage-download.googleapis.com/maven2/org/apache/storm/storm-starter/2.8.9/storm-starter-2.8.9.jar
)
for u in "${urls[@]}"; do
  f="$(basename "$u")"
  [ -s "$f" ] && { echo "ok (já existe): $f"; continue; }
  echo "baixando $f"; curl -fSL --retry 0 -o "$f.part" "$u" && mv "$f.part" "$f" || { echo "FALHOU: $u"; rm -f "$f.part"; }
done
ls -la
