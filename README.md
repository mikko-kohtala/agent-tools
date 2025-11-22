# Agent Tools

A curated collection of agent commands and skills for various CLI-based AI coding assistants, including Claude Code, Codex CLI, Gemini CLI, and other agent-based development tools.

## About

This repository provides reusable skills and commands that extend the capabilities of AI coding assistants. Skills enable agents to interact with external tools and services, while commands provide templates for common development workflows.

## Installation

### Add Marketplace from GitHub

```
/plugin marketplace add mikko-kohtala/agent-tools/main
```

Then install skills:

```
/plugins install tmux
/plugins install windmill
```

### Install Individual Skills Directly

```
/plugins install github:mikko-kohtala/agent-tools/main/skills/tmux
/plugins install github:mikko-kohtala/agent-tools/main/skills/windmill
```

## Skills

### tmux (`skills/tmux/`)

Remote control tmux sessions for interactive CLIs (Python, gdb, lldb, etc.) by sending keystrokes and scraping pane output.

_Origin: [Armin Ronacher](https://github.com/mitsuhiko) - [agent-commands](https://github.com/mitsuhiko/agent-commands)_

### windmill (`skills/windmill/`)

Assist with Windmill platform development. Guide agents working on Windmill codebase (backend Rust, frontend Svelte, CLI TypeScript) and helping users create Windmill projects. Provides workflows for scripts/flows creation, references existing guidance files, and scaffolding tools.

**Features:**
- Complete workflow patterns for script and flow development
- CLI command reference
- Interactive scaffolding tools (init-script.sh, init-flow.sh)
- Development best practices
- Testing and deployment strategies

_Origin: Vibecoded_

## Commands

**Location:** `commands/`

Commands are reusable templates for common development tasks. This directory is currently empty but ready for future command additions.

## Reference Links

### Agent Skills Documentation

- [Claude Agent Skills Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) - Official documentation for creating agent skills
- [Custom Skills Cookbook](https://github.com/anthropics/claude-cookbooks/tree/main/skills/custom_skills) - Examples and guides for building custom skills
- https://skillsmp.com

## Credits

- **tmux skill:** [Armin Ronacher](https://github.com/mitsuhiko) - [agent-commands](https://github.com/mitsuhiko/agent-commands)
- **windmill skill:** Vibecoded
