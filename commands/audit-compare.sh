#!/bin/bash

# Audit Comparison Command
# Compares multiple companies' audit results side-by-side

if [ "$#" -lt 2 ]; then
  echo ""
  echo "Usage: ./commands/audit-compare.sh \"Company 1\" \"Company 2\" [\"Company 3\" ...]"
  echo ""
  echo "Example:"
  echo "  ./commands/audit-compare.sh \"Hargreaves Lansdown\" \"AJ Bell\" \"Vanguard\""
  echo ""
  echo "This will create a comparison table showing gaps and strengths across companies."
  echo ""
  exit 1
fi

COMPANIES=("$@")
DATE=$(date +%Y-%m-%d)
OUTPUT_FILE="./outputs/audits/${DATE}-comparison.csv"

echo ""
echo "📊 Creating comparison for:"
for company in "${COMPANIES[@]}"; do
  echo "  - $company"
done
echo ""
echo "⏳ Analyzing results..."
echo ""

# Create the comparison prompt
COMPANY_LIST=$(IFS=, ; echo "${COMPANIES[*]}")

PROMPT="You are analyzing experience audit results for multiple companies.

COMPANIES TO COMPARE: $COMPANY_LIST

YOUR TASK:
1. Find all audit CSV files for these companies in ./outputs/audits/
2. Combine them into a comparison view
3. Identify patterns:
   - Where all companies are strong (industry standards)
   - Where some excel and others lag (competitive gaps)
   - Where everyone is weak (market opportunities)

OUTPUT FORMAT:
Create a comparison CSV at: $OUTPUT_FILE

CSV Structure:
Theme,Tactic,$(echo "${COMPANIES[@]}" | sed 's/ /_Score,/g')_Score,Gap_Analysis,Opportunity

Where:
- Each company gets a score column
- Gap_Analysis = \"Industry Standard\" | \"Competitive Gap\" | \"Market Opportunity\"
- Opportunity = Brief note on what this means

Example row:
Ease of Use,Clear navigation,5,5,3,Industry Standard,All companies have clear nav - table stakes
Ease of Use,Bulk actions,5,1,1,Competitive Gap,Company 1 leads - others should adopt
Ease of Use,AI assistants,1,1,1,Market Opportunity,No one doing this well yet - white space

After creating the comparison, provide:

📊 SUMMARY:
- Total tactics analyzed: X
- Industry standards (all ≥4): X tactics
- Competitive gaps (variance >2): X tactics  
- Market opportunities (all ≤2): X tactics

🎯 TOP 5 OPPORTUNITIES:
List the 5 biggest gaps where you could differentiate

Now create the comparison CSV."

# Run through Claude Code
echo "$PROMPT" | npx @anthropic-ai/claude-code

echo ""
echo "✅ Comparison complete!"
echo "📄 Saved to: $OUTPUT_FILE"
echo ""
echo "💡 Open in Excel or Google Sheets to analyze gaps"
echo ""
