# Windmill Script Writing Guide

Complete reference for writing scripts in Windmill. This guidance covers all supported languages and platform conventions.

## General Principles

On Windmill, scripts are executed in isolated environments with specific conventions:

- Scripts must export a main function
- Do not call the main function
- Libraries are installed automatically - do not show installation instructions
- Credentials and configuration are stored in resources and passed as parameters
- The windmill client (wmill) provides APIs for interacting with the platform
- You can use `wmill resource-type list --schema` to list all resource types available. You should use that to know the type of the resource you need to use in your script. You can use grep if the output is too long.

## Workflow

1. Each script should be placed in a folder. Ask the user in which folder he wants the script to be located at before starting coding.
2. After writing a script, you do not need to create .lock and .yaml files manually. Instead, you can run `wmill script generate-metadata` bash command. This command takes no arguments.
3. After writing the script, you can ask the user if he wants to push the script with `wmill sync push`. Both should be run at the root of the repository.

## Language-Specific Instructions

### TypeScript Variants

#### Bun Runtime (`bun`)

- Export a single **async** function called `main`
- Libraries are installed automatically
- Full npm ecosystem available

#### Deno Runtime (`deno`)

- Export a single **async** function called `main`
- Import npm libraries: `import ... from "npm:{package}";`
- Import deno libraries normally
- Libraries are installed automatically

#### Native TypeScript / REST (`nativets`, `bunnative`)

- Add a leading `//native` comment when required
- Same conventions as bun; npm packages are supported
- REST scripts are TypeScript/JavaScript that typically only use `fetch` and platform APIs
- Use for lightweight scripts that don't need full runtime overhead

```typescript
//native
export async function main(url: string) {
  const response = await fetch(url);
  return await response.json();
}
```

#### TypeScript Resource Types & Windmill Client

**Resource Types:**
On Windmill, credentials and configuration are stored in resources and passed as parameters to main.
If you need credentials, add a parameter to `main` with the corresponding resource type inside the `RT` namespace: `RT.Stripe`.
Only use them if needed to satisfy instructions. Always use the RT namespace.

**Windmill Client (`import * as wmill from "windmill-client"`):**

```typescript
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

### Python (`python3`)

- Script contains at least one function called `main`
- Libraries are installed automatically
- Do not call the main function

**Resource Types:**
If you need credentials, add a parameter to `main` with the corresponding resource type.
**Redefine** the type of needed resources before the main function as TypedDict (only include if actually needed).
Resource type name must be **IN LOWERCASE**.
If an import conflicts with a resource type name, **rename the imported object, not the type name**.
Import TypedDict from typing **if using it**.

**Windmill Client (`import wmill`):**

```python
# Resource operations
wmill.get_resource(path: str, none_if_undefined: bool = False) -> dict | None
wmill.set_resource(path: str, value: Any, resource_type: str = "any") -> None

# State management
wmill.get_state() -> Any
wmill.set_state(value: Any) -> None
wmill.get_flow_user_state(key: str) -> Any
wmill.set_flow_user_state(key: str, value: Any) -> None

# Variables
wmill.get_variable(path: str) -> str
wmill.set_variable(path: str, value: str, is_secret: bool = False) -> None

# Script execution
wmill.run_script(path: str = None, hash_: str = None, args: dict = None, timeout = None, verbose: bool = False) -> Any
wmill.run_script_async(path: str = None, hash_: str = None, args: dict = None, scheduled_in_secs: int = None) -> str
wmill.wait_job(job_id: str, timeout = None, verbose: bool = False) -> Any
wmill.get_result(job_id: str) -> Any

# S3 operations
wmill.load_s3_file(s3object: S3Object | str, s3_resource_path: str | None = None) -> bytes
wmill.write_s3_file(s3object: S3Object | str | None, file_content: BufferedReader | bytes, s3_resource_path: str | None = None) -> S3Object

# Utilities
wmill.get_workspace() -> str
wmill.whoami() -> dict
wmill.set_progress(value: int, job_id: Optional[str] = None) -> None
```

### PHP (`php`)

- Script must start with `<?php`
- Contains at least one function called `main`
- **Redefine** resource types before main function (only if needed)
- Check if class exists using `class_exists` before defining types
- Resource type name must be exactly as specified

**Resource Types:**
If you need credentials, add a parameter to `main` with the corresponding resource type.
**Redefine** the type of needed resources before the main function.
Before defining each type, check if the class already exists using class_exists.
The resource type name has to be exactly as specified.

**Library Dependencies:**

```php
// require:
// mylibrary/mylibrary
// myotherlibrary/myotherlibrary@optionalversion
```

One per line before main function. Autoload already included.

### Rust (`rust`)

```rust
use anyhow::anyhow;
use serde::Serialize;

#[derive(Serialize, Debug)]
struct ReturnType {
    // ...
}

fn main(...) -> anyhow::Result<ReturnType>
```

**Dependencies:**

````rust
//! ```cargo
//! [dependencies]
//! anyhow = "1.0.86"
//! ```
````

Serde already included. For async functions, keep main sync and create runtime inside.

### Go (`go`)

- File package must be "inner"
- Export single function called `main`
- Return type: `({return_type}, error)`

### Bash (`bash`)

- Do not include "#!/bin/bash"
- Arguments: `var1="$1"`, `var2="$2"`, etc.

### SQL Variants

#### PostgreSQL (`postgresql`)

- Arguments: `$1::{type}`, `$2::{type}`, etc.
- Name parameters: `-- $1 name1` or `-- $2 name = default`

#### MySQL (`mysql`)

- Arguments: `?` placeholders
- Name parameters: `-- ? name1 ({type})` or `-- ? name2 ({type}) = default`

#### BigQuery (`bigquery`)

- Arguments: `@name1`, `@name2`, etc.
- Name parameters: `-- @name1 ({type})` or `-- @name2 ({type}) = default`

#### Snowflake (`snowflake`)

- Arguments: `?` placeholders
- Name parameters: `-- ? name1 ({type})` or `-- ? name2 ({type}) = default`

#### Microsoft SQL Server (`mssql`)

- Arguments: `@P1`, `@P2`, etc.
- Name parameters: `-- @P1 name1 ({type})` or `-- @P2 name2 ({type}) = default`

### GraphQL (`graphql`)

- Add needed arguments as query parameters

### PowerShell (`powershell`)

- Arguments via param function on first line:

```powershell
param($ParamName1, $ParamName2 = "default value", [{type}]$ParamName3, ...)
```

### C# (`csharp`)

- Public static Main method inside a class
- NuGet packages: `#r "nuget: PackageName, Version"` at top
- Method signature: `public static ReturnType Main(parameter types...)`

### Java (`java`)

- Main public class with `public static main()` method
- Dependencies: `//requirements://groupId:artifactId:version` at top
- Method signature: `public static Object main(parameter types...)`

### Ruby (`ruby`)

- Script contains at least one function called `main`
- Libraries are installed automatically
- Do not call the main function

```ruby
def main(param1, param2)
  # Your code here
  return { result: "value" }
end
```

**Resource Types:**
If you need credentials, add a parameter to `main` with the corresponding resource type (lowercase).

### Docker (`docker`)

- Containerized script execution
- Uses a Dockerfile or container image
- Script runs inside the specified container
- Follow language conventions for the script inside the container

### REST API (`rest`)

- HTTP REST API calls
- Configure HTTP method, URL, headers, body
- Authentication via resources

### Ansible (`ansible`)

- Ansible playbook YAML format
- Define tasks, hosts, and variables
- Use resources for SSH credentials and inventory

```yaml
---
- name: Example playbook
  hosts: all
  tasks:
    - name: Execute task
      shell: echo "Hello"
```

### Nu Shell (`nushell`)

- Nu shell scripting language
- Structured data pipeline approach
- Arguments via parameters

```nu
def main [param1: string, param2: int] {
  # Your code here
  $param1 | str length
}
```

## Supported Languages

`bunnative`, `nativets`, `bun`, `deno`, `python3`, `php`, `rust`, `go`, `bash`, `postgresql`, `mysql`, `bigquery`, `snowflake`, `mssql`, `graphql`, `powershell`, `csharp`, `java`, `ruby`, `docker`, `rest`, `ansible`, `nushell`

**TypeScript Variants:** `bun` (fastest), `deno`, `nativets` (Node.js-based), `bunnative`

Always follow the specific conventions for the language being used and include only necessary dependencies and resource types.
