# XTAP for Muse

Use this skill when the person needs an **enterprise tool** through XTAP (Jira, Salesforce, Notion, etc.).

## When not to call xtap (SC-005)

**Never call `xtap` when no enterprise tool is needed.** If the request can be answered without an enterprise system, do not run any `xtap` command. That keeps ACT and MCP gateway traffic at zero.

## Safe sequence

1. Write the person's prompt to a file **exactly as typed** (raw UTF-8; no trim, paraphrase, or newline changes).
2. `xtap task start --prompt-file <path>` — reuse the returned task id when the prompt matches a live task.
3. Use **exact** tool names from `xtap tool list`. The `--args-file` is a JSON object matching that tool's input schema; **never guess** names or fields.
4. `xtap tool call --task <id> --tool <name> --args-file <json>` (never omit `--task`).
5. `xtap task complete --task <id>` when finished (or `task cancel` if aborting).

Do **not** call the MCP server any other way. Do **not** put tokens in commands, environment variables, files, or chat.

## Tools list

When the person asks to refresh XTAP tools, says they connected or disconnected an enterprise tool, or a tool call fails because the gateway does not know the tool:

1. `xtap tool sync`
2. `xtap tool list`
3. Report the available tools and schemas.

## When a command fails: act on `next_action`

Every failed command prints one JSON object on stdout with `ok: false`. Read `error.next_action` and do exactly what it says. Do not branch on the wording of `error.message` or `error.hint`; they are for the person.

- `retry` — run the same command once more (wait `error.retry_after_seconds` first when it is present). If it fails again, tell the person and stop.
- `fix_input` — correct the flag, file, or tool name the hint points at, then run the command again once. Use an exact name from `xtap tool list`; never guess.
- `sync_tools` — run `xtap tool sync`, then `xtap tool list`, then retry the call once with an exact listed tool name.
- `new_task` — the task ended or does not belong to this caller: start a new task with the current prompt (`xtap task start`). Never reuse a task id across different person requests.
- `tell_person` — tell the person what happened (use `error.message`) and stop. Do not retry and do not reword the prompt or arguments to get around a policy denial.
- `connect_app` — tell the person to connect that app in XTAP Connected apps (the hint names the app), then stop. Do not retry until they say it is connected.
- `reconnect_xtap` — tell the person to press Connect on the XTAP connector in Muse again, then stop. Run `xtap setup` again only after they confirm.
- `ask_then_recover` — tell the person what happened and stop. Run `xtap recover` only if they agree, because recover disconnects the agent on the other device. On setup `key_retired` the same applies.
- `run_doctor` — run `xtap doctor` and report its output. This is the only case in which to run doctor; use it only for `run_doctor`, never as a default.
- `report` — give the person `error.message` and the correlation id (`error.correlation_id`, if present) and stop. Do not retry and do not run doctor.

## Consent and policy

- **`consent_required`** (from task start): tell the person to approve the request in ACT (it shows `XTAP task` plus the first 8 chars of the task id), then **stop**. Do not retry or poll. Its `next_action` is `tell_person`.
- **Policy denial** (`tell_person`, `reason` set): tell the person what was denied; do not retry with reworded prompts or arguments.

## Setup, recover, and state

- Do not run `xtap setup` or `xtap recover` unless the person asks, or `next_action` says to and the person agrees.
- Prefer `xtap status` for local inspection; it does not invent credentials.
- **Never edit or delete `~/.xtap`.**

## Offline commands

`xtap version`, `xtap status`, `xtap task list`, `xtap tool list`, and `xtap skill show` make no network calls. Use them freely for inspection.
