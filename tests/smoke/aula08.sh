#!/usr/bin/env bash
# Aula 8: 8a (Hive, Sqoop, mrjob), 8b (HBase/Phoenix), 8c (Mongo/Cassandra + Spark2).
set -uo pipefail; cd "$(dirname "$0")/../.."; source tests/smoke/common.sh

SB "lab aula 8a --quiet" || fail "lab aula 8a"
SBU "beeline -u jdbc:hive2://localhost:10000 -n maria_dev --silent=true -e 'SELECT COUNT(*) FROM ratings'" | expect_grep "Hive ratings = 100000" '100000'
SBU "beeline -u jdbc:hive2://localhost:10000 -n maria_dev --silent=true -e 'DROP VIEW IF EXISTS topMovieIDs' >/dev/null 2>&1; beeline -u jdbc:hive2://localhost:10000 -n maria_dev --silent=true -f aulas/aula08/Hive_example/MostPopularMovie.sql" | expect_grep "Hive filme mais popular" 'Star Wars'
SBU "hdfs dfs -rm -r -f movies; sqoop import --connect jdbc:mysql://localhost/movielens --driver com.mysql.jdbc.Driver --username root --password hadoop --table movies -m 1 2>&1 | tail -3; hdfs dfs -cat movies/part-m-00000 | head -2" | expect_grep "Sqoop import movies" 'Toy Story'
SBU "cd aulas/aula08 && python MapReduce_exercise.py ~/data/ml-100k/u.data 2>/dev/null" | expect_grep "mrjob local" '"5"\s+21201'
SBU "cd aulas/aula08 && python MapReduce_exercise.py -r hadoop --hadoop-streaming-jar /usr/odp/current/hadoop-mapreduce-client/hadoop-streaming.jar hdfs:///user/maria_dev/ml-100k/u.data 2>/dev/null" | expect_grep "mrjob no YARN" '"5"\s+21201'

SB "lab aula 8b --quiet" || fail "lab aula 8b"
SBU "echo \"disable 'users'; drop 'users'\" | hbase shell -n >/dev/null 2>&1; echo \"create 'users','userinfo'\" | hbase shell -n >/dev/null 2>&1; echo \"exists 'users'\" | hbase shell -n 2>/dev/null" | expect_grep "HBase create users" 'does exist'
SBU "cd aulas/aula08/HBase_example && pig hbase.pig >/dev/null 2>&1; echo \"count 'users'\" | hbase shell -n 2>/dev/null" | expect_grep "Pig HBaseStorage 943 usuários" '943'
echo "SKIP: Phoenix sqlline (Phoenix 5.1.3 do ODP 1.2.4 e incompativel com o HBase 2.5.6 - ver aulas/ERRATA.md)"

docker compose --profile nosql up -d mongo cassandra >/dev/null
SB "lab aula 8c --quiet" || fail "lab aula 8c"
for _ in $(seq 1 30); do docker compose exec -T cassandra cqlsh -e 'describe keyspaces' >/dev/null 2>&1 && break; sleep 5; done
docker compose exec -T cassandra cqlsh -e "CREATE KEYSPACE IF NOT EXISTS movielens WITH replication = {'class': 'SimpleStrategy', 'replication_factor':'1'}; USE movielens; CREATE TABLE IF NOT EXISTS users (user_id int, age int, gender text, occupation text, zip text, PRIMARY KEY (user_id));" || fail "cqlsh schema"
docker compose exec -T cassandra cqlsh -e "TRUNCATE movielens.users;" >/dev/null 2>&1   # idempotência: os scripts fazem append
docker compose exec -T mongo mongo --quiet movielens --eval 'db.users.drop()' >/dev/null 2>&1
SBU "export SPARK_MAJOR_VERSION=2; cd aulas/aula08/Cassandra && spark-submit --packages com.datastax.spark:spark-cassandra-connector_2.12:2.5.2 CassandraSpark.py 2>/dev/null" | expect_grep "Spark2 -> Cassandra" 'occupation'
docker compose exec -T cassandra cqlsh -e "SELECT COUNT(*) FROM movielens.users;" | expect_grep "Cassandra 943 usuários" '943'
SBU "export SPARK_MAJOR_VERSION=2; cd aulas/aula08/MongoDB && spark-submit --packages org.mongodb.spark:mongo-spark-connector_2.12:2.4.4 MongoSpark.py 2>/dev/null" | expect_grep "Spark2 -> MongoDB" 'occupation'
docker compose exec -T mongo mongo --quiet movielens --eval 'db.users.count()' | expect_grep "Mongo 943 usuários" '^943'
