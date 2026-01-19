#!/bin/bash
# link_skills.sh - Symlink local skills to ~/.claude/skills/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"
SKILLS_DEST="$HOME/.claude/skills"

# Create destination if needed
mkdir -p "$SKILLS_DEST"

# Link each skill
for skill in "$SKILLS_SRC"/*/; do
    skill_name=$(basename "$skill")
    target="$SKILLS_DEST/$skill_name"

    if [ -L "$target" ]; then
        echo "Updating: $skill_name"
        rm "$target"
    elif [ -e "$target" ]; then
        echo "Skipping: $skill_name (already exists, not a symlink)"
        continue
    else
        echo "Linking: $skill_name"
    fi

    ln -s "$skill" "$target"
done

echo "Done. Linked skills:"
ls -la "$SKILLS_DEST" | grep "^l"
