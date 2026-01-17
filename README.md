# PAI Personal Data Template

A template for storing your [PAI](https://github.com/danielmiessler/PAI) personal data in a separate, version-controlled repository.

## The Problem

PAI stores your learning, preferences, and work in three directories:
- `MEMORY/` - Learnings, research, session history
- `USER/` - Personal configuration overrides
- `WORK/` - Active work sessions

When PAI updates, these could be overwritten or cause merge conflicts.

## The Solution

Store your personal data in a **separate git repo** and **symlink** it into PAI. This gives you:

- **Update safety** - PAI updates never touch your data
- **Version control** - Full git history of your learnings
- **Backup** - Push to your private GitHub repo
- **Portability** - Clone to any machine, run setup, done

## Quick Start

```bash
# 1. Clone this template to your preferred location
git clone https://github.com/danielmiessler/pai-personal-data.git ~/my-pai-data
cd ~/my-pai-data

# 2. Run setup (creates symlinks to PAI)
./setup.sh

# 3. Set your remote to your own private repo
git remote set-url origin git@github.com:YOUR_USERNAME/YOUR_PRIVATE_REPO.git
git push -u origin main
```

That's it. Your personal data is now separate from PAI and backed up.

## What the Setup Script Does

1. Creates `MEMORY/`, `USER/`, `WORK/` directories if missing
2. Backs up any existing directories in PAI (to `*.backup`)
3. Creates symlinks from PAI to this repo:
   ```
   ~/.claude/MEMORY → ~/my-pai-data/MEMORY
   ~/.claude/USER   → ~/my-pai-data/USER
   ~/.claude/WORK   → ~/my-pai-data/WORK
   ```
4. Copies `.gitignore.template` to `.gitignore`
5. Initializes git if not already a repo

## Directory Structure

```
your-pai-data/
├── README.md              ← This file
├── setup.sh               ← One-command setup
├── .gitignore.template    ← Template (copied to .gitignore)
├── MEMORY/                ← Learning and research
│   └── .gitkeep
├── USER/                  ← Personal customizations
│   └── .gitkeep
└── WORK/                  ← Active work sessions
    └── .gitkeep
```

### MEMORY - Learning & Research

Everything PAI learns about you:
- `LEARNINGS/` - Patterns and insights from sessions
- `PAISYSTEMUPDATES/` - Session documentation
- `RESEARCH/` - Archived research
- `SIGNALS/` - Rating and sentiment data

### USER - Personal Configuration

Your customizations that override PAI defaults:
- `ASSETMANAGEMENT.md` - Your websites, domains, tech stacks
- `CONTACTS.md` - Contact directory
- `DAIDENTITY.md` - AI personality customization
- `TECHSTACKPREFERENCES.md` - Preferred technologies

### WORK - Active Sessions

Scratch space for ongoing work. The `scratch/` subdirectory is git-ignored for temporary files.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PAI_DIR` | `~/.claude` | PAI installation directory |

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

## Security Notes

- **Make your repo private** - It contains personal data
- **Review before pushing** - Check for accidental secrets
- **Use .gitignore** - Secrets are excluded by default

## Troubleshooting

### Symlinks not working

```bash
# Verify symlinks exist
ls -la ~/.claude/ | grep -E "MEMORY|USER|WORK"

# Re-run setup
./setup.sh
```

### PAI can't find data

```bash
# Check PAI_DIR matches your installation
echo $PAI_DIR  # Should be ~/.claude or your custom path
```

---

*Template for [PAI (Personal AI Infrastructure)](https://github.com/danielmiessler/PAI)*
