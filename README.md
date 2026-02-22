# gitlens-tui

Lightweight installer for a terminal-first Git workflow with `tig` and Vim commands.

## What It Configures

- Installs `tig` if missing (`apt-get`, `dnf`, or `pacman`).
- Appends managed blocks (marker: `>>> gitlens-tui >>>`) to:
`~/.tigrc` and `~/.vimrc`.
- Adds `tig` keybindings in `~/.tigrc`:
`q`, `<C-r>`, `J`, `K`, `s`, `l`, `r`, `y`, `f`, `b`, `g`, `p`, `n`, `N`,
`u`, `U`, `A`, `C`, `R`.
- Provides Vim commands and mappings:
`:TigFile`, `:TigBlame`, `:TigStatus`, `:TigRefs`, `:TigReflog`, `:TigLog`,
`:TigGrep`, plus `<leader>g{h,b,s,r,R,l,g}`.
- During install, removes only legacy aliases from older `gitlens-tui` releases when the current alias value still matches the legacy toolkit value.

## Install

```bash
cd /home/prince/tools/gitlens-tui
./install.sh
```

## Guides

- VS Code users (non-Vim): `tools/gitlens-tui/VSCODE_GUIDE.md`
- Vim users: `tools/gitlens-tui/cheatsheet.md`

## GitLens Coverage

- Covered now:
`file history`, `line blame`, `status/stage/revert`, `refs/tags/branches`,
`stash view`, `reflog`, `repo grep`, `parent traversal`, `search next/prev`,
`amend`, `checkout/rebase selected ref`.
- Not included (intentional):
PR discussions, IDE inline decorations, hosted provider issue/PR metadata.

## Verify

```bash
command -v tig
grep -F '>>> gitlens-tui >>>' ~/.tigrc ~/.vimrc
grep -E 'set blame-options = -C -C -C|set ignore-case = smart-case|bind generic f view-reflog|bind generic g view-grep|bind generic p parent|bind generic n find-next|bind generic N find-prev' ~/.tigrc
vim -Nu ~/.vimrc -n -es +'call writefile([string(exists(":TigFile"))." ".string(exists(":TigBlame"))." ".string(exists(":TigStatus"))." ".string(exists(":TigRefs"))." ".string(exists(":TigReflog"))." ".string(exists(":TigLog"))." ".string(exists(":TigGrep"))], "/tmp/gitlens_tui_cmds.txt")' +qa && cat /tmp/gitlens_tui_cmds.txt
vim -Nu ~/.vimrc -n -es +'call writefile([string(!empty(maparg("<leader>gh","n")))." ".string(!empty(maparg("<leader>gb","n")))." ".string(!empty(maparg("<leader>gs","n")))." ".string(!empty(maparg("<leader>gr","n")))." ".string(!empty(maparg("<leader>gR","n")))." ".string(!empty(maparg("<leader>gl","n")))." ".string(!empty(maparg("<leader>gg","n")))], "/tmp/gitlens_tui_maps.txt")' +qa && cat /tmp/gitlens_tui_maps.txt
```

Expected Vim check output:
- commands: `2 2 2 2 2 2 2`
- mappings: `1 1 1 1 1 1 1`

## Rollback

1. Remove the managed marker blocks from `~/.tigrc` and `~/.vimrc`.

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

2. Optional: remove `tig` package.

```bash
# Debian/Ubuntu
sudo apt-get remove -y tig
# Fedora/RHEL
sudo dnf remove -y tig
# Arch
sudo pacman -R --noconfirm tig
```
