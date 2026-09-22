#!/usr/bin/env bash
# Pré-baixa os pacotes usados com `spark-submit --packages ...` nos roteiros, para que funcionem
# offline e sem espera. Cache Ivy fica em /home/maria_dev/.ivy2 (e copiado para root).
set -euo pipefail
export JAVA_HOME="$(cat /etc/java_home)"
export PATH="$JAVA_HOME/bin:$PATH"

run_spark() { # run_spark <spark-home> <packages> — roda SparkPi com --packages só para popular ~/.ivy2
  local jar; jar=$(ls "$1"/examples/jars/spark-examples_*.jar 2>/dev/null | head -1)
  su - maria_dev -c "$1/bin/spark-submit --master local[1] --conf spark.hadoop.fs.defaultFS=file:/// --packages $2 --class org.apache.spark.examples.SparkPi $jar 1 < /dev/null" > /tmp/ivy.log 2>&1     || { echo "aviso: falha ao pré-baixar $2"; grep -iE 'unresolved|not found|error' /tmp/ivy.log | head -5; }
}

SPARK2=/usr/odp/current/spark2-client
SPARK3=/usr/odp/current/spark3-client

# Spark 2.4.8 do ODP é compilado com Scala 2.12 (o do HDP era 2.11): pacotes _2.12
run_spark "$SPARK2" "org.apache.spark:spark-streaming-flume_2.12:2.4.8"
run_spark "$SPARK2" "org.mongodb.spark:mongo-spark-connector_2.12:2.4.4"
run_spark "$SPARK2" "com.datastax.spark:spark-cassandra-connector_2.12:2.5.2"
# Spark 3.5.1 / Scala 2.12 (versões modernas dos mesmos conectores)
run_spark "$SPARK3" "org.mongodb.spark:mongo-spark-connector_2.12:10.4.1"
run_spark "$SPARK3" "com.datastax.spark:spark-cassandra-connector_2.12:3.5.1"

cp -r /home/maria_dev/.ivy2 /root/.ivy2 2>/dev/null || true
cp -r /home/maria_dev/.ivy2 /home/raj_ops/.ivy2 2>/dev/null && chown -R raj_ops:raj_ops /home/raj_ops/.ivy2 || true
du -sh /home/maria_dev/.ivy2 || true
