# Agent Tools

A curated collection of plugins for Claude Code and other CLI-based AI coding assistants.

## About

This repository provides reusable plugins that extend the capabilities of AI coding assistants. Each plugin can contain skills, commands, agents, and hooks.

## Installation

### Add Marketplace from GitHub

```bash
claude plugin marketplace add mikko-kohtala/agent-tools
```

Then install plugins:

```bash
claude plugin install playwright-plugin
claude plugin install tmux-plugin
claude plugin install windmill-plugin
```

### Install Individual Plugins Directly

```bash
claude plugin install github:mikko-kohtala/agent-tools/plugins/playwright-plugin
claude plugin install github:mikko-kohtala/agent-tools/plugins/tmux-plugin
claude plugin install github:mikko-kohtala/agent-tools/plugins/windmill-plugin
```

## Plugins

| Plugin                                                        | Skills                  | Commands | Agents | Hooks | Origin                                                        |
| ------------------------------------------------------------- | ----------------------- | -------- | ------ | ----- | ------------------------------------------------------------- |
| [playwright-plugin](plugins/playwright-plugin/)               | playwright-skill        | -        | -      | -     | [lackeyjb](https://github.com/lackeyjb/playwright-skill)      |
| [tmux-plugin](plugins/tmux-plugin/)                           | tmux-skill              | -        | -      | -     | [Armin Ronacher](https://github.com/mitsuhiko/agent-commands) |
| [windmill-plugin](plugins/windmill-plugin/)                   | windmill-skill          | -        | -      | -     | Vibecoded                                                     |
| [gemini-imagegen-plugin](plugins/gemini-imagegen-plugin/)     | gemini-imagegen-skill   | -        | -      | -     | [EveryInc](https://github.com/EveryInc/every-marketplace)     |
| [skill-development-plugin](plugins/skill-development-plugin/) | skill-development-skill | -        | -      | -     | [Anthropic](https://github.com/anthropics/claude-code)        |
| [codex-plugin](plugins/codex-plugin/)                         | codex-skill             | -        | -      | -     | [skills-directory](https://github.com/skills-directory/skill-codex) |

## Reference Links

### Claude Code Documentation

- [Plugins Overview](https://code.claude.com/docs/en/plugins.md) - Official plugin documentation
- [Agent Skills Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) - Official skill documentation
- [Custom Skills Cookbook](https://github.com/anthropics/claude-cookbooks/tree/main/skills/custom_skills) - Examples and guides

### Plugin Marketplaces

- https://skillsmp.com
- https://www.aitmpl.com/skills
- https://github.com/ComposioHQ/awesome-claude-skills
- https://github.com/anthropics/skills
