#!/bin/bash

# Get the topic
TOPIC="$1"

if [ -z "$TOPIC" ]; then
  echo "Usage: ./commands/learn.sh \"your topic here\""
  exit 1
fi

# Create filename
FILENAME=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
DATE=$(date +%Y-%m-%d)
OUTPUT_FILE="./learning/${DATE}-${FILENAME}.txt"

echo ""
echo "🤔 Learning about: $TOPIC"
echo ""
echo "⏳ Asking Claude Code..."
echo ""

# Create the prompt
PROMPT="I want to learn about: \"$TOPIC\"

Please explain this at a beginner level suitable for a design leader learning about technical concepts.

Include:
1. What it is in simple terms (use analogies if helpful)
2. Why it matters for design automation in financial services
3. A concrete example relevant to their work
4. What they should explore next

Please create the file: $OUTPUT_FILE

Format as plain text with clear sections. Be concise but thorough."

# Call Claude Code with the prompt
echo "$PROMPT" | npx @anthropic-ai/claude-code

echo ""
echo "✅ Learning saved to: $OUTPUT_FILE"
echo ""
