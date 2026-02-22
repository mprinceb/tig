# gitlens-tui Cheatsheet

## Shell

```bash
tig                      # interactive commit browser
tig status               # status view (stage/revert from here)
tig reflog               # reflog timeline
tig refs                 # branches/tags/remotes
tig grep -- <pattern>    # repo-wide grep view
tig show HEAD            # last commit with patch/stat
tig -- <path>            # history for a file/path
tig blame -- <path>      # blame for a file
tig <ref>                # open a branch/tag/revision
```

## Legacy Alias Equivalents

```text
git st        -> tig status
git lg/lga    -> tig, then press l
git last      -> tig show HEAD
git amend     -> press A in tig (confirm)
git unstage   -> press u in tig status view
git br        -> tig refs (or press r)
git co        -> refs view: select ref, press C
git rb        -> refs view: select ref, press R
```

## Tig Keybindings

```text
q                        # quit current view
<C-r>                    # refresh
J / K                    # move down/up in main view
s / l / r / y            # jump to status / main log / refs / stash views
f / b / g                # jump to reflog / blame / grep views
p                        # move to parent (commit/file ancestry navigation)
n / N                    # find next/prev in current search
u / U                    # stage update / revert in status view
A                        # run git commit --amend --no-edit (confirm)
C / R (refs view)        # checkout / rebase onto selected ref (confirm)
```

## Vim

```vim
:TigFile                 " tig history for current file
:TigBlame                " tig blame for current file
:TigStatus               " open tig status
:TigRefs                 " open tig refs view
:TigReflog               " open tig reflog view
:TigLog                  " open main tig log view
:TigGrep [pattern]       " open tig grep, optional pattern
<leader>gh               " mapped to :TigFile
<leader>gb               " mapped to :TigBlame
<leader>gs               " mapped to :TigStatus
<leader>gr               " mapped to :TigRefs
<leader>gR               " mapped to :TigReflog
<leader>gl               " mapped to :TigLog
<leader>gg               " mapped to :TigGrep
```

## Quick Verify

```bash
command -v tig
grep -F '>>> gitlens-tui >>>' ~/.tigrc ~/.vimrc
grep -E 'set blame-options = -C -C -C|set ignore-case = smart-case|bind generic f view-reflog|bind generic g view-grep|bind generic p parent|bind generic n find-next|bind generic N find-prev' ~/.tigrc
vim -Nu ~/.vimrc -n -es +'call writefile([string(exists(":TigFile"))." ".string(exists(":TigBlame"))." ".string(exists(":TigStatus"))." ".string(exists(":TigRefs"))." ".string(exists(":TigReflog"))." ".string(exists(":TigLog"))." ".string(exists(":TigGrep"))], "/tmp/gitlens_tui_cmds.txt")' +qa && cat /tmp/gitlens_tui_cmds.txt
vim -Nu ~/.vimrc -n -es +'call writefile([string(!empty(maparg("<leader>gh","n")))." ".string(!empty(maparg("<leader>gb","n")))." ".string(!empty(maparg("<leader>gs","n")))." ".string(!empty(maparg("<leader>gr","n")))." ".string(!empty(maparg("<leader>gR","n")))." ".string(!empty(maparg("<leader>gl","n")))." ".string(!empty(maparg("<leader>gg","n")))], "/tmp/gitlens_tui_maps.txt")' +qa && cat /tmp/gitlens_tui_maps.txt
```

## Legacy Alias Note

The installer removes only legacy aliases created by older `gitlens-tui` versions, and only when the current alias value matches the legacy managed value.

## Quick Rollback

```bash
for f in ~/.tigrc ~/.vimrc; do
  [ -f "$f" ] || continue
  awk '
    />>> gitlens-tui >>>/ {skip=1; next}
    /<<< gitlens-tui <<</ {skip=0; next}
    !skip {print}
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done
```
