# Prompts for Senior Software Development

A curated collection of battle-tested prompting patterns for CLI-based AI coding assistants, extracted from production systems and research.

## Purpose

This directory contains reusable prompt patterns specifically optimized for complex software development tasks. These patterns help AI coding assistants perform senior-level development work with greater autonomy, consistency, and effectiveness.

## Prompt Categories

### [Autonomous Agents](./autonomous-agents.md)

Patterns for building self-directed coding agents that can take a task from requirements to completion without constant hand-holding. Includes the "senior pair-programmer" pattern and techniques for preventing premature termination.

### [Tool Usage Patterns](./tool-usage-patterns.md)

Guidelines for when and how to invoke tools effectively. Covers parallel vs sequential execution, specialized tool selection, and avoiding common anti-patterns.

### [Planning & Tracking](./planning-and-tracking.md)

Structured approaches to breaking down complex tasks, tracking progress with milestones, and providing meaningful status updates at appropriate intervals.

### [Design Constraints](./design-constraints.md)

Techniques for enforcing design systems, code standards, and architectural patterns through prompts. Ensures consistency across generated code.

### [Metaprompting](./metaprompting.md)

Advanced techniques for diagnosing prompt failures, resolving contradictory instructions, and iteratively optimizing prompt effectiveness.

## How to Use

Each file contains:

- **Clear explanation** of the pattern or principle
- **Concrete examples** ready to copy and adapt
- **Real-world scenarios** showing when to apply the pattern
- **Integration tips** for CLI-based AI assistants (Claude Code, Codex CLI, etc.)

You can:

1. **Reference directly**: Copy patterns into your system prompts or `.claude/` configurations
2. **Adapt for your context**: Modify examples to match your codebase conventions
3. **Combine patterns**: Mix multiple patterns for sophisticated agent behaviors

## Credits

These prompting patterns are extracted and adapted from:

- [OpenAI GPT-5.1 Prompting Guide](https://cookbook.openai.com/examples/gpt-5/gpt-5-1_prompting_guide) - Production-tested patterns for GPT-5 series models

While originally documented for GPT-5.1, these patterns are generally applicable to advanced language models including Claude 3.5 Sonnet, Opus, and similar frontier models.

## Contributing

When adding new prompt patterns:

1. Use markdown format with clear examples
2. Include real-world usage scenarios
3. Credit the original source
4. Focus on patterns valuable for senior-level development work

## License

See repository root LICENSE. Individual patterns maintain attribution to their original sources as noted in credits sections.
