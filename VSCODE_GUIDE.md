# gitlens-tui for VS Code Users

This guide is for users who do not use Vim and want a GitLens-style workflow in VS Code with `tig` in the integrated terminal.

## 1) Install Once

From a terminal:

```bash
cd /home/prince/tools/gitlens-tui
./install.sh
```

This installs `tig` (if missing) and writes managed settings to `~/.tigrc`.

## 2) Use from VS Code

1. Open your repository folder in VS Code.
2. Open integrated terminal: `Ctrl+\``.
3. Start `tig`:

```bash
tig
```

## 3) Core Navigation in `tig`

```text
q          quit current view
<C-r>      refresh
J / K      move down/up in main view
Enter      open selected item (commit/file/ref)
,          parent traversal (history ancestry)
/          search
n / N      next/previous search match
```

## 4) GitLens Feature Mapping

```text
Commit graph/history           -> tig (main view), key: l
File history                   -> tig -- <path-to-file>
Line blame                     -> tig blame -- <path-to-file>
Branches/tags/remotes          -> key: r (refs view) or tig refs
Stash list                     -> key: y or tig stash
Reflog timeline                -> key: f or tig reflog
Repo text search               -> key: g or tig grep -- <pattern>
Stage/unstage + revert         -> key: s (status), then u / U
Amend last commit              -> key: A (with confirmation)
Checkout selected ref          -> refs view, key: C (with confirmation)
Rebase onto selected ref       -> refs view, key: R (with confirmation)
```

## 5) Typical VS Code Terminal Flows

### History for current file

1. In Explorer, right-click file and use "Copy Relative Path".
2. In terminal:

```bash
tig -- <relative-path>
```

### Blame for current file

```bash
tig blame -- <relative-path>
```

### Status + stage/revert

```bash
tig status
```

Then use `u` (stage/unstage) and `U` (revert) on selected items.

## 6) Optional VS Code Task Snippets

Optional `tasks.json` entries (workspace-local) for quick launch:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "tig: main",
      "type": "shell",
      "command": "tig",
      "options": { "cwd": "${workspaceFolder}" },
      "problemMatcher": []
    },
    {
      "label": "tig: status",
      "type": "shell",
      "command": "tig status",
      "options": { "cwd": "${workspaceFolder}" },
      "problemMatcher": []
    },
    {
      "label": "tig: refs",
      "type": "shell",
      "command": "tig refs",
      "options": { "cwd": "${workspaceFolder}" },
      "problemMatcher": []
    },
    {
      "label": "tig: reflog",
      "type": "shell",
      "command": "tig reflog",
      "options": { "cwd": "${workspaceFolder}" },
      "problemMatcher": []
    }
  ]
}
```

## 7) Quick Checks

```bash
command -v tig
tig --version
grep -E 'set blame-options = -C -C -C|set ignore-case = smart-case|bind generic f view-reflog|bind generic g view-grep' ~/.tigrc
```

## 8) Known Differences vs GitLens

- No inline in-editor blame decorations.
- No PR timeline/comments/issues panel.
- No hosted provider metadata overlays.

All workflows are terminal-driven through `tig`.
