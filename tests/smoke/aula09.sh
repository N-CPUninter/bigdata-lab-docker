#!/usr/bin/env bash
# Aula 9: Flume (netcat), Kafka (produce/consume), Storm (topologia), Flink (cluster local).
set -uo pipefail; cd "$(dirname "$0")/../.."; source tests/smoke/common.sh

SB "lab aula 9b --quiet" || fail "lab aula 9b"
K=/usr/hdp/current/kafka-broker/bin
SBU "$K/kafka-topics.sh --create --if-not-exists --bootstrap-server localhost:6667 --replication-factor 1 --partitions 1 --topic Teste && $K/kafka-topics.sh --list --bootstrap-server localhost:6667" | expect_grep "Kafka tópico Teste" '^Teste'
SBU "echo 'ola kafka' | $K/kafka-console-producer.sh --bootstrap-server localhost:6667 --topic Teste >/dev/null && timeout 20 $K/kafka-console-consumer.sh --bootstrap-server localhost:6667 --topic Teste --from-beginning --max-messages 1" | expect_grep "Kafka produce/consume" 'ola kafka'

SB "lab aula 9a --quiet" || fail "lab aula 9a"
SBU "cp aulas/aula09/Flume/example.conf ~/ && (timeout 40 flume-ng agent --conf /usr/hdp/current/flume-server/conf --conf-file ~/example.conf --name a1 -Dflume.root.logger=INFO,console > /tmp/flume.out 2>&1 &) ; sleep 20; printf 'evento flume
' | nc -w 2 localhost 44444; sleep 5; grep -c 'evento flume' /tmp/flume.out" | expect_grep "Flume netcat -> logger" '^[1-9]'

SB "lab aula 9c --quiet && lab storm start --quiet" || fail "lab aula 9c"
sleep 40
SBU "storm jar /usr/hdp/current/storm-client/contrib/storm-starter/storm-starter-topologies-*.jar org.apache.storm.starter.WordCountTopology wordcount 2>&1 | tail -2; sleep 15; storm list 2>/dev/null" | expect_grep "Storm topologia wordcount ativa" 'wordcount\s+ACTIVE'
SBU "storm kill wordcount -w 1 >/dev/null 2>&1; lab storm stop --quiet" >/dev/null

SB "lab aula 9d --quiet" >/dev/null
SBU "rm -rf flink-1.20.5 && tar -xzf downloads/flink-1.20.5-bin-scala_2.12.tgz && cd flink-1.20.5 && (grep -q '^rest.port' conf/config.yaml && sed -i 's/^rest.port: .*/rest.port: 8082/' conf/config.yaml || echo 'rest.port: 8082' >> conf/config.yaml) && ./bin/start-cluster.sh >/dev/null && sleep 15 && curl -s http://localhost:8082/overview; ./bin/stop-cluster.sh >/dev/null" | expect_grep "Flink cluster local na 8082" 'taskmanagers'
