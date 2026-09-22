#!/usr/bin/env bash
# Python para os roteiros:
#   - Python 3.9 do sistema: Spark 3 (PySpark 3.5), mrjob 0.7.4, pymongo, cassandra-driver, pandas
#   - Python 3.7 compilado: exigido pelo PySpark 2.4.8 (Spark2), usado quando SPARK_MAJOR_VERSION=2
set -euo pipefail
PY37_VERSION="${PY37_VERSION:-3.7.17}"

# --- bibliotecas no Python 3.9 (global, para todos os usuários) ---
python3 -m pip install --no-cache-dir --upgrade pip
python3 -m pip install --no-cache-dir \
  "mrjob==0.7.4" "PyYAML>=5.3" pathlib2 \
  pymongo "cassandra-driver" \
  pandas numpy \
  "jupyterlab<5" ipykernel

# --- Python 3.7 para Spark 2.4.8 ---
dnf -y install bzip2-devel libffi-devel zlib-devel xz-devel sqlite-devel readline-devel && dnf clean all
cd /opt/src
if [ -s "/build/downloads/Python-${PY37_VERSION}.tgz" ]; then cp "/build/downloads/Python-${PY37_VERSION}.tgz" py37.tgz; else curl -fSL --retry 3 -o py37.tgz "https://www.python.org/ftp/python/${PY37_VERSION}/Python-${PY37_VERSION}.tgz"; fi
tar -xzf py37.tgz && cd "Python-${PY37_VERSION}"
./configure --prefix=/opt/python3.7 --enable-optimizations --with-ensurepip=install >/dev/null
make -j"$(nproc)" >/dev/null && make install >/dev/null
cd /opt/src && rm -rf "Python-${PY37_VERSION}" py37.tgz
/opt/python3.7/bin/python3.7 -m pip install --no-cache-dir --upgrade pip
/opt/python3.7/bin/python3.7 -m pip install --no-cache-dir numpy pymongo cassandra-driver

# --- Spark 3 como cliente puro (fora do Ambari: SPARK2 e SPARK3 conflitam nas configs livy2-*) ---
SPARK3_HOME=/usr/odp/current/spark3-client
mkdir -p /etc/spark3/conf
[ -e /etc/spark3/conf/conf ] && rm -rf /etc/spark3/conf/conf
cat > /etc/spark3/conf/spark-defaults.conf <<'EOF'
spark.master                     local[*]
spark.driver.memory              1g
spark.executor.memory            1g
spark.sql.warehouse.dir          /user/hive/warehouse
spark.ui.showConsoleProgress     false
spark.eventLog.enabled           false
EOF
cat > /etc/spark3/conf/spark-env.sh <<EOF
export JAVA_HOME=$(cat /etc/java_home)
export HADOOP_CONF_DIR=/etc/hadoop/conf
export SPARK_DIST_CLASSPATH=\$(/usr/odp/current/hadoop-client/bin/hadoop classpath 2>/dev/null)
EOF
cp "$SPARK3_HOME/conf/log4j2.properties.template" /etc/spark3/conf/log4j2.properties 2>/dev/null || true
sed -i 's/^rootLogger.level = .*/rootLogger.level = warn/' /etc/spark3/conf/log4j2.properties 2>/dev/null || true
ln -sfn /etc/hive/conf/hive-site.xml /etc/spark3/conf/hive-site.xml 2>/dev/null || true
[ -L "$SPARK3_HOME/conf" ] || { rm -rf "$SPARK3_HOME/conf"; ln -s /etc/spark3/conf "$SPARK3_HOME/conf"; }

# --- seleção de Spark e Python conforme SPARK_MAJOR_VERSION (igual ao fluxo do HDP) ---
cat > /etc/profile.d/spark-python.sh <<'EOF'
# SPARK_MAJOR_VERSION=2 -> Spark 2.4.8 (Python 3.7); qualquer outro valor -> Spark 3.5.1 (Python 3.9)
export SPARK_MAJOR_VERSION="${SPARK_MAJOR_VERSION:-3}"
if [ "$SPARK_MAJOR_VERSION" = "2" ]; then
  export SPARK_HOME=/usr/odp/current/spark2-client
  export PYSPARK_PYTHON=/opt/python3.7/bin/python3.7
  export PYSPARK_DRIVER_PYTHON=/opt/python3.7/bin/python3.7
else
  export SPARK_HOME=/usr/odp/current/spark3-client
  export PYSPARK_PYTHON=/usr/bin/python3
  export PYSPARK_DRIVER_PYTHON=/usr/bin/python3
fi
# (sem prepend de $SPARK_HOME/bin no PATH: os wrappers /usr/bin/spark-* escolhem a versao a cada chamada)
export HADOOP_CONF_DIR=/etc/hadoop/conf
EOF
# /usr/bin/spark-* passam a respeitar SPARK_HOME. Atenção: no ODP eles são symlinks para os scripts
# reais do spark3 — remover o link antes de escrever, senão o script original é sobrescrito.
for b in spark-submit spark-shell pyspark spark-sql; do
  rm -f /usr/bin/$b
  cat > /usr/bin/$b <<EOF
#!/usr/bin/env bash
# wrapper da sandbox: escolhe o Spark pelo SPARK_MAJOR_VERSION (2 ou 3)
[ -f /etc/profile.d/spark-python.sh ] && . /etc/profile.d/spark-python.sh
exec "\$SPARK_HOME/bin/$b" "\$@"
EOF
  chmod +x /usr/bin/$b
done

# atalhos: python -> python3 (roteiros chamam "python sqlline.py", "python MapReduce_exercise.py")
alternatives --install /usr/bin/python python /usr/bin/python3 1 || ln -sf /usr/bin/python3 /usr/bin/python
