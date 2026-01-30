const { LinearClient } = require('@linear/sdk');
require('dotenv').config();

async function getLabels() {
  const linear = new LinearClient({
    apiKey: process.env.LINEAR_API_KEY
  });

  const labels = await linear.issueLabels();
  
  console.log('\n📋 Your Linear Labels:\n');
  
  for await (const label of labels) {
    console.log(`Name: ${label.name}`);
    console.log(`ID: ${label.id}`);
    console.log(`---`);
  }
}

getLabels();