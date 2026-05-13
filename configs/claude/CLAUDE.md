## Rules

- Always read documentation and search for reported bugs before going through source code
- If available, always use the Context7 MCP when you need documentation
- Avoid writing superfluous comments that state what is obvious from reading code
- Always confirm implementation plans with the user before writing any code or requesting changes. When the user responds to multiple items, read each response individually — questions or pushback on an item are not approval.

## Context efficient commands

When you only need to know whether a bash command succeeds (eg: tests, linting, scripts with side effects, etc), wrap it with an output suppression pattern to preserve context window and only show full output on failure:

```bash
output=$(<command> 2>&1) && echo "✓ <description>" || { echo "✗ <description>"; echo "$output"; false; }
```

## Tool Preferences

The following non-standard CLI tools are available for you to use:

- Use `rg` instead of `grep` (example: `rg "pattern"` instead of `grep -r "pattern"`)
- Use `fd` instead of `find` (example: `fd "filename"` instead of `find . -name "filename"`)
- Use `gh` for interacting with Github

## Commit preferences

Follow a lightweight Conventional Commit pattern for commit messages: `<type>: <brief description>`.  Add a body (after a blank line) ONLY if there is non-obvious context worth recording.