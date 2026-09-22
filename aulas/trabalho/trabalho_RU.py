"""
Atividade Prática de Big Data — esqueleto para rodar na sandbox com spark-submit.
Substitua RU pelo seu RU (no nome do arquivo e das variáveis) e preencha as funções.

Uso:  spark-submit trabalho_RU.py [caminho_do_csv]
"""
import sys
from pyspark.sql import SparkSession

RU = "0000000"  # <-- seu RU

app_name = f"PySpark Trabalho de Big Data RU {RU}"
spark = SparkSession.builder.appName(app_name).master("local[*]").getOrCreate()
spark.sparkContext.setLogLevel("WARN")

csv_path = sys.argv[1] if len(sys.argv) > 1 else "imdb-reviews-pt-br.csv"
imdb_df = spark.read.csv(csv_path, header=True, quote="\"", escape="\"", encoding="UTF-8")
imdb_df.printSchema()


# ---------- Questão 1: soma dos ids dos filmes com sentiment == 'neg' ----------
def map1_RU(x):
    # retorne uma tupla (chave, valor)
    raise NotImplementedError


def reduceByKey1_RU(x, y):
    raise NotImplementedError


# ---------- Questão 2: diferença de palavras (text_pt - text_en) das avaliações negativas ----------
def map2_RU(x):
    raise NotImplementedError


def reduceByKey2_RU(x, y):
    raise NotImplementedError


if __name__ == "__main__":
    imdb_rdd = imdb_df.rdd
    resultado1_RU = imdb_rdd.map(map1_RU).reduceByKey(reduceByKey1_RU).collect()
    print(f"[RU {RU}] Questão 1:", resultado1_RU)

    resultado2_RU = imdb_rdd.map(map2_RU).reduceByKey(reduceByKey2_RU).collect()
    print(f"[RU {RU}] Questão 2:", resultado2_RU)
    spark.stop()
