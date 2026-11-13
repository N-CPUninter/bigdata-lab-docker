# Aula 8 — Hive, Sqoop, MapReduce (mrjob), HBase/Phoenix, Drill, Presto, MongoDB e Cassandra

A aula 8 usa muitos serviços; em 8 GB não cabem todos ao mesmo tempo. Ela foi dividida em quatro perfis:

| Perfil | Comando | O que liga | Temas |
|---|---|---|---|
| 8a | `.\lab.cmd aula 8a` | ZK, HDFS, YARN, MapReduce2, Hive | Hive, Sqoop + MariaDB, mrjob, Pig/Oozie (iguais à aula 7) |
| 8b | `.\lab.cmd aula 8b` | ZK, HDFS, YARN, MapReduce2, HBase (+ Phoenix Query Server) | HBase, Phoenix, Pig com HBaseStorage |
| 8c | `.\lab.cmd nosql` e `.\lab.cmd aula 8c` | ZK, HDFS + containers Mongo e Cassandra | MongoDB, Cassandra, Spark 2 |
| 8d | `.\lab.cmd nosql` e `.\lab.cmd aula 8d` | ZK, HDFS, Hive (metastore) + Mongo/Cassandra | Drill, Presto |

## 8a — Hive

O HDP tinha o **Hive View** com "Upload Table"; o Ambari 2.7 não tem mais. As tabelas `ratings` e `names` são criadas automaticamente pelo `lab aula 8a` (DDL em `sandbox/runtime/hive-seed.sql`, mesmo layout do vídeo). Para consultar:

```bash
beeline -u jdbc:hive2://localhost:10000 -n maria_dev          # cliente SQL do Hive (o comando "hive" também abre o beeline)
```
```sql
SHOW TABLES;
SELECT * FROM ratings LIMIT 5;
!run /home/maria_dev/aulas/aula08/Hive_example/MostPopularMovie.sql
```
Alternativa com interface web: **Zeppelin** (`http://localhost:9995`, ligue com `lab start ZEPPELIN`; ~1 GB de RAM) usando o interpretador `%jdbc(hive)`.

## 8a — Sqoop e MariaDB

O MySQL do HDP virou MariaDB; usuário `root`, senha `hadoop` (igual). O banco `movielens` já está carregado (as tabelas `occupations, users, ratings, movies, genres, genres_movies`). Para carregar de novo: `mysql -u root -phadoop movielens < ~/data/movielens.sql`.

```bash
sqoop import --connect jdbc:mysql://localhost/movielens --driver com.mysql.jdbc.Driver --username root --password hadoop --table movies -m 1
sqoop import --connect jdbc:mysql://localhost/movielens --driver com.mysql.jdbc.Driver --username root --password hadoop --table movies -m 1 --hive-import
sqoop export --connect jdbc:mysql://localhost/movielens --driver com.mysql.jdbc.Driver --username root --password hadoop --table exported_movies --export-dir /user/maria_dev/movies --input-fields-terminated-by ','
```
O acesso anônimo ao banco `movielens` (como no MySQL do HDP) está liberado, então os comandos do vídeo **sem** `--username/--password` também funcionam. O material tinha o erro de digitação `.com.mysql.jdbc.Driver` (ponto a mais).

## 8a — MapReduce com mrjob

`mrjob 0.7.4` já está instalado no Python 3 (o HDP usava Python 2.7 e mrjob 0.5.11; o código é o mesmo).

```bash
cd ~/aulas/aula08
python MapReduce_exercise.py ~/data/ml-100k/u.data                                  # local
python MapReduce_exercise.py -r hadoop --hadoop-streaming-jar /usr/odp/current/hadoop-mapreduce-client/hadoop-streaming.jar hdfs:///user/maria_dev/ml-100k/u.data
```

## 8b — HBase e Phoenix

```bash
hbase shell
  create 'users', 'userinfo'
  list
  exit
cd ~/aulas/aula08/HBase_example && pig hbase.pig          # Pig com HBaseStorage
hbase shell
  scan 'users', {LIMIT => 5}
```
**Phoenix — limitação conhecida:** o Phoenix 5.1.3 empacotado no ODP 1.2.4 não é compatível com o HBase 2.5.6 do mesmo ODP (erro `NoSuchMethodError ... protobuf ... internalBuildGeneratedFileFrom` ao conectar; corrigido só no Phoenix 5.1.4/5.2). O `sqlline.py` e o Query Server (porta 8765) estão instalados, mas a conexão falha. Enquanto não houver um client jar compatível, cubra o conteúdo de Phoenix com a leitura do `Phoenix.txt` (DDL corrigido nesta pasta) e pratique o acesso ao HBase pelo `hbase shell`, pelo Pig (`hbase.pig`) e pelo Spark. Se quiser tentar: `cd /usr/hdp/current/phoenix-client/bin && python sqlline.py localhost:2181:/hbase-unsecure`.

## 8c — MongoDB e Cassandra

No HDP o Mongo era instalado como serviço do Ambari (`mongo-ambari`, repo morto) e o Cassandra via `yum install dsc30` (repo morto). Aqui são dois containers oficiais que compartilham a rede da sandbox: continuam respondendo em `127.0.0.1`, então `MongoSpark.py` e `CassandraSpark.py` rodam **sem alteração**.

```powershell
.\lab.cmd nosql        # sobe mongo:4.4 e cassandra:3.11 (no host)
```
Dentro da sandbox:
```bash
export SPARK_MAJOR_VERSION=2
cd ~/aulas/aula08/MongoDB
spark-submit --packages org.mongodb.spark:mongo-spark-connector_2.12:2.4.4 MongoSpark.py
cd ~/aulas/aula08/Cassandra
spark-submit --packages com.datastax.spark:spark-cassandra-connector_2.12:2.5.2 CassandraSpark.py
```
Pacotes `--packages` diferem do vídeo (`2.0.0` e `datastax:...:2.0.0-M2-s_2.11` não existem mais para Spark 2.4; o Spark 2 do ODP usa Scala 2.12) e já estão em cache na imagem. No `CassandraSpark.py` aparece um erro `NoClassDefFoundError: jnr/posix/POSIXHandler` no log: é do relógio nativo opcional do driver e não impede a gravação (confira com `SELECT COUNT(*) FROM movielens.users`).

Shells (rodam **no seu computador**, não dentro da sandbox):
```powershell
docker compose exec mongo mongo                    # shell do Mongo (comandos do runningMongoDBSparkpy.txt)
docker compose exec cassandra cqlsh                # cqlsh (CQL 3.4.x). Crie o keyspace/tabela do installing.txt antes do CassandraSpark.py
```

## 8d — Drill e Presto

Tarballs já baixados em `~/downloads` (não precisa de `wget`). Versões: Drill 1.21.2 (a 1.12 não fala com o metastore do Hive 3) e Presto 0.235.1 (igual ao vídeo).

```bash
cd ~ && tar -xzf downloads/apache-drill-1.21.2.tar.gz && cd apache-drill-1.21.2
bin/drillbit.sh start -Ddrill.exec.port=8756        # UI: http://localhost:8756  (Storage > hive > Update: "hive.metastore.uris": "thrift://localhost:9083")
bin/drillbit.sh stop
```
```bash
cd ~ && tar -xzf downloads/presto-server-0.235.1.tar.gz && cd presto-server-0.235.1
cp -r ~/downloads/presto-etc/etc .                  # config da aula, com heap 1,5 GB em vez de 16 GB
cp ~/downloads/presto-cli-0.235.1-executable.jar bin/presto && chmod +x bin/presto
bin/launcher start                                  # UI: http://localhost:8090
bin/presto --server 127.0.0.1:8090 --catalog hive   # show tables from default;
bin/launcher stop
```
O `cassandra.properties` já vem em `etc/catalog` (o original tinha `connector.name=cassadra`).
