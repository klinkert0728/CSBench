import time
from pymongo import MongoClient
import csv
import os
import sys

replica_url = sys.argv[1]
print(replica_url)