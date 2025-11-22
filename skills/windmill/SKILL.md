---
name: windmill
description: "Help users create Windmill scripts, workflows, and apps. Use when user mentions workflow automation, creating internal tools, Windmill CLI, or OpenFlow YAML. Supports 18+ languages including TypeScript, Python, Go, Bash, SQL, Rust, Docker, REST/GraphQL."
license: MIT
---

# Windmill Skill

Guide agents helping users CREATE Windmill projects (scripts, flows, apps).

## What is Windmill?

Windmill is an open-source developer platform for building internal tools, workflows, API integrations, and UIs. Alternative to Retool, n8n, and Airflow.

**Core Components:**

- **Scripts**: Individual functions (Python, TypeScript, Go, Bash, SQL, Rust, C#, Java, Ruby, Docker, REST/GraphQL, Ansible, etc.)
- **Flows**: YAML-based workflows (OpenFlow standard) - DAGs composing scripts together
- **Apps**: User-facing dashboards and interfaces

**Key Features:**

- Auto-generated UIs from function signatures
- Automatic dependency management
- Resource management for credentials
- Git sync capabilities
- Job scheduling and queuing

## When to Use This Skill

Use this skill when the user:

- Mentions creating workflows, automation, or internal tools
- Asks about Windmill CLI commands or setup
- Wants to write scripts in Windmill-supported languages
- Needs to create OpenFlow YAML workflow specifications
- Asks about deploying or testing Windmill projects

**Example Triggers:**

- "Help me create a Windmill workflow"
- "How do I write a Python script for Windmill?"
- "What's the Windmill CLI command for...?"
- "I need to set up automated data processing with Windmill"
- "How do I create an internal tool with Windmill?"

## Quick Start

### Creating a Script

1. Ask user for folder location (e.g., `f/workflows/data_processing/`)
2. Use `tools/init-script.sh` for interactive scaffolding (recommended), or create manually
3. Run `wmill script generate-metadata` at repository root (generates .lock and .yaml)
4. Test with `wmill script run <path>`
5. Deploy with `wmill sync push`

### Creating a Flow

1. Ask user for folder location (must end with `.flow`)
2. Use `tools/init-flow.sh` for interactive scaffolding (recommended), or create manually
3. Run `wmill flow generate-locks --yes` at repository root
4. Test with `wmill flow run <path>`
5. Deploy with `wmill sync push`

### Creating an App

1. Ask user for folder location
2. Use `tools/init-app.sh` for interactive scaffolding
3. Deploy with `wmill sync push`

## Comprehensive Guidance Files

This skill includes detailed reference files:

**For Scripts:**
Read `SCRIPT_GUIDANCE.md` in this skill directory for:

- Complete language-specific conventions (18+ languages)
- Resource type patterns (credentials, databases, APIs)
- Windmill client API reference (`wmill`)
- Workflow steps for script creation

**For Flows:**
Read `WORKFLOW_GUIDANCE.md` in this skill directory for:

- Complete OpenFlow YAML specification
- All module types (rawscript, script, flow, loops, branches)
- Input transforms and data flow patterns
- Advanced properties (error handling, retry, suspend/approval)

**For Apps:**
Read `APP_GUIDANCE.md` in this skill directory for:

- App builder component reference
- Layout patterns and UI composition
- App-script interaction patterns

**For CLI:**
Read `WINDMILL_CLI.md` in this skill directory for:

- Complete CLI command reference
- Common command sequences
- Development workflows

**For Patterns:**
Read `PATTERNS.md` in this skill directory for:

- Development patterns with code examples
- Testing strategies
- Deployment patterns (single env, multi-env, CI/CD)
- Debugging strategies
- Team collaboration workflows

**For Quick Reference:**
Read `QUICKREF.md` in this skill directory for:

- Most common CLI commands (cheat sheet)
- Script conventions at-a-glance
- Flow module types reference

## Helper Tools

### tools/init-script.sh

Interactive script scaffolding wizard that:

- Prompts for language selection (bun, deno, python3, go, bash, SQL variants, rust, php, docker, REST/GraphQL, ansible, etc.)
- Asks for folder path
- Generates script template with proper conventions
- Automatically runs metadata generation

**Usage:**

```bash
cd /path/to/windmill/repo
/path/to/skills/windmill/tools/init-script.sh
```

### tools/init-flow.sh

Interactive flow scaffolding wizard that:

- Prompts for flow template selection (simple, API integration, data processing, etc.)
- Asks for folder path (auto-adds .flow suffix)
- Generates flow.yaml with inline scripts
- Automatically runs lock generation

**Usage:**

```bash
cd /path/to/windmill/repo
/path/to/skills/windmill/tools/init-flow.sh
```

### tools/init-app.sh

Interactive app scaffolding wizard that:

- Prompts for app template selection
- Asks for folder path
- Generates app structure with components

**Usage:**

```bash
cd /path/to/windmill/repo
/path/to/skills/windmill/tools/init-app.sh
```

## Common CLI Sequences

### Initial Project Setup

```bash
wmill init                    # Bootstrap project with wmill.yaml
wmill workspace add           # Configure workspace
wmill sync pull               # Pull existing resources
```

### Development Loop

```bash
# Make changes to scripts/flows
wmill script generate-metadata  # or wmill flow generate-locks --yes
wmill sync push                 # Deploy changes
```

### Testing

```bash
wmill script run f/folder/script  # Test script execution
wmill flow run f/folder/flow      # Test flow execution
```

### Development Mode (Live Reload)

```bash
wmill dev  # Watch files and auto-sync changes
```

## Best Practices

### Project Organization

- Use folder structure: `f/category/subcategory/`
- Scripts: Individual files in folders
- Flows: Folders ending with `.flow/` containing `flow.yaml`
- Apps: Folders in `f/apps/`
- Resources: Centralize in `f/resources/`

### Development Workflow

1. **Always generate metadata**: Don't create `.lock` or `.yaml` manually
2. **Test before push**: Use `wmill script run` or `wmill flow run`
3. **Use sync**: Prefer `wmill sync push/pull` over individual commands
4. **Development mode**: Use `wmill dev` for rapid iteration
5. **Resource types**: Check available types with `wmill resource-type list --schema`

### Script Best Practices

- Keep scripts focused (single responsibility)
- Use resources for credentials, not hardcoded values
- Use `wmill.getState()` for persistence across runs
- Add proper JSON Schema for parameters
- Return structured data for flow integration

### Flow Best Practices

- Use `rawscript` for simple inline logic
- Use `script` references for reusable code
- Prefer `parallel: true` for independent operations
- Add `failure_module` for critical workflows
- Use meaningful step IDs for debugging

## Troubleshooting

### Common Issues

**Metadata generation fails:**

- Run from repository root
- Ensure script file exists and has valid syntax
- Check language is supported

**Sync push fails:**

- Verify workspace is configured: `wmill workspace list`
- Check authentication: `wmill user whoami`
- Validate YAML syntax for flows

**Resource type not found:**

- List available types: `wmill resource-type list --schema`
- Check spelling and casing (TypeScript: `RT.Postgresql`, Python: `postgresql`)

**Flow locks not generating:**

- Ensure inline script paths are correct: `!inline path/to/script.ts`
- Check inline script files exist
- Verify YAML syntax is valid

For detailed patterns and examples, read the PATTERNS.md file in this skill directory.

## Additional Resources

- **Platform Docs**: https://www.windmill.dev/docs
- **OpenFlow Standard**: https://www.openflow.dev
- **Script Reference**: Read SCRIPT_GUIDANCE.md
- **Workflow Reference**: Read WORKFLOW_GUIDANCE.md
- **App Reference**: Read APP_GUIDANCE.md
- **CLI Reference**: Read WINDMILL_CLI.md
- **Workflow Patterns**: Read PATTERNS.md
- **Quick Reference**: Read QUICKREF.md
