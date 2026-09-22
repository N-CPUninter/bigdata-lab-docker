#!/usr/bin/env bash
# Ajusta dono/permissões dos diretórios que vivem em volumes (Docker copia o conteúdo da imagem
# para um volume nomeado vazio na primeira subida; só as permissões precisam ser garantidas).
set -uo pipefail
chown -R postgres:postgres /var/lib/pgsql/data 2>/dev/null || true
chmod 700 /var/lib/pgsql/data 2>/dev/null || true
chown -R mysql:mysql /var/lib/mysql 2>/dev/null || true
chown maria_dev:maria_dev /home/maria_dev 2>/dev/null || true
mkdir -p /home/maria_dev/spool /home/maria_dev/checkpoint /home/maria_dev/logs
chown maria_dev:maria_dev /home/maria_dev/spool /home/maria_dev/checkpoint /home/maria_dev/logs 2>/dev/null || true
