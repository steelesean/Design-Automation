# Design Automation

AI-enabled tooling for design teams to automate research, competitive intelligence, and journey mapping.

---

## The Problem

You're Head of Design at a B2B2C investment platform that's becoming a "legacy platform" when you want to be "first choice." You need to understand why you're losing ground to competitors and where the opportunities are.

**The Strategic Insight:** Platforms become "legacy" when they optimize for the wrong user segment. The audit framework reveals whether you're serving Occasional, Frequent, or High-Volume users—and whether competitors are winning a segment you should own.

---

## The Vision

Your design team becomes 10x more efficient because AI handles the tedious parts (research, competitor tracking, documentation) while humans focus on strategy and craft.

**What we're automating:**
- Discovery & research
- Competitor audits
- Journey mapping
- Research synthesis

---

## Project Structure

```
design-automation/
├── commands/                    # Shell scripts (your tools)
│   ├── experience-audit.sh      # Competitive audit (68 tactics × 5 themes)
│   ├── audit-compare.sh         # Compare multiple companies side-by-side
│   ├── journey-mapper.sh        # Map competitor customer journeys
│   ├── learn.sh                 # Personal knowledge building
│   └── future-idea.sh           # Capture ideas for future commands
│
├── dashboard/                   # React heatmap dashboard (GitHub Pages)
│   ├── src/
│   │   ├── App.jsx              # Main dashboard component
│   │   ├── App.css              # Styles
│   │   └── main.jsx             # Entry point
│   ├── public/
│   │   └── audit-data.csv       # Data powering the dashboard
│   ├── package.json             # Vite + React + PapaParse
│   └── .git/                    # Separate git repo for GitHub Pages
│
├── outputs/                     # Generated outputs from tools
│   ├── audits/
│   │   ├── master-competitive-audit.csv   # Aggregated audit data
│   │   └── [company-slug]/                # Per-company audit results
│   │       └── [date]-[theme].csv
│   └── journey-maps/
│       └── [date]-[company]-[product].md
│
├── future-ideas/                # Captured ideas for future tools
│   └── [date]-[idea-slug].txt
│
├── learning/                    # Personal learning outputs
│   └── [date]-[topic].txt
│
├── tactics-library.md           # 68 tactics across 5 themes (reference doc)
├── USER-SEGMENT-ANALYSIS.md     # Maps tactics to user segments
├── linear-helper.js             # Linear integration utilities
├── get-linear-labels.js         # Linear label helper
└── README.md                    # This file
```

---

## Tools Built

### 1. Experience Audit (`experience-audit.sh`)

Benchmarks a company's digital experience against 68 tactics across 5 themes.

**Usage:**
```bash
./commands/experience-audit.sh "Company Name" "Theme"     # Single theme
./commands/experience-audit.sh "Company Name" "all"       # All 5 themes
```

**Themes:**
1. Ease of Use - Can I get things done quickly?
2. Emotional Design - How does it make me feel?
3. Social Proof & Belonging - Do I belong here?
4. Decision Support - Can I make good decisions?
5. Service Orchestration - Is this frictionless end-to-end?

**Output:** CSV file with columns:
- Company, Category, Theme, Tactic_ID, Tactic_Name, Score, Confidence, Evidence, Source

**Scoring:**
- 1 = No evidence found
- 3 = Some evidence (partial implementation)
- 5 = Strong evidence (mature, well-implemented)

---

### 2. Audit Compare (`audit-compare.sh`)

Compares multiple companies' audit results side-by-side with gap analysis.

**Usage:**
```bash
./commands/audit-compare.sh "Company1" "Company2" "Company3"
```

**Output:** Comparison CSV with gap analysis categories:
- "Industry Standard" (all score ≥4)
- "Competitive Gap" (variance >2)
- "Market Opportunity" (all score ≤2)

---

### 3. Journey Mapper (`journey-mapper.sh`)

Maps the end-to-end customer journey for a competitor's product using publicly available information.

**Usage:**
```bash
./commands/journey-mapper.sh "Company" "Product"
# Example: ./commands/journey-mapper.sh "Aviva" "SIPP"
```

**Output:** Markdown document covering 7 stages:
1. Awareness
2. Research & Consideration
3. Sign-up & Application
4. Onboarding
5. Core Usage
6. Support & Service
7. Retention & Growth

Each stage includes: Touchpoints, Channels, Messaging/CTAs, Trust Signals, Friction Points, Opportunities

---

### 4. Heatmap Dashboard (React)

Visual analysis dashboard showing all competitors across all tactics.

**Features:**
- Heatmap grid: tactics as rows, companies as columns
- Color-coded scores (1=red → 5=green)
- Company averages with per-theme breakdown on hover
- Filter by theme
- Sort by tactic ID or average score
- Sidebar insights: Opportunities (low avg) and Battlegrounds (high avg)
- Hover tooltips showing evidence for each score

**Tech Stack:** Vite + React + PapaParse

**Deployment:** GitHub Pages at https://steelesean.github.io/Design-Automation/

**To update dashboard:**
```bash
cd dashboard
npm run build
git add .
git commit -m "Update dashboard"
git push origin main
```

---

### 5. Learn (`learn.sh`)

Creates beginner-friendly learning materials about technical topics.

**Usage:**
```bash
./commands/learn.sh "topic name"
```

**Output:** Text file at `./learning/[date]-[topic].txt`

---

### 6. Future Idea (`future-idea.sh`)

Captures ideas for future commands with a structured template.

**Usage:**
```bash
./commands/future-idea.sh "idea description"
```

**Output:** Template file at `./future-ideas/[date]-[idea-slug].txt`

---

## Data Formats

### Audit CSV Format

The master audit data (`outputs/audits/master-competitive-audit.csv` and `dashboard/public/audit-data.csv`) uses this format:

```csv
Company,Category,Theme,Tactic_ID,Tactic_Name,Score,Confidence,Evidence,Source
Aviva,Competitor,Ease of Use,1,Clear navigation and findability,5,High,"Evidence summary here",source.com
```

**Categories:**
- Competitors (e.g., Quilter, Transact, Aviva, AJ Bell, Aberdeen)
- Fintechs (e.g., Monzo, Revolut, Wise)
- Market Leaders (e.g., Netflix, Amazon, OpenAI)

---

## GitHub Setup

The dashboard has its own git repository inside `dashboard/` for GitHub Pages deployment.

**Remote:** https://github.com/steelesean/Design-Automation.git

**To push changes:**
```bash
cd ~/design-automation/dashboard
git add .
git commit -m "Your message"
git push origin main
```

**Note:** Your GitHub token needs the `workflow` scope to push (due to the GitHub Actions deploy workflow).

---

## Future Ideas Captured

See `future-ideas/` folder for captured ideas, including:
- Auto-generate accessibility audit from Figma file

---

## Key Reference Documents

- **tactics-library.md** - Full list of 68 tactics with descriptions
- **USER-SEGMENT-ANALYSIS.md** - Maps tactics to user segments (Occasional, Frequent, Power, Enterprise)

---

## Session Context for Claude

When starting a new session, Claude should:

1. Read this README for project context
2. Check `outputs/audits/` for existing audit data
3. Check `outputs/journey-maps/` for existing journey maps
4. Review `future-ideas/` for pending tool ideas
5. The dashboard repo is at `dashboard/` with its own `.git`

**Common tasks:**
- Adding features to the dashboard → Edit `dashboard/src/App.jsx` and `App.css`
- Running an audit → `./commands/experience-audit.sh "Company" "Theme"`
- Mapping a journey → `./commands/journey-mapper.sh "Company" "Product"`
- Pushing to GitHub → `cd dashboard && git add . && git commit -m "msg" && git push`

**User context:** The user is a design leader, not a developer. Keep explanations simple and avoid creating complexity. One project, one location, clear steps.
