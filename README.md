# Agent Tools

A curated collection of agent commands and skills for various CLI-based AI coding assistants, including Claude Code, Codex CLI, Gemini CLI, and other agent-based development tools.

## About

This repository provides reusable skills and commands that extend the capabilities of AI coding assistants. Skills enable agents to interact with external tools and services, while commands provide templates for common development workflows.

## Installation

### Add Marketplace from GitHub

```bash
claude plugin marketplace add mikko-kohtala/agent-tools
```

Then install skills:

```bash
claude plugin install tmux
claude plugin install windmill
claude plugin install skill-development
```

### Install Individual Skills Directly

```bash
claude plugin install github:mikko-kohtala/agent-tools/skills/tmux
claude plugin install github:mikko-kohtala/agent-tools/skills/windmill
claude plugin install github:mikko-kohtala/agent-tools/skills/skill-development
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

### skill-development (`skills/skill-development/`)

Guide agents in creating effective skills for Claude Code plugins following progressive disclosure principles. Comprehensive documentation on skill anatomy, creation process, validation checklist, writing style requirements, and best practices for building modular, self-contained packages that extend Claude's capabilities.

**Features:**

- Six-step skill creation process (understanding, planning, structure, editing, validation, iteration)
- Progressive disclosure design principles (metadata → SKILL.md → bundled resources)
- Plugin-specific considerations and auto-discovery
- Writing style requirements (imperative form, third-person descriptions)
- Validation checklist and common mistakes to avoid
- Examples from plugin-dev skills demonstrating best practices

_Origin: [Anthropic](https://github.com/anthropics) - [claude-code](https://github.com/anthropics/claude-code)_

## Commands

**Location:** `commands/`

Commands are reusable templates for common development tasks. This directory is currently empty but ready for future command additions.

## Reference Links

### Agent Skills Documentation

- [Claude Agent Skills Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) - Official documentation for creating agent skills
- [Custom Skills Cookbook](https://github.com/anthropics/claude-cookbooks/tree/main/skills/custom_skills) - Examples and guides for building custom skills
- https://skillsmp.com
- https://www.aitmpl.com/skills
- https://github.com/ComposioHQ/awesome-claude-skills
- https://github.com/anthropics/skills
