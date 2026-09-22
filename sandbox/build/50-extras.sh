#!/usr/bin/env bash
# Ferramentas que o ODP não traz, instaladas no mesmo layout do HDP (/usr/odp/current/<x>),
# com /usr/hdp -> /usr/odp para os roteiros que usam /usr/hdp/current/...
#   Pig 0.18.0  (Hadoop 3, Tez 0.10, Python 3)  — Aulas 7 e 8 (Pig View usa este binário via WebHCat)
#   Flume 1.11.0                                 — Aulas 9, 10 e 12
#   Storm 2.8.x (com examples/storm-starter)     — Aulas 9 e 10
set -euo pipefail
PIG_VERSION="${PIG_VERSION:-0.18.0}"
FLUME_VERSION="${FLUME_VERSION:-1.11.0}"
STORM_VERSION="${STORM_VERSION:-2.8.9}"
ODP_ROOT=/usr/odp/current
mkdir -p /opt/src && cd /opt/src

fetch() { # fetch URL DEST — usa cópia local de /build/downloads se existir; senão baixa (sem honrar Retry-After de 1 dia)
  local f="/build/downloads/$(basename "$1")"
  if [ -s "$f" ]; then cp "$f" "$2"; return 0; fi
  for i in 1 2 3 4 5; do
    curl -fSL --retry 0 -o "$2" "$1" && return 0
    echo "download falhou ($1), tentativa $i"; sleep 20
  done
  return 1
}

# --- Pig ---
fetch "https://dlcdn.apache.org/pig/pig-${PIG_VERSION}/pig-${PIG_VERSION}.tar.gz" pig.tgz
mkdir -p "$ODP_ROOT/pig-client" && tar -xzf pig.tgz -C "$ODP_ROOT/pig-client" --strip-components=1 && rm pig.tgz
cat > /etc/profile.d/pig.sh <<EOF
export PIG_HOME=$ODP_ROOT/pig-client
export HADOOP_HOME=$ODP_ROOT/hadoop-client
export HADOOP_CONF_DIR=/etc/hadoop/conf
export TEZ_HOME=$ODP_ROOT/tez-client
export TEZ_CONF_DIR=/etc/tez/conf
# /etc/hbase/conf: HBaseStorage precisa achar o znode /hbase-unsecure (hbase-site.xml)
export PIG_CLASSPATH=/etc/hadoop/conf:/etc/tez/conf:/etc/hbase/conf:$ODP_ROOT/tez-client/*:$ODP_ROOT/tez-client/lib/*:$ODP_ROOT/hbase-client/lib/*
export PATH=\$PATH:\$PIG_HOME/bin
EOF
ln -sf "$ODP_ROOT/pig-client/bin/pig" /usr/bin/pig

# --- Flume ---
fetch "https://dlcdn.apache.org/flume/${FLUME_VERSION}/apache-flume-${FLUME_VERSION}-bin.tar.gz" flume.tgz
mkdir -p "$ODP_ROOT/flume-server" && tar -xzf flume.tgz -C "$ODP_ROOT/flume-server" --strip-components=1 && rm flume.tgz
# o sink HDFS do Flume precisa das libs do Hadoop no classpath
cat > "$ODP_ROOT/flume-server/conf/flume-env.sh" <<EOF
export JAVA_HOME=$(cat /etc/java_home)
export JAVA_OPTS="-Xmx256m"
export HADOOP_HOME=$ODP_ROOT/hadoop-client
export FLUME_CLASSPATH=/etc/hadoop/conf:$ODP_ROOT/hadoop-client/*:$ODP_ROOT/hadoop-client/lib/*:$ODP_ROOT/hadoop-hdfs-client/*:$ODP_ROOT/hadoop-hdfs-client/lib/*
EOF
# guava antiga do Flume conflita com Hadoop 3
rm -f "$ODP_ROOT/flume-server/lib/guava-11"*.jar
# wrapper (nao symlink): o flume-ng deriva FLUME_HOME do caminho pelo qual foi chamado
printf '#!/usr/bin/env bash
exec %s/flume-server/bin/flume-ng "$@"
' "$ODP_ROOT" > /usr/bin/flume-ng && chmod +x /usr/bin/flume-ng
echo "export FLUME_HOME=$ODP_ROOT/flume-server" > /etc/profile.d/flume.sh
chmod -R a+rX "$ODP_ROOT/flume-server"

# --- Storm ---
fetch "https://archive.apache.org/dist/storm/apache-storm-${STORM_VERSION}/apache-storm-${STORM_VERSION}.tar.gz" storm.tgz
mkdir -p "$ODP_ROOT/storm-client" && tar -xzf storm.tgz -C "$ODP_ROOT/storm-client" --strip-components=1 && rm storm.tgz
cat > "$ODP_ROOT/storm-client/conf/storm.yaml" <<'EOF'
storm.zookeeper.servers: ["localhost"]
nimbus.seeds: ["localhost"]
storm.local.dir: "/hadoop/storm"
ui.port: 8744
supervisor.slots.ports: [6700, 6701]
nimbus.childopts: "-Xmx256m"
ui.childopts: "-Xmx256m"
supervisor.childopts: "-Xmx256m"
worker.childopts: "-Xmx256m"
storm.log.dir: "/var/log/storm"
storm.metricstore.class: "org.apache.storm.metricstore.NoOpMetricStore"
EOF
mkdir -p /var/log/storm /hadoop/storm && chmod 777 /var/log/storm /hadoop/storm
# Storm 2.8 exige Java 17 (o resto do stack usa Java 8): JAVA_HOME so para o Storm
dnf -y install java-17-openjdk-headless && dnf clean all
J17=$(ls -d /usr/lib/jvm/java-17-openjdk-17* | head -1)
printf 'export JAVA_HOME=%s
export PATH=%s/bin:$PATH
' "$J17" "$J17" > "$ODP_ROOT/storm-client/conf/storm-env.sh"
# roteiro: cd /usr/hdp/current/storm-client/contrib/storm-starter/... e storm jar .../storm-starter-topologies-*.jar
ln -sfn "$ODP_ROOT/storm-client/examples" "$ODP_ROOT/storm-client/contrib"
# a distribuicao binaria do Storm 2.x traz o storm-starter so em fonte: usar o jar do Maven com o nome do HDP
fetch "https://maven-central.storage-download.googleapis.com/maven2/org/apache/storm/storm-starter/${STORM_VERSION}/storm-starter-${STORM_VERSION}.jar"   "$ODP_ROOT/storm-client/examples/storm-starter/storm-starter-topologies-${STORM_VERSION}.jar"
ln -sf "$ODP_ROOT/storm-client/bin/storm" /usr/bin/storm
echo "export PATH=\$PATH:$ODP_ROOT/storm-client/bin" > /etc/profile.d/storm.sh

# --- Phoenix: o phoenix_utils.py do pacote ODP e uma copia quebrada do sqlline.py; usar o upstream 5.1.3 ---
for d in /usr/odp/*/phoenix/bin; do cp /build/phoenix_utils.py "$d/phoenix_utils.py"; done
# o sqlline (shell SQL do Phoenix) tambem nao vem no pacote ODP
fetch "https://maven-central.storage-download.googleapis.com/maven2/sqlline/sqlline/1.9.0/sqlline-1.9.0-jar-with-dependencies.jar" /tmp/sqlline.jar
for d in /usr/odp/*/phoenix/lib; do cp /tmp/sqlline.jar "$d/sqlline-1.9.0-jar-with-dependencies.jar"; done; rm -f /tmp/sqlline.jar
# o phoenix_utils procura o client jar "embedded" na raiz do pacote (bin/..), o ODP o poe em lib/
for d in /usr/odp/*/phoenix; do for j in "$d"/lib/phoenix-client-embedded-hbase-*.jar; do ln -sf "$j" "$d/$(basename "$j")"; done; done
# log4j 1.x (reload4j) e slf4j backend: o phoenix_utils procura por nome em lib/ e o client "embedded" nao os inclui
for d in /usr/odp/*/phoenix/lib; do cp /usr/odp/current/hadoop-client/lib/reload4j-*.jar /usr/odp/current/hadoop-client/lib/slf4j-reload4j-*.jar "$d/"; done

# --- /usr/hdp -> /usr/odp (roteiros usam /usr/hdp/current/...) ---
ln -sfn /usr/odp /usr/hdp

# --- diretórios que os roteiros esperam no home da maria_dev ---
su - maria_dev -c "mkdir -p ~/spool ~/checkpoint ~/logs"
