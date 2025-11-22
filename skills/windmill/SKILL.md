---
name: windmill
description: "Assist with Windmill platform development. Guide agents working on Windmill codebase (backend Rust, frontend Svelte, CLI TypeScript). Provides workflows for scripts/flows creation, references existing guidance files, scaffolding tools."
license: MIT
---

# Windmill Development Skill

Guide agents working on the Windmill platform codebase and helping users create Windmill projects.

## What is Windmill?

Windmill is an open-source developer platform for building internal tools, workflows, API integrations, and UIs. Alternative to Retool, n8n, and Airflow.

**Core Components:**
- **Scripts**: Individual functions (Python, TypeScript, Go, Bash, SQL, etc.)
- **Flows**: YAML-based workflows (OpenFlow standard)
- **Apps**: User-facing dashboards and interfaces

**Key Features:**
- Auto-generated UIs from function signatures
- Automatic dependency management
- Resource management for credentials
- Git sync capabilities
- Job scheduling and queuing

## When to Use This Skill

Use when:
- Working on Windmill codebase (backend, frontend, CLI)
- Creating scripts or flows in Windmill workspace
- Setting up Windmill projects
- Debugging Windmill development issues
- Understanding Windmill workflows and best practices

## Complete Guidance References

This skill includes comprehensive references for Windmill development:

- **@SCRIPT_GUIDANCE.md**: Complete script-writing guide for all supported languages
  - Language-specific conventions (bun, deno, python, go, bash, SQL, etc.)
  - Resource type patterns
  - Windmill client API reference (`wmill`)
  - Workflow steps for script creation

- **@WORKFLOW_GUIDANCE.md**: Complete OpenFlow specification
  - All module types (rawscript, script, flow, loops, branches)
  - Input transforms and data flow
  - Advanced properties (error handling, retry, suspend)
  - Complete workflow examples

- **@WINDMILL_CLI.md**: Complete CLI command reference

- **@WORKFLOWS.md**: Development workflow patterns and best practices

**Note**: When users run `wmill init`, it creates `.cursor/rules/script.mdc` and `.cursor/rules/flow.mdc` files with similar guidance, along with a `CLAUDE.md` file. These files provide context-specific guidance in Windmill projects.

## Script Development Workflow

### Creating a New Script

1. **Choose folder location**:
   ```bash
   # Ask user which folder, e.g., f/workflows/data_processing/
   ```

2. **Use scaffolding helper** (recommended):
   ```bash
   ./tools/init-script.sh
   # Interactive wizard: language selection, folder, template
   ```

3. **Or create manually**:
   ```bash
   # Create script file in folder
   # Write script following language conventions from script_guidance.ts
   ```

4. **Generate metadata**:
   ```bash
   wmill script generate-metadata
   # Run at repository root
   # Creates .lock and .yaml files automatically
   ```

5. **Push to workspace**:
   ```bash
   wmill sync push
   # Or for testing: wmill script run <path>
   ```

### Key Script Conventions

See @SCRIPT_GUIDANCE.md for complete reference. Key points:

- Export single `main` function (async for bun/deno)
- Don't call main function
- Libraries installed automatically
- Resources passed as parameters (e.g., `database: RT.Postgresql` in TypeScript)
- Use `wmill` client for platform interactions

**Common wmill client operations:**
```typescript
import * as wmill from "windmill-client"

// Resources
await wmill.getResource(path)
await wmill.setResource(value, path)

// State (persistent across executions)
await wmill.getState()
await wmill.setState(state)

// Execute scripts
await wmill.runScript(path, hash, args)
await wmill.waitJob(jobId)
```

See @SCRIPT_GUIDANCE.md for complete API reference and all language-specific patterns.

## Flow Development Workflow

### Creating a New Flow

1. **Choose folder location**:
   ```bash
   # Ask user which folder, e.g., f/workflows/data_pipeline/
   # Flow folder must end with .flow
   ```

2. **Use scaffolding helper** (recommended):
   ```bash
   ./tools/init-flow.sh
   # Interactive wizard: template selection, folder
   ```

3. **Or create manually**:
   ```bash
   # Create folder ending with .flow
   mkdir -p f/workflows/data_pipeline.flow

   # Create flow.yaml with OpenFlow specification
   # For rawscript modules, use: content: '!inline inline_script_0.inline_script.ts'
   # Create corresponding inline script files in same folder
   ```

4. **Generate locks**:
   ```bash
   wmill flow generate-locks --yes
   # Run at repository root
   # Creates dependency locks for all inline scripts
   ```

5. **Push to workspace**:
   ```bash
   wmill sync push
   # Or for testing: wmill flow run <path>
   ```

### Key Flow Conventions

See @WORKFLOW_GUIDANCE.md for complete OpenFlow specification. Key points:

**Flow Structure:**
```yaml
summary: "Brief description"
value:
  modules: []  # Array of steps
  failure_module: {}  # Optional error handler
schema:  # Input parameters
  type: object
  properties: {}
```

**Module Types:**
- `rawscript`: Inline code with `content: '!inline path/to/script.ts'`
- `script`: Reference existing script with `path: "f/folder/script"`
- `flow`: Sub-workflow
- `forloopflow`: Iterate over array
- `whileloopflow`: Conditional loop
- `branchone`: If/else logic
- `branchall`: Parallel branches

**Data Flow:**
```yaml
input_transforms:
  param_name:
    type: javascript
    expr: "flow_input.name"  # or "results.previous_step"
```

See @WORKFLOW_GUIDANCE.md for complete OpenFlow specification with all module types and properties.

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

See @WINDMILL_CLI.md for complete command reference.

## Helper Tools

### init-script.sh

Interactive script scaffolding wizard.

```bash
cd /path/to/windmill/repo
/path/to/skills/windmill/tools/init-script.sh
```

Features:
- Language selection (bun, deno, python3, go, bash, etc.)
- Folder path input
- Template generation with proper conventions
- Automatic metadata generation

### init-flow.sh

Interactive flow scaffolding wizard.

```bash
cd /path/to/windmill/repo
/path/to/skills/windmill/tools/init-flow.sh
```

Features:
- Flow template selection (simple, API integration, data processing, etc.)
- Folder path input (auto-adds .flow suffix)
- YAML generation with inline scripts
- Automatic lock generation

## Best Practices

### Project Organization

- Use folder structure: `f/category/subcategory/`
- Scripts: Individual files in folders
- Flows: Folders ending with `.flow/` containing `flow.yaml`
- Resources: Centralize in `f/resources/`
- Group related scripts/flows by domain

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

## Working on Windmill Codebase

### Repository Structure

- **`backend/`**: Rust backend (windmill-api, windmill-worker)
- **`frontend/`**: Svelte 5 frontend
- **`cli/`**: TypeScript CLI (Deno runtime)
- **`cli/src/guidance/`**: Guidance files for AI assistants

### Development Guidelines

From CLAUDE.md in Windmill repo:

- **Clean code first**: Readable, maintainable
- **Avoid duplication at all costs**: Search for existing implementations
- **Adapt existing code**: Refactor/generalize rather than duplicate
- **Follow established patterns**: Study existing code conventions
- **Single responsibility**: Each function/module has one purpose
- **Incremental implementation**: Break features into reviewable chunks

### Language-Specific References

- **Backend (Rust)**: See `@backend/rust-best-practices.mdc`
- **Frontend (Svelte 5)**: See `@frontend/svelte5-best-practices.mdc`
- **Schema**: See `@backend/summarized_schema.txt`

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

See @WORKFLOWS.md for detailed workflow patterns and debugging strategies.

## Additional Resources

- **Platform Docs**: https://www.windmill.dev/docs
- **OpenFlow Standard**: https://www.openflow.dev
- **Script Reference**: @SCRIPT_GUIDANCE.md
- **Workflow Reference**: @WORKFLOW_GUIDANCE.md
- **CLI Reference**: @WINDMILL_CLI.md
- **Workflow Patterns**: @WORKFLOWS.md
