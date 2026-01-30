#!/bin/bash

# Experience Audit Command
# Benchmarks a company's experience against 5 themes and ~68 tactics

COMPANY="$1"
THEME="$2"

if [ -z "$COMPANY" ]; then
  echo ""
  echo "Usage: ./commands/experience-audit.sh \"Company Name\" [\"Theme Name\"]"
  echo ""
  echo "Examples:"
  echo "  ./commands/experience-audit.sh \"Hargreaves Lansdown\""
  echo "  ./commands/experience-audit.sh \"Hargreaves Lansdown\" \"Ease of Use\""
  echo "  ./commands/experience-audit.sh \"Vanguard\" \"all\""
  echo ""
  echo "Available Themes:"
  echo "  - Ease of Use"
  echo "  - Emotional Design"
  echo "  - Social Proof & Belonging"
  echo "  - Decision Support"
  echo "  - Service Orchestration"
  echo "  - all (runs all themes)"
  echo ""
  exit 1
fi

# Create safe filename
COMPANY_SLUG=$(echo "$COMPANY" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
DATE=$(date +%Y-%m-%d)

# Create output directory
mkdir -p ./outputs/audits/$COMPANY_SLUG

# Determine which themes to run
if [ -z "$THEME" ] || [ "$THEME" = "all" ]; then
  THEMES=("Ease of Use" "Emotional Design" "Social Proof & Belonging" "Decision Support" "Service Orchestration")
  echo ""
  echo "🔍 Running FULL audit for: $COMPANY"
  echo "⏱️  Estimated time: 30-40 minutes"
  echo ""
else
  THEMES=("$THEME")
  echo ""
  echo "🔍 Running audit for: $COMPANY"
  echo "📋 Theme: $THEME"
  echo "⏱️  Estimated time: 8-12 minutes"
  echo ""
fi

# Process each theme
for CURRENT_THEME in "${THEMES[@]}"; do
  
  THEME_SLUG=$(echo "$CURRENT_THEME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
  OUTPUT_FILE="./outputs/audits/$COMPANY_SLUG/${DATE}-${THEME_SLUG}.csv"
  
  echo "📊 Researching: $CURRENT_THEME..."
  echo ""
  
  # Create the research prompt
  PROMPT="You are an evidence-led competitive intelligence analyst conducting an experience audit.

TARGET COMPANY: $COMPANY
THEME TO ANALYZE: $CURRENT_THEME
REGION: UK (analyze UK-specific experiences only)

YOUR TASK:
Research this company's publicly available experience and score ALL tactics within the \"$CURRENT_THEME\" theme.

TACTICS TO SCORE:
Read the complete tactics library from: ./tactics-library.md
Score ONLY the tactics under the \"$CURRENT_THEME\" section.

RESEARCH STRATEGY (Three-Tier Approach):

Tier 1 - Direct Observable Evidence (HIGH CONFIDENCE):
- Live public website (navigation, features, content)
- App Store listings (iOS/Android screenshots, descriptions, features)
- Public demo videos on YouTube
- Help center / knowledge base structure
- Public documentation
- Community forums / social media presence

Tier 2 - Review-Based Evidence (MEDIUM CONFIDENCE):
- Trustpilot reviews (search for specific tactic keywords)
- App Store reviews (user mentions of specific features)
- G2 / Capterra business reviews
- Reddit / forum discussions
- LinkedIn posts from users

Tier 3 - Proxy/Inference Evidence (LOW CONFIDENCE):
- Job postings (signals of priorities)
- Press releases (new features, partnerships)
- Case studies published by the company
- Conference presentations
- LinkedIn posts from employees

SCORING RUBRIC:
1 = No Evidence Found
  - Extensive public research conducted
  - No observable evidence
  - List where you looked
  
3 = Some Evidence
  - At least one concrete example
  - OR inferred from user reviews
  - Partial/inconsistent implementation
  
5 = Strong Evidence
  - Clear evidence across multiple channels
  - OR consistently praised in reviews
  - Mature, well-implemented

CONFIDENCE LEVELS:
- High: Directly observable (website, app stores, demos)
- Medium: From user reviews/feedback
- Low: From indirect signals (job posts, press, partnerships)
- None: No evidence found despite extensive search

OUTPUT FORMAT:
Create a CSV file at: $OUTPUT_FILE

CSV Columns (comma-separated):
Company,Theme,Tactic,Score,Confidence,EvidenceType,EvidenceSummary,SourceURL,Notes

Requirements:
- One row per tactic
- Evidence summaries ≤ 30 words
- Actual URLs (not placeholders)
- UK-region focus only
- No speculation - evidence only
- Mark \"No evidence\" if nothing found

After scoring, provide a summary:
✅ High confidence scores: X tactics
⚠️  Medium confidence scores: X tactics  
❓ Low confidence scores: X tactics
❌ No evidence found: X tactics

Suggest 3-5 areas that would benefit from manual research (e.g., \"Request demo account to test bulk actions\")

Now begin your research and create the CSV file."

  # Run the audit through Claude Code
  echo "$PROMPT" | npx @anthropic-ai/claude-code
  
  echo ""
  echo "✅ Completed: $CURRENT_THEME"
  echo "📄 Saved to: $OUTPUT_FILE"
  echo ""
  
done

echo ""
echo "🎉 Audit complete for: $COMPANY"
echo "📁 All results saved to: ./outputs/audits/$COMPANY_SLUG/"
echo ""
echo "💡 Next steps:"
echo "  1. Review the CSV files in VS Code or Excel"
echo "  2. Look for patterns (low scores = opportunities)"
echo "  3. Run ./commands/audit-compare.sh to compare multiple companies"
echo ""
