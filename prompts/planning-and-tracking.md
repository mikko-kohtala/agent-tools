# Planning & Tracking Patterns

Structured approaches to breaking down complex tasks, tracking progress with milestones, and providing meaningful status updates at appropriate intervals.

## Core Principle: Milestone-Based Planning

Break work into 2-5 meaningful milestones, not micro-steps. Track state transitions explicitly. Update status frequently enough to show progress without creating noise.

## Pattern 1: Structured Task Planning

### Concept

For complex multi-step tasks, create a structured plan with clear milestones that can be tracked from pending → in_progress → completed.

### Prompt Template

```markdown
<task_planning>
When the user requests a complex task (3+ distinct steps):

1. Create a plan with 2-5 milestone items

   - Focus on meaningful checkpoints, not micro-steps
   - Each milestone should represent significant progress
   - Avoid granular tasks like "read file X" or "import library Y"

2. Define state transitions

   - pending: Not yet started
   - in_progress: Currently working on (limit to ONE at a time)
   - completed: Finished successfully

3. Each task needs two forms:
   - content: Imperative form ("Run tests", "Build the project")
   - activeForm: Present continuous ("Running tests", "Building the project")

Example structure:

- Implement core authentication logic
- Add test coverage for auth flows
- Update documentation and examples
  </task_planning>
```

### When to Use

- Feature development spanning multiple files
- Refactoring with multiple stages
- Bug investigation requiring several steps
- Any task that will take >3 tool invocations

### Real-World Examples

**❌ Too granular (micro-steps)**

```markdown
Plan:

1. Read user.ts file
2. Read auth.ts file
3. Import bcrypt library
4. Write hash function
5. Write verify function
6. Export functions
7. Update imports in main.ts
8. Run tests
```

**✓ Meaningful milestones**

```markdown
Plan:

1. Implement password hashing utilities
2. Integrate with authentication flow
3. Add comprehensive test coverage
```

**Real implementation example**

```markdown
User: "Add Redis caching to the API"

Agent creates plan:

1. Set up Redis connection and configuration
2. Implement cache middleware for API routes
3. Add cache invalidation on data mutations
4. Verify performance improvement with tests
```

### Integration Tips

For CLI assistants with TodoWrite tools:

```markdown
<planning_with_tools>
Use planning tools for complex tasks:

TodoWrite([
{content: "Set up Redis connection", status: "pending", activeForm: "Setting up Redis connection"},
{content: "Implement cache middleware", status: "pending", activeForm: "Implementing cache middleware"},
{content: "Add cache invalidation", status: "pending", activeForm: "Adding cache invalidation"},
{content: "Verify with tests", status: "pending", activeForm: "Verifying with tests"}
])

Rules:

- Mark first task in_progress before starting work
- Complete current task before starting next
- Exactly ONE task in_progress at any time
- Update immediately after finishing each task
  </planning_with_tools>
```

## Pattern 2: Update Frequency Rules

### Concept

Provide status updates at appropriate intervals - frequent enough to show progress, infrequent enough to avoid noise.

### Prompt Template

```markdown
<user_updates>
Provide status updates to the user:

Trigger conditions (whichever comes first):

- Every 6 execution steps, OR
- Every 8 tool calls, OR
- When encountering unexpected discoveries or blockers, OR
- When completing a major milestone

Update content should include:

- Initial approach/plan (at start)
- Key discoveries or unexpected findings
- Concrete outcomes achieved (at milestones)

Update length guidelines:

- Quick progress: 1-2 sentences
- Major milestones: 3-5 bullet points
- Blockers/changes: Brief explanation + new approach

Do not:

- Provide updates after every single tool call
- Send identical "still working" messages
- Skip updates during long operations
  </user_updates>
```

### When to Use

- Long-running implementations
- Tasks with uncertain complexity
- Investigations where findings might change the approach
- Any work where the user might wonder "what's happening?"

### Real-World Examples

**❌ Too frequent (noisy)**

```markdown
Agent: "Reading auth.ts..."
Agent: "Read complete. Now reading user.ts..."
Agent: "Read complete. Now reading config.ts..."
Agent: "Read complete. Now analyzing..."
```

**✓ Appropriate frequency**

```markdown
Agent: "I'm implementing authentication. Starting with context gathering..."
[Makes 5 parallel Read calls, analyzes]
Agent: "Reviewed the auth system. Found JWT-based auth. Implementing password reset flow..."
[Implements across 3 files]
Agent: "Implementation complete. Running tests..."
[Tests run]
Agent: "All tests passing. Password reset flow ready."
```

**Example with discovery**

```markdown
Agent: "Implementing user profile update endpoint..."
[Reads files, discovers validation framework]
Agent: "Found existing validation framework using Zod. Adapting approach to use it..."
[Continues with updated approach]
```

### Integration Tips

Set explicit thresholds in system prompts:

```markdown
Update the user every 8 tool calls or when significant progress is made.
Track tool call count internally and provide brief updates at intervals.
```

## Pattern 3: Task Completion Criteria

### Concept

Define explicit conditions that must be met before marking a task as completed.

### Prompt Template

```markdown
<completion_criteria>
Only mark a task as completed when ALL conditions are met:

For implementation tasks:
✓ Code implements all stated requirements
✓ Existing tests still pass
✓ New tests added for new functionality
✓ No linting errors or warnings
✓ Edge cases are handled

For investigation tasks:
✓ Root cause identified
✓ Findings documented clearly
✓ Recommendation provided (if applicable)

For refactoring tasks:
✓ Behavior unchanged (tests prove it)
✓ Code quality improved measurably
✓ No regressions introduced

If ANY criterion is unmet:

- Keep task as in_progress
- Address the gap
- Only then mark completed
  </completion_criteria>
```

### When to Use

Always. This prevents premature task completion and ensures quality.

### Real-World Examples

**❌ Premature completion**

```markdown
Agent: Task "Add user authentication" - completed
[But tests are failing]
[No password validation implemented]
[Security best practices not followed]
```

**✓ Proper completion verification**

```markdown
Agent: Implementing authentication...
[Implements core logic]
Agent: Running tests... found 2 failures in edge cases
[Fixes edge cases]
Agent: Re-running tests... all passing
[Checks linting]
Agent: Linting clean. Verifying security best practices...
[Reviews against OWASP guidelines]
Agent: Task "Add user authentication" - completed
```

## Pattern 4: Adaptive Planning

### Concept

Plans should evolve as you discover new requirements or blockers. Adjust the task list rather than forcing the original plan.

### Prompt Template

```markdown
<adaptive_planning>
When working on planned tasks:

If you discover:

- Additional requirements → Add new tasks to the plan
- Blockers → Add prerequisite tasks before current task
- Tasks no longer needed → Remove from plan entirely
- Tasks more complex than expected → Break into sub-tasks

Always:

- Explain why you're adjusting the plan
- Keep the user informed of changes
- Maintain focus on the overall goal

Example:
"While implementing X, I discovered we need Y first. Adding task:
'Implement Y dependency' before continuing with X."
</adaptive_planning>
```

### Real-World Examples

**Discovering new requirements**

```markdown
Agent: [Working on "Add user profile editing"]
Agent: "Found that profile images need validation. Adding new task:
'Implement image upload validation' before completing profile edit."

Updated plan:

1. Implement image upload validation (new)
2. Add user profile editing
3. Write comprehensive tests
```

**Removing unnecessary tasks**

```markdown
Agent: [Planned to "Refactor database queries"]
Agent: "Discovered the ORM already handles connection pooling efficiently.
Removing 'Implement connection pooling' from plan."

Updated plan:

1. ~~Implement connection pooling~~ (already handled by ORM)
2. Add query result caching
3. Optimize N+1 queries
```

**Breaking down complex tasks**

```markdown
Agent: [Working on "Implement real-time notifications"]
Agent: "This is more complex than anticipated. Breaking into phases: 1. Set up WebSocket server 2. Implement notification queue 3. Add client-side handlers 4. Add persistence layer"
```

## Pattern 5: Progress Visualization

### Concept

Present progress in a clear, scannable format that shows what's done, what's current, and what's remaining.

### Prompt Template

```markdown
<progress_reporting>
When reporting progress on multi-task work:

Format:
✓ Completed task description
→ Current task in progress

- Pending task description
- Pending task description

Example:
✓ Set up Redis connection and configuration
→ Implementing cache middleware for API routes

- Add cache invalidation on data mutations
- Verify performance improvement with tests

For detailed status:

1. Task name [COMPLETED] - Brief outcome
2. Task name [IN PROGRESS] - Current step
3. Task name [PENDING]
4. Task name [PENDING]
   </progress_reporting>
```

### Real-World Examples

**Simple progress indicator**

```markdown
Implementing user authentication:
✓ Password hashing utilities
→ Integration with login flow

- Test coverage
- Documentation update
```

**Detailed status report**

```markdown
User Profile Feature Progress:

1. Database schema migration [COMPLETED]

   - Added profile_data column with JSONB type
   - All existing tests passing

2. API endpoint implementation [IN PROGRESS]

   - GET /profile complete and tested
   - Working on PUT /profile validation

3. Frontend components [PENDING]

4. E2E test suite [PENDING]
```

## Combining Patterns

For comprehensive planning and tracking:

```markdown
# Task Management System

When the user requests a complex task:

## 1. Initial Planning

Create 2-5 milestone-level tasks with:

- Clear, actionable names
- Both imperative and active forms
- Explicit completion criteria

## 2. Execution

- Mark ONE task in_progress at a time
- Work autonomously through the task
- Adapt plan as discoveries are made

## 3. Status Updates

Provide updates every 8 tool calls or at milestones:

- Brief progress indicators for routine work
- Detailed explanations for discoveries/blockers
- Clear progress visualization

## 4. Completion Verification

Before marking completed, verify ALL criteria met:

- Tests passing
- Linting clean
- Requirements fulfilled
- Edge cases handled

## 5. Plan Adaptation

As work progresses:

- Add tasks for discovered requirements
- Remove tasks that are unnecessary
- Break down tasks that are too complex
- Always explain plan changes to user
```

## Anti-Patterns to Avoid

❌ **Micro-step planning**: Breaking work into trivial tasks like "import library"
❌ **Stale plans**: Continuing with original plan despite discovering blockers
❌ **Update spam**: Reporting after every single tool call
❌ **Premature completion**: Marking tasks done when tests are still failing
❌ **Multiple in-progress**: Working on several tasks simultaneously
❌ **Silent work**: Long operations without any status updates

✓ **Meaningful milestones**: 2-5 significant checkpoints
✓ **Adaptive planning**: Adjusting based on discoveries
✓ **Appropriate frequency**: Updates every ~8 tool calls or at milestones
✓ **Verified completion**: All criteria checked before marking complete
✓ **Sequential focus**: One task in_progress at a time
✓ **Progressive updates**: Keep user informed without noise

## Integration with CLI Assistants

### Claude Code

```markdown
Use TodoWrite tool for task tracking:

- Create todos at task start
- Update status in real-time
- Mark completed immediately after finishing
- Adapt plan by adding/removing tasks
```

### General CLI Tools

```markdown
If no planning tool available:

- Show progress in text updates
- Use clear visual indicators (✓, →, -)
- Maintain mental model of task state
- Communicate plan changes explicitly
```

## Credits

Patterns extracted and adapted from:

- [OpenAI GPT-5.1 Prompting Guide](https://cookbook.openai.com/examples/gpt-5/gpt-5-1_prompting_guide)

Applicable to Claude Code, Codex CLI, and similar AI coding assistants with task planning capabilities.
