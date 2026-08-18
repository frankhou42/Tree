# Architecture and context semantics

Tree models a conversation as a recursive graph of `Chat` values. Each node owns three distinct
forms of state:

1. `inheritedContext`, an immutable snapshot of the parent prefix at the fork point
2. `messages`, the new dialogue created inside this node
3. `branchedChats`, child explorations created from this node

## Context isolation invariant

For any model request inside a branch, the prompt history is exactly:

```text
system prompt + inherited context + active branch messages
```

Messages added to one branch never mutate its parent or siblings. A nested fork composes the
ancestor context with the current node's prefix, so it retains the reasoning path without importing
messages that occurred after the fork point.

## Branch lifecycle

When the user selects Branch beneath an assistant response, Tree snapshots all active-context
messages through that response. The branch panel then collects isolated messages.

- Closing a Temporary branch discards only the isolated messages.
- Closing a Permanent branch saves the isolated messages, inherited snapshot, parent chat ID, and
  source message ID as a child conversation.

The sidebar renders child conversations recursively and uses index paths only for transient UI
selection. Stable UUIDs preserve identity and provenance in persisted data.

## Persistence

`ChatStore` encodes the complete recursive graph to `chats.json` under the user's Application
Support directory and writes it atomically. The custom decoder supplies defaults for newer branch
fields, allowing graphs saved by an older version of Tree to keep loading.

## Local inference

`OllamaClient` sends typed JSON requests to the local Ollama chat endpoint. Main and branch calls run
in asynchronous tasks, and UI mutations return to the main actor. The macOS app sandbox permits
outgoing client connections only so it can reach the local model service.

## Current limitations

- Model responses arrive as a complete response rather than a token stream.
- JSON persistence is appropriate for a single-user prototype, not collaborative editing.
- Conversation paths are rendered hierarchically; a spatial graph view is part of the roadmap.
- The system has not yet been evaluated through a formal user study.
