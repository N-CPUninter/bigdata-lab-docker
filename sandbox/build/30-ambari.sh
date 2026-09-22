#!/usr/bin/env bash
# Configura PostgreSQL (banco do Ambari), MariaDB (metastore Hive/Oozie + banco movielens do Sqoop),
# ambari-server (banco externo, sem systemd) e ambari-agent (hostname fixo).
set -euo pipefail
JAVA_HOME="$(cat /etc/java_home)"
SANDBOX_FQDN="${SANDBOX_FQDN:-sandbox.hortonworks.com}"

# diretórios de runtime (sem systemd-tmpfiles no container)
mkdir -p /var/run/postgresql /var/run/mariadb && chown postgres:postgres /var/run/postgresql && chown mysql:mysql /var/run/mariadb

# --- PostgreSQL: banco 'ambari', usuário 'ambari', senha 'bigdata' (igual ao guia de reset de senha) ---
su - postgres -c "/usr/bin/initdb -D /var/lib/pgsql/data --auth-local=peer --auth-host=md5 --pwfile=<(echo postgres)" >/dev/null
su - postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data -l /var/lib/pgsql/initdb.log start -w"
su - postgres -c "psql -c \"CREATE USER ambari WITH PASSWORD 'bigdata';\""
su - postgres -c "psql -c \"CREATE DATABASE ambari OWNER ambari;\""
su - postgres -c "psql -d ambari -c \"CREATE SCHEMA ambari AUTHORIZATION ambari; ALTER ROLE ambari SET search_path TO ambari, public;\""
cat > /var/lib/pgsql/data/pg_hba.conf <<'EOH'
local   all   all                 peer
host    all   all   127.0.0.1/32  md5
host    all   all   ::1/128       md5
EOH
su - postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data reload"
PGPASSWORD=bigdata psql -U ambari -h 127.0.0.1 -d ambari -f /var/lib/ambari-server/resources/Ambari-DDL-Postgres-CREATE.sql >/dev/null

# --- MariaDB: hive/oozie metastores + banco movielens (Aula 7/8: Sqoop, Oozie) ---
mysql_install_db --user=mysql --datadir=/var/lib/mysql >/dev/null
(mysqld_safe --user=mysql >/dev/null 2>&1 &)
for i in $(seq 1 30); do mysqladmin ping >/dev/null 2>&1 && break; sleep 1; done
mysql -u root <<'EOSQL'
CREATE DATABASE hive  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE oozie CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE hue   CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'hive'@'%'  IDENTIFIED BY 'hive';   GRANT ALL ON hive.*  TO 'hive'@'%';
CREATE USER 'oozie'@'%' IDENTIFIED BY 'oozie';  GRANT ALL ON oozie.* TO 'oozie'@'%';
CREATE USER 'hue'@'%'   IDENTIFIED BY 'hue';    GRANT ALL ON hue.*   TO 'hue'@'%';
CREATE USER 'hive'@'localhost'  IDENTIFIED BY 'hive';  GRANT ALL ON hive.*  TO 'hive'@'localhost';
CREATE USER 'oozie'@'localhost' IDENTIFIED BY 'oozie'; GRANT ALL ON oozie.* TO 'oozie'@'localhost';
CREATE USER 'hue'@'localhost'   IDENTIFIED BY 'hue';   GRANT ALL ON hue.*   TO 'hue'@'localhost';
-- usuário usado nos roteiros (mysql -u root -p ; senha hadoop, igual ao HDP)
ALTER USER 'root'@'localhost' IDENTIFIED BY 'hadoop';
CREATE USER 'root'@'%' IDENTIFIED BY 'hadoop'; GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOSQL

# Driver JDBC MySQL (Sqoop, Hive metastore, Oozie) — Connector/J 8.x, classe com.mysql.cj.jdbc.Driver
MYSQL_CJ_VERSION="${MYSQL_CJ_VERSION:-8.4.0}"
mkdir -p /usr/share/java
curl -fsSL "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_CJ_VERSION}/mysql-connector-j-${MYSQL_CJ_VERSION}.jar" \
  -o /usr/share/java/mysql-connector-j.jar
ln -sf /usr/share/java/mysql-connector-j.jar /usr/share/java/mysql-connector-java.jar

# --- ambari-server: setup silencioso com PostgreSQL externo ---
ambari-server setup -s -j "$JAVA_HOME" \
  --database=postgres --databasehost=localhost --databaseport=5432 \
  --databasename=ambari --postgresschema=ambari \
  --databaseusername=ambari --databasepassword=bigdata
ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar
# menos memória e menos threads: sandbox de um nó
cat >> /etc/ambari-server/conf/ambari.properties <<'EOP'
agent.threadpool.size.max=4
client.threadpool.size.max=8
server.execution.scheduler.maxThreads=2
server.jdbc.connection-pool=internal
EOP
sed -i 's/^export AMBARI_JVM_ARGS=.*/export AMBARI_JVM_ARGS="$AMBARI_JVM_ARGS -Xms256m -Xmx640m -Djava.security.auth.login.config=$ROOT\/etc\/ambari-server\/conf\/krb5JAASLogin.conf -Djava.security.krb5.conf=\/etc\/krb5.conf -Djavax.security.auth.useSubjectCredsOnly=false"/' /var/lib/ambari-server/ambari-env.sh || true

# --- ambari-agent: hostname fixo, independente do hostname real do container ---
cat > /var/lib/ambari-agent/hostname.sh <<EOH
#!/bin/sh
echo ${SANDBOX_FQDN}
EOH
chmod +x /var/lib/ambari-agent/hostname.sh
AGENT_INI=/etc/ambari-agent/conf/ambari-agent.ini
sed -i "s/^hostname=.*/hostname=localhost/" "$AGENT_INI"
sed -i "s|^\[agent\]|[agent]\nhostname_script=/var/lib/ambari-agent/hostname.sh\npublic_hostname_script=/var/lib/ambari-agent/hostname.sh|" "$AGENT_INI"
grep -q '^hostname_script' "$AGENT_INI"

# para: os serviços são iniciados pelo entrypoint em runtime
mysqladmin -u root -phadoop shutdown
su - postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data stop -m fast"
