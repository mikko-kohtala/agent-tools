# Bun TypeScript Scripts

TypeScript runtime using Bun - fastest execution, full npm ecosystem.

## Conventions

- Export a single **async** function called `main`
- Libraries are installed automatically
- Full npm ecosystem available
- Do not call the main function

## Resource Types

Credentials and configuration are stored in resources and passed as parameters to `main`.
Use the `RT` namespace for resource types: `RT.Stripe`, `RT.Postgresql`, etc.

```typescript
import * as wmill from "windmill-client";

export async function main(stripe: RT.Stripe) {
  // Use stripe credentials
}
```

## Windmill Client

```typescript
import * as wmill from "windmill-client";

// Resource operations
wmill.getResource(path?: string, undefinedIfEmpty?: boolean): Promise<any>
wmill.setResource(value: any, path?: string, initializeToTypeIfNotExist?: string): Promise<void>

// State management (persistent across executions)
wmill.getState(): Promise<any>
wmill.setState(state: any): Promise<void>

// Variables
wmill.getVariable(path: string): Promise<string>
wmill.setVariable(path: string, value: string, isSecretIfNotExist?: boolean, descriptionIfNotExist?: string): Promise<void>

// Script execution
wmill.runScript(path?: string | null, hash_?: string | null, args?: Record<string, any> | null, verbose?: boolean): Promise<any>
wmill.runScriptAsync(path: string | null, hash_: string | null, args: Record<string, any> | null, scheduledInSeconds?: number | null): Promise<string>
wmill.waitJob(jobId: string, verbose?: boolean): Promise<any>
wmill.getResult(jobId: string): Promise<any>
wmill.getRootJobId(jobId?: string): Promise<string>

// S3 file operations (if S3 is configured)
wmill.loadS3File(s3object: S3Object, s3ResourcePath?: string | undefined): Promise<Uint8Array | undefined>
wmill.writeS3File(s3object: S3Object | undefined, fileContent: string | Blob, s3ResourcePath?: string | undefined): Promise<S3Object>

// Flow operations
wmill.setFlowUserState(key: string, value: any, errorIfNotPossible?: boolean): Promise<void>
wmill.getFlowUserState(key: string, errorIfNotPossible?: boolean): Promise<any>
wmill.getResumeUrls(approver?: string): Promise<{approvalPage: string, resume: string, cancel: string}>
```

## Example

```typescript
import * as wmill from "windmill-client";

export async function main(name: string, count: number = 1) {
  const state = await wmill.getState() || { runs: 0 };
  state.runs += 1;
  await wmill.setState(state);

  return {
    message: `Hello ${name}!`,
    count,
    totalRuns: state.runs
  };
}
```
