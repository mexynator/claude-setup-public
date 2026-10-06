# claude-setup

Mein Claude-Code-Setup: globale Anweisungen, Einstellungen, Hooks, Skills, Agents, Commands und Plugin-Liste. Zum Nachbauen oder als Vorlage für das eigene Setup.

## Installieren

```bash
git clone https://github.com/<user>/claude-setup.git ~/claude-setup
cd ~/claude-setup && ./install.sh
```

`install.sh` sichert vorher den bestehenden Stand nach `~/.claude/backups/setup-<datum>/`. Es ist für macOS geschrieben (Homebrew, `osascript`-Benachrichtigungen).

`claude/CLAUDE.md` vor dem Installieren an dich anpassen: Sprache, Stack, Arbeitsweise.

## Inhalt

| Pfad | Was |
|---|---|
| `claude/CLAUDE.md` | Globale Anweisungen (Deutsch, Stack, Arbeitsweise, Datenschutz) |
| `claude/settings.json` | Rechte (deny für Passwörter, `.env`, Kundenexporte, Zeiterfassung), Hooks, Statuszeile |
| `claude/hooks/secret-scanner.py` | Blockiert `git commit`, wenn Secrets in den Dateien stehen |
| `claude/scripts/context-monitor.py` | Statuszeile mit Kontext, Kosten, Git-Status |
| `claude/skills/` | Skills, u. a. der eigene `video-verstehen` (Reels/Videos transkribieren + Standbilder) |
| `claude/agents/`, `claude/commands/` | Subagents und Slash-Commands |
| `plugins.txt` | Marketplaces und Plugins, die `install.sh` installiert |
| `mcp.example.json` | MCP-Server-Vorlage **ohne Tokens** |

## Plugins

ponytail, paper-desktop, context7, typescript-lsp, security-guidance, superpowers, claude-code-setup, claude-md-management, static-analysis (Trail of Bits).

Zusätzlich empfohlen, aber wegen fehlender Lizenz nicht mitgeliefert: [`web-design-guidelines`](https://github.com/vercel-labs/agent-skills) von Vercel.

## Herkunft und Lizenzen

Eigene Teile (`CLAUDE.md`, `settings.json`, `install.sh`, `video-verstehen`): MIT, siehe `LICENSE`. Alles andere stammt aus diesen Quellen und steht unter deren Lizenz:

| Teil | Quelle | Lizenz |
|---|---|---|
| `canvas-design`, `frontend-design`, `webapp-testing` | [anthropics/skills](https://github.com/anthropics/skills) | Apache 2.0 (`LICENSE.txt` im Skill-Ordner) |
| `react-best-practices` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | MIT (laut Skill) |
| `copywriting`, `content-strategy`, `marketing-psychology`, `social` | [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) | MIT, `licenses/marketingskills-MIT.txt` |
| `grill-me`, `grilling`, `setup-matt-pocock-skills`, `to-spec`, `to-tickets` | [mattpocock/skills](https://github.com/mattpocock/skills) | MIT, `licenses/mattpocock-skills-MIT.txt` |
| `graphify` | [safishamsi/graphify](https://github.com/safishamsi/graphify) | Apache 2.0, `licenses/graphify-*.txt` |
| `ui-ux-pro-max` | [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | MIT, `licenses/ui-ux-pro-max-MIT.txt` |
| `mobile-design` | [vudovn/antigravity-kit](https://github.com/vudovn/antigravity-kit) | MIT, `licenses/antigravity-kit-MIT.txt` |
| `agents/`, `commands/`, `hooks/secret-scanner.py`, `scripts/context-monitor.py` | [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates) | MIT, `licenses/claude-code-templates-MIT.txt` |

## Regeln für dieses Repo

- Keine Tokens, keine `.claude.json`, keine Session-Daten committen. Der Secret-Scanner-Hook prüft jeden Commit.
- Neue Skills/Plugins vor dem Aufnehmen prüfen: echtes Repo (Owner, Sterne, Lizenz), Hooks und MCP-Server ansehen, `skillspector scan <dir> --no-llm`.
