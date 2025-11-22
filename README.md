# Agent Tools

A curated collection of agent commands and skills for various CLI-based AI coding assistants, including Claude Code, Codex CLI, Gemini CLI, and other agent-based development tools.

## About

This repository provides reusable skills and commands that extend the capabilities of AI coding assistants. Skills enable agents to interact with external tools and services, while commands provide templates for common development workflows.

## Skills

### tmux (`skills/tmux/`)

Remote control tmux sessions for interactive CLIs (Python, gdb, lldb, etc.) by sending keystrokes and scraping pane output.

*Origin: [Armin Ronacher](https://github.com/mitsuhiko) - [agent-commands](https://github.com/mitsuhiko/agent-commands)*

## Commands

**Location:** `commands/`

Commands are reusable templates for common development tasks. This directory is currently empty but ready for future command additions.

## Usage

### For Claude Code

Skills are automatically discovered when placed in the `skills/` directory. To use the tmux skill:

```bash
# The agent will automatically load skills from the skills/ directory
# Reference the skill in your prompts when needed
```

### For Other AI Coding Assistants

Refer to your specific AI coding assistant's documentation for how to integrate custom skills and commands.

## Contributing

Feel free to add new skills and commands. When adding content:

- Place skills in `skills/<skill-name>/`
- Include a `SKILL.md` file with documentation
- Add helper scripts in `tools/` subdirectories
- Update this README with descriptions and credits

## License

Individual skills and commands may have their own licenses. Please refer to each skill's documentation for specific licensing information.

## Credits

- **tmux skill:** [Armin Ronacher](https://github.com/mitsuhiko) - [agent-commands](https://github.com/mitsuhiko/agent-commands)
