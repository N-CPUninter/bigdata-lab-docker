# Aula 12 — Spark Streaming (Flume → Spark) e Structured Streaming

**Preparar:** `.\lab.cmd aula 12` — liga ZooKeeper e HDFS (o `spark.readStream.text("logs")` do Structured Streaming resolve para `/user/maria_dev/logs` no HDFS, como no vídeo; Flume e Spark rodam localmente).

Este exercício exige **Spark 2** (`spark-streaming-flume` não existe no Spark 3). A sandbox mantém o Spark 2.4.8 justamente para isso.

## Flume → Spark Streaming (DStream)

Três terminais (shell web `localhost:4200` abre quantos quiser; ou `ssh -p 2222 maria_dev@localhost`):

```bash
# terminal 1 — Spark
cd ~/aulas/aula12/SparkStreaming
export SPARK_MAJOR_VERSION=2
spark-submit --packages org.apache.spark:spark-streaming-flume_2.12:2.4.8 SparkFlume.py
```
```bash
# terminal 2 — Flume com sink Avro na porta 9092 (a mesma do vídeo)
cp ~/aulas/aula12/SparkStreaming/sparkstreamingflume.conf ~/
cd /usr/hdp/current/flume-server/
bin/flume-ng agent --conf conf --conf-file ~/sparkstreamingflume.conf --name a1
```
```bash
# terminal 3 — alimentar o spool
cp ~/data/access_log.txt ~/spool/log.txt
cp ~/data/access_log.txt ~/spool/log2.txt      # a contagem dobra
```

Diferença do vídeo: `--packages ...spark-streaming-flume_2.11:2.0.0` virou `..._2.12:2.4.8` (o Spark 2 do ODP usa Scala 2.12) (mesma versão do Spark instalado; já está em cache, não baixa nada). `SparkFlume2.py` (contagem por status HTTP) roda do mesmo jeito.

## Structured Streaming

```bash
cd ~/aulas/aula12/SparkStreaming
hdfs dfs -mkdir -p logs
spark-submit structured-streaming.py            # Spark 3 ou 2, tanto faz
# em outro terminal: hdfs dfs -put ~/data/access_log.txt logs/   (ou pelo Files View)
```

## MLlib (05-MLLib)

Igual à aula 10: `cd ~/aulas/aula12/05-MLLib && spark-submit movie-recommendations-als.py 50`.
