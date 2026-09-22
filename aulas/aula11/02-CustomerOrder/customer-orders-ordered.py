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
sortedTotal = totalByCustomer.map(lambda x: (x[1], x[0])).sortByKey()
totalByCustomer = sortedTotal.map(lambda x: (x[1], x[0]))

results = totalByCustomer.collect()
for result in results:
    print(result)
