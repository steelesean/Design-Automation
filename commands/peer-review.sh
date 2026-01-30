#!/bin/bash

# Peer Review Command
# Uses Gemini API to critique experience audit scores and suggest adjustments

CSV_FILE="$1"

if [ -z "$CSV_FILE" ]; then
  echo ""
  echo "Usage: ./commands/peer-review.sh \"path/to/audit.csv\""
  echo ""
  echo "Examples:"
  echo "  ./commands/peer-review.sh outputs/audits/master-competitive-audit.csv"
  echo "  ./commands/peer-review.sh outputs/audits/aviva/2026-01-28-ease-of-use.csv"
  echo ""
  echo "This command sends your audit scores to Gemini for peer review,"
  echo "shows proposed adjustments, and lets you approve/reject each one."
  echo ""
  exit 1
fi

# Check if file exists
if [ ! -f "$CSV_FILE" ]; then
  echo "Error: File not found: $CSV_FILE"
  exit 1
fi

# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Check for API key
if [ -z "$GEMINI_API_KEY" ]; then
  echo "Error: GEMINI_API_KEY not found in .env file"
  exit 1
fi

# Check for jq
if ! command -v jq &> /dev/null; then
  echo "Error: jq is required but not installed."
  echo "Install with: brew install jq"
  exit 1
fi

echo ""
echo "🔍 Peer Review: $CSV_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Read CSV content (skip header, limit to avoid token limits)
CSV_CONTENT=$(cat "$CSV_FILE")
ROW_COUNT=$(tail -n +2 "$CSV_FILE" | wc -l | tr -d ' ')

echo "📊 Found $ROW_COUNT audit entries"
echo "⏳ Sending to Gemini for peer review..."
echo ""

# Create the prompt for Gemini
PROMPT="You are a senior UX researcher peer-reviewing a competitive experience audit.

Here is the audit data in CSV format:

$CSV_CONTENT

TASK:
Review each score critically. Look for:
1. Scores that seem too high given the evidence provided
2. Scores that seem too low given the evidence provided
3. Inconsistencies between similar tactics across companies
4. Evidence that doesn't support the confidence level

RESPOND WITH ONLY A JSON ARRAY of suggested changes. Each change should have:
- company: the company name
- tactic_id: the tactic ID number
- tactic_name: the tactic name
- current_score: their current score (1-5)
- suggested_score: your suggested score (1-5)
- reason: brief explanation (max 50 words)

Only include entries where you suggest a DIFFERENT score. If you think a score is correct, don't include it.

Example format:
[
  {
    \"company\": \"Aviva\",
    \"tactic_id\": 7,
    \"tactic_name\": \"Inline validation\",
    \"current_score\": 1,
    \"suggested_score\": 3,
    \"reason\": \"Evidence mentions form validation in app reviews, suggesting some implementation exists.\"
  }
]

If all scores look reasonable, return an empty array: []

Return ONLY the JSON array, no other text."

# Escape the prompt for JSON
ESCAPED_PROMPT=$(echo "$PROMPT" | jq -Rs .)

# Call Gemini API
RESPONSE=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY" \
  -H 'Content-Type: application/json' \
  -d "{
    \"contents\": [{
      \"parts\": [{
        \"text\": $ESCAPED_PROMPT
      }]
    }],
    \"generationConfig\": {
      \"temperature\": 0.3,
      \"maxOutputTokens\": 8192
    }
  }")

# Check for API errors
if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
  echo "❌ API Error:"
  echo "$RESPONSE" | jq -r '.error.message'
  exit 1
fi

# Extract the text response
TEXT_RESPONSE=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text')

# Try to extract JSON from the response (handle markdown code blocks)
JSON_CHANGES=$(echo "$TEXT_RESPONSE" | sed -n '/^\[/,/^\]/p' | head -1)

# If that didn't work, try removing markdown code blocks
if [ -z "$JSON_CHANGES" ] || [ "$JSON_CHANGES" = "null" ]; then
  JSON_CHANGES=$(echo "$TEXT_RESPONSE" | sed 's/```json//g' | sed 's/```//g' | tr -d '\n' | grep -o '\[.*\]')
fi

# Validate JSON
if ! echo "$JSON_CHANGES" | jq . > /dev/null 2>&1; then
  echo "❌ Could not parse Gemini response as JSON"
  echo ""
  echo "Raw response:"
  echo "$TEXT_RESPONSE"
  exit 1
fi

# Count suggestions
SUGGESTION_COUNT=$(echo "$JSON_CHANGES" | jq 'length')

if [ "$SUGGESTION_COUNT" -eq 0 ]; then
  echo "✅ Gemini found no issues with your scores!"
  echo "   All scores appear well-justified by the evidence."
  echo ""
  exit 0
fi

echo "📝 Gemini suggests $SUGGESTION_COUNT score adjustments:"
echo ""

# Create a temporary file for tracking approved changes
APPROVED_CHANGES="[]"
APPROVED_COUNT=0
REJECTED_COUNT=0

# Process each suggestion interactively
echo "$JSON_CHANGES" | jq -c '.[]' | while read -r CHANGE; do
  COMPANY=$(echo "$CHANGE" | jq -r '.company')
  TACTIC_ID=$(echo "$CHANGE" | jq -r '.tactic_id')
  TACTIC_NAME=$(echo "$CHANGE" | jq -r '.tactic_name')
  CURRENT=$(echo "$CHANGE" | jq -r '.current_score')
  SUGGESTED=$(echo "$CHANGE" | jq -r '.suggested_score')
  REASON=$(echo "$CHANGE" | jq -r '.reason')

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Company:  $COMPANY"
  echo "Tactic:   #$TACTIC_ID - $TACTIC_NAME"
  echo "Current:  $CURRENT → Suggested: $SUGGESTED"
  echo "Reason:   $REASON"
  echo ""

  # Prompt for approval
  read -p "Accept this change? (y/n): " ANSWER

  if [ "$ANSWER" = "y" ] || [ "$ANSWER" = "Y" ]; then
    echo "$CHANGE" >> /tmp/peer-review-approved.json
    echo "✅ Approved"
  else
    echo "❌ Rejected"
  fi
  echo ""
done

# Check if any changes were approved
if [ ! -f /tmp/peer-review-approved.json ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "No changes approved. Original file unchanged."
  echo ""
  rm -f /tmp/peer-review-approved.json
  exit 0
fi

# Count approved changes
APPROVED_COUNT=$(wc -l < /tmp/peer-review-approved.json | tr -d ' ')

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Summary: $APPROVED_COUNT changes approved"
echo ""

# Apply approved changes to CSV
OUTPUT_FILE="${CSV_FILE%.csv}-reviewed.csv"

# Copy original file
cp "$CSV_FILE" "$OUTPUT_FILE"

# Apply each approved change
while read -r CHANGE; do
  COMPANY=$(echo "$CHANGE" | jq -r '.company')
  TACTIC_ID=$(echo "$CHANGE" | jq -r '.tactic_id')
  NEW_SCORE=$(echo "$CHANGE" | jq -r '.suggested_score')

  # Use awk to update the score for matching company and tactic_id
  awk -F',' -v company="$COMPANY" -v tactic_id="$TACTIC_ID" -v new_score="$NEW_SCORE" '
    BEGIN { OFS="," }
    NR==1 { print; next }
    $1 == company && $4 == tactic_id { $6 = new_score }
    { print }
  ' "$OUTPUT_FILE" > /tmp/peer-review-temp.csv && mv /tmp/peer-review-temp.csv "$OUTPUT_FILE"

done < /tmp/peer-review-approved.json

# Cleanup
rm -f /tmp/peer-review-approved.json

echo "✅ Updated CSV saved to: $OUTPUT_FILE"
echo ""
echo "💡 Next steps:"
echo "   - Review the changes: diff \"$CSV_FILE\" \"$OUTPUT_FILE\""
echo "   - If happy, replace original: mv \"$OUTPUT_FILE\" \"$CSV_FILE\""
echo "   - Update dashboard data if needed"
echo ""
