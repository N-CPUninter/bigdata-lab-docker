from pyspark import SparkConf, SparkContext

conf = SparkConf().setMaster("local").setAppName("RatingsCount")
sc = SparkContext(conf = conf)

lines = sc.textFile("u.data")
ratings = lines.map(lambda x: x.split()[2])
totalCounts = ratings.countByValue()

for key, value in totalCounts.items():
    print("%s %i" % (key, value))
