#!/bin/bash
#
# PAI Personal Data Setup Script
#
# Creates symlinks from PAI to this repository for personal data storage.
# Run from the root of your personal data repo.
#
# Usage:
#   cd /path/to/your/pai-data-repo
#   ./setup.sh
#
# Environment:
#   PAI_DIR - PAI installation directory (default: ~/.claude)
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PAI_DIR="${PAI_DIR:-$HOME/.claude}"
REPO_DIR="$(pwd)"
DIRS=("MEMORY" "USER" "WORK")

echo -e "${BLUE}PAI Personal Data Setup${NC}"
echo "========================"
echo ""
echo "Repository:  $REPO_DIR"
echo "PAI Directory: $PAI_DIR"
echo ""

# Verify we're in a reasonable location
if [[ "$REPO_DIR" == "$HOME" ]]; then
    echo -e "${RED}Error: Don't run this from your home directory.${NC}"
    echo "Clone or create your personal data repo first, then run setup.sh from there."
    exit 1
fi

# Check PAI directory exists
if [[ ! -d "$PAI_DIR" ]]; then
    echo -e "${RED}Error: PAI directory not found at $PAI_DIR${NC}"
    echo "Set PAI_DIR environment variable if PAI is installed elsewhere."
    exit 1
fi

# Create directories in this repo if they don't exist
echo -e "${BLUE}Creating directories...${NC}"
for dir in "${DIRS[@]}"; do
    if [[ ! -d "$REPO_DIR/$dir" ]]; then
        mkdir -p "$REPO_DIR/$dir"
        echo -e "  ${GREEN}Created${NC} $dir/"
    else
        echo -e "  ${YELLOW}Exists${NC}  $dir/"
    fi
done

# Handle symlinks and backups for main directories
echo ""
echo -e "${BLUE}Setting up symlinks...${NC}"
for dir in "${DIRS[@]}"; do
    target="$REPO_DIR/$dir"
    link="$PAI_DIR/$dir"

    if [[ -L "$link" ]]; then
        # Already a symlink
        current_target=$(readlink "$link")
        if [[ "$current_target" == "$target" ]]; then
            echo -e "  ${GREEN}OK${NC}      $link -> $target"
        else
            echo -e "  ${YELLOW}Update${NC}  $link (was -> $current_target)"
            rm "$link"
            ln -s "$target" "$link"
            echo -e "  ${GREEN}Linked${NC}  $link -> $target"
        fi
    elif [[ -d "$link" ]]; then
        # Existing directory - backup and replace
        backup="${link}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "  ${YELLOW}Backup${NC}  $link -> $backup"
        mv "$link" "$backup"
        ln -s "$target" "$link"
        echo -e "  ${GREEN}Linked${NC}  $link -> $target"
    else
        # Nothing there - create symlink
        ln -s "$target" "$link"
        echo -e "  ${GREEN}Linked${NC}  $link -> $target"
    fi
done

# Handle CORE_USER -> ~/.claude/skills/CORE/USER
echo ""
echo -e "${BLUE}Setting up CORE_USER...${NC}"
CORE_USER_TARGET="$REPO_DIR/CORE_USER"
CORE_USER_LINK="$PAI_DIR/skills/CORE/USER"

if [[ -d "$REPO_DIR/CORE_USER" ]]; then
    # Ensure the parent directory exists
    mkdir -p "$PAI_DIR/skills/CORE"

    if [[ -L "$CORE_USER_LINK" ]]; then
        # Already a symlink
        current_target=$(readlink "$CORE_USER_LINK")
        if [[ "$current_target" == "$CORE_USER_TARGET" ]]; then
            echo -e "  ${GREEN}OK${NC}      $CORE_USER_LINK -> $CORE_USER_TARGET"
        else
            echo -e "  ${YELLOW}Update${NC}  $CORE_USER_LINK (was -> $current_target)"
            rm "$CORE_USER_LINK"
            ln -s "$CORE_USER_TARGET" "$CORE_USER_LINK"
            echo -e "  ${GREEN}Linked${NC}  $CORE_USER_LINK -> $CORE_USER_TARGET"
        fi
    elif [[ -d "$CORE_USER_LINK" ]]; then
        # Existing directory - DON'T auto-backup, warn user
        echo -e "  ${RED}WARNING${NC} Existing directory found at:"
        echo -e "          $CORE_USER_LINK"
        echo ""
        echo -e "  ${YELLOW}This contains your personal CORE user data.${NC}"
        echo -e "  To use this repo for CORE_USER, you must manually:"
        echo ""
        echo -e "    1. Move your data:  ${BLUE}mv $CORE_USER_LINK/* $CORE_USER_TARGET/${NC}"
        echo -e "    2. Remove the dir:  ${BLUE}rmdir $CORE_USER_LINK${NC}"
        echo -e "    3. Re-run setup:    ${BLUE}./setup.sh${NC}"
        echo ""
        echo -e "  ${YELLOW}Skipping CORE_USER setup for now.${NC}"
    else
        # Nothing there - create symlink
        ln -s "$CORE_USER_TARGET" "$CORE_USER_LINK"
        echo -e "  ${GREEN}Linked${NC}  $CORE_USER_LINK -> $CORE_USER_TARGET"
    fi
else
    echo -e "  ${YELLOW}Skipped${NC} CORE_USER/ directory not found in repo"
fi

# Handle personal skills
echo ""
echo -e "${BLUE}Setting up personal skills...${NC}"
SKILLS_DIR="$REPO_DIR/skills"

if [[ -d "$SKILLS_DIR" ]]; then
    # Count subdirectories (actual skills, not just .gitkeep)
    skill_count=$(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)

    if [[ $skill_count -gt 0 ]]; then
        echo -e "  Found $skill_count skill(s) to link"
        if [[ -x "$REPO_DIR/link_skills.sh" ]]; then
            "$REPO_DIR/link_skills.sh"
        else
            echo -e "  ${YELLOW}Warning${NC} link_skills.sh not found or not executable"
        fi
    else
        echo -e "  ${YELLOW}Skipped${NC} No skills found in skills/ (add _ALLCAPS skill directories)"
    fi
else
    echo -e "  ${YELLOW}Skipped${NC} skills/ directory not found"
fi

# Copy gitignore template if it exists and .gitignore doesn't
if [[ -f "$REPO_DIR/.gitignore.template" ]] && [[ ! -f "$REPO_DIR/.gitignore" ]]; then
    echo ""
    echo -e "${BLUE}Setting up .gitignore...${NC}"
    cp "$REPO_DIR/.gitignore.template" "$REPO_DIR/.gitignore"
    echo -e "  ${GREEN}Created${NC} .gitignore from template"
fi

# Initialize git if not already
if [[ ! -d "$REPO_DIR/.git" ]]; then
    echo ""
    echo -e "${BLUE}Initializing git repository...${NC}"
    git init
    echo -e "  ${GREEN}Initialized${NC} git repository"
fi

echo ""
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Add your remote: git remote add origin git@github.com:YOU/your-repo.git"
echo "  2. Commit and push: git add -A && git commit -m 'Initial setup' && git push -u origin main"
echo ""
echo "Your PAI personal data is now stored in this repository."
