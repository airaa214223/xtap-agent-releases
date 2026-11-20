# LunarFence for Muse

Use this skill when the person needs an **enterprise tool** through LunarFence (Notion, Gmail, Slack, etc.), or asks which apps LunarFence supports or to connect one.

## When not to call xtap (SC-005)

**Never call `xtap` when no enterprise tool is needed.** If the request can be answered without an enterprise system, do not run any `xtap` command. That keeps LunarFence traffic at zero. Questions about LunarFence apps (which are supported, which are connected, connecting one) do need it.

## After setup, and LunarFence apps

- **After `xtap setup` succeeds**: give the person the `data.brief` from its output in your own words, in a few lines, then stop. Don't list tools.
- **"Which apps does LunarFence support?"** (or similar): call `lunarfence_list_available_apps` through `xtap tool call`, following the safe sequence below (start a task with the person's prompt first). If they ask what is already connected, call `lunarfence_list_connected_apps` the same way.
- **"Connect <app>"**: call `lunarfence_request_app_connection` the same way and give the person the link it returns. If it is refused with `requests_not_allowed`, follow the LunarFence requests rule under Consent and policy. After they say the app is connected, run `xtap tool sync` then `xtap tool list`.

## Safe sequence

1. Write the person's prompt to a file **exactly as typed** (raw UTF-8; no trim, paraphrase, or newline changes).
2. `xtap task start --prompt-file <path>` — reuse the returned task id when the prompt matches a live task.
3. Use **exact** tool names from `xtap tool list`. The `--args-file` is a JSON object matching that tool's input schema; **never guess** names or fields.
4. `xtap tool call --task <id> --tool <name> --args-file <json>` (never omit `--task`).
5. `xtap task complete --task <id>` when finished (or `task cancel` if aborting).

Do **not** call the MCP server any other way. Do **not** put tokens in commands, environment variables, files, or chat.

## Tools list

When the person asks to refresh LunarFence tools, says they connected or disconnected an enterprise tool, or a tool call fails because the gateway does not know the tool:

1. `xtap tool sync`
2. `xtap tool list`
3. Report the available tools and schemas.

After the person connects an app (or approves a LunarFence request to connect one or grant access), run `xtap tool sync` then `xtap tool list` before calling that app's tools.

## When a command fails: act on `next_action`

Every failed command prints one JSON object on stdout with `ok: false`. Read `error.next_action` and do exactly what it says. Do not branch on the wording of `error.message` or `error.hint`; they are for the person.

- `retry` — run the same command once more (wait `error.retry_after_seconds` first when it is present). Each retry of `xtap tool call` gets a new call token. If the same call fails again, treat it as `report`.
- `fix_input` — correct the flag, file, or tool name the hint points at, then run the command again once. Use an exact name from `xtap tool list`; never guess.
- `sync_tools` — run `xtap tool sync`, then `xtap tool list`, then retry the call once with an exact listed tool name.
- `new_task` — the task ended or does not belong to this caller: start a new task with the current prompt (`xtap task start`). Never reuse a task id across different person requests. `request_not_in_task` means the task was started by an older xtap that declared actions; the new task declares none.
- `tell_person` — tell the person what happened (use `error.message`) and stop. Do not retry and do not reword the prompt or arguments to get around a policy denial.
- `connect_app` — the app isn't connected (the hint names it). Tell the person and offer to request the connection: if they agree, call `lunarfence_request_app_connection` through `xtap tool call` on the same task and give them the link (they can also connect it under Connectors in the LunarFence console). Then stop. Do not retry until they say it is connected; then run `xtap tool sync` and `xtap tool list` first.
- `reconnect_xtap` — tell the person to press Connect on the LunarFence connector in Muse again, then stop. Run `xtap setup` again only after they confirm.
- `ask_then_recover` — tell the person what happened and stop. Run `xtap recover` only if they agree, because recover disconnects the agent on the other device. On setup `key_retired` the same applies.
- `run_doctor` — run `xtap doctor` and report its output. This is the only case in which to run doctor; use it only for `run_doctor`, never as a default.
- `report` — give the person `error.message` and the correlation id (`error.correlation_id`, if present) and stop. Do not retry and do not run doctor.
- `wait_for_approval` — LunarFence is holding this change until the person approves it. Show the person `error.message_for_person` (it has the approval link) in your own words, then run `error.resume_command` (`xtap approval wait <approval_id>`). Repeat that command while it answers `wait_for_approval`, until the call completes or is refused. Never call the tool again with other arguments while you wait.

## Consent and policy

- **`consent_required`** (from task start): tell the person to approve the request in LunarFence (it shows `XTAP task` plus the first 8 chars of the task id), then **stop**. Do not retry or poll. Its `next_action` is `tell_person`.
- **Policy denial** (`tell_person`, `reason` set): tell the person what was denied; do not retry with reworded prompts or arguments.
- **Monthly tool-call limit** (`plan_limit_reached`, `tell_person`): the person's LunarFence account used this month's tool-call limit. Tell the person when calls work again: `error.limit_resets_at` (and the hint) give it in UTC, so convert it to the person's own time zone before telling them, then stop. Never retry. LunarFence's own tools (`explain_refusal`, `get_my_access`) still work.
- **LunarFence requests**: a request tool (`lunarfence_request_app_connection`, `lunarfence_request_app_access`) refused with `requests_not_allowed`: tell the person to open this agent in the LunarFence console and turn on 'Allow this agent to ask you to connect apps or give it access', then stop.
- **After an xtap upgrade**, each live prompt gets one new task, so the person approves it once more.

## Approvals

LunarFence decides every tool call itself, from the person's rules. Reads run as before. A change (for example Calendar create, edit or delete event) may be allowed, blocked, or held for the person's approval; with no rules, any change can be held.

- **A held change** answers `wait_for_approval`: show the person the link from `message_for_person`, wait, then continue or stop as they decide. `xtap approval wait <approval_id>` waits up to 50 seconds per run; run it again while it still answers `wait_for_approval`.
- **After a decline, stop that action.** Tell the person it was not made.
- **A blocked or declined change stays refused.** Never reword, split or switch tools to get around a refused change, and never make the same change another way.
- **Lost the approval id?** Run `xtap approval list`; it shows each held call and its resume command. Making the same call again (same tool, same arguments, same task) also works: the same call again returns the same pending approval rather than a new one.
- **`lunarfence_suggest_rule`**: suggest a rule only after the person has approved the same kind of change several times, and only about yourself (this agent). The person decides in the LunarFence console; never pressure them to accept. After `suggestion_dismissed`, `suggestions_pending_limit` or a "too many suggestions today" answer, don't suggest again.

## Setup, recover, and state

- Do not run `xtap setup` or `xtap recover` unless the person asks, or `next_action` says to and the person agrees.
- Prefer `xtap status` for local inspection; it does not invent credentials.
- **Never edit or delete `~/.xtap`.**

## Offline commands

`xtap version`, `xtap status`, `xtap task list`, `xtap tool list`, `xtap approval list`, and `xtap skill show` make no network calls. Use them freely for inspection.
