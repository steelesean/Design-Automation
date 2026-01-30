const { LinearClient } = require('@linear/sdk');
require('dotenv').config();

async function createLearningIssue(topic, filepath) {
  const linear = new LinearClient({
    apiKey: process.env.LINEAR_API_KEY
  });

  const issue = await linear.createIssue({
    teamId: process.env.LINEAR_TEAM_ID,
    title: `Learning: ${topic}`,
    description: `Learned about: ${topic}\n\nSaved to: ${filepath}`,
    labelIds: [] // We'll add the label ID next
  });

  return issue;
}

async function createFutureIdeaIssue(idea, filepath) {
  const linear = new LinearClient({
    apiKey: process.env.LINEAR_API_KEY
  });

  const issue = await linear.createIssue({
    teamId: process.env.LINEAR_TEAM_ID,
    title: `Future Command: ${idea}`,
    description: `Command idea: ${idea}\n\nBrief saved to: ${filepath}`,
    labelIds: [] // We'll add the label ID next
  });

  return issue;
}

module.exports = { createLearningIssue, createFutureIdeaIssue };