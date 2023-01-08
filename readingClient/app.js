const { MongoClient } = require('mongodb');
const process = require('process');
const fs = require('fs')
const csv = require('fast-csv');

// Connection URL
// additional arguments start from index 2
const replicaUrl = process.argv[2]
const url = `mongodb://${replicaUrl}:27017/?replicaSet=rs0&directConnection=true&readPreference=secondary`;
const client = new MongoClient(url);
var inverval_timer;

// Database Name
const dbName = 'csbench';

async function measureStaleness() {
  // Run the isMaster command
  await client.connect();
  inverval_timer = setInterval(async () => {
    const result = await client.db('admin').command({ hello: 1 })
    const lastWrite = result.lastWrite.opTime.ts
    const lastWriteDate = new Date(lastWrite.getHighBits() * 1000);
    const lastWriteSeconds = Math.round(lastWriteDate / 1000)

    // Calculate the staleness in seconds
    const currentDate = parseInt((Date.now() / 1000))
    const staleness = parseInt(currentDate - parseInt(lastWriteSeconds))
    console.log('Staleness: in seconds', staleness);
    writeToFile(staleness, currentDate)
  }, 5000);
}

function writeToFile(staleness, date) {
  const path = `${replicaUrl}.csv`
  let stream;
  if (fs.existsSync(path)) {
    stream = csv.format({ headers: true, writeHeaders: false, includeEndRowDelimiter: true })
  } else {
    stream = csv.format({ headers: true, writeHeaders: true, includeEndRowDelimiter: true })
  }

  const csvFile = fs.createWriteStream(path, { flags: 'a' })
  stream.pipe(csvFile)
  stream.write({ timestampt: date, staleness: staleness, replicaInfo: replicaUrl })
  stream.end()
}

measureStaleness()
  .then(console.log)
  .catch(console.error)
  .finally(() => client.close());