const { MongoClient } = require('mongodb');
const { faker } = require('@faker-js/faker')
var assert = require('assert');
const process = require('process');

// Connection URL
const primaryURL = process.argv[2]
const url = `mongodb://${primaryURL}:27017?replicaSet=rs0&w=majority`;
const client = new MongoClient(url);

// Database Name
const dbName = 'csbench';
const collectionName = 'products'
var inverval_timer;

async function main() {
  // Use connect method to connect to the server
  await client.connect();
  console.log('Connected successfully to server');
  const db = client.db(dbName);

  inverval_timer = setInterval(async () => {
    const products = [];
    for (let i = 0; i < 2000; i++) {
      products.push(createProduct())
    }

    await db.collection(collectionName).insertMany(products)
    console.log("batch of 2000");
  }, 3000);
}

function createProduct() {
  const product = {
    id: faker.datatype.uuid(),
    name: faker.commerce.productName(),
    price: faker.commerce.price(),
    availability: faker.datatype.boolean(),
    category: faker.commerce.department()
  }

  return product
}


main()
  .then(console.log)
  .catch(console.error)



