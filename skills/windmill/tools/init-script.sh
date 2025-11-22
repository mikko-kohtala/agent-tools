#!/usr/bin/env bash
set -euo pipefail

# Windmill Script Scaffolding Tool
# Interactive wizard to create new Windmill scripts with proper conventions

echo "=== Windmill Script Scaffolding Wizard ==="
echo

# Check if we're in a Windmill project
if [[ ! -f "wmill.yaml" ]]; then
    echo "Error: Not in a Windmill project directory (wmill.yaml not found)"
    echo "Run 'wmill init' first or navigate to your Windmill project root"
    exit 1
fi

# Language selection
echo "Select language:"
echo "  1) TypeScript (Bun) - recommended for TypeScript"
echo "  2) TypeScript (Deno)"
echo "  3) Python"
echo "  4) Go"
echo "  5) Bash"
echo "  6) PostgreSQL"
echo "  7) PHP"
echo "  8) Rust"
echo "  9) PowerShell"
echo " 10) Other (manual entry)"
echo
read -p "Choice (1-10): " lang_choice

case "$lang_choice" in
    1)
        lang="bun"
        ext="ts"
        template="typescript_bun"
        ;;
    2)
        lang="deno"
        ext="ts"
        template="typescript_deno"
        ;;
    3)
        lang="python3"
        ext="py"
        template="python"
        ;;
    4)
        lang="go"
        ext="go"
        template="go"
        ;;
    5)
        lang="bash"
        ext="sh"
        template="bash"
        ;;
    6)
        lang="postgresql"
        ext="sql"
        template="postgresql"
        ;;
    7)
        lang="php"
        ext="php"
        template="php"
        ;;
    8)
        lang="rust"
        ext="rs"
        template="rust"
        ;;
    9)
        lang="powershell"
        ext="ps1"
        template="powershell"
        ;;
    10)
        read -p "Enter language (e.g., mysql, java, csharp): " lang
        read -p "Enter file extension (e.g., sql, java, cs): " ext
        template="custom"
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

# Folder path
echo
read -p "Enter folder path (e.g., f/scripts/utils or f/integrations/stripe): " folder_path

# Normalize folder path
folder_path="${folder_path%/}"  # Remove trailing slash if present

# Script name
echo
read -p "Enter script name (e.g., process_data or create_customer): " script_name

# Full path
script_path="${folder_path}/${script_name}.${ext}"

# Check if file already exists
if [[ -f "$script_path" ]]; then
    read -p "File $script_path already exists. Overwrite? (y/N): " overwrite
    if [[ "$overwrite" != "y" && "$overwrite" != "Y" ]]; then
        echo "Aborted"
        exit 0
    fi
fi

# Create directory
mkdir -p "$folder_path"

# Generate script based on template
case "$template" in
    typescript_bun)
        cat > "$script_path" <<'EOF'
import * as wmill from "windmill-client"

export async function main(
  param1: string,
  param2: number = 42
) {
  // Your code here
  console.log("Processing:", param1, param2)

  // Example: Get resource
  // const db = await wmill.getResource("f/resources/postgres")

  // Example: Get/set state
  // const state = await wmill.getState()
  // await wmill.setState({ ...state, updated: true })

  return {
    success: true,
    result: `Processed ${param1}`
  }
}
EOF
        ;;

    typescript_deno)
        cat > "$script_path" <<'EOF'
import * as wmill from "npm:windmill-client"

export async function main(
  param1: string,
  param2: number = 42
) {
  // Your code here
  console.log("Processing:", param1, param2)

  return {
    success: true,
    result: `Processed ${param1}`
  }
}
EOF
        ;;

    python)
        cat > "$script_path" <<'EOF'
import wmill

def main(
    param1: str,
    param2: int = 42
):
    """Your script description"""
    # Your code here
    print(f"Processing: {param1}, {param2}")

    # Example: Get resource
    # db = wmill.get_resource("f/resources/postgres")

    # Example: Get/set state
    # state = wmill.get_state()
    # wmill.set_state({**state, "updated": True})

    return {
        "success": True,
        "result": f"Processed {param1}"
    }
EOF
        ;;

    go)
        cat > "$script_path" <<'EOF'
package inner

type Result struct {
    Success bool   `json:"success"`
    Result  string `json:"result"`
}

func main(param1 string, param2 int) (Result, error) {
    // Your code here

    return Result{
        Success: true,
        Result:  "Processed " + param1,
    }, nil
}
EOF
        ;;

    bash)
        cat > "$script_path" <<'EOF'
# Arguments: $1, $2, etc.
param1="$1"
param2="${2:-42}"

# Your code here
echo "Processing: $param1, $param2"

# Return JSON
echo '{"success": true, "result": "Processed '"$param1"'"}'
EOF
        ;;

    postgresql)
        cat > "$script_path" <<'EOF'
-- $1 param1 (text)
-- $2 param2 (integer) = 42

SELECT
    true as success,
    'Processed ' || $1::text as result;
EOF
        ;;

    php)
        cat > "$script_path" <<'EOF'
<?php

function main(
    string $param1,
    int $param2 = 42
) {
    // Your code here
    error_log("Processing: $param1, $param2");

    return [
        'success' => true,
        'result' => "Processed $param1"
    ];
}
EOF
        ;;

    rust)
        cat > "$script_path" <<'EOF'
//! ```cargo
//! [dependencies]
//! anyhow = "1.0.86"
//! serde = { version = "1.0", features = ["derive"] }
//! ```

use anyhow::anyhow;
use serde::Serialize;

#[derive(Serialize, Debug)]
struct Result {
    success: bool,
    result: String,
}

fn main(param1: String, param2: Option<i32>) -> anyhow::Result<Result> {
    let param2 = param2.unwrap_or(42);

    // Your code here

    Ok(Result {
        success: true,
        result: format!("Processed {}", param1),
    })
}
EOF
        ;;

    powershell)
        cat > "$script_path" <<'EOF'
param($param1, $param2 = 42)

# Your code here
Write-Host "Processing: $param1, $param2"

# Return object
@{
    success = $true
    result = "Processed $param1"
} | ConvertTo-Json
EOF
        ;;

    custom)
        cat > "$script_path" <<EOF
# Custom script template for $lang
# See cli/src/guidance/script_guidance.ts for language-specific conventions

def main():
    # Your code here
    pass
EOF
        ;;
esac

echo
echo "✓ Created script: $script_path"
echo

# Ask if user wants to generate metadata
read -p "Generate metadata (.lock and .yaml)? (Y/n): " generate
if [[ "$generate" != "n" && "$generate" != "N" ]]; then
    echo
    echo "Running: wmill script generate-metadata"
    if wmill script generate-metadata; then
        echo "✓ Metadata generated successfully"
    else
        echo "⚠ Metadata generation failed - check script syntax"
        exit 1
    fi
fi

echo
echo "=== Next Steps ==="
echo "1. Edit the script: $script_path"
echo "2. Test: wmill script run ${folder_path}/${script_name}"
echo "3. Deploy: wmill sync push"
echo

# Ask if user wants to open the file
if command -v code &> /dev/null; then
    read -p "Open in VS Code? (y/N): " open_code
    if [[ "$open_code" == "y" || "$open_code" == "Y" ]]; then
        code "$script_path"
    fi
fi
