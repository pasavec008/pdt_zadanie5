from elasticsearch import Elasticsearch, helpers
import json
import time

BATCHSIZE = 5000

# Connect to the Elasticsearch cluster
es = Elasticsearch(hosts=['http://localhost:9200'], timeout=1200)


# Open the JSON file
with open('D:\\skola2022_2023\\PDT\\zadanie5\\big_file.json', 'r', encoding='utf8') as f:
    x = 0
    start = time.time()
    documents = []
    for line in f:
        x += 1
        documents.append(json.loads(line))

        if len(documents) == BATCHSIZE:
            resp = helpers.bulk(
                es,
                documents,
                index = "tweets",
                request_timeout=1200
            )
            print(x)
            documents = []

    #send final data
    resp = helpers.bulk(
        es,
        documents,
        index = "tweets",
        request_timeout=1200
    )
    print(resp)
    print('Final time:')
    print(time.time() - start)