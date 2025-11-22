# Windmill Development Workflow Patterns

Comprehensive workflow patterns for developing with and on Windmill.

## Setting Up Windmill Development

### For Users: Setting Up a Windmill Project

```bash
# 1. Initialize project
mkdir my-windmill-project && cd my-windmill-project
wmill init

# 2. Add workspace
wmill workspace add
# Interactive prompts:
# - Workspace name (e.g., "production")
# - Windmill instance URL (e.g., https://app.windmill.dev)
# - Workspace ID (e.g., "my-workspace")
# - API token

# 3. Pull existing resources (if any)
wmill sync pull

# 4. Optional: Bind workspace to git branch
wmill init --bind-profile
```

### For Contributors: Setting Up Windmill Codebase

```bash
# 1. Clone repository
git clone https://github.com/windmill-labs/windmill.git
cd windmill

# 2. Backend setup (Rust)
cd backend
# Follow @backend/rust-best-practices.mdc

# 3. Frontend setup (Svelte)
cd ../frontend
# Follow @frontend/svelte5-best-practices.mdc

# 4. CLI setup (TypeScript/Deno)
cd ../cli
deno task dev
```

## Script Development Patterns

### Pattern 1: Simple Data Processing Script

**Use case:** Transform data, call APIs, process files

**Steps:**
```bash
# 1. Ask user for folder location
# Example: f/data/transformers/

# 2. Create script file
# Example: f/data/transformers/csv_to_json.py

# 3. Write script
```

```python
# f/data/transformers/csv_to_json.py
import csv
import json

def main(csv_data: str):
    """Convert CSV string to JSON array"""
    reader = csv.DictReader(csv_data.splitlines())
    return [row for row in reader]
```

```bash
# 4. Generate metadata
wmill script generate-metadata

# 5. Test locally
wmill script run f/data/transformers/csv_to_json --data '{"csv_data": "name,age\nJohn,30"}'

# 6. Deploy
wmill sync push
```

### Pattern 2: Script with External API Integration

**Use case:** Call third-party APIs with authentication

**Steps:**
```bash
# 1. Check available resource types
wmill resource-type list --schema | grep -i stripe

# 2. Create script with resource parameter
```

```typescript
// f/integrations/stripe/create_customer.ts
import * as wmill from "windmill-client"

type Stripe = {
  api_key: string
}

export async function main(
  stripe: Stripe,
  email: string,
  name: string
) {
  const response = await fetch('https://api.stripe.com/v1/customers', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${stripe.api_key}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({ email, name })
  })

  return await response.json()
}
```

```bash
# 3. Generate metadata
wmill script generate-metadata

# 4. Create resource in Windmill UI or via YAML
# f/resources/stripe_prod.yaml

# 5. Test with resource
wmill script run f/integrations/stripe/create_customer \
  --data '{"stripe": "$res:f/resources/stripe_prod", "email": "test@example.com", "name": "Test User"}'

# 6. Deploy
wmill sync push
```

### Pattern 3: Script with State Persistence

**Use case:** Track state across executions (counters, caches, etc.)

```typescript
// f/utils/rate_limiter.ts
import * as wmill from "windmill-client"

export async function main(action: string) {
  // Get persistent state
  let state = await wmill.getState() || { count: 0, last_reset: Date.now() }

  // Reset counter every hour
  if (Date.now() - state.last_reset > 3600000) {
    state = { count: 0, last_reset: Date.now() }
  }

  // Check rate limit
  if (state.count >= 100) {
    throw new Error("Rate limit exceeded")
  }

  // Increment and save
  state.count++
  await wmill.setState(state)

  return { action, remaining: 100 - state.count }
}
```

### Pattern 4: Script Calling Other Scripts

**Use case:** Compose functionality, reuse scripts

```typescript
// f/workflows/orchestrator.ts
import * as wmill from "windmill-client"

export async function main(items: string[]) {
  const results = []

  for (const item of items) {
    // Call existing script
    const result = await wmill.runScript(
      "f/utils/processor",
      null,
      { input: item },
      true  // verbose
    )
    results.push(result)
  }

  return results
}
```

## Flow Development Patterns

### Pattern 1: Simple Sequential Flow

**Use case:** Chain multiple steps together

```bash
# 1. Create flow folder
mkdir -p f/workflows/user_onboarding.flow

# 2. Create flow.yaml
```

```yaml
# f/workflows/user_onboarding.flow/flow.yaml
summary: "Onboard new user"
value:
  modules:
    - id: validate_email
      value:
        type: rawscript
        content: '!inline validate_email.ts'
        language: bun
        input_transforms:
          email:
            type: javascript
            expr: "flow_input.email"

    - id: create_user
      value:
        type: rawscript
        content: '!inline create_user.ts'
        language: bun
        input_transforms:
          email:
            type: javascript
            expr: "results.validate_email.email"
          name:
            type: javascript
            expr: "flow_input.name"

    - id: send_welcome_email
      value:
        type: script
        path: "f/emails/send_welcome"
        input_transforms:
          user:
            type: javascript
            expr: "results.create_user"

schema:
  type: object
  properties:
    email:
      type: string
      format: email
    name:
      type: string
  required: ["email", "name"]
```

```bash
# 3. Create inline scripts
```

```typescript
// f/workflows/user_onboarding.flow/validate_email.ts
export async function main(email: string) {
  if (!email.includes('@')) {
    throw new Error('Invalid email')
  }
  return { email, valid: true }
}
```

```typescript
// f/workflows/user_onboarding.flow/create_user.ts
export async function main(email: string, name: string) {
  // Create user logic
  return { id: 123, email, name, created_at: new Date().toISOString() }
}
```

```bash
# 4. Generate locks
wmill flow generate-locks --yes

# 5. Test
wmill flow run f/workflows/user_onboarding --data '{"email": "test@example.com", "name": "Test"}'

# 6. Deploy
wmill sync push
```

### Pattern 2: Flow with Conditional Branching

**Use case:** Different paths based on conditions

```yaml
summary: "Process order with approval"
value:
  modules:
    - id: calculate_total
      value:
        type: rawscript
        content: '!inline calculate_total.ts'
        language: bun
        input_transforms:
          items:
            type: javascript
            expr: "flow_input.items"

    - id: check_amount
      value:
        type: branchone
        branches:
          - summary: "High value - needs approval"
            expr: "results.calculate_total.total > 1000"
            modules:
              - id: request_approval
                value:
                  type: rawscript
                  content: '!inline request_approval.ts'
                  language: bun
                  suspend:
                    required_events: 1
                    timeout: 86400
                  input_transforms: {}

          - summary: "Low value - auto-approve"
            expr: "results.calculate_total.total <= 1000"
            modules:
              - id: auto_approve
                value:
                  type: rawscript
                  content: '!inline auto_approve.ts'
                  language: bun
                  input_transforms: {}

    - id: process_payment
      value:
        type: script
        path: "f/payments/charge"
        input_transforms:
          amount:
            type: javascript
            expr: "results.calculate_total.total"

schema:
  type: object
  properties:
    items:
      type: array
      items:
        type: object
```

### Pattern 3: Flow with Parallel Processing

**Use case:** Process items concurrently

```yaml
summary: "Process multiple items in parallel"
value:
  modules:
    - id: fetch_items
      value:
        type: rawscript
        content: '!inline fetch_items.ts'
        language: bun
        input_transforms: {}

    - id: process_loop
      value:
        type: forloopflow
        iterator:
          type: javascript
          expr: "results.fetch_items.items"
        skip_failures: true
        parallel: true
        parallelism: 4  # Process 4 at a time
        modules:
          - id: process_item
            value:
              type: rawscript
              content: '!inline process_item.ts'
              language: bun
              input_transforms:
                item:
                  type: javascript
                  expr: "flow_input.iter.value"
                index:
                  type: javascript
                  expr: "flow_input.iter.index"

    - id: aggregate_results
      value:
        type: rawscript
        content: '!inline aggregate_results.ts'
        language: bun
        input_transforms:
          results:
            type: javascript
            expr: "results.process_loop"

schema:
  type: object
  properties: {}
```

### Pattern 4: Flow with Error Handling

**Use case:** Graceful error recovery

```yaml
summary: "Robust data pipeline"
value:
  modules:
    - id: extract
      value:
        type: script
        path: "f/etl/extract_data"
        retry:
          constant:
            attempts: 3
            seconds: 5
        input_transforms: {}

    - id: transform
      value:
        type: script
        path: "f/etl/transform_data"
        continue_on_error: true  # Don't fail entire flow
        input_transforms:
          data:
            type: javascript
            expr: "results.extract"

    - id: load
      value:
        type: script
        path: "f/etl/load_data"
        input_transforms:
          data:
            type: javascript
            expr: "results.transform || results.extract"  # Fallback to raw data

  failure_module:
    id: handle_error
    value:
      type: rawscript
      content: '!inline handle_error.ts'
      language: bun
      input_transforms: {}

schema:
  type: object
  properties: {}
```

## Testing Strategies

### Local Script Testing

```bash
# 1. Test with inline data
wmill script run f/folder/script --data '{"param": "value"}'

# 2. Test with file input
echo '{"param": "value"}' > test_input.json
wmill script run f/folder/script --data @test_input.json

# 3. Test with resource reference
wmill script run f/folder/script --data '{"db": "$res:f/resources/postgres"}'
```

### Local Flow Testing

```bash
# 1. Test entire flow
wmill flow run f/workflows/pipeline --data '{"input": "test"}'

# 2. Test with verbose output
wmill flow run f/workflows/pipeline --data '{"input": "test"}' --verbose

# 3. Check flow structure
wmill flow show f/workflows/pipeline
```

### Development Mode Testing

```bash
# Start dev mode
wmill dev

# Make changes to scripts/flows
# Changes are auto-synced to workspace
# Test in Windmill UI or via CLI
```

## Deployment Patterns

### Pattern 1: Single Environment

```bash
# Development workflow
wmill init
wmill workspace add  # Configure single workspace
wmill sync pull      # Get existing resources
# Make changes...
wmill sync push      # Deploy changes
```

### Pattern 2: Multi-Environment (Dev/Prod)

```bash
# Setup
wmill init

# Add dev workspace
wmill workspace add
# Name: dev
# URL: https://dev.windmill.dev
# Workspace: dev-workspace

# Add prod workspace
wmill workspace add
# Name: prod
# URL: https://app.windmill.dev
# Workspace: prod-workspace

# Use git branches with workspace binding
git checkout develop
wmill init --bind-profile  # Bind dev workspace to develop branch

git checkout main
wmill init --bind-profile  # Bind prod workspace to main branch

# Development workflow
git checkout develop
# Make changes...
wmill sync push  # Auto-pushes to dev workspace

# Promote to production
git checkout main
git merge develop
wmill sync push  # Auto-pushes to prod workspace
```

### Pattern 3: CI/CD Integration

```yaml
# .github/workflows/deploy.yml
name: Deploy to Windmill

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Deno
        uses: denoland/setup-deno@v1

      - name: Install Windmill CLI
        run: deno install -A https://deno.land/x/wmill/main.ts

      - name: Deploy to Windmill
        env:
          WMILL_TOKEN: ${{ secrets.WMILL_TOKEN }}
          WMILL_WORKSPACE: ${{ secrets.WMILL_WORKSPACE }}
          WMILL_BASE_URL: ${{ secrets.WMILL_BASE_URL }}
        run: |
          wmill sync push --token $WMILL_TOKEN \
                         --workspace $WMILL_WORKSPACE \
                         --base-url $WMILL_BASE_URL
```

## Debugging Strategies

### Script Debugging

```bash
# 1. Check script syntax (generate metadata will validate)
wmill script generate-metadata

# 2. Run with verbose output
wmill script run f/folder/script --data '{}' --verbose

# 3. Check logs in Windmill UI
# Navigate to: Runs > Select job > View logs

# 4. Add debug logging in script
```

```typescript
export async function main(param: string) {
  console.log("Debug: param =", param)
  // ... rest of code
  console.log("Debug: intermediate result =", result)
  return result
}
```

### Flow Debugging

```bash
# 1. Validate flow structure
wmill flow show f/workflows/pipeline

# 2. Run with verbose
wmill flow run f/workflows/pipeline --data '{}' --verbose

# 3. Check individual step results in UI
# Navigate to: Runs > Select job > View flow graph > Click step

# 4. Test steps individually
wmill script run f/workflows/pipeline.flow/inline_script_0
```

### Common Issues

**Issue: "Resource type not found"**
```bash
# List available types
wmill resource-type list --schema | grep -i <type>

# Check spelling and casing
# TypeScript: RT.Postgresql (capitalized)
# Python: postgresql (lowercase)
```

**Issue: "Script metadata generation failed"**
```bash
# Run from repository root
cd /path/to/windmill/repo
wmill script generate-metadata

# Check script syntax is valid
# Ensure language is supported
```

**Issue: "Flow locks not generating"**
```bash
# Ensure inline paths are correct
# content: '!inline path/to/script.ts'

# Check files exist
ls f/workflows/pipeline.flow/inline_script_0.ts

# Validate YAML syntax
```

## Best Practices

### Project Organization

```
windmill-project/
├── wmill.yaml                 # Project config
├── wmill-lock.yaml           # Lock file (auto-generated)
├── f/                        # Folder-based resources
│   ├── scripts/
│   │   ├── data/            # Data processing scripts
│   │   ├── integrations/    # API integrations
│   │   └── utils/           # Utility scripts
│   ├── workflows/
│   │   ├── etl.flow/        # ETL workflow
│   │   └── onboarding.flow/ # User onboarding
│   ├── apps/
│   │   └── dashboard/       # Admin dashboard
│   └── resources/
│       ├── databases/       # DB credentials
│       └── apis/            # API keys
└── u/                        # User-specific (optional)
```

### Code Reuse

1. **Shared scripts**: Place in `f/shared/` for reuse across flows
2. **Flow composition**: Use `type: flow` to call sub-workflows
3. **Script calls**: Use `wmill.runScript()` for script composition
4. **Resource centralization**: Store all resources in `f/resources/`

### Performance Optimization

1. **Parallel loops**: Use `parallel: true` for independent iterations
2. **Caching**: Use `cache_ttl` for expensive operations
3. **Batch processing**: Process items in chunks instead of one-by-one
4. **Worker tags**: Route heavy jobs to specific worker groups

### Security Best Practices

1. **Never hardcode credentials**: Always use resources
2. **Use secrets**: Mark sensitive variables as secret
3. **Least privilege**: Grant minimum necessary permissions
4. **Resource scoping**: Scope resources to specific folders/users
5. **Token rotation**: Regularly rotate API tokens

## Team Collaboration

### Branch-Based Development

```bash
# Feature development
git checkout -b feature/new-workflow
# Make changes...
wmill sync push  # Push to dev workspace (if bound to feature branches)

# Code review
# Create PR, review flow.yaml and scripts

# Merge to main
git checkout main
git merge feature/new-workflow
wmill sync push  # Deploy to production
```

### Code Review Checklist

- [ ] Scripts follow language conventions (see script_guidance.ts)
- [ ] Flow YAML is valid and follows OpenFlow spec
- [ ] Resources are parameterized, not hardcoded
- [ ] Error handling is implemented
- [ ] Input schemas are defined
- [ ] Metadata/locks are generated
- [ ] Tests pass locally
- [ ] Documentation is updated

### Conflict Resolution

```bash
# Pull latest from workspace
wmill sync pull

# Resolve conflicts in files
# Edit conflicting files

# Re-generate metadata/locks
wmill script generate-metadata
wmill flow generate-locks --yes

# Push resolved version
wmill sync push
```

## Advanced Patterns

### Dynamic Resource Selection

```typescript
export async function main(env: "dev" | "prod", query: string) {
  const resourcePath = env === "prod"
    ? "f/resources/prod_db"
    : "f/resources/dev_db"

  const db = await wmill.getResource(resourcePath)
  // Use db connection...
}
```

### Flow Suspension for Approval

```yaml
- id: approval_step
  value:
    type: rawscript
    content: '!inline approval.ts'
    language: bun
    suspend:
      required_events: 1
      timeout: 86400  # 24 hours
      resume_form:
        schema:
          type: object
          properties:
            approved:
              type: boolean
            comments:
              type: string
      user_groups_required:
        type: static
        value: ["approvers"]
    input_transforms: {}
```

### S3 File Operations

```typescript
import * as wmill from "windmill-client"

export async function main() {
  // Write file to S3
  const s3Object = await wmill.writeS3File(
    undefined,
    "file content",
    "f/resources/s3_bucket"
  )

  // Read file from S3
  const content = await wmill.loadS3File(
    s3Object,
    "f/resources/s3_bucket"
  )

  return { s3Object, content }
}
```
