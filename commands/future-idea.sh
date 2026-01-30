#!/bin/bash

# Get the idea description
IDEA="$1"

if [ -z "$IDEA" ]; then
  echo "Usage: ./commands/future-idea.sh \"description of command idea\""
  exit 1
fi

# Ensure future-ideas directory exists
mkdir -p ./future-ideas

# Create filename
FILENAME=$(echo "$IDEA" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-' | cut -c1-50)
DATE=$(date +%Y-%m-%d)
OUTPUT_FILE="./future-ideas/${DATE}-${FILENAME}.txt"

echo ""
echo "💡 Capturing future command idea..."
echo ""

# Create the file directly with a structured template
cat > "$OUTPUT_FILE" << EOF
FUTURE COMMAND IDEA
===================
$IDEA

Captured: $DATE
Status: Draft


1. COMMAND NAME
---------------
[What would you type to run this? e.g., ./commands/my-command.sh <args>]



2. PURPOSE
----------
[What problem does this solve? Why is it valuable?]



3. INPUTS NEEDED
----------------
Required:
- [What information or files does it need?]

Optional:
- [Any optional parameters or configurations?]



4. OUTPUTS GENERATED
--------------------
[What does this command produce? Files, reports, tickets, notifications?]



5. KEY STEPS
------------
1. [High-level workflow step]
2. [Next step]
3. [Continue as needed]



6. TOOLS/APIs REQUIRED
----------------------
Essential:
- [What APIs or tools are required?]

Optional:
- [Nice-to-have integrations]



7. ESTIMATED COMPLEXITY
-----------------------
[ ] Simple - Can build in a single session
[ ] Medium - Requires some research or multiple components
[ ] Complex - Needs phased approach or significant exploration



8. QUESTIONS TO ANSWER BEFORE BUILDING
--------------------------------------
- [What do you need to figure out first?]
- [Any decisions to make?]
- [Dependencies or blockers?]



RELATED COMMANDS
----------------
[What other commands might complement this one?]



NOTES
-----
[Any additional thoughts, inspirations, or references]

EOF

# Verify file was created
if [ -f "$OUTPUT_FILE" ]; then
  echo "✅ Future idea saved to: $OUTPUT_FILE"
  echo ""
  echo "📝 The file contains a template to flesh out your idea."
  echo "   Run 'claude' and ask it to help expand the brief!"
else
  echo "❌ Error: Could not create file at $OUTPUT_FILE"
  echo "   Check directory permissions and try again."
  exit 1
fi

echo ""
echo "💡 Tip: Review your ideas anytime in the future-ideas folder"
echo ""
