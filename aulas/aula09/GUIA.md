# Aula 9 — Flume, Kafka, Storm, Flink e Spark Streaming

Perfis (cada um liga só o necessário):

| Perfil | Comando | Liga |
|---|---|---|
| 9a Flume | `.\lab.cmd aula 9a` | ZK, HDFS |
| 9b Kafka | `.\lab.cmd aula 9b` | ZK, Kafka |
| 9c Storm | `.\lab.cmd aula 9c` e, na sandbox, `lab storm start` | ZK + daemons do Storm |
| 9d Flink | `.\lab.cmd aula 9d` | nada (Flink é standalone) |
| Spark Streaming | ver `aula12/GUIA.md` | — |

Os temas de Hive/HBase/Mongo/Cassandra/Drill/Presto da aula 9 são os mesmos da aula 8 (`aula08/GUIA.md`).

## Flume (9a)

Flume 1.11 instalado em `/usr/hdp/current/flume-server` como no vídeo. As pastas `~/spool` e o `~/checkpoint` já existem.

```bash
cp ~/aulas/aula09/Flume/*.conf ~/
cd /usr/hdp/current/flume-server/
bin/flume-ng agent --conf conf --conf-file ~/example.conf --name a1 -Dflume.root.logger=INFO,console
# 2º terminal:  telnet localhost 44444   (ou: nc localhost 44444)
```
Exemplo spooldir → HDFS (`flumelogs.conf`): crie a pasta `/user/maria_dev/flume` no Files View (ou `hdfs dfs -mkdir /user/maria_dev/flume`) e copie `cp ~/data/access_log_small.txt ~/spool/log.txt`.

## Kafka (9b)

Kafka 3.6 (o HDP tinha 1.0). A porta do broker continua **6667**. O que muda: as ferramentas não aceitam mais `--zookeeper`; use `--bootstrap-server`.

| No vídeo | Na sandbox |
|---|---|
| `kafka-topics.sh --create --zookeeper sandbox.hortonworks.com:2181 ...` | `kafka-topics.sh --create --bootstrap-server localhost:6667 --replication-factor 1 --partitions 1 --topic Teste` |
| `kafka-topics.sh --list --zookeeper ...` | `kafka-topics.sh --list --bootstrap-server localhost:6667` |
| `kafka-console-producer.sh --broker-list sandbox.hortonworks.com:6667 --topic Teste` | igual (`--broker-list` ainda funciona; o novo nome é `--bootstrap-server`) |
| `kafka-console-consumer.sh --bootstrap-server ...:6667 --zookeeper localhost:2181 --topic Teste --from-beginning` | remova `--zookeeper localhost:2181` |
| `./kafka-standalone.sh ...` | `./connect-standalone.sh ~/connect-standalone.properties ~/connect-file-source.properties ~/connect-file-sink.properties` |

Os scripts ficam em `/usr/hdp/current/kafka-broker/bin` e os `.properties` de exemplo em `/usr/hdp/current/kafka-broker/config` (no HDP era `conf`).

## Storm (9c)

Storm 2.8.9 (tarball, fora do Ambari; usa Java 17 internamente — configurado, nada a fazer). Em vez de "Ambari > Storm > Start", rode na sandbox:
```bash
lab storm start          # nimbus + supervisor + UI (http://localhost:8744); aguarde ~30 s
storm jar /usr/hdp/current/storm-client/contrib/storm-starter/storm-starter-topologies-*.jar org.apache.storm.starter.WordCountTopology wordcount
storm list
storm kill wordcount
lab storm stop
```
O código-fonte do exemplo está em `/usr/hdp/current/storm-client/examples/storm-starter/src/jvm/org/apache/storm/starter/WordCountTopology.java` (`contrib` é um atalho para `examples`). Logs em `/var/log/storm/workers-artifacts`.

## Flink (9d)

Flink 1.20 já baixado em `~/downloads` (o 1.10 do vídeo não roda no Java atual). Dois comandos mudaram de nome:

```bash
cd ~ && tar -xzf downloads/flink-1.20.5-bin-scala_2.12.tgz && cd flink-1.20.5
sed -i 's/^rest.port: .*/rest.port: 8082/; s/^#*rest.port.*/rest.port: 8082/' conf/config.yaml   # no vídeo: jobmanager.web.port no flink-conf.yaml
grep -q '^rest.port' conf/config.yaml || echo 'rest.port: 8082' >> conf/config.yaml
./bin/start-cluster.sh                      # no vídeo: start-local.sh
./bin/flink run examples/streaming/SocketWindowWordCount.jar --port 9000
# outro terminal:  nc -l 9000   e digite palavras
tail -f log/flink-*-taskexecutor-*.out       # no vídeo: log/flink-maria_dev-jobmanager-0-*.out
./bin/stop-cluster.sh
```
UI: `http://localhost:8082`.
