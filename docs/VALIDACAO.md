# Validação — o que foi testado e o que ficou de fora

Última rodada: 2026-09-21, imagem `bigdata-sandbox:1.0.1` (Ambari 2.7.11.0.0-161 + ODP 1.2.4.0-108, com os cortes de memória do capítulo 7 do Guia) subida **do zero** (volumes novos) no Docker Desktop do Windows 11 (WSL2), container limitado a 7 GB, perfil `LAB_MEM=8g`: 30 verificações PASS, 0 FAIL, 1 SKIP (Phoenix). Consumo do container ao final da bateria: 3,9 GB. Os testes são os scripts de `tests/smoke/` (rodam `tests/ci.sh aula07 aula08 ...`).

| Aula / perfil | O que o teste faz | Resultado |
|---|---|---|
| 10 / 11 | `ratings-counter.py` no Spark 3 e no Spark 2 (lendo `u.data` do HDFS), `spark-sql.py`, ALS (`movie-recommendations-als.py 50`) | PASS |
| 7 | `ml-100k` no HDFS; Pig `MostRatedFiveStarMovie` e `OldestFiveStarMovie` no MapReduce/YARN e em modo local; workflow Oozie original (`job.properties`, `workflow.xml`) com ação Sqoop (MariaDB → HDFS) e ação Hive → `/user/maria_dev/oldmovies` | PASS |
| 8a | Hive: `SELECT COUNT(*) FROM ratings` = 100000 e `MostPopularMovie.sql` (Star Wars); `sqoop import` da tabela `movies`; mrjob local e no YARN (`-r hadoop`) | PASS |
| 8b | `hbase shell create 'users'`; Pig com `HBaseStorage` (943 usuários); Phoenix `sqlline.py` | PASS, PASS, **SKIP** (ver abaixo) |
| 8c | containers `mongo` e `cassandra`; `CassandraSpark.py` e `MongoSpark.py` no Spark 2 (943 registros em cada) | PASS |
| 9 | Kafka: criar tópico, produzir e consumir (`--bootstrap-server localhost:6667`); Flume netcat → logger; Storm `WordCountTopology` ACTIVE; Flink `start-cluster.sh` na porta 8082 | PASS |
| 12 | Flume (avro 9092) → `SparkFlume.py` no Spark 2 contando URLs; `structured-streaming.py` no Spark 3 contando status 200 | PASS |
| trabalho | upload do `imdb-reviews-pt-br.csv` para o HDFS, `copyToLocal`, `spark-submit` (Spark 3) com script de referência → 459568555 e diferença de palavras na faixa 54000–55000 | PASS |

Não testados automaticamente (fluxo manual do roteiro, tarballs pré-baixados em `~/downloads`): Drill 1.21.2 e Presto 0.235.1 (perfil 8d), Zeppelin, Kafka Connect (`connect-standalone.sh`), Flume spooldir → HDFS.

## Limitações conhecidas

- **Phoenix não conecta**: o Phoenix 5.1.3 empacotado no ODP 1.2.4 é incompatível com o HBase 2.5.6 do mesmo ODP (`NoSuchMethodError` de protobuf ao abrir a conexão, tanto no `sqlline.py` quanto no Query Server). O pacote ainda vem com `phoenix_utils.py` corrompido e sem o `sqlline` — ambos corrigidos na imagem, para o dia em que houver um client jar compatível (Phoenix 5.1.4+/5.2). Enquanto isso, o tema é coberto por HBase shell, Pig `HBaseStorage` e Spark.
- **Pig View e Hive View do Ambari** não existem nesta versão (Pig View precisa do WebHCat, ausente no ODP). Files View e Workflow Manager (Oozie) funcionam.
- **Spark2 History Server** (componente do Ambari) não sobe; nenhum perfil o usa. Spark 3 roda fora do Ambari (cliente puro), porque SPARK2 e SPARK3 não coexistem no mesmo cluster ODP.
- **NameNode UI** é publicada em `localhost:9870` (o Windows reserva 50000–50959).
- Cassandra 3.11 precisa de 1,5 GB (`mem_limit`); com 1 GB morre por OOM.
- Imagem grande (~22 GB descompactada). O `dnf` traz plugins Ranger, Iceberg e Java 17 como dependências; Java 17 é usado pelo Storm.

## Como repetir

```powershell
.\lab.ps1 up
bash tests/ci.sh aula10 aula07 aula08 aula09 aula12 trabalho   # Git Bash / WSL; leva ~1h30
```
`tests/smoke/trabalho.sh` só roda se `data/imdb-reviews-pt-br.csv` existir.
