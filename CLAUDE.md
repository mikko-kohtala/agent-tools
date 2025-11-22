# Agent Tools

This file provides guidance to CLI-based AI coding assistants when working with code in this repository.

## Repository Purpose

This is a curated collection of agent commands and skills for CLI-based AI coding assistants (Claude Code, Codex CLI, Gemini CLI, etc.). The repository serves as a reference library of reusable capabilities that extend what AI agents can do.

### Key Distinctions

- **`skills/`**: Active skills intended for use in this or other codebases. Currently contains the tmux skill for programmatic terminal control.
- **`skills-archive/`**: Reference implementations from external sources (Claude Cookbooks, claude-agent-desktop). These serve as examples and inspiration but are not primary skills of this repository.
- **`commands/`**: Placeholder for future command templates (reusable workflow patterns).

## Skill Structure

Each skill follows this pattern:

- `SKILL.md` - Required documentation with YAML frontmatter (name, description, license)
- `tools/` - Optional directory for helper scripts (must be executable)
- `REFERENCE.md` - Optional supporting documentation

### Active Skills

**tmux** (`skills/tmux/`): Remote controls tmux sessions for interactive CLIs (Python, gdb, lldb). Uses isolated sockets under `${TMPDIR:-/tmp}/claude-tmux-sockets`. Helper scripts:

- `find-sessions.sh` - List/filter tmux sessions
- `wait-for-text.sh` - Poll panes for regex patterns with timeout

**windmill** (`skills/windmill/`): Assists with Windmill platform development. Guides agents working on Windmill codebase (Rust backend, Svelte frontend, TypeScript CLI) and creating Windmill projects. Includes comprehensive workflow patterns, CLI reference, and scaffolding tools. Additional files:

- `WINDMILL_CLI.md` - Complete CLI command reference
- `WORKFLOWS.md` - Development workflow patterns and best practices
- `tools/init-script.sh` - Interactive script scaffolding wizard
- `tools/init-flow.sh` - Interactive flow scaffolding wizard

## Adding New Content

When adding skills or commands:

1. **Active skills**: Place in `skills/<skill-name>/` with SKILL.md and any tools
2. **Reference/archived skills**: Place in `skills-archive/<skill-name>/`
3. **Commands**: Place in `commands/` (structure TBD)
4. Update README.md with description and credit original author
5. Ensure helper scripts in `tools/` are executable (`chmod +x`)

## Important References

- [Claude Agent Skills Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) - Official skill creation docs
- [Custom Skills Cookbook](https://github.com/anthropics/claude-cookbooks/tree/main/skills/custom_skills) - Examples and guides

## Credits

All skills maintain attribution to original authors. See README.md for current credits. When copying skills, preserve attribution and exclude LICENSE files (individual skills may have different licenses noted in SKILL.md frontmatter).
