# Python Scripts

Python 3 runtime with automatic dependency management.

## Conventions

- Script contains at least one function called `main`
- Libraries are installed automatically
- Do not call the main function

## Resource Types

Credentials are passed as parameters to `main` using TypedDict definitions.

**Important:**
- **Redefine** resource types as TypedDict before main function
- Resource type name must be **lowercase** (e.g., `stripe`, `postgresql`)
- If an import conflicts with a resource type name, **rename the import, not the type**
- Import `TypedDict` from `typing` if using it

```python
from typing import TypedDict

class stripe(TypedDict):
    api_key: str

def main(stripe_creds: stripe):
    # Use credentials
    pass
```

## Windmill Client

```python
import wmill

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

## Example

```python
from typing import TypedDict
import wmill

class postgresql(TypedDict):
    host: str
    port: int
    user: str
    password: str
    dbname: str

def main(db: postgresql, query: str):
    import psycopg2

    conn = psycopg2.connect(
        host=db["host"],
        port=db["port"],
        user=db["user"],
        password=db["password"],
        dbname=db["dbname"]
    )

    with conn.cursor() as cur:
        cur.execute(query)
        results = cur.fetchall()

    conn.close()
    return {"rows": results}
```
