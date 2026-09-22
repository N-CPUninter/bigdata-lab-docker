"""Implementação de referência da Atividade Prática (usada só pelos testes; não distribuir aos alunos)."""
import sys
from pyspark.sql import SparkSession

RU = "teste"
spark = SparkSession.builder.appName(f"PySpark Trabalho de Big Data RU {RU}").master("local[*]").getOrCreate()
spark.sparkContext.setLogLevel("WARN")
csv_path = sys.argv[1] if len(sys.argv) > 1 else "imdb-reviews-pt-br.csv"
imdb_df = spark.read.csv(csv_path, header=True, quote="\"", escape="\"", encoding="UTF-8")


def map1_RU(x):
    return (x["sentiment"], int(x["id"]))


def reduceByKey1_RU(x, y):
    return x + y


def map2_RU(x):
    return (x["sentiment"], (len(x["text_pt"].split()), len(x["text_en"].split())))


def reduceByKey2_RU(x, y):
    return (x[0] + y[0], x[1] + y[1])


if __name__ == "__main__":
    rdd = imdb_df.rdd
    print(f"[RU {RU}] Questão 1:", rdd.map(map1_RU).reduceByKey(reduceByKey1_RU).collect())
    print(f"[RU {RU}] Questão 2:", rdd.map(map2_RU).reduceByKey(reduceByKey2_RU).collect())
    spark.stop()
