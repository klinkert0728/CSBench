import time
from pymongo import MongoClient
import csv
import os
import sys

replica_url = sys.argv[1]
url = f'mongodb://{replica_url}:27017/?replicaSet=rs0&directConnection=true&readPreference=secondary'
db_name = 'csbench'
client = MongoClient(url)

def measure_staleness():
    while True:
        result = client.admin.command('hello', 1)
        last_write = result['lastWrite']['opTime']['ts']
        last_write_date = last_write.as_datetime()
        last_write_seconds = int(last_write_date.strftime('%s'))
        
        current_date = int(time.time())
        staleness = current_date - last_write_seconds
        print(result)
        print(staleness)
        write_to_file(staleness, current_date)
        time.sleep(10)

def write_to_file(staleness, date):
    path = f'{replica_url}.csv'
    headers = ['timestamp', 'staleness', 'replica_info']
    if os.path.exists(path):
        mode = 'a'
    else:
        mode = 'w'
    
    with open(path, mode) as csv_file:
        curren_file = csv.DictWriter(csv_file, fieldnames=headers)
        if mode == 'w':
            curren_file.writeheader()
        curren_file.writerow({ 'timestamp': date, 'staleness': staleness, 'replica_info': replica_url })

try: 
    measure_staleness()
except KeyboardInterrupt:
    client.close()