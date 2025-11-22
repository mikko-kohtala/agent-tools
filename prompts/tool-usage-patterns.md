# Tool Usage Patterns

Guidelines for when and how AI coding assistants should invoke tools effectively. These patterns maximize performance, reduce errors, and improve the developer experience.

## Core Principle: Parallelization

When multiple operations are independent, execute them in parallel. When operations depend on each other, execute them sequentially. Never use placeholders or guess missing parameters.

## Pattern 1: Parallel vs Sequential Tool Calls

### Concept

Distinguish between independent operations (which can run simultaneously) and dependent operations (which must run in sequence).

### Prompt Template

```markdown
<tool_usage>
When multiple independent operations are needed:

- Make parallel tool calls in a single response
- Example: Reading 3 unrelated files → 3 Read calls simultaneously
- Example: Searching different parts of codebase → Multiple Grep calls in parallel

When operations depend on each other:

- Execute sequentially, waiting for results
- Example: Read file → Analyze content → Edit file based on analysis
- Use && to chain bash commands that must run in order
- Example: mkdir && cp requires directory to exist first

Never:

- Use placeholders like "TO_BE_DETERMINED" in tool parameters
- Guess at missing values required for tool execution
- Run dependent operations in parallel
  </tool_usage>
```

### When to Use

- Any time you need to gather multiple pieces of information
- Complex refactoring touching many files
- Initial exploration of unfamiliar codebases
- Performance-critical operations where speed matters

### Real-World Examples

**Parallel: Reading multiple files**

```markdown
User: "Review the authentication implementation"
Agent: [Makes 3 parallel Read calls]

- Read("src/auth/middleware.ts")
- Read("src/auth/handlers.ts")
- Read("tests/auth.test.ts")
  [All execute simultaneously]
```

**Sequential: Edit based on analysis**

```markdown
Agent: [Step 1] Read("config.ts")
[Wait for result, analyze content]
Agent: [Step 2] Edit("config.ts", old_string="...", new_string="...")
[Based on what was actually in the file]
```

**Parallel: Multiple searches**

```markdown
User: "Find all database queries in the codebase"
Agent: [Makes 3 parallel Grep calls]

- Grep(pattern="SELECT._FROM", glob="\*\*/_.ts")
- Grep(pattern="INSERT INTO", glob="\*_/_.ts")
- Grep(pattern="UPDATE._SET", glob="\*\*/_.ts")
```

**Sequential: Chained bash commands**

```markdown
# Correct - operations depend on each other

Bash("mkdir -p dist && cp src/\*.js dist/")

# Incorrect - second command would fail if run before first

Bash("mkdir -p dist")
Bash("cp src/\*.js dist/") # Might run before directory exists
```

## Pattern 2: Specialized Tools vs Bash

### Concept

Use dedicated tools for file operations rather than bash commands. Reserve bash for actual terminal operations.

### Prompt Template

```markdown
<tool_selection>
Always prefer specialized tools over bash commands:

File operations:
✓ Use Read instead of cat/head/tail
✓ Use Edit instead of sed/awk
✓ Use Write instead of echo > or cat << EOF
✓ Use Glob instead of find or ls
✓ Use Grep instead of grep or rg

Only use Bash for:

- Git operations (git status, git diff, git commit)
- Package managers (npm, cargo, pip)
- Build tools (make, cargo build, npm run)
- Test runners (pytest, cargo test, npm test)
- Other actual terminal commands

Never use bash for:

- Reading file contents
- Searching for files or patterns
- Editing files
- Communicating with users (use direct text output)
  </tool_selection>
```

### When to Use

Always. This is a fundamental best practice for all tool-using agents.

### Real-World Examples

**❌ Anti-pattern: Using bash for file operations**

```bash
# Don't do this
Bash("cat src/config.ts")
Bash("grep -r 'TODO' src/")
Bash("find . -name '*.test.ts'")
Bash("sed -i 's/old/new/g' file.ts")
```

**✓ Correct: Using specialized tools**

```markdown
Read("src/config.ts")
Grep(pattern="TODO", path="src/")
Glob(pattern="\*_/_.test.ts")
Edit("file.ts", old_string="old", new_string="new")
```

**✓ Correct bash usage: Terminal operations**

```bash
# These are appropriate bash uses
Bash("git status")
Bash("npm install")
Bash("cargo test")
Bash("gh pr create --title 'Fix auth bug'")
```

### Integration Tips

- Add this pattern to system prompts as a hard rule
- Include examples of correct tool selection
- Explicitly list what bash should/shouldn't be used for

## Pattern 3: Context-Aware Tool Invocation

### Concept

Provide meaningful descriptions and use appropriate parameters based on the operation's scope and impact.

### Prompt Template

```markdown
<tool_invocation_quality>
When invoking tools:

1. Always include clear descriptions

   - Bash: "Run tests for auth module"
   - Read: Reading to understand, not just "read file"
   - Edit: "Update API endpoint to use new auth middleware"

2. Use appropriate scope parameters

   - Grep with glob filters for targeted searches
   - Read with offset/limit for very large files
   - Glob with specific patterns, not overly broad wildcards

3. Provide context in error recovery

   - If a tool fails, explain what you were trying to accomplish
   - Don't just retry blindly - adjust based on the error

4. Respect tool limitations
   - Don't use Grep for full file contents (use Read)
   - Don't use Read for searching (use Grep)
   - Don't use Glob for content search (use Grep)
     </tool_invocation_quality>
```

### Real-World Examples

**Good: Clear descriptions**

```markdown
Bash("npm test", description="Run test suite to verify auth changes")
Read("src/auth/middleware.ts") # To understand current implementation
Grep(pattern="async._login", glob="\*\*/_.ts") # Find all login functions
```

**Better: Appropriate scope**

```markdown
# Targeted search instead of broad

Grep(pattern="TODO", glob="src/features/**/\*.ts") # Not "**/\*"

# Specific pattern instead of vague

Glob(pattern="**/test-\*.ts") # Not "**/\*.ts" then filtering
```

**Best: Error recovery with context**

```markdown
# After Edit fails

Agent: "Edit failed because the old_string wasn't unique. I was trying to
update the auth timeout from 3600 to 7200. Let me search for the
exact context..."
[Makes Grep call to find precise location]
```

## Pattern 4: Batching Readonly Operations

### Concept

When exploring codebases or gathering information, make all readonly operations in a single parallel batch.

### Prompt Template

```markdown
<exploration_batching>
When you need to understand a codebase area:

1. Identify all information you need
2. Make all readonly tool calls in one batch:
   - All Read calls together
   - All Grep calls together
   - All Glob calls together
3. Wait for all results
4. Analyze and proceed

Do not:

- Read one file, analyze, read next file, analyze (sequential)
- Make a guess about what you'll need (incomplete batch)
- Mix readonly and write operations in same batch (different phases)
  </exploration_batching>
```

### Real-World Examples

**❌ Sequential exploration (slow)**

```markdown
Agent: Let me read the user model
[Read("models/user.ts")]
Agent: Now let me read the user controller
[Read("controllers/user.ts")]
Agent: Now let me check the tests
[Read("tests/user.test.ts")]
```

**✓ Batched exploration (fast)**

```markdown
Agent: Let me understand the user module
[Parallel calls:]

- Read("models/user.ts")
- Read("controllers/user.ts")
- Read("tests/user.test.ts")
- Grep(pattern="User", glob="src/\*_/_.ts", output_mode="files_with_matches")
  [Analyze all results together]
```

**✓ Separate read and write phases**

```markdown
Phase 1 - Read (parallel):

- Read("auth/middleware.ts")
- Read("auth/types.ts")
- Grep(pattern="AuthConfig")

[Analyze results, plan changes]

Phase 2 - Write (sequential based on dependencies):

- Edit("auth/types.ts", ...)
- Edit("auth/middleware.ts", ...) # Uses updated types
- Write("tests/auth-config.test.ts", ...)
```

## Pattern 5: Tool Call Descriptions

### Concept

Every tool invocation should have a clear, concise description in active voice explaining what the operation does.

### Prompt Template

```markdown
<tool_descriptions>
Format: "Verb object" in active voice (5-10 words)

Good examples:

- "List files in current directory" (ls)
- "Run test suite for auth module" (npm test)
- "Install project dependencies" (npm install)
- "Create prompts directory" (mkdir)
- "Search for TODO comments in source" (grep)

Bad examples:

- "ls" (not descriptive)
- "This command will list the files" (passive, verbose)
- "Listing files" (gerund, not active)
- "" (missing entirely)

Always include descriptions for:

- Bash commands (required)
- Any operation that modifies state
- Operations that might not be obvious from context
  </tool_descriptions>
```

### Integration Tips

- Make descriptions mandatory in your system prompts
- Provide a list of good vs bad examples
- Focus on clarity over brevity

## Anti-Patterns to Avoid

❌ **Serial file reading**: Reading files one at a time instead of in parallel
❌ **Bash for everything**: Using bash commands instead of specialized tools
❌ **Missing descriptions**: Tool calls without clear explanations
❌ **Placeholder parameters**: Using "TBD" or guessing at required values
❌ **Dependent parallelization**: Running dependent operations simultaneously
❌ **Mixed phases**: Combining exploration and modification in one batch

✓ **Parallel readonly operations**: All Reads/Greps in one batch
✓ **Specialized tool usage**: Right tool for each operation
✓ **Clear descriptions**: Every tool call explains its purpose
✓ **Complete parameters**: Wait for information rather than guessing
✓ **Sequential dependencies**: Operations run in required order
✓ **Separate phases**: Explore first, then modify

## Combining Patterns

For complex tasks, combine multiple patterns:

```markdown
# Efficient Tool Usage

When working on a multi-file feature:

## Phase 1: Exploration (Parallel)

Make all readonly tool calls simultaneously:

- Read all relevant source files
- Grep for related patterns
- Glob for test files

## Phase 2: Analysis (No tools)

Analyze results and plan changes

## Phase 3: Implementation (Sequential as needed)

- Make independent edits in parallel
- Chain dependent edits sequentially
- Use Edit (not sed), Write (not echo >), etc.

## Phase 4: Verification (Parallel)

- Run tests
- Check linting
- Verify build

Always:

- Include clear descriptions for all Bash commands
- Use specialized tools over bash for file operations
- Respect dependencies when ordering operations
```

## Credits

Patterns extracted and adapted from:

- [OpenAI GPT-5.1 Prompting Guide](https://cookbook.openai.com/examples/gpt-5/gpt-5-1_prompting_guide)

Applicable to Claude Code, Codex CLI, and similar tool-using AI coding assistants.
