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
claude plugin install tmux-skill
claude plugin install windmill-skill
claude plugin install playwright-skill
```

### Install Individual Skills Directly

```bash
claude plugin install github:mikko-kohtala/agent-tools/skills/tmux-skill
claude plugin install github:mikko-kohtala/agent-tools/skills/windmill-skill
claude plugin install github:mikko-kohtala/agent-tools/skills/playwright-skill
```

## Skills

| Skill | Description | Origin |
|-------|-------------|--------|
| [tmux-skill](skills/tmux-skill/) | Remote control tmux sessions for interactive CLIs | [Armin Ronacher](https://github.com/mitsuhiko/agent-commands) |
| [windmill-skill](skills/windmill-skill/) | Windmill platform development assistance | Vibecoded |
| [playwright-skill](skills/playwright-skill/) | Browser automation with Playwright | [lackeyjb](https://github.com/lackeyjb/playwright-skill) |
| [gemini-imagegen-skill](skills/gemini-imagegen-skill/) | Gemini API image generation | [EveryInc](https://github.com/EveryInc/every-marketplace/tree/main/plugins/compounding-engineering/skills/gemini-imagegen) |
| [skill-development-skill](skills/skill-development-skill/) | Guide for creating Claude Code skills | [Anthropic](https://github.com/anthropics/claude-code) |

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
