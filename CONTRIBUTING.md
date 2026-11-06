# Contributing to agentack

Thanks for helping. agentack is a set of prompts, so most contributions are text, but they
change how agents behave, so please test them on a real project.

## Good first contributions

- English translations of the agent prompts and references
- Builders for more stacks (Python/FastAPI, Java/Spring, .NET, Vue, SvelteKit, ...)
- Better routing rules based on real-world usage
- Tooling alternatives in `references/contracts.md`

## How to work

1. Fork and clone, then install from your clone: `./install.sh`
2. Make your change in the repo (never in `~/.claude`), then reinstall.
3. Try it on a real task with `/agentack` and note what changed in behavior.
4. Open a PR describing:
   - what you changed and why
   - the task you tested with and the result (which agents ran, which models, outcome)

## Guidelines

- **Keep the skill generic.** Project-specific rules belong in a project's `CLAUDE.md`, not here.
- **Be concrete.** Prefer measurable rules ("touches more than 5 files") over vague ones ("complex tasks").
- **Respect the gates.** Changes that let builders start before the contract gate, or let an
  agent approve its own work, need a strong justification.
- **Least privilege.** Read-only agents (`reviewer`, `decider`, `contract-guard`) must not get `Edit`/`Write`.
- **Agent frontmatter** must keep `name`, `description`, `model` and `tools`.
- Update `CHANGELOG.md` under "Unreleased".

## Reporting issues

Include your Claude Code version, the models available on your account, the `/agentack`
prompt you used, and what the manager did versus what you expected.
