#!/usr/bin/env bash

# Agentic Kernel Installer
# Quickly bootstrap a project with the Agentic Kernel framework

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Initializing Agentic Kernel...${NC}"

TARGET_DIR="${1:-.}"
AGENT_DIR="$TARGET_DIR/.agents"

# Create directories
echo "Creating directory structure in $AGENT_DIR..."
mkdir -p "$AGENT_DIR/skills/01_mission_synthesis"
mkdir -p "$AGENT_DIR/skills/02_execution_engine"
mkdir -p "$AGENT_DIR/skills/03_verification_matrix"
mkdir -p "$AGENT_DIR/skills/04_cognitive_persistence"
mkdir -p "$AGENT_DIR/skills/05_interface_protocols"
mkdir -p "$AGENT_DIR/skills/06_adaptive_protocols"
mkdir -p "$AGENT_DIR/templates"
mkdir -p "$TARGET_DIR/.docs/architecture"
mkdir -p "$TARGET_DIR/.docs/context"
mkdir -p "$TARGET_DIR/.docs/decisions"
mkdir -p "$TARGET_DIR/.docs/learned_rules"

# Copy files
echo "Copying kernel files..."
cp -r SYSTEM_CORE.md "$AGENT_DIR/"
cp -r skills/* "$AGENT_DIR/skills/"
cp -r templates/* "$AGENT_DIR/templates/"

# Initialize progress log
if [ ! -f "$TARGET_DIR/progress_log.md" ]; then
    echo "Initializing progress_log.md..."
    cp templates/PROGRESS_LOG_TEMPLATE.md "$TARGET_DIR/progress_log.md"
fi

echo -e "${GREEN}Agentic Kernel successfully installed in $TARGET_DIR!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Integrate SYSTEM_CORE.md with your agent's system prompt or rules file."
echo "   See QUICKSTART.md for examples (Claude Code, Cursor, Copilot, etc.)."
echo "2. Tell your agent to begin Phase 1 (Mission Synthesis) for your first task."
