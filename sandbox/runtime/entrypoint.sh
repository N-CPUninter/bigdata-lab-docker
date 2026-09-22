#!/usr/bin/env bash
# Entrypoint da sandbox: sobe os serviços de base (sem systemd) e, opcionalmente, prepara uma aula.
set -uo pipefail
FQDN="${SANDBOX_FQDN:-sandbox.hortonworks.com}"
export JAVA_HOME="$(cat /etc/java_home)"
export PATH="$JAVA_HOME/bin:/usr/local/bin:$PATH"

log() { echo "[sandbox] $*"; }

# /etc/hosts: o Ambari registrou o host como $FQDN no build; precisa resolver para 127.0.0.1
grep -q " $FQDN" /etc/hosts || echo "127.0.0.1 $FQDN sandbox-hdp.hortonworks.com sandbox localhost" >> /etc/hosts
hostname "$FQDN" 2>/dev/null || true

# diretórios em volumes podem chegar vazios (primeira subida com volume novo)
/opt/lab/init-volumes.sh

mkdir -p /var/run/postgresql /var/run/mariadb && chown postgres:postgres /var/run/postgresql && chown mysql:mysql /var/run/mariadb
log "PostgreSQL (banco do Ambari)"
su - postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data -l /var/lib/pgsql/pg.log start -w -t 60" >/dev/null

log "MariaDB (metastore Hive/Oozie, banco movielens)"
(mysqld_safe --user=mysql >/dev/null 2>&1 &)
for _ in $(seq 1 60); do mysqladmin ping >/dev/null 2>&1 && break; sleep 1; done

log "sshd (porta 2222 no host) e ttyd (http://localhost:4200)"
/usr/sbin/sshd
(ttyd -p 4200 -W -t titleFixed="sandbox.hortonworks.com" /opt/lab/login.sh >/var/log/ttyd.log 2>&1 &)

log "Página inicial em http://localhost:8888"
(cd /opt/lab/splash && python3 -m http.server 8888 --bind 0.0.0.0 >/var/log/splash.log 2>&1 &)

log "Ambari server (http://localhost:8080 — admin/admin, raj_ops/raj_ops, maria_dev/maria_dev)"
ambari-server start >/var/log/ambari-server-start.log 2>&1
ambari-agent start  >/var/log/ambari-agent-start.log 2>&1

lab wait-ambari
lab mem "${LAB_MEM:-8g}" --quiet
if [ -n "${LAB_AULA:-}" ]; then
  log "Preparando aula ${LAB_AULA}"
  lab aula "${LAB_AULA}"
else
  log "Nenhuma aula selecionada. Use: lab aula <7|8a|8b|8c|8d|9a|9b|9c|9d|10|11|12|trabalho>"
fi
log "Pronto."

# mantém o container vivo e encerra com graça
trap 'log "Parando..."; lab stop-all --quiet; ambari-agent stop; ambari-server stop; mysqladmin -u root -phadoop shutdown; su - postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data stop -m fast"; exit 0' TERM INT
while true; do sleep 3600 & wait $!; done
