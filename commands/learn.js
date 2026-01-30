#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Get the topic from command line arguments
const topic = process.argv.slice(2).join(' ');

if (!topic) {
  console.log('Usage: node learn.js "your topic here"');
  process.exit(1);
}

// Create a filename-friendly version
const filename = topic
  .toLowerCase()
  .replace(/[^a-z0-9]+/g, '-')
  .replace(/^-|-$/g, '');

const date = new Date().toISOString().split('T')[0];
const outputFile = path.join(__dirname, '..', 'learning', `${date}-${filename}.txt`);

// The prompt for Claude
const prompt = `I want to learn about: "${topic}"

Please explain this at a beginner level suitable for a design leader learning about technical concepts.

Include:
1. What it is in simple terms (use analogies if helpful)
2. Why it matters for design automation in financial services
3. A concrete example relevant to their work
4. What they should explore next

Save your explanation to this file: ${outputFile}

Format as plain text with clear sections. Be concise but thorough.`;

console.log('\n🤔 Learning about:', topic);
console.log('\n📋 Instructions:');
console.log('1. I will open Claude Code for you');
console.log('2. Copy the prompt below');
console.log('3. Paste it into Claude Code');
console.log('4. Claude will create the file automatically\n');
console.log('---COPY THIS PROMPT---');
console.log(prompt);
console.log('---END PROMPT---\n');

console.log('💡 Opening Claude Code now...\n');

// This will be run separately
console.log('Run this command in another Terminal window:');
console.log('npx @anthropic-ai/claude-code\n');
