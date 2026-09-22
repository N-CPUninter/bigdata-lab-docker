#!/usr/bin/env bash
# Tarballs que os roteiros mandam o aluno baixar com wget (Drill, Presto, Flink).
# Ficam pré-baixados em /home/maria_dev/downloads para funcionar sem internet e sem esperar.
# O roteiro original usa Drill 1.12 e Flink 1.10; aqui vão versões que funcionam com Hadoop 3 / Hive 3.
set -euo pipefail
DRILL_VERSION="${DRILL_VERSION:-1.21.2}"
PRESTO_VERSION="${PRESTO_VERSION:-0.235.1}"
FLINK_VERSION="${FLINK_VERSION:-1.20.5}"
D=/home/maria_dev/downloads
mkdir -p "$D"
fetch() { # fetch URL DEST — usa cópia local de /build/downloads se existir; senão baixa (sem honrar Retry-After de 1 dia)
  local f="/build/downloads/$(basename "$1")"
  if [ -s "$f" ]; then cp "$f" "$2"; return 0; fi
  for i in 1 2 3 4 5; do
    curl -fSL --retry 0 -o "$2" "$1" && return 0
    echo "download falhou ($1), tentativa $i"; sleep 20
  done
  return 1
}

fetch "https://dlcdn.apache.org/drill/${DRILL_VERSION}/apache-drill-${DRILL_VERSION}.tar.gz" "$D/apache-drill-${DRILL_VERSION}.tar.gz"
fetch "https://maven-central.storage-download.googleapis.com/maven2/com/facebook/presto/presto-server/${PRESTO_VERSION}/presto-server-${PRESTO_VERSION}.tar.gz" "$D/presto-server-${PRESTO_VERSION}.tar.gz"
fetch "https://maven-central.storage-download.googleapis.com/maven2/com/facebook/presto/presto-cli/${PRESTO_VERSION}/presto-cli-${PRESTO_VERSION}-executable.jar" "$D/presto-cli-${PRESTO_VERSION}-executable.jar"
fetch "https://dlcdn.apache.org/flink/flink-${FLINK_VERSION}/flink-${FLINK_VERSION}-bin-scala_2.12.tgz" "$D/flink-${FLINK_VERSION}-bin-scala_2.12.tgz"

# config do Presto usada em aula (presto-hdp-config.tgz do professor), com heap reduzido
cp -r /opt/lab/presto-etc "$D/presto-etc"
chown -R maria_dev:maria_dev "$D"
ls -la "$D"
