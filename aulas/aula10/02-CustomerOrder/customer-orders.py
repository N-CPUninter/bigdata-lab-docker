from pyspark import SparkConf, SparkContext

conf = SparkConf().setMaster("local").setAppName("CustomerOrder")
sc = SparkContext(conf = conf)

def parseLines(line):
    fields = line.split(',')
    customer_id = int(fields[0])
    item_price = float(fields[2])
    return (customer_id, item_price)
    

lines = sc.textFile("customer-orders.csv")

parsedLines = lines.map(parseLines)
totalByCustomer = parsedLines.reduceByKey(lambda x, y: x+y)

results = totalByCustomer.collect()
for result in results:
    print(result)
