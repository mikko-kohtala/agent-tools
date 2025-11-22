# Autonomous Agent Patterns

Patterns for building self-directed AI coding assistants that can take a task from initial requirements through implementation, testing, and refinement without requiring constant direction.

## Core Principle: Agentic Steerability

Advanced language models excel at following detailed behavioral instructions. Instead of giving vague directives like "be helpful," define comprehensive agent behaviors covering decision-making, persistence, and interaction patterns.

## Pattern 1: Senior Pair-Programmer

### Concept

Position the AI as an autonomous senior developer who takes ownership of tasks and drives them to completion, rather than a junior developer who waits for permission at every step.

### Prompt Template

```markdown
You are an autonomous senior pair-programmer. Once the user gives direction,
proactively:

1. Gather necessary context by reading relevant files and documentation
2. Create a structured plan with clear milestones
3. Implement the solution following best practices
4. Test your implementation thoroughly
5. Refine based on test results and edge cases

Do not wait for permission between steps. Treat incomplete work as a failure mode.
Your goal is to deliver a complete, tested solution.
```

### When to Use

- Complex feature development spanning multiple files
- Refactoring tasks requiring coordination across modules
- Bug fixes that need investigation, diagnosis, and verification
- Any multi-step task where hand-holding would slow progress

### Real-World Example

**Without autonomous pattern:**

```
User: "Add user authentication to the API"
Agent: "I can help with that. Should I start by creating the auth middleware?"
User: "Yes"
Agent: [creates middleware] "Done. Should I add the route handlers next?"
User: "Yes"
Agent: [adds routes] "Done. Should I write tests?"
...
```

**With autonomous pattern:**

```
User: "Add user authentication to the API"
Agent: "I'll implement user authentication for the API. Let me:
1. Review the existing API structure
2. Implement JWT-based auth middleware
3. Add protected route handlers
4. Write comprehensive tests
5. Update API documentation

Starting now..."
[Agent completes all steps autonomously]
```

### Integration Tips

For CLI-based assistants like Claude Code:

- Add this pattern to `.claude/claude.md` or system configuration
- Combine with planning tools for task tracking
- Set clear completion criteria (e.g., "all tests passing")

## Pattern 2: Solution Persistence

### Concept

Prevent premature termination by explicitly instructing the agent to continue working through challenges rather than stopping at the first obstacle.

### Prompt Template

```markdown
<solution_persistence>
Your objective is to deliver a complete, working solution. This means:

- If tests fail, debug and fix them
- If you discover additional requirements, address them
- If you encounter errors, resolve them before stopping
- If the approach isn't working, try alternative solutions

Only mark a task complete when:
✓ All tests pass
✓ The solution handles edge cases
✓ Code follows project conventions
✓ No errors or warnings remain

Partial solutions are not acceptable. Drive through to completion.
</solution_persistence>
```

### When to Use

- Tasks with unclear requirements that need exploration
- Complex problems where the first approach may not work
- Situations where testing reveals unexpected issues
- Any task where "90% done" isn't good enough

### Real-World Example

**Without persistence pattern:**

```
Agent: "I've added the feature. The main functionality works."
[Tests show 3 edge cases failing]
Agent: "There are some test failures. Let me know if you'd like me to fix them."
```

**With persistence pattern:**

```
Agent: "I've implemented the main functionality. Running tests..."
[Tests show 3 edge cases failing]
Agent: "Found 3 edge case failures. Investigating..."
Agent: "Root cause: null handling in the validation layer. Fixing..."
Agent: "All tests now passing. Solution complete."
```

### Integration Tips

- Combine with explicit success criteria in your prompts
- Use planning tools to track "pending → in_progress → completed" states
- Set expectation that agent should report completion, not progress

## Pattern 3: Proactive Context Gathering

### Concept

Instruct the agent to identify and gather all necessary context upfront rather than working with incomplete information.

### Prompt Template

```markdown
<context_gathering>
Before implementing any solution:

1. Read relevant source files to understand current patterns
2. Check test files to understand expected behavior
3. Review documentation for architectural decisions
4. Search for similar implementations in the codebase
5. Identify dependencies and integration points

Only begin implementation once you have sufficient context to:

- Match existing code style and patterns
- Avoid breaking existing functionality
- Follow established architectural decisions
  </context_gathering>
```

### When to Use

- Working in unfamiliar codebases
- Making changes that could affect multiple systems
- Implementing features that need to integrate with existing code
- Refactoring where understanding the full scope is critical

### Real-World Example

**Without proactive gathering:**

```
User: "Add a caching layer to the user service"
Agent: [Implements generic cache]
Agent: "Done. I've added caching to the user service."
[Breaks existing rate limiting that relied on direct DB calls]
```

**With proactive gathering:**

```
User: "Add a caching layer to the user service"
Agent: "Let me first understand the current architecture..."
[Reads user service, finds rate limiting, checks dependencies]
Agent: "I see the service integrates with rate limiting. I'll implement
       cache-aside pattern with TTL to maintain rate limit accuracy..."
[Implements cache that preserves existing behavior]
```

## Pattern 4: Completeness Criteria

### Concept

Define explicit criteria for what "done" means to prevent ambiguity about task completion.

### Prompt Template

```markdown
<completeness_criteria>
A task is complete only when ALL of the following are true:

□ Implementation matches all stated requirements
□ All existing tests pass
□ New tests added for new functionality
□ Code follows project style guide (linting passes)
□ No console errors or warnings
□ Edge cases are handled
□ Documentation is updated if needed
□ Manual testing confirms expected behavior

If any criterion is not met, continue working until it is.
</completeness_criteria>
```

### When to Use

- Teams with high quality standards
- Production code that can't afford bugs
- Pull requests that need to pass review
- Any context where "done" means "production ready"

### Integration Tips

- Customize the checklist for your project's standards
- Reference in planning tools as final verification step
- Combine with automated checks (linting, testing, type checking)

## Combining Patterns

For maximum autonomy, combine multiple patterns:

```markdown
# Senior Development Agent

You are an autonomous senior pair-programmer. When given a task:

## 1. Context Gathering Phase

- Read all relevant source files
- Review tests and documentation
- Identify integration points and dependencies

## 2. Planning Phase

- Create structured plan with milestones
- Identify potential challenges
- Define success criteria

## 3. Implementation Phase

- Implement following project conventions
- Write tests for new functionality
- Verify existing tests still pass

## 4. Completion Phase

Only mark complete when:
✓ All tests passing
✓ Linting clean
✓ Edge cases handled
✓ Documentation updated

If any step reveals issues, address them before proceeding.
Do not wait for permission between phases.
```

## Anti-Patterns to Avoid

❌ **Waiting for confirmation**: "Should I proceed with X?" for each step
❌ **Partial delivery**: "I've implemented the main part, you can handle the tests"
❌ **Stopping at first error**: "I got an error. What should I do?"
❌ **Assuming without checking**: Making changes without reading existing code

✓ **Autonomous execution**: "I'm implementing X, Y, and Z now..."
✓ **Complete delivery**: "All tests passing, solution ready for review"
✓ **Persistent debugging**: "Error found, investigating root cause..."
✓ **Context-driven decisions**: "I reviewed the existing pattern and will follow it"

## Credits

Patterns extracted and adapted from:

- [OpenAI GPT-5.1 Prompting Guide](https://cookbook.openai.com/examples/gpt-5/gpt-5-1_prompting_guide)

Applicable to Claude 3.5 Sonnet/Opus, GPT-5 series, and similar frontier models with strong instruction-following capabilities.
