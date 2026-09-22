from pyspark.sql import SparkSession
from pyspark.sql import Row

import collections

spark = SparkSession.builder.appName("SparkSQL").getOrCreate()

def mapper(line):
    fields = line.split(',')
    return Row(comanda_id=int(fields[0]), produto_id=int(fields[1]), preco=float(fields[2]))

lines = spark.sparkContext.textFile("customer-order.csv")
compras = lines.map(mapper)

schemaCompras = spark.createDataFrame(compras).cache()
schemaCompras.createOrReplaceTempView("compras")

acimaDaMedia = spark.sql("SELECT comanda_id, sum(preco) FROM compras GROUP BY comanda_id")

for item in acimaDaMedia.collect():
  print(item)

schemaCompras.groupBy("comanda_id").sum("preco").orderBy("sum(preco)").show()

spark.stop()
