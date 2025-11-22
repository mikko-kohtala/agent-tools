# Design Constraints Patterns

Techniques for enforcing design systems, code standards, and architectural patterns through prompts. Ensures consistency and quality across AI-generated code.

## Core Principle: Explicit Over Implicit

Don't assume the AI will infer your conventions. State design rules explicitly with concrete examples of what's allowed and forbidden.

## Pattern 1: Design System Enforcement

### Concept

When working on UI code, explicitly forbid hard-coded values and require references to design system variables.

### Prompt Template

```markdown
<design_system_rules>
When generating UI code:

Color usage:
✗ NEVER hard-code colors (hex, hsl, oklch, rgb, named colors)
✓ ALWAYS use CSS variables from globals.css
✓ Use semantic names: --primary, --accent, --danger, --text-primary

Spacing:
✗ NEVER use arbitrary pixel values (margin: 24px)
✓ ALWAYS use spacing scale: --space-xs, --space-sm, --space-md, --space-lg, --space-xl

Typography:
✗ NEVER set font-size directly
✓ ALWAYS use type scale: --text-xs, --text-sm, --text-base, --text-lg, --text-xl

Border radius:
✗ NEVER use pixel values
✓ ALWAYS use: --radius-sm, --radius-md, --radius-lg

Before writing any UI code:

1. Read globals.css to understand available variables
2. Use only those variables in your implementation
3. If a needed variable doesn't exist, ask before creating it
   </design_system_rules>
```

### When to Use

- Projects with established design systems
- Teams requiring strict UI consistency
- Component libraries that need to follow patterns
- Any codebase with a globals.css or theme file

### Real-World Examples

**❌ Hard-coded values (violates design system)**

```css
.button {
  background-color: #3b82f6;
  color: #ffffff;
  padding: 12px 24px;
  border-radius: 8px;
  font-size: 16px;
}
```

**✓ Design system references**

```css
.button {
  background-color: var(--primary);
  color: var(--text-on-primary);
  padding: var(--space-sm) var(--space-md);
  border-radius: var(--radius-md);
  font-size: var(--text-base);
}
```

**Example with discovery**

```markdown
Agent: "Let me first check the design system..."
[Reads globals.css]
Agent: "Found variables: --primary, --space-sm through --space-xl, --radius-md.
Implementing button component using these variables..."
[Generates code using only design system references]
```

### Integration Tips

Add to system prompts for frontend work:

```markdown
Before generating any UI component:

1. Read the design system file (globals.css, theme.ts, etc.)
2. Identify relevant variables for your component
3. Use ONLY those variables, never hard-coded values
4. If you need a value that doesn't exist, flag it and ask
```

## Pattern 2: Code Style Enforcement

### Concept

Define mandatory code patterns and forbidden patterns with concrete examples.

### Prompt Template

```markdown
<code_style_rules>
Required patterns in this codebase:

Error handling:
✓ Use Result<T, E> types for fallible operations
✗ Never use exceptions for control flow
Example:
fn process_data(input: &str) -> Result<Data, ParseError> { ... }

Async patterns:
✓ Use async/await with proper error propagation
✗ Never use .unwrap() in async code
Example:
async fn fetch_user(id: UserId) -> Result<User, ApiError> {
let response = client.get(&url).await?;
response.json().await.map_err(Into::into)
}

Imports:
✓ Group by: std, external crates, internal modules
✓ Sort alphabetically within groups
✗ Never use wildcard imports (use std::\*;)

Naming:
✓ Functions: snake_case
✓ Types: PascalCase
✓ Constants: SCREAMING_SNAKE_CASE
✗ Never abbreviate unless standard (like id, url)
</code_style_rules>
```

### When to Use

- Projects with strict linting rules
- Teams with established conventions
- Languages with multiple valid styles (Python, JavaScript)
- Codebases requiring consistency for maintainability

### Real-World Examples

**Rust: Error handling patterns**

```markdown
<rust_error_handling>
✓ Use ? operator for error propagation:
fn read_config() -> Result<Config, ConfigError> {
let contents = fs::read_to_string("config.toml")?;
toml::from_str(&contents).map_err(ConfigError::ParseError)
}

✗ Never use .unwrap() in production code:
let contents = fs::read_to_string("config.toml").unwrap(); // FORBIDDEN

✗ Never ignore errors with let _:
let _ = fs::remove_file(path); // FORBIDDEN, use .ok() if intentional
</rust_error_handling>
```

**TypeScript: Null handling patterns**

```markdown
<typescript_null_safety>
✓ Use optional chaining and nullish coalescing:
const name = user?.profile?.name ?? 'Anonymous';

✗ Never use as for type assertions without validation:
const user = data as User; // FORBIDDEN without runtime check

✓ Use type guards for unknown data:
function isUser(data: unknown): data is User {
return typeof data === 'object' && data !== null && 'id' in data;
}
</typescript_null_safety>
```

### Integration Tips

Create a CODE_STYLE.md in your repo and reference it:

```markdown
Before writing code, review CODE_STYLE.md for this project's conventions.
Follow all rules exactly. If a pattern isn't documented, match existing code.
```

## Pattern 3: Architectural Patterns

### Concept

Enforce high-level architectural decisions like layering, dependency direction, and separation of concerns.

### Prompt Template

```markdown
<architecture_rules>
This project follows Clean Architecture:

Layer rules:

1. Domain layer (src/domain/):
   ✓ Contains business logic and entities
   ✗ NEVER imports from infrastructure or presentation layers
   ✗ No dependencies on frameworks or external libraries

2. Application layer (src/application/):
   ✓ Contains use cases and application services
   ✓ May import from domain layer
   ✗ NEVER imports from infrastructure or presentation

3. Infrastructure layer (src/infrastructure/):
   ✓ Contains database, API clients, external integrations
   ✓ May import from domain and application layers
   ✓ Implements interfaces defined in domain

4. Presentation layer (src/presentation/):
   ✓ Contains controllers, views, API routes
   ✓ May import from application layer
   ✗ NEVER directly accesses infrastructure

Dependency direction: Presentation → Application → Domain ← Infrastructure

Before creating any new file:

1. Identify which layer it belongs to
2. Place it in the correct directory
3. Verify imports follow dependency rules
4. Use dependency injection for cross-layer communication
   </architecture_rules>
```

### When to Use

- Projects following DDD, Clean Architecture, or Hexagonal Architecture
- Microservices with strict service boundaries
- Large codebases where architecture drift is a risk
- Teams onboarding new developers who need guidance

### Real-World Examples

**Enforcing dependency direction**

```markdown
Agent: "I need to fetch user data. Let me check the architecture..."
[Reads ARCHITECTURE.md]

Agent: "Following Clean Architecture: 1. Domain layer defines User entity and UserRepository interface 2. Infrastructure layer implements UserRepository with DB access 3. Application layer uses UserRepository through dependency injection 4. Presentation layer calls application service"

[Creates properly layered implementation]
```

**❌ Violating layer rules**

```typescript
// src/domain/user.ts - WRONG
import { DatabaseClient } from "../infrastructure/database"; // Forbidden!

class User {
  async save() {
    await DatabaseClient.insert(this); // Domain shouldn't know about DB
  }
}
```

**✓ Following layer rules**

```typescript
// src/domain/user.ts
interface UserRepository {
  save(user: User): Promise<void>;
}

class User {
  // Business logic only, no infrastructure
}

// src/infrastructure/user-repository-impl.ts
class UserRepositoryImpl implements UserRepository {
  async save(user: User): Promise<void> {
    await this.db.insert(user); // Infrastructure handles DB
  }
}
```

## Pattern 4: Security Requirements

### Concept

Explicitly forbid insecure patterns and require security best practices.

### Prompt Template

```markdown
<security_rules>
Security requirements for all code:

Input validation:
✓ Validate and sanitize ALL user input
✓ Use parameterized queries for database operations
✗ NEVER concatenate user input into SQL/NoSQL queries
✗ NEVER use eval() or similar with user data

Authentication:
✓ Hash passwords with bcrypt/argon2 (work factor ≥ 12)
✗ NEVER store passwords in plain text
✗ NEVER log sensitive data (passwords, tokens, PII)

API security:
✓ Use HTTPS for all external communications
✓ Validate JWT tokens on every protected endpoint
✓ Implement rate limiting on authentication endpoints
✗ NEVER trust client-side validation alone

File uploads:
✓ Validate file types by content, not just extension
✓ Scan uploaded files for malware
✓ Store outside webroot with random names
✗ NEVER execute uploaded files

Before implementing any feature:

1. Identify security risks
2. Apply OWASP Top 10 mitigations
3. Use security linters (semgrep, bandit, eslint-plugin-security)
4. Never relax security for convenience
   </security_rules>
```

### When to Use

Always. Security should be non-negotiable in every codebase.

### Real-World Examples

**❌ SQL Injection vulnerability**

```javascript
// FORBIDDEN
app.get("/users", (req, res) => {
  const query = `SELECT * FROM users WHERE name = '${req.query.name}'`;
  db.query(query, (err, results) => res.json(results));
});
```

**✓ Parameterized query (safe)**

```javascript
app.get("/users", (req, res) => {
  const query = "SELECT * FROM users WHERE name = ?";
  db.query(query, [req.query.name], (err, results) => res.json(results));
});
```

**✓ Agent following security rules**

```markdown
Agent: "Implementing user search endpoint..."
[Reviews security requirements]
Agent: "Using parameterized queries to prevent SQL injection.
Adding input validation with Joi schema.
Implementing rate limiting (100 req/min per IP).
Logging searches but excluding PII."
[Implements secure version]
```

## Pattern 5: Testing Requirements

### Concept

Require specific types of tests and coverage levels for new code.

### Prompt Template

```markdown
<testing_requirements>
All new code must include:

Unit tests:
✓ Test happy path
✓ Test edge cases (empty input, null, boundary values)
✓ Test error conditions
✓ Aim for 80%+ code coverage on new code

Integration tests:
✓ Test component interactions
✓ Use test database/mocks for external services
✓ Verify error handling across boundaries

Test structure:
✓ Follow AAA pattern: Arrange, Act, Assert
✓ One assertion focus per test
✓ Descriptive test names: test*<function>*<scenario>\_<expected>

Example:
test_calculate_discount_when_user_is_premium_returns_20_percent()

Before marking implementation complete:

1. Write comprehensive tests
2. Run full test suite
3. Verify all tests pass
4. Check coverage meets threshold
   </testing_requirements>
```

### When to Use

- Projects with strict quality gates
- TDD/BDD workflows
- Critical systems requiring high reliability
- Teams requiring test documentation

### Real-World Examples

**Complete test coverage**

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_email_with_valid_input_succeeds() {
        let result = parse_email("user@example.com");
        assert!(result.is_ok());
    }

    #[test]
    fn test_parse_email_with_missing_at_returns_error() {
        let result = parse_email("userexample.com");
        assert!(matches!(result, Err(EmailError::InvalidFormat)));
    }

    #[test]
    fn test_parse_email_with_empty_string_returns_error() {
        let result = parse_email("");
        assert!(matches!(result, Err(EmailError::Empty)));
    }
}
```

## Combining Patterns

For comprehensive code quality enforcement:

```markdown
# Code Quality Standards

When writing any code in this project:

## 1. Pre-Implementation

- Read ARCHITECTURE.md for layer placement
- Review CODE_STYLE.md for conventions
- Check design system (globals.css) for UI work

## 2. Implementation

Design system:

- Use design tokens, never hard-coded values
- Reference existing patterns

Code style:

- Follow naming conventions
- Use approved error handling patterns
- Import organization: std → external → internal

Architecture:

- Place files in correct layer
- Respect dependency directions
- Use dependency injection

Security:

- Validate all inputs
- Use parameterized queries
- Hash passwords properly
- Never log sensitive data

## 3. Testing

- Write unit tests (80%+ coverage)
- Include edge cases and error conditions
- Integration tests for cross-component logic
- All tests must pass before completion

## 4. Verification

- Run linter: npm run lint / cargo clippy
- Run type checker: tsc / cargo check
- Run tests: npm test / cargo test
- Verify security: npm audit / cargo audit
```

## Anti-Patterns to Avoid

❌ **Assuming conventions**: Guessing at code style without checking
❌ **Partial compliance**: Following some rules but ignoring others
❌ **Hardcoded values**: Using magic numbers/strings instead of design tokens
❌ **Insecure shortcuts**: Skipping security for development speed
❌ **Test-after thinking**: Writing tests as an afterthought
❌ **Dependency violations**: Importing from layers you shouldn't

✓ **Explicit checking**: Reading style guides before writing code
✓ **Full compliance**: Following ALL rules consistently
✓ **Design system usage**: All values from defined tokens
✓ **Security first**: Building in security from the start
✓ **Test-driven approach**: Tests as part of implementation
✓ **Architectural discipline**: Respecting layer boundaries

## Integration with CLI Assistants

### Adding to System Prompts

```markdown
<project_constraints>
This project requires strict adherence to:

1. Design system (globals.css)
2. Code style (CODE_STYLE.md)
3. Architecture (Clean Architecture, see ARCHITECTURE.md)
4. Security (OWASP Top 10 compliance)
5. Testing (80%+ coverage, all tests passing)

Before writing any code:

- Read relevant documentation files
- Identify applicable rules
- Follow them exactly

Never:

- Skip security for convenience
- Hard-code values that should use design tokens
- Violate architectural layer boundaries
- Submit code without tests
  </project_constraints>
```

### File-Based Configuration

Create `.claude/constraints.md` or similar:

```markdown
# Project Constraints

Read before every implementation:

- [Design System](../docs/design-system.md)
- [Code Style](../CODE_STYLE.md)
- [Architecture](../ARCHITECTURE.md)
- [Security](../SECURITY.md)

These are mandatory, not suggestions.
```

## Credits

Patterns extracted and adapted from:

- [OpenAI GPT-5.1 Prompting Guide](https://cookbook.openai.com/examples/gpt-5/gpt-5-1_prompting_guide)
- OWASP Top 10 security guidelines
- Clean Architecture principles (Robert C. Martin)

Applicable to all AI coding assistants working in professional codebases.
