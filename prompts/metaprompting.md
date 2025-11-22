# Metaprompting Patterns

Advanced techniques for diagnosing prompt failures, resolving contradictory instructions, and iteratively optimizing prompt effectiveness.

## Core Principle: Prompts as Code

Treat prompts like software: debug systematically, version control changes, measure impact, and iterate based on data.

## Pattern 1: Two-Step Diagnosis and Optimization

### Concept

Don't guess at prompt fixes. Use a structured two-step process: first diagnose the failure mode, then make surgical edits.

### Prompt Template

```markdown
<metaprompting_workflow>
When a prompt isn't working as intended:

## Step 1: Diagnosis Phase

Ask the model to analyze the current prompt:

"Here is my current system prompt:
[INSERT PROMPT]

And here are examples where it fails:
[INSERT FAILURE EXAMPLES WITH EXPECTED VS ACTUAL BEHAVIOR]

Analyze:

1. What contradictory instructions exist?
2. What ambiguities could cause this behavior?
3. What implicit assumptions might the model be making?
4. Which parts of the prompt are being ignored or overridden?
5. What explicit instructions would resolve these failures?"

## Step 2: Implementation Phase

Ask for surgical edits:

"Based on your analysis, provide specific prompt edits that:

1. Resolve contradictions you identified
2. Add missing explicit instructions
3. Preserve existing good behaviors
4. Are minimal and targeted (not a full rewrite)

Format as:
OLD: [exact text to replace]
NEW: [replacement text]
REASON: [why this fixes the issue]"
</metaprompting_workflow>
```

### When to Use

- Prompt isn't producing expected behavior
- Inconsistent results across similar inputs
- Model seems to ignore specific instructions
- After major prompt changes that introduce regressions

### Real-World Examples

**Example failure case**

```markdown
Problem: Agent keeps using bash 'cat' instead of Read tool

Current prompt section:
"Use available tools to complete tasks efficiently."

Diagnosis request:
"My prompt says 'use available tools' but the agent uses 'cat' via Bash
instead of the Read tool. Why is this happening?"

Model diagnosis:
"The instruction is too vague. 'Available tools' could mean bash commands
OR specialized tools. The prompt doesn't explicitly forbid bash for file
reading. Add explicit hierarchy: specialized tools > bash."

Surgical fix:
OLD: "Use available tools to complete tasks efficiently."
NEW: "Use available tools to complete tasks efficiently. Always prefer
specialized tools over bash: use Read (not cat), Edit (not sed),
Grep (not grep). Only use Bash for actual terminal operations."
REASON: Explicitly establishes tool preference hierarchy.
```

**Example contradictory instructions**

```markdown
Problem: Agent waits for permission despite being told to work autonomously

Current prompt:
Section 1: "You are an autonomous agent. Complete tasks without waiting."
Section 2: "Before making changes, confirm with the user."

Diagnosis request:
"Agent both 'works autonomously' and 'confirms before changes'. These
conflict. How do I resolve this?"

Model diagnosis:
"Section 2 overrides Section 1 due to recency bias and specificity.
'Confirm with user' is more specific than 'work autonomously'."

Surgical fix:
OLD: "Before making changes, confirm with the user."
NEW: "Before making destructive changes (deleting files, force push, etc.),
confirm with the user. For normal development work (edits, tests,
commits), proceed autonomously."
REASON: Resolves contradiction by scoping when confirmation is needed.
```

### Integration Tips

**Version control your prompts**

```bash
# Keep prompts in git
.claude/
  prompts/
    system-v1.md
    system-v2.md (current)
    CHANGELOG.md
```

**Document failure modes**

```markdown
# CHANGELOG.md

## v2 (2024-01-15)

Fixed: Agent using 'cat' instead of Read tool

- Added explicit tool preference hierarchy
- Test case: "read config.json" → uses Read, not Bash

## v1 (2024-01-10)

Initial prompt
```

## Pattern 2: Contradiction Detection

### Concept

Proactively identify and resolve contradictory instructions before they cause problems.

### Prompt Template

```markdown
<contradiction_check>
Review the following system prompt and identify any contradictions:

[INSERT FULL SYSTEM PROMPT]

For each contradiction found, provide:

1. Instruction A (quote exactly)
2. Instruction B (quote exactly)
3. How they conflict
4. Recommended resolution
5. Scenarios where the conflict would manifest

Format:
CONTRADICTION #1:
A: "..." (line X)
B: "..." (line Y)
CONFLICT: [explanation]
RESOLUTION: [specific fix]
EXAMPLE SCENARIO: [when this would cause problems]
</contradiction_check>
```

### When to Use

- After adding new instructions to existing prompts
- When combining prompts from multiple sources
- Before deploying prompts to production
- During prompt reviews/audits

### Real-World Examples

**Detected contradiction**

```markdown
CONTRADICTION #1:
A: "Provide concise responses (2-3 sentences max)" (line 15)
B: "Explain your reasoning in detail" (line 42)
CONFLICT: Conciseness and detailed explanation are mutually exclusive
RESOLUTION: Specify when each applies:
"Provide concise summaries for routine operations (2-3 sentences).
Provide detailed explanations for complex decisions, errors, or
when user asks 'why'."
EXAMPLE SCENARIO: User asks "why did this fail?" - agent gives 2 sentence
response instead of detailed debugging explanation.

CONTRADICTION #2:
A: "Use British English spelling" (line 8)
B: "Follow the codebase's existing conventions" (line 23)
CONFLICT: If codebase uses American English, which takes precedence?
RESOLUTION: Make hierarchy explicit:
"Use British English for user-facing messages. Match codebase
conventions for code comments and documentation."
EXAMPLE SCENARIO: Agent writes "colour" in code comments when codebase
consistently uses "color".
```

## Pattern 3: Iterative Refinement with Measurement

### Concept

Measure prompt performance systematically and iterate based on data, not intuition.

### Prompt Template

```markdown
<prompt_evaluation>
To evaluate prompt effectiveness:

## 1. Define Test Cases

Create 10-20 representative scenarios covering:

- Common tasks (60%)
- Edge cases (30%)
- Known failure modes (10%)

Format:
{
"input": "User request",
"expected": "Desired behavior",
"eval_criteria": ["criterion1", "criterion2"]
}

## 2. Run Evaluation

For each test case, record:

- Did it follow instructions? (yes/no)
- Did it use correct tools? (yes/no)
- Was output format correct? (yes/no)
- Custom criteria from test case

## 3. Calculate Metrics

- Overall success rate: X/Y tasks
- Per-category success rates
- Common failure patterns

## 4. Iterate

- If success rate < 90%: Identify most common failure
- Make one targeted change
- Re-run evaluation
- Compare before/after metrics

Never make multiple changes simultaneously - you won't know what worked.
</prompt_evaluation>
```

### When to Use

- Optimizing prompts for production
- A/B testing different prompt variations
- Validating prompt changes before deployment
- Tracking prompt performance over time

### Real-World Examples

**Evaluation test suite**

```json
[
  {
    "input": "Read the config file and tell me the API endpoint",
    "expected": "Uses Read tool (not Bash cat), extracts endpoint, responds clearly",
    "eval_criteria": ["uses_read_tool", "no_bash_cat", "correct_extraction"]
  },
  {
    "input": "Search for all TODO comments",
    "expected": "Uses Grep with pattern='TODO', not multiple file reads",
    "eval_criteria": ["uses_grep", "efficient_search"]
  },
  {
    "input": "Implement user authentication",
    "expected": "Creates plan, gathers context, implements autonomously, writes tests",
    "eval_criteria": ["creates_plan", "autonomous", "includes_tests"]
  }
]
```

**Metrics tracking**

```markdown
# Prompt Performance Log

## Version 2 (2024-01-15)

Success rate: 18/20 (90%)
Failures:

- Test #7: Used cat instead of Read (1/20)
- Test #14: Waited for permission instead of autonomous work (1/20)

## Version 1 (2024-01-10)

Success rate: 14/20 (70%)
Failures:

- Used cat instead of Read (4/20)
- Waited for permission (2/20)

Improvement: +20% success rate

- Fixed tool preference → reduced cat usage from 20% to 5%
- Clarified autonomy → reduced permission-seeking from 10% to 5%
```

## Pattern 4: Prompt Composition

### Concept

Build complex prompts from modular, tested components rather than monolithic instructions.

### Prompt Template

```markdown
<prompt_modules>
Structure prompts as composable sections:

## Base Behavior

[Core agent personality and approach]

## Domain Knowledge

[Project-specific context and conventions]

## Tool Usage Rules

[How and when to use each tool]

## Quality Standards

[Code style, testing, security requirements]

## Output Formatting

[How to structure responses]

Each section should be:

- Self-contained (not referencing other sections)
- Independently testable
- Reusable across different agents
- Clearly demarcated with headers

Combine sections with clear hierarchy:

1. Base behavior (always applies)
2. Domain knowledge (context-specific)
3. Tool usage (override base if needed)
4. Quality standards (non-negotiable)
5. Output formatting (user experience)
   </prompt_modules>
```

### When to Use

- Building prompts for multiple similar agents
- Maintaining prompts across team members
- Sharing prompt patterns across projects
- Making prompts easier to debug and update

### Real-World Examples

**Modular structure**

```markdown
# modules/base-agent.md

You are an autonomous senior pair-programmer...
[Core autonomous behavior]

# modules/tool-usage.md

Always prefer specialized tools over bash...
[Tool selection rules]

# modules/rust-conventions.md

Follow these Rust-specific patterns...
[Language-specific rules]

# Combined prompt for Rust project:

{{base-agent.md}}
{{tool-usage.md}}
{{rust-conventions.md}}
```

**Benefits of modularity**

```markdown
Scenario: Need to create Python agent

Reuse:

- base-agent.md (unchanged)
- tool-usage.md (unchanged)

Replace:

- rust-conventions.md → python-conventions.md

Result: 2/3 of prompt reused, only language-specific section changes
```

## Pattern 5: Failure Mode Documentation

### Concept

Document known failure modes and their fixes to prevent regressions.

### Prompt Template

```markdown
<failure_mode_tracking>
Maintain a FAILURE_MODES.md document:

## Failure Mode: [Short Description]

### Symptoms

- Observable behavior indicating this failure
- Example inputs that trigger it

### Root Cause

- Why the prompt produces this behavior
- What instruction is being misinterpreted

### Fix

- Exact prompt change that resolves it
- Before/after comparison

### Test Case

- Input that would fail before fix
- Expected behavior after fix
- How to verify it's fixed

### Related Issues

- Links to other similar failures
- Patterns across failures
  </failure_mode_tracking>
```

### Real-World Examples

**Documented failure mode**

```markdown
## Failure Mode: Agent Uses cat Instead of Read Tool

### Symptoms

- Agent runs Bash("cat file.txt") instead of Read("file.txt")
- Happens on ~20% of file reading tasks
- Inconsistent - sometimes uses Read correctly

### Root Cause

Prompt said "use available tools" but didn't establish hierarchy.
Agent treats bash commands as equally valid "tools" as specialized tools.

### Fix

OLD: "Use available tools to complete tasks efficiently."
NEW: "Use available tools to complete tasks efficiently. Always prefer
specialized tools over bash: use Read (not cat), Edit (not sed),
Grep (not grep). Only use Bash for actual terminal operations."

### Test Case

Input: "What's in config.json?"
Before: Bash("cat config.json")
After: Read("config.json")
Verification: Check tool invocation logs

### Related Issues

- Similar issue with grep vs Grep (fixed in v1.2)
- Similar issue with find vs Glob (fixed in v1.3)
- Pattern: Need explicit tool preference hierarchy for all file operations
```

## Combining Patterns

Comprehensive metaprompting workflow:

```markdown
# Prompt Optimization Workflow

## 1. Modular Design

- Break prompt into logical sections
- Make each section independently testable
- Version control each module

## 2. Initial Testing

- Create 20 test cases covering common tasks and edge cases
- Run baseline evaluation
- Document initial success rate

## 3. Contradiction Detection

- Review full assembled prompt
- Identify conflicting instructions
- Resolve before deployment

## 4. Production Monitoring

- Track failure patterns
- Document in FAILURE_MODES.md
- Collect examples for evaluation suite

## 5. Iterative Improvement

When failures occur:
a) Diagnosis: Ask model to analyze prompt + failures
b) Fix: Make surgical edits, not rewrites
c) Test: Re-run evaluation suite
d) Measure: Compare before/after metrics
e) Document: Add test case and failure mode entry

## 6. Regression Prevention

- Add test case for every fixed failure
- Update evaluation suite regularly
- Review prompt changes in pull requests
```

## Anti-Patterns to Avoid

❌ **Guessing at fixes**: Making changes without diagnosing root cause
❌ **Multiple simultaneous changes**: Can't tell what worked
❌ **No measurement**: "Seems better" isn't evidence
❌ **Monolithic prompts**: Hard to debug and maintain
❌ **Ignoring contradictions**: They will cause inconsistent behavior
❌ **No version control**: Can't roll back bad changes

✓ **Systematic diagnosis**: Use model to analyze failures
✓ **One change at a time**: Isolate what works
✓ **Data-driven iteration**: Measure before/after
✓ **Modular composition**: Reusable, testable sections
✓ **Proactive contradiction detection**: Check before deploying
✓ **Git-tracked prompts**: Full history and rollback capability

## Evaluation Framework

### Deterministic Graders

For objective criteria:

```python
def check_tool_usage(response):
    """Verify Read tool used instead of cat command"""
    tool_calls = extract_tool_calls(response)

    # Negative criteria
    bash_cats = [t for t in tool_calls
                 if t.tool == "Bash" and "cat" in t.args]
    if bash_cats:
        return {"pass": False, "reason": "Used cat instead of Read"}

    # Positive criteria
    reads = [t for t in tool_calls if t.tool == "Read"]
    if not reads:
        return {"pass": False, "reason": "Did not read file"}

    return {"pass": True}
```

### LLM-as-Judge

For subjective criteria:

```markdown
Evaluate this agent response against the rubric:

Response: [AGENT OUTPUT]

Rubric:

1. Autonomy (1-5): Did agent work independently without asking permission?
2. Completeness (1-5): Did agent finish the task fully?
3. Code Quality (1-5): Does code follow best practices?
4. Testing (1-5): Are comprehensive tests included?

Provide:

- Score for each criterion (1-5)
- Brief justification for each score
- Overall pass/fail (pass if all ≥ 4)
```

### Combined Evaluation

```python
def evaluate_prompt(test_cases, prompt):
    results = []
    for test in test_cases:
        response = run_agent(test.input, prompt)

        # Deterministic checks
        tool_check = check_tool_usage(response)
        format_check = check_output_format(response)

        # LLM judge for subjective criteria
        quality_score = llm_judge(response, test.rubric)

        results.append({
            "test": test.name,
            "tool_usage": tool_check.pass,
            "formatting": format_check.pass,
            "quality": quality_score.overall >= 4,
            "overall": all([tool_check.pass, format_check.pass, quality_score.overall >= 4])
        })

    return {
        "success_rate": sum(r.overall for r in results) / len(results),
        "details": results
    }
```

## Credits

Patterns extracted and adapted from:

- [OpenAI GPT-5.1 Prompting Guide](https://cookbook.openai.com/examples/gpt-5/gpt-5-1_prompting_guide)
- Prompt engineering research and best practices

Applicable to all frontier language models and AI coding assistants where prompt quality directly impacts performance.
