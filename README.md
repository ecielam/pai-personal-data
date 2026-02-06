# PAI Personal Data Template

A template for storing your [PAI](https://github.com/danielmiessler/PAI) personal data in a separate, version-controlled repository.

## Why Separate Your Data?

PAI stores personal data in several directories within `~/.claude/`. When PAI updates, these could be overwritten or cause merge conflicts. By storing your data in a separate repo and symlinking back, you get:

- **Update safety** - PAI updates never touch your data
- **Version control** - Full git history of your learnings and configurations
- **Backup** - Push to your private GitHub repo
- **Portability** - Clone to any machine, run setup, done

## The "Move Out, Link Back" Pattern

This template uses symlinks to keep your data in this repo while PAI sees it in its expected locations:

```
Your Repo (source of truth)          PAI Directory (symlinks)
========================             ====================
~/my-pai-data/MEMORY/       <-----   ~/.claude/MEMORY
~/my-pai-data/USER/         <-----   ~/.claude/USER
~/my-pai-data/WORK/         <-----   ~/.claude/WORK
~/my-pai-data/CORE_USER/    <-----   ~/.claude/skills/CORE/USER
~/my-pai-data/skills/_FOO/  <-----   ~/.claude/skills/_FOO
```

## Quick Start

```bash
# 1. Clone this template
git clone https://github.com/ecielam/pai-personal-data.git ~/my-pai-data
cd ~/my-pai-data

# 2. Run setup (creates symlinks)
./setup.sh

# 3. Set your remote to your own PRIVATE repo
git remote set-url origin git@github.com:YOUR_USERNAME/YOUR_PRIVATE_REPO.git
git push -u origin main
```

## Directory Structure

```
your-pai-data/
├── README.md              # This file
├── setup.sh               # One-command setup script
├── link_skills.sh         # Helper to symlink personal skills
├── .gitignore.template    # Template (copied to .gitignore on first run)
│
├── MEMORY/                # Learning, research, session history
│   └── .gitkeep
│
├── USER/                  # Personal configuration overrides
│   └── .gitkeep
│
├── WORK/                  # Active work sessions
│   └── .gitkeep
│
├── CORE_USER/             # CORE skill user overrides
│   └── .gitkeep
│
└── skills/                # Personal skills (_ALLCAPS naming)
    └── .gitkeep
```

## What Goes Where

### MEMORY/ - Learning & Research

Everything PAI learns and remembers:

| Subdirectory | Contents |
|--------------|----------|
| `LEARNINGS/` | Patterns and insights from sessions |
| `PAISYSTEMUPDATES/` | Session documentation and changelogs |
| `RESEARCH/` | Archived research and investigations |
| `SIGNALS/` | Rating and sentiment data |

### USER/ - Personal Configuration

Your customizations that override PAI system defaults:

| File | Purpose |
|------|---------|
| `ASSETMANAGEMENT.md` | Your websites, domains, deployment methods |
| `CONTACTS.md` | Contact directory |
| `DAIDENTITY.md` | AI personality customization |
| `TECHSTACKPREFERENCES.md` | Preferred technologies and tools |
| `PAISECURITYSYSTEM/` | Personal security patterns |

### WORK/ - Active Sessions

Scratch space for ongoing work. Contains `scratch/` subdirectory for temporary files (git-ignored).

### CORE_USER/ - CORE Skill Overrides

The CORE skill auto-loads at every session start. This directory contains your personal overrides:

| Subdirectory | Contents |
|--------------|----------|
| `TELOS/` | Your goals, projects, life direction documents |
| `RESPONSEFORMAT.md` | Custom response format preferences |
| Other `.md` files | Any CORE-level customizations |

**Important**: If you already have content in `~/.claude/skills/CORE/USER`, you must move it here manually before running setup.

### skills/ - Personal Skills

Personal skills use the `_ALLCAPS` naming convention (e.g., `_BLOGGING`, `_MYWORKFLOW`). These are private and never sync to the public PAI repo.

To add a personal skill:
1. Create a directory: `skills/_MYSKILL/`
2. Add at minimum: `skills/_MYSKILL/SKILL.md`
3. Run `./link_skills.sh` or `./setup.sh`

## Migrating Existing Data

If you already have PAI data, follow these steps to migrate:

### Step 1: Clone This Template

```bash
git clone https://github.com/ecielam/pai-personal-data.git ~/my-pai-data
cd ~/my-pai-data
```

### Step 2: Move Your Existing Data

```bash
# Move main directories (setup.sh handles this automatically with backups)
# But for CORE_USER, you must do it manually:

# Check if you have existing CORE/USER data
ls ~/.claude/skills/CORE/USER

# If it exists and has content, move it:
mv ~/.claude/skills/CORE/USER/* ~/my-pai-data/CORE_USER/
rmdir ~/.claude/skills/CORE/USER

# For personal skills, move them too:
mv ~/.claude/skills/_MYSKILL ~/my-pai-data/skills/
```

### Step 3: Run Setup

```bash
./setup.sh
```

The setup script will:
1. Create any missing directories
2. Backup existing PAI directories (MEMORY, USER, WORK)
3. Create symlinks pointing back to this repo
4. Link CORE_USER if the PAI location is empty
5. Link any personal skills in `skills/`

### Step 4: Verify

```bash
# Check symlinks are correct
ls -la ~/.claude/ | grep -E "MEMORY|USER|WORK"
ls -la ~/.claude/skills/CORE/

# Check skills are linked
ls -la ~/.claude/skills/ | grep "^l"
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PAI_DIR` | `~/.claude` | PAI installation directory |

## Security Notes

**This repository contains personal data. Keep it private.**

- Make your GitHub repo **private**
- Review commits before pushing - check for accidental secrets
- The `.gitignore` excludes common secret patterns
- Never commit API keys, credentials, or tokens
- CORE_USER may contain personal goals and life information

### What's Excluded by Default

The `.gitignore.template` excludes:
- `.env` files and credentials
- `scratch/` directories (temporary files)
- `node_modules/` in skills
- Common secret file patterns

## Maintenance

### Regular Backups

```bash
cd ~/my-pai-data
git add -A
git commit -m "Session update: $(date +%Y-%m-%d)"
git push
```

### New Machine Setup

```bash
git clone git@github.com:YOU/your-pai-data.git ~/my-pai-data
cd ~/my-pai-data
./setup.sh
```

### Adding a New Personal Skill

```bash
cd ~/my-pai-data
mkdir -p skills/_NEWSKILL
cat > skills/_NEWSKILL/SKILL.md << 'EOF'
---
name: _NEWSKILL
description: Description of what this skill does
---

# _NEWSKILL

Your skill documentation here.
EOF

# Link it
./link_skills.sh
```

## Troubleshooting

### Symlinks Not Working

```bash
# Verify symlinks exist
ls -la ~/.claude/ | grep -E "MEMORY|USER|WORK"

# Re-run setup
./setup.sh
```

### CORE_USER Shows Warning

If setup.sh shows a warning about existing CORE_USER directory:

```bash
# Move your existing data first
mv ~/.claude/skills/CORE/USER/* ~/my-pai-data/CORE_USER/
rmdir ~/.claude/skills/CORE/USER

# Then re-run setup
./setup.sh
```

### Skills Not Linking

```bash
# Check skills directory has actual skill folders
ls -la skills/

# Make sure link_skills.sh is executable
chmod +x link_skills.sh

# Run it directly
./link_skills.sh
```

### PAI Can't Find Data

```bash
# Check PAI_DIR matches your installation
echo $PAI_DIR  # Should be ~/.claude or your custom path

# Verify the symlinks resolve correctly
realpath ~/.claude/MEMORY
realpath ~/.claude/USER
```

## Full Symlink Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Your Personal Data Repo                         │
│                      ~/my-pai-data/                                 │
├─────────────────────────────────────────────────────────────────────┤
│  MEMORY/          USER/           WORK/                             │
│  CORE_USER/       skills/_FOO/    skills/_BAR/                      │
└────────┬─────────────┬──────────────┬──────────────────────────────┘
         │             │              │
         │ symlinks    │              │
         ▼             ▼              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         PAI (~/.claude/)                            │
├─────────────────────────────────────────────────────────────────────┤
│  MEMORY → ../my-pai-data/MEMORY                                     │
│  USER   → ../my-pai-data/USER                                       │
│  WORK   → ../my-pai-data/WORK                                       │
│  skills/                                                            │
│    ├── CORE/                                                        │
│    │   └── USER → ../../../my-pai-data/CORE_USER                    │
│    ├── _FOO → ../../my-pai-data/skills/_FOO                         │
│    └── _BAR → ../../my-pai-data/skills/_BAR                         │
└─────────────────────────────────────────────────────────────────────┘
```

---

*Template for [PAI (Personal AI Infrastructure)](https://github.com/danielmiessler/PAI)*
