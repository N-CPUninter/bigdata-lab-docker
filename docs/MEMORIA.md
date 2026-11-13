# Memória: o que cabe em 8 GB

A VM HDP 2.6.5 precisava de 8 GB só para ela (ou seja, um computador de 16 GB). Aqui o Ambari só liga os serviços de cada aula; serviço parado não usa memória.

## Orçamento por perfil (perfil de memória `8g`)

| Perfil | Serviços ligados | RAM estimada do container |
|---|---|---|
| base (sempre) | Ambari server/agent, PostgreSQL, MariaDB, sshd, ttyd | ~1,3 GB |
| 9d | nenhum (Flink standalone) | ~2 GB |
| 10, 11, 12, trabalho, 9a | ZooKeeper, HDFS (+ Spark local) | ~2,5 GB |
| 9b | ZooKeeper, Kafka | ~2,3 GB |
| 9c | ZooKeeper + Storm | ~3 GB |
| 8b | ZooKeeper, HDFS, YARN, MapReduce2, HBase | ~4,8 GB |
| 8c | ZooKeeper, HDFS + Mongo (0,5 GB) + Cassandra (1,5 GB) | ~4,5 GB |
| 8d | ZooKeeper, HDFS, Hive + Mongo/Cassandra | ~4,5 GB |
| 8a, 7a | ZooKeeper, HDFS, YARN, MapReduce2, Hive | ~4,8 GB |
| 7 | 8a + Oozie | ~5,5 GB |

Com 8 GB no computador: `.wslconfig` com `memory=6GB` e `swap=6GB` (Windows) ou 6 GB no Docker Desktop (macOS). Os perfis 7/8a/8d ficam lentos mas funcionam; feche o navegador com muitas abas.

Com 16 GB ou mais: dê 10 GB ao Docker e use `.\lab.cmd mem 16g` (Linux/macOS: `./lab.sh mem 16g`). Os heaps ficam maiores e os jobs mais rápidos; o perfil é o mesmo para 16, 32 ou 64 GB, não precisa ajustar nada além disso.

## Diferenças entre `8g` e `16g` além dos heaps

| | `8g` | `16g` |
|---|---|---|
| Ambari server | heap 640 MB | heap 640 MB |
| Oozie | heap 384 MB | heap 512 MB |
| YARN Timeline Server + Timeline Reader | **ficam parados** (o `lab aula` os desliga após ligar o YARN) | ligados |

O que se perde sem o Timeline no `8g`: o YARN UI (`localhost:8088`) não lista as aplicações **concluídas** que rodaram em Tez (Pig, Hive); `yarn logs -applicationId` e o JobHistory do MapReduce (`localhost:19888`, usado por mrjob e Pig em modo MR) continuam funcionando. O Ambari mostra os dois componentes como "Stopped" — é esperado. Para religar manualmente: `lab mem 16g` e `lab aula 7` de novo.

Medição real do perfil 7 após 12 h ligado (antes deste ajuste): container em 7,0 GB (limite), Ambari 1,4 GB, Oozie 1,4 GB, Timeline+History ~900 MB.

## O que o perfil `mem` muda

`sandbox/build/configs-8g.json` e `configs-16g.json`: heap do NameNode/DataNode/RM/NM/HiveServer2/Metastore/HBase/Oozie/ZooKeeper, tamanho dos containers YARN (`yarn.nodemanager.resource.memory-mb`, map/reduce/Tez) e memória do driver/executor do Spark. `lab mem 8g|16g` grava no Ambari; o perfil vale na próxima vez que o serviço for ligado (`lab aula ...` já religa).

## Não deixe os serviços ligados por horas a fio

Medição real (perfil 7, `8g`): logo após ligar, ~5,4 GB; depois de ~24 h ligado sem uso, 7,0 GB (o limite do container), CPU alta e Ambari sem responder. Os processos Java (Oozie, HiveServer2, Metastore) crescem lentamente com o tempo mesmo ociosos, e o cache de página do HDFS conta no limite do container.

Regra prática: ao terminar a sessão de estudo rode `lab aula none` (para todos os serviços, mantém o Ambari) ou `.\lab.cmd down` (para o container; os dados ficam nos volumes). Se o Ambari deixar de responder (`.\lab.cmd status` trava), `docker restart sandbox-hdp` resolve em ~3 min sem perder nada.

## Sinais de falta de memória

- Serviço no Ambari vai para vermelho logo após ligar → veja `lab status` (coluna RSS) e o log em `/var/log/<serviço>`.
- `Container killed on request. Exit code is 137` em jobs YARN → aumente `swap` no `.wslconfig` ou use perfis menores (`7a` em vez de `7`).
- Docker Desktop trava o Windows → `memory` do `.wslconfig` alto demais para a máquina.
