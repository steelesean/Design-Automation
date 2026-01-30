#!/bin/bash
# Journey Mapper Command
# Maps the end-to-end customer journey for a competitor's product
# using publicly available information

COMPANY="$1"
PRODUCT="$2"

if [ -z "$COMPANY" ] || [ -z "$PRODUCT" ]; then
  echo ""
  echo "Usage: ./commands/journey-mapper.sh \"Company\" \"Product\""
  echo ""
  echo "Examples:"
  echo "  ./commands/journey-mapper.sh \"Aviva\" \"SIPP\""
  echo "  ./commands/journey-mapper.sh \"Vanguard\" \"ISA\""
  echo "  ./commands/journey-mapper.sh \"Hargreaves Lansdown\" \"General Investment Account\""
  echo ""
  echo "This command researches publicly available information to map"
  echo "the complete customer journey from awareness through retention."
  echo ""
  exit 1
fi

# Create slugs for filename
COMPANY_SLUG=$(echo "$COMPANY" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
PRODUCT_SLUG=$(echo "$PRODUCT" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
DATE=$(date +%Y-%m-%d)
OUTPUT_FILE="./outputs/journey-maps/${DATE}-${COMPANY_SLUG}-${PRODUCT_SLUG}.md"

# Ensure output directory exists
mkdir -p ./outputs/journey-maps

echo ""
echo "🗺️  Journey Mapper: $COMPANY $PRODUCT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⏳ Researching publicly available information..."
echo "   This typically takes 2-3 minutes."
echo ""

PROMPT="You are a UX researcher mapping the customer journey for $COMPANY's $PRODUCT.

## Your Task
Research all publicly available information to create a comprehensive journey map. Use:
- The company's official website
- App store listings and reviews
- Trustpilot and similar review sites
- Comparison websites
- Financial guides and articles
- Social media presence
- Any public documentation or help centers

## Output Format
Create a detailed markdown document and save it to: $OUTPUT_FILE

## Journey Stages to Map
For each stage, document:
- **Touchpoints**: What specific interactions occur
- **Channels**: Where this happens (web, app, phone, email, etc.)
- **User Actions**: What the customer does
- **Messaging & CTAs**: Key language and calls-to-action used
- **Trust Signals**: Credibility indicators present
- **Friction Points**: Pain points, complexity, or barriers
- **Opportunities**: Where competitors could differentiate

### Stage 1: Awareness
How do potential customers first discover $COMPANY's $PRODUCT?
- Marketing channels, advertising, SEO presence
- Brand positioning and value proposition
- Initial impressions and messaging

### Stage 2: Research & Consideration
How do customers evaluate the product?
- Information architecture on the website
- Comparison tools, calculators, educational content
- Pricing transparency and fee structures
- Social proof (reviews, ratings, testimonials)

### Stage 3: Sign-up & Application
What is the account opening experience?
- Application flow and required information
- Identity verification process
- Time to complete
- Mobile vs desktop experience
- Drop-off risks

### Stage 4: Onboarding
How are new customers activated?
- Welcome communications
- First-time user experience
- Funding the account
- Making first investment
- Educational prompts

### Stage 5: Core Usage
What is the ongoing product experience?
- Key features and functionality
- Portfolio management tools
- Research and insights
- Mobile app experience
- Notifications and alerts

### Stage 6: Support & Service
How are issues resolved?
- Help center and self-service
- Contact channels (chat, phone, email)
- Response times (from reviews)
- Common complaints and praise

### Stage 7: Retention & Growth
How does $COMPANY keep and grow customers?
- Loyalty features
- Cross-sell and upsell
- Regular communications
- Annual reviews or check-ins
- Exit barriers and switching costs

## Document Structure
Use this structure for the output file:

\`\`\`markdown
# Customer Journey Map: $COMPANY $PRODUCT

**Generated:** $DATE
**Research Method:** Public information analysis

## Executive Summary
[2-3 paragraph overview of the journey, key strengths, and main friction points]

## Journey Overview
[Visual representation using a simple table or list showing the 7 stages]

## Detailed Journey Analysis

### 1. Awareness
[Detailed findings for this stage]

### 2. Research & Consideration
[Detailed findings for this stage]

[Continue for all 7 stages...]

## Key Findings

### Strengths
- [Bullet points of what they do well]

### Friction Points
- [Bullet points of pain points and barriers]

### Opportunities
- [Bullet points of gaps or improvement areas]

## Competitive Implications
[How does this journey compare to industry expectations? What can your platform learn?]

## Data Sources
[List the URLs and sources referenced]
\`\`\`

## Important Notes
- Be specific with evidence - quote actual messaging, describe actual UI elements
- Note confidence levels - distinguish between confirmed observations vs inferences
- Include URLs where you found key information
- If information is unavailable for a stage, note what's missing and why it matters

Now research and create the journey map for $COMPANY's $PRODUCT."

echo "$PROMPT" | npx @anthropic-ai/claude-code

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Journey map complete!"
echo ""
echo "📁 Output saved to: $OUTPUT_FILE"
echo ""
echo "💡 Next steps:"
echo "   - Review the journey map for accuracy"
echo "   - Compare against your own product's journey"
echo "   - Use findings to inform experience-audit.sh themes"
echo ""
