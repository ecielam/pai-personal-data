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

# Handle symlinks and backups
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
