# Manually-installed binaries

Binaries installed outside of Homebrew/npm/cargo/gem/pip — track them here so a fresh machine can be rebuilt.

Generated: 2026-04-22

## `/usr/local/bin` (symlinks into .app bundles)

| Binary | Target | Source |
|---|---|---|
| `code` | `/Applications/Visual Studio Code.app/…/bin/code` | Cask `visual-studio-code` (auto) |
| `cursor` | `/Applications/Cursor.app/…/bin/code` | Cask `cursor` (auto) |
| `wolframscript` | `/Applications/WolframScript.app/…/wolframscript` | [Wolfram download](https://www.wolfram.com/wolframscript/) |
| `hubcli` | `/Applications/Workspace ONE Intelligent Hub.app/…/hubcli` | Corp MDM — managed install |
| `hubhealth` | `/Library/Application Support/AirWatch/hubhealth` | Corp MDM — managed install |

Most of `/usr/local/bin` on this machine is `python3*` / `pip*` from the python.org installer — see "Python" below.

## `~/.local/bin`

| Binary | Target | Source |
|---|---|---|
| `claude` | `~/.local/share/claude/versions/<ver>` | `curl -fsSL claude.ai/install.sh \| bash` |
| `it2` | `~/.local/share/uv/tools/it2/bin/it2` | `uv tool install it2` (iTerm2 integrations) |

## Python

Installed from the official python.org installer (not Homebrew). Everything in `/usr/local/bin/python3*` and `/usr/local/bin/pip3*` comes from `/Library/Frameworks/Python.framework/Versions/3.13/`.

- Download: https://www.python.org/downloads/macos/
- After install: `pip3 install -r manifests/pip-user.txt --user`

## curl-based installers

Keep this list up to date as you run new one-liners:

```sh
# Claude Code CLI
curl -fsSL https://claude.ai/install.sh | bash

# rustup (installs cargo) — only if not already via brew
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Oh My Zsh (if used)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
