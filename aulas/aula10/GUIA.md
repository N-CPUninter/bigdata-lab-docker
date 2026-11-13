# Aulas 10 e 11 — PySpark (RDD, DataFrame, Spark SQL, MLlib)

**Preparar:** `.\lab.cmd aula 10` — liga só ZooKeeper e HDFS. O Spark roda em modo **local**, mas, como no HDP, `sc.textFile("u.data")` lê do **HDFS** (`/user/maria_dev/u.data`). No vídeo o professor sobe `u.data`, `u.item` e `customer-orders.csv` pelo Files View; na sandbox eles já estão lá (`hdfs dfs -ls`), e você pode repetir o upload para praticar. Os `open("u.item")` do Python leem o arquivo **local** da pasta do script. Para ler um arquivo local pelo Spark sem HDFS: `sc.textFile("file:///home/maria_dev/aulas/aula10/01-RatingsCounter/u.data")`.

Os scripts são os originais. Na sandbox há dois Sparks, como no HDP:

| | Spark 2 (2.4.8, Scala 2.12) | Spark 3 (3.5.1, Scala 2.12) |
|---|---|---|
| Selecionar | `export SPARK_MAJOR_VERSION=2` | `export SPARK_MAJOR_VERSION=3` (padrão) |
| Python usado | 3.7 (`/opt/python3.7`) — automático | 3.9 — automático |

Os scripts da aula rodam nas duas versões. Use Spark 2 quando quiser reproduzir exatamente o vídeo; Spark 3 é o que o Trabalho pede.

```bash
cd ~/aulas/aula10/01-RatingsCounter && spark-submit ratings-counter.py
cd ~/aulas/aula10/02-CustomerOrder  && spark-submit customer-orders.py && spark-submit customer-orders-ordered.py
cd ~/aulas/aula10/03-MostPopularMovies && spark-submit popular-movies.py && spark-submit popular-movies-names.py && spark-submit popular-movies-dataframe.py
cd ~/aulas/aula10/04-SparkSQL && spark-submit spark-sql.py
cd ~/aulas/aula10/05-MLLib && spark-submit movie-recommendations-als.py 50
```

Observações:
- `04-SparkSQL`: o script lê `customer-order.csv` (singular); a pasta já traz o arquivo com esse nome (no material da aula 10 o arquivo chamava `customer-orders.csv` e o script falhava — a aula 11 corrigiu renomeando).
- `05-MLLib` cria a pasta `checkpoint` no diretório atual.
- Para reduzir o ruído de log: `spark-submit --conf spark.ui.showConsoleProgress=false ...` ou edite `~/aulas/log4j.properties`.
- A aula 11 é uma repetição da aula 10 (`aula11/` tem os mesmos arquivos).
