# Analyzing Audit Results by User Segment

## Quick Reference: Which Tactics Matter for Which Users?

After running your audits, use this guide to filter and analyze results by user segment.

---

## Occasional Users — Building Confidence

**These tactics determine if your platform feels safe and learnable for infrequent users:**

### Theme 1: Ease of Use
- Clear navigation and findability
- Single workspace for key tasks
- Progressive disclosure
- Smart defaults and pre-filling
- Inline validation and helpful constraints
- Contextual help (tooltips, videos, guides)
- Drafts and autosave
- Undo/redo capabilities
- Fast feedback on actions
- Reliable performance at scale
- Works on poor connections
- Strong WCAG support
- Security without burden
- Consistent experience across devices

### Theme 2: Emotional Design
- Clean, calm design with clear hierarchy
- Gentle, purposeful animation
- Friendly, human language
- Avoids blame in errors
- Supportive service interactions
- Visual celebration of progress
- Clear sense of completion
- Onboarding that builds confidence
- Options to pace work
- Predictable updates and change notices
- Clear separation of safe vs. dangerous actions

### Theme 3: Social Proof & Belonging
- Social proof (awards, ratings, user numbers)
- Case studies from peer organizations
- Community spaces
- Professional profiles visible to clients
- Firm branding in client-facing views

### Theme 4: Decision Support
- Clear, layered explanations
- Visualizations of complex info
- In-context definitions and glossaries
- Time-anchored reminders
- Side-by-side comparisons
- Transparent cost breakdowns
- Recommendations / next-best-actions
- Highlighting of risks and anomalies
- Clear "what happens next" signposting

### Theme 5: Service Orchestration
- Consistent state across channels
- Clear journey architecture
- Smooth hand-offs between teams
- Multi-modal support options
- Proactive service
- Structured training paths
- Searchable knowledge base
- Migration and switching support
- Clean exit and closure flows

**If you're losing occasional users, focus on these gaps first.**

---

## Frequent Users — Enabling Efficiency

**These tactics determine if your platform helps regular users work efficiently:**

### Theme 1: Ease of Use
- All "Occasional User" tactics (they need the basics too)
- PLUS:
- Low-click flows for common tasks
- Robust search with filters and history
- Saved searches and frequently-used filters
- Quick actions (right-click menus, action shortcuts)
- Templates and presets

### Theme 2: Emotional Design
- Most emotional design tactics
- Dark mode / theme controls (for long sessions)
- Predictable updates and change notices

### Theme 3: Social Proof & Belonging
- Case studies from peer organizations
- Community spaces
- Champion/advocate programs
- Shared workspaces for teams
- Activity visibility for accountability
- Named human contacts
- Status indicators

### Theme 4: Decision Support
- All decision support tactics
- Scenario tools (what-if analysis)
- AI assistants for drafting, summarizing
- Activity logs and audit trails

### Theme 5: Service Orchestration
- All service orchestration tactics
- Visible SLAs and response times
- Structured training paths

**If you're losing frequent users, they likely need better efficiency tools.**

---

## High-Volume Users — Powering Scale

**These tactics determine if your platform can handle advisers with large client books:**

### Theme 1: Ease of Use — Critical Differentiators
- Progressive disclosure (scales to their needs)
- Low-click flows for common tasks
- Robust search with filters and history
- Saved searches and frequently-used filters
- Quick actions
- Templates and presets
- **Bulk actions** ⭐ CRITICAL
- **Workflow automation** ⭐ CRITICAL
- **Batch editing** ⭐ CRITICAL
- **Customizable views** ⭐ CRITICAL
- **Advanced export options** ⭐ CRITICAL
- Reliable performance at scale

### Theme 2: Emotional Design
- Dark mode / theme controls (long sessions)
- Predictable updates and change notices

### Theme 3: Social Proof & Belonging
- Peer benchmarks ("firms like you")
- Champion/advocate programs
- Shared workspaces for teams
- Activity visibility for accountability
- Named human contacts
- Status indicators

### Theme 4: Decision Support
- Scenario tools (what-if analysis)
- AI assistants for drafting, summarizing
- Data provenance (source, freshness, reliability)
- Activity logs and audit trails

### Theme 5: Service Orchestration
- Visible SLAs and response times
- **Data export and portability** ⭐ CRITICAL
- **Integration with other tools** ⭐ CRITICAL

**If you're losing high-volume users, check the ⭐ CRITICAL tactics first.**

---

## Strategic Analysis Framework

### Step 1: Run Your Audits

```bash
./commands/experience-audit.sh "Competitor A"
./commands/experience-audit.sh "Competitor B"
./commands/experience-audit.sh "Competitor C"
./commands/audit-compare.sh "Competitor A" "Competitor B" "Competitor C"
```

### Step 2: Filter the Comparison by User Type

Open the comparison CSV and create three views:

**View 1: Occasional User Tactics**
- Filter to tactics tagged "Occasional users" or "All users"
- Look for tactics where competitors score 4-5 and you score 1-3
- These are your **confidence gaps**

**View 2: Frequent User Tactics**
- Filter to tactics tagged "Frequent users" or "All users"
- Look for tactics where competitors score 4-5 and you score 1-3
- These are your **efficiency gaps**

**View 3: High-Volume User Tactics**
- Filter to tactics with ⭐ CRITICAL designation
- Look for tactics where competitors score 4-5 and you score 1-3
- These are your **scale gaps** (why you're becoming legacy)

### Step 3: Identify Your Strategic Position

**Scenario A: You're Weak on High-Volume Tactics**
```
Occasional: ✅ Strong (scores 4-5)
Frequent: ✅ Strong (scores 4-5)
High-Volume: ❌ Weak (scores 1-3)
```
**Diagnosis:** You're losing large firms/paraplanners
**Strategy:** Invest in bulk actions, automation, customization
**Risk:** Becoming a "small firm" platform

---

**Scenario B: You're Weak on Occasional User Tactics**
```
Occasional: ❌ Weak (scores 1-3)
Frequent: ✅ Strong (scores 4-5)
High-Volume: ✅ Strong (scores 4-5)
```
**Diagnosis:** You're intimidating to new users
**Strategy:** Invest in onboarding, help, friendly UX
**Risk:** Only serving established firms, not winning new advisers

---

**Scenario C: You're Weak Across All User Types**
```
Occasional: ❌ Weak
Frequent: ❌ Weak
High-Volume: ❌ Weak
```
**Diagnosis:** Broad experience debt
**Strategy:** Pick one segment to fix first (recommend High-Volume if becoming legacy)
**Risk:** Trying to fix everything at once

---

**Scenario D: You're Strong But Becoming Legacy**
```
Occasional: ✅ Strong
Frequent: ✅ Strong
High-Volume: ✅ Strong
```
**Diagnosis:** Not an experience problem — likely pricing, relationships, or switching costs
**Strategy:** Look at Service Orchestration (Theme 5) — are you helping firms migrate?
**Risk:** Complacency while market shifts

---

## Sample Analysis Questions

Once you have your audit results, ask:

### About Market Position:
- "Are we losing to someone who's better at everything, or better for someone?"
- "Which user segment do our competitors clearly target?"
- "Where are we differentiated vs. me-too?"

### About Strategic Choices:
- "Should we double down on occasional users and own that segment?"
- "Or should we invest in high-volume tactics to become 'first choice' again?"
- "Can we realistically serve all three segments, or should we pick?"

### About Implementation:
- "Which 5 tactics would have the biggest impact on our target segment?"
- "What's the effort vs. impact of each gap we've identified?"
- "Are we trying to fix too much at once?"

---

## Next Steps

1. **Run audits on 3-5 competitors**
2. **Create the comparison CSV**
3. **Filter by user segment using this guide**
4. **Identify your strategic position**
5. **Choose which segment to serve best**
6. **Prioritize 5-10 tactics to close the gap**

Remember: You don't need to be strong at everything. But you need to be **exceptional for someone**.
