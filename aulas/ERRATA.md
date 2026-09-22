# Errata — o que muda em relação aos vídeos (HDP 2.6.5)

Resumo das diferenças entre a VM HDP 2.6.5 dos vídeos e esta sandbox (Ambari 2.7.11 + ODP 1.2.4). Detalhes por aula nos `GUIA.md` de cada pasta.

## Versões

| Componente | HDP 2.6.5 (vídeo) | Sandbox |
|---|---|---|
| Ambari | 2.6.2 | 2.7.11 (Clemlab) — sem Hive View/Tez View; com Files View e Workflow Manager (Oozie). O Pig View existe mas depende do WebHCat, que o stack ODP não tem → Pig pelo terminal |
| Hadoop (HDFS/YARN/MR) | 2.7.3 | 3.3.6 |
| Hive | 1.2 / 2.1 | 3.1.3 (`hive` abre o beeline) |
| Tez | 0.7 | 0.10.2 |
| Pig | 0.16 | 0.18 (tarball; terminal `pig`, sem Pig View) |
| Sqoop | 1.4.6 | 1.4.7 |
| Oozie | 4.2 | 5.2.1 |
| HBase / Phoenix | 1.1 / 4.7 | 2.5.6 / 5.1.3 — **Phoenix não conecta** (incompatibilidade do pacote ODP; ver `aula08/GUIA.md`) |
| Kafka | 1.0 | 3.6.2 (sem `--zookeeper`; porta 6667 mantida) |
| Spark | 2.3 (`SPARK_MAJOR_VERSION=2`, Scala 2.11, master yarn) | 2.4.8 **e** 3.5.1 (`SPARK_MAJOR_VERSION=2|3`), ambos Scala 2.12, `spark.master=local[*]` por padrão |
| Python | 2.7 | 3.9 (Spark 3, mrjob) e 3.7 (Spark 2) |
| Zeppelin | 0.7 | 0.11 |
| Flume | 1.5 | 1.11 (tarball) |
| Storm | 1.1 (serviço Ambari) | 2.8.9 (tarball; `lab storm start`; roda em Java 17 internamente; `storm-starter-topologies-2.8.9.jar` = jar do Maven, pois o tarball só traz o fonte) |
| Flink | 1.10 (wget) | 1.20 (tarball em `~/downloads`) |
| Drill | 1.12 (wget) | 1.21.2 (tarball em `~/downloads`) |
| Presto | 0.235.1 (wget) | 0.235.1 (tarball em `~/downloads`, heap 1,5 GB) |
| MongoDB | 3.2 (serviço Ambari) | 4.4 (container `mongo`, `docker compose exec mongo mongo`) |
| Cassandra | 3.0 (yum dsc30) | 3.11 (container `cassandra`, `docker compose exec cassandra cqlsh`) |
| MySQL | MySQL 5 (root sem senha) | MariaDB 10 (`root`/`hadoop`) |
| SO | CentOS 7 | Rocky Linux 9 (`dnf` em vez de `yum`; `yum` continua existindo como atalho) |

## Comandos que mudaram

| Onde | Antes | Agora |
|---|---|---|
| Kafka | `--zookeeper host:2181` | `--bootstrap-server localhost:6667` |
| Kafka Connect | `kafka-standalone.sh` (erro no material) | `connect-standalone.sh` |
| Flink | `start-local.sh`; `jobmanager.web.port` | `start-cluster.sh`; `rest.port` em `conf/config.yaml` |
| Phoenix | `python sqlline.py` | indisponível nesta versão (limitação do ODP 1.2.4); conteúdo coberto por HBase shell/Pig/Spark |
| Sqoop | sem `--username/--password` | `--username root --password hadoop` |
| Spark + Mongo | `--packages org.mongodb.spark:mongo-spark-connector_2.11:2.0.0` | `..._2.12:2.4.4` (Spark 2) ou `..._2.12:10.4.1` (Spark 3) |
| Spark + Cassandra | `--packages datastax:spark-cassandra-connector:2.0.0-M2-s_2.11` | `com.datastax.spark:spark-cassandra-connector_2.12:2.5.2` (Spark 2) ou `..._2.12:3.5.1` (Spark 3) |
| Spark + Flume | `--packages org.apache.spark:spark-streaming-flume_2.11:2.0.0` | `..._2.12:2.4.8` (só Spark 2) |
| Hive View "Upload Table" | UI | tabelas já criadas por `lab aula 8a` (ou beeline/Zeppelin) |
| Ambari > Storm/MongoDB > Start | serviço Ambari | `lab storm start` / `docker compose --profile nosql up -d` |
| Shell web | shell-in-a-box `:4200` | ttyd `:4200` (mesma porta, mesmo login) |
| Portas HDFS | NameNode UI `50070` | `50070` dentro da sandbox; no seu navegador `http://localhost:9870` (Windows reserva 50000–50959) |

## Erros de digitação corrigidos nos arquivos de `aulas/`

- Pig: `ORDER ... BY numRatings AS numRatings DESC` → `ORDER ... BY numRatings DESC`; `videoRealese` → `videoRelease`; `numRatigs` → `numRatings`.
- Phoenix: `PRIMARY_KEY (state,city)` → `PRIMARY KEY (estado, cidade)`, parêntese e `;` faltando, `CONTRAINT` → `CONSTRAINT`.
- Presto: `connector.name=cassadra` → `cassandra`; `bin/laucher` → `launcher`; `limited 10` → `limit 10`; `where ratings = 5` → `where rating = 5`.
- Sqoop: `--driver .com.mysql.jdbc.Driver` → `--driver com.mysql.jdbc.Driver`.
- Cassandra: `{'class'; 'SimpleStrategy'` → `{'class': 'SimpleStrategy'`.
- Aula 10: `04-SparkSQL` lê `customer-order.csv` (arquivo renomeado, como na aula 11).
- `job.properties` do Oozie: espaço sobrando no fim de `queueName=default`.
