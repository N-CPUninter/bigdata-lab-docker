#!/usr/bin/env bash
# Cria o cluster de um nó via blueprint do Ambari (INSTALL_ONLY), formata o NameNode
# iniciando o HDFS uma vez, semeia dados no HDFS/MariaDB, cria usuários do Ambari e para tudo.
# Roda dentro do `docker build` — sem systemd; os serviços são iniciados como processos.
set -euo pipefail
FQDN="${SANDBOX_FQDN:-sandbox.hortonworks.com}"
export JAVA_HOME="$(cat /etc/java_home)"
export PATH="$JAVA_HOME/bin:/usr/local/bin:$PATH"
AMB="http://localhost:8080/api/v1"
CURL=(curl -sS -u admin:admin -H 'X-Requested-By: ambari')

log() { echo "[build:blueprint] $*"; }

# no `docker build` o /etc/hosts é somente-leitura: o nome vem de `--add-host $FQDN:127.0.0.1`
if ! getent hosts "$FQDN" >/dev/null; then
  echo "127.0.0.1 $FQDN sandbox-hdp.hortonworks.com sandbox" >> /etc/hosts 2>/dev/null     || { echo "ERRO: $FQDN não resolve. Rode o build com --add-host $FQDN:127.0.0.1"; exit 1; }
fi

log "iniciando PostgreSQL e MariaDB"
mkdir -p /var/run/postgresql /var/run/mariadb && chown postgres:postgres /var/run/postgresql && chown mysql:mysql /var/run/mariadb
su - postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data status" >/dev/null 2>&1   || su - postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data -l /var/lib/pgsql/pg.log start -w"
mysqladmin ping >/dev/null 2>&1 || (mysqld_safe --user=mysql >/dev/null 2>&1 &)
for _ in $(seq 1 60); do mysqladmin ping >/dev/null 2>&1 && break; sleep 1; done

log "iniciando ambari-server"
ambari-server status >/dev/null 2>&1 || ambari-server start
for _ in $(seq 1 120); do
  code=$("${CURL[@]}" -o /dev/null -w '%{http_code}' "$AMB/clusters" || true)
  [ "$code" = "200" ] && break; sleep 5
done
[ "$code" = "200" ] || { tail -50 /var/log/ambari-server/ambari-server.log; exit 1; }

log "iniciando ambari-agent (host $FQDN)"
ambari-agent status >/dev/null 2>&1 || ambari-agent start
# (não usar `curl | grep -q` com pipefail: o grep fecha o pipe e o curl sai com SIGPIPE)
for _ in $(seq 1 60); do
  out=$("${CURL[@]}" "$AMB/hosts/$FQDN" 2>/dev/null || true)
  grep -q '"host_name"' <<<"$out" && break; sleep 5
done
grep -q '"host_name"' <<<"$out" || { tail -50 /var/log/ambari-agent/ambari-agent.log; exit 1; }

log "registrando versão do stack (VDF ${ODP_BUILD})"
curl -fsSL "https://archive.clemlab.com/centos9/odp-release/${ODP_BUILD}/ODP-VDF.xml" -o /build/ODP-VDF.xml
"${CURL[@]}" -X POST -d '{"VersionDefinition":{"version_url":"file:///build/ODP-VDF.xml"}}' "$AMB/version_definitions" >/dev/null

if [ "$("${CURL[@]}" -o /dev/null -w '%{http_code}' "$AMB/clusters/sandbox")" = "200" ]; then
  log "cluster 'sandbox' já existe — pulando blueprint (re-execução)"
else
  log "enviando blueprint e template de cluster"
  "${CURL[@]}" -X POST -d @/build/blueprint.json "$AMB/blueprints/sandbox?validate_topology=false" | tee /tmp/bp.out
  grep -q '"status"' /tmp/bp.out && { echo "blueprint rejeitado"; exit 1; }
  "${CURL[@]}" -X POST -d @/build/cluster-template.json "$AMB/clusters/sandbox" | tee /tmp/cluster.out
  REQ_URL=$(python3 -c "import json,sys; print(json.load(open('/tmp/cluster.out'))['href'])")

  log "aguardando instalação ($REQ_URL)"
  while :; do
    st=$("${CURL[@]}" "$REQ_URL" | python3 -c "import json,sys; r=json.load(sys.stdin)['Requests']; print(r['request_status'], r.get('progress_percent'))")
    echo "  $st"
    case "$st" in
      COMPLETED*) break ;;
      FAILED*|ABORTED*|TIMEDOUT*)
        "${CURL[@]}" "$REQ_URL/tasks?fields=Tasks/command_detail,Tasks/status,Tasks/stderr,Tasks/stdout&Tasks/status=FAILED" | head -c 20000
        exit 1 ;;
    esac
    sleep 15
  done
fi

# helpers de serviço
svc_current() { "${CURL[@]}" "$AMB/clusters/sandbox/services/$1?fields=ServiceInfo/state" | python3 -c "import json,sys; print(json.load(sys.stdin)['ServiceInfo']['state'])"; }
svc_state() { # svc_state SERVICE STARTED|INSTALLED
  local svc="$1" target="$2" url st
  for attempt in 1 2 3 4 5 6; do
    [ "$(svc_current "$svc")" = "$target" ] && return 0
    "${CURL[@]}" -X PUT -d "{\"RequestInfo\":{\"context\":\"build: $target $svc\"},\"Body\":{\"ServiceInfo\":{\"state\":\"$target\"}}}" "$AMB/clusters/sandbox/services/$svc" > /tmp/req.out
    url=$(python3 -c "import json; print(json.load(open('/tmp/req.out')).get('href',''))" 2>/dev/null || true)
    if [ -z "$url" ]; then sleep 10; continue; fi   # sem request (transição em andamento): espera e tenta de novo
    while :; do
      st=$("${CURL[@]}" "$url" | python3 -c "import json,sys; print(json.load(sys.stdin)['Requests']['request_status'])")
      case "$st" in
        COMPLETED) break ;;
        FAILED|ABORTED|TIMEDOUT) "${CURL[@]}" "$url/tasks?fields=Tasks/stderr,Tasks/stdout&Tasks/status=FAILED" | head -c 20000; return 1 ;;
      esac
      sleep 10
    done
    [ "$(svc_current "$svc")" = "$target" ] && return 0
  done
  echo "serviço $svc não chegou a $target"; return 1
}

log "iniciando ZooKeeper e HDFS (formata o NameNode na primeira subida)"
svc_state ZOOKEEPER STARTED
svc_state HDFS STARTED

log "semeando HDFS: /user/maria_dev/ml-100k e dados das aulas"
su - hdfs -c "hdfs dfs -mkdir -p /user/maria_dev /user/raj_ops /user/admin /user/root /user/hive /user/oozie /user/spark /user/zeppelin /tmp /apps/hive/warehouse /app-logs /mr-history/done /mr-history/tmp /spark2-history /spark3-history /ats/done /ats/active /apps/spark/warehouse /home/maria_dev"
su - hdfs -c "hdfs dfs -chmod 1777 /tmp /app-logs /mr-history/tmp /spark2-history /spark3-history && hdfs dfs -chmod 777 /apps/hive/warehouse && hdfs dfs -chown -R spark:hadoop /spark2-history /spark3-history && hdfs dfs -chown -R yarn:hadoop /ats"
# o Timeline Server (YARN) reenvia service-dep.tar.gz como usuário yarn: o diretório precisa ser dele
su - hdfs -c "hdfs dfs -mkdir -p /odp/apps/${ODP_BUILD}/yarn && hdfs dfs -chown -R yarn:hadoop /odp/apps/${ODP_BUILD}/yarn"
su - hdfs -c "hdfs dfs -chown maria_dev:hadoop /user/maria_dev /home/maria_dev && hdfs dfs -chown raj_ops:hadoop /user/raj_ops && hdfs dfs -chown admin:hadoop /user/admin && hdfs dfs -chown hive:hadoop /user/hive /apps/hive && hdfs dfs -chown oozie:hadoop /user/oozie && hdfs dfs -chown spark:hadoop /user/spark && hdfs dfs -chown zeppelin:hadoop /user/zeppelin && hdfs dfs -chown mapred:hadoop /mr-history /mr-history/tmp /mr-history/done && hdfs dfs -chmod 1777 /mr-history/tmp /mr-history/done"
mkdir -p /home/maria_dev/data && cp -r /build/data/. /home/maria_dev/data/ && rm -f /home/maria_dev/data/imdb-reviews-pt-br.csv && chown -R maria_dev:maria_dev /home/maria_dev/data
su - maria_dev -c "hdfs dfs -test -e /user/maria_dev/ml-100k/u.data || { hdfs dfs -rm -r -f /user/maria_dev/ml-100k; hdfs dfs -put /home/maria_dev/data/ml-100k /user/maria_dev/ml-100k; }; hdfs dfs -ls /user/maria_dev/ml-100k | tail -3"
# como no curso original (Aulas 10-12): u.data, u.item e customer-orders.csv também na raiz do home no HDFS
su - maria_dev -c "cd /home/maria_dev/data && hdfs dfs -put -f ml-100k/u.data ml-100k/u.item customer-orders.csv access_log.txt /user/maria_dev/ && hdfs dfs -cp -f /user/maria_dev/customer-orders.csv /user/maria_dev/customer-order.csv && hdfs dfs -ls /user/maria_dev"

log "Oozie: criando a sharelib no HDFS; adicionando driver MySQL e jars do MapReduce às ações sqoop/hive (Aula 7)"
svc_state OOZIE STARTED
/opt/lab/oozie-sharelib-fix.sh
svc_state OOZIE INSTALLED

log "carregando banco movielens no MariaDB (Sqoop/Oozie, Aulas 7 e 8)"
mysql -u root -phadoop -e "CREATE DATABASE IF NOT EXISTS movielens; GRANT ALL ON movielens.* TO 'maria_dev'@'%' IDENTIFIED BY 'maria_dev'; GRANT ALL ON movielens.* TO 'maria_dev'@'localhost' IDENTIFIED BY 'maria_dev'; FLUSH PRIVILEGES;"
# Os roteiros (Sqoop e o workflow do Oozie) conectam em jdbc:mysql://localhost/movielens sem usuário/senha,
# como no MySQL da VM HDP: usuário anônimo com acesso ao banco movielens (ambiente de laboratório).
mysql -u root -phadoop -e "CREATE USER IF NOT EXISTS ''@'localhost'; GRANT ALL ON movielens.* TO ''@'localhost'; FLUSH PRIVILEGES;"
# o dump é latin1 (títulos com acento)
mysql --default-character-set=latin1 -u root -phadoop movielens < /build/data/movielens.sql
mysql -u root -phadoop -e "USE movielens; SHOW TABLES; SELECT COUNT(*) AS ratings FROM ratings;"

log "usuários do Ambari e Views"
for u in raj_ops maria_dev; do
  "${CURL[@]}" -X POST -d "{\"Users/user_name\":\"$u\",\"Users/password\":\"$u\",\"Users/active\":true,\"Users/admin\":false}" "$AMB/users" >/dev/null || true
done
"${CURL[@]}" -X PUT -d '{"Users":{"admin":true}}' "$AMB/users/raj_ops" >/dev/null || true
for u in raj_ops maria_dev; do
  "${CURL[@]}" -X POST -d "{\"PrivilegeInfo\":{\"permission_name\":\"CLUSTER.USER\",\"principal_name\":\"$u\",\"principal_type\":\"USER\"}}" "$AMB/clusters/sandbox/privileges" >/dev/null || true
done
"${CURL[@]}" "$AMB/views?fields=versions/instances/ViewInstanceInfo/instance_name" | python3 -c "import json,sys; d=json.load(sys.stdin); [print('  view', v['ViewInfo']['view_name'], [i['ViewInstanceInfo']['instance_name'] for ver in v['versions'] for i in ver['instances']]) for v in d['items']]"
# Files View: instância explícita apontando para o HDFS (auto-instância pode não existir)
FILES_VER=$("${CURL[@]}" "$AMB/views/FILES" | python3 -c "import json,sys; print(json.load(sys.stdin)['versions'][0]['ViewVersionInfo']['version'])")
"${CURL[@]}" -X POST -d "{\"ViewInstanceInfo\":{\"label\":\"Files View\",\"description\":\"Sistema de arquivos HDFS\",\"visible\":true,\"properties\":{\"webhdfs.url\":\"hdfs://$FQDN:8020\",\"webhdfs.auth\":\"auth=SIMPLE\",\"webhdfs.username\":\"\${username}\"}}}" "$AMB/views/FILES/versions/$FILES_VER/instances/FILES_1" >/dev/null || true
for u in raj_ops maria_dev; do
  "${CURL[@]}" -X POST -d "{\"PrivilegeInfo\":{\"permission_name\":\"VIEW.USER\",\"principal_name\":\"$u\",\"principal_type\":\"USER\"}}" "$AMB/views/FILES/versions/$FILES_VER/instances/FILES_1/privileges" >/dev/null || true
done

log "parando serviços e daemons"
svc_state HDFS INSTALLED
svc_state ZOOKEEPER INSTALLED
ambari-agent stop
ambari-server stop
mysqladmin -u root -phadoop shutdown
su - postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data stop -m fast"
rm -rf /var/lib/ambari-agent/data/tmp/* /var/lib/ambari-agent/cache/tmp/* /tmp/* /var/cache/dnf
log "cluster instalado"
