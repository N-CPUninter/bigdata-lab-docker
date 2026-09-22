# Diferenças para a VM HDP 2.6.5

## O que é igual

- Ambari em `localhost:8080`; usuários `admin/admin`, `raj_ops/raj_ops`, `maria_dev/maria_dev`.
- Shell web em `localhost:4200`; SSH `maria_dev@localhost -p 2222` (senha `maria_dev`).
- Hostname `sandbox.hortonworks.com`; HDFS `hdfs://sandbox.hortonworks.com:8020`; ResourceManager `8050`.
- Home `/home/maria_dev`; HDFS `/user/maria_dev` com `ml-100k` já carregado.
- Layout `/usr/hdp/current/<componente>` (atalho para `/usr/odp/current`).
- `export SPARK_MAJOR_VERSION=2` para o Spark 2.
- Files View no Ambari (o Pig View não funciona: exige WebHCat, ausente no ODP).
- MySQL/MariaDB `root/hadoop` com o banco `movielens`.

## O que é diferente

| Assunto | HDP 2.6.5 | Sandbox |
|---|---|---|
| Distribuição | Hortonworks HDP (descontinuada) | ODP 1.2.4 (Clemlab, fork open source do HDP) + Ambari 2.7.11 |
| SO | CentOS 7 (repositórios mortos) | Rocky Linux 9 |
| Hive View / Tez View / Pig View | existiam | Hive/Tez View removidos no Ambari 2.7; Pig View sem WebHCat → use `beeline`, Zeppelin, `pig` no terminal (o `lab aula 8a` cria as tabelas do Hive) |
| Storm, Flume, MongoDB | serviços do Ambari | Storm/Flume por tarball (`lab storm start`); Mongo/Cassandra em containers ao lado |
| Ligar serviços | Ambari > Service Actions > Start (60 min para tudo) | `lab aula <perfil>` liga só os da aula (ou pelo Ambari, igual ao vídeo) |
| Python | 2.7 | 3.9 (e 3.7 para o Spark 2) |
| Boot | 30–60 min (VirtualBox), 12 h (Apple Silicon/QEMU) | 2–4 min |
| Estado | dentro do disco da VM | volumes Docker (`docker volume ls`), apagáveis com `lab.ps1 reset` |
| Ambari Metrics, Ranger, Knox, Atlas, NiFi | presentes (pesados) | não instalados (não são usados nas aulas) |
