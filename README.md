# Tree

> Think in branches, not chats.

Tree is a native macOS workspace for nonlinear conversations with local AI. A user can fork any
assistant response, explore a tangent with the exact context that produced it, and either discard
the exploration or preserve it as a navigable child conversation.

The project starts from a simple human and AI interaction belief: people do not think in one long
transcript. They compare alternatives, follow side questions, revisit assumptions, and return to an
earlier line of reasoning. AI interfaces should make that structure visible and put the user in
control of it.

## What is implemented

- Native SwiftUI interface for macOS with resizable conversation and branch panels
- Local inference through Ollama, with no cloud API key or remote model dependency
- Branching from any assistant response with exact parent-prefix context inheritance
- Temporary branches for disposable exploration and permanent branches for durable knowledge
- Recursive conversation tree with expandable, renameable, selectable, and deletable nodes
- Provenance metadata linking every saved branch to its parent chat and source message
- Atomic local JSON persistence in Application Support
- Token-streamed model responses that keep the interface responsive

## Why branching changes the interaction

In a linear chat, asking a side question pollutes the context of everything that follows. Starting a
new chat avoids that pollution but loses the reasoning that made the question meaningful. Tree
separates those concerns:

| Interaction | Context behavior | User intent |
| --- | --- | --- |
| Main thread | Continues the active conversation | Advance the primary line of thought |
| Temporary branch | Inherits the parent prefix, then disappears on close | Test an idea without clutter |
| Permanent branch | Inherits the parent prefix and persists as a child node | Keep a useful alternative |

The result is a user-controlled context graph. The model receives only the inherited prefix and the
messages within the active branch, while the interface preserves where that branch came from.

## Architecture

| Component | Responsibility |
| --- | --- |
| `ContentView` | Owns selection, branch lifecycle, recursive graph updates, and persistence triggers |
| `Chat` | Stores messages, inherited context, child conversations, and branch provenance |
| `MainChatColumn` | Runs the active conversation and captures the context prefix at a fork point |
| `BranchPanel` | Isolates temporary or permanent exploration from the main thread |
| `ChatSidebar` | Renders and edits the recursive conversation hierarchy |
| `OllamaService` | Streams typed local chat responses through an isolated Swift actor |
| `ChatStore` | Saves and restores the complete conversation graph as local JSON |

See [the architecture notes](docs/ARCHITECTURE.md) for context isolation invariants and
[the product vision](docs/VISION.md) for the longer-term interaction model.

## Run locally

Requirements:

- macOS 15.5 or newer
- Xcode 16.4 or newer
- [Ollama](https://ollama.com/)

Install and start the default model:

```bash
ollama pull llama3.2
ollama serve
```

Open `Tree.xcodeproj` in Xcode and run the `Tree` scheme. The app connects only to
`http://localhost:11434` by default.

Run the conversation-graph checks independently of Xcode:

```bash
swiftc Tree/ChatMessage.swift Tree/Chat.swift Scripts/TreeModelChecks.swift -o /tmp/tree-model-checks
/tmp/tree-model-checks
swiftc -parse Tree/*.swift
```

## Suggested demo

1. Ask the model to propose an architecture for a personal knowledge assistant.
2. Fork the response and investigate one storage choice as a temporary branch.
3. Close it and show that the main conversation was not changed.
4. Fork again, choose Permanent, and keep the alternative.
5. Expand the saved child in the sidebar, reopen it, and continue with its inherited context.
6. Relaunch the app to demonstrate local graph persistence.

## Product boundaries

Tree is an early, focused macOS prototype. It does not claim collaborative sync, semantic search,
multi-model comparison, or production-scale inference. Those boundaries are deliberate so the
implemented interaction model remains inspectable and credible.

## Roadmap

- Visualize large conversation trees as a zoomable spatial canvas
- Compare sibling branches and synthesize their conclusions into a parent thread
- Add semantic search across user-approved branches
- Export selected subtrees as Markdown knowledge artifacts
- Evaluate whether branching reduces context contamination and repeated prompting

## Privacy

Conversation history is stored locally in the user's Application Support directory. Model requests
go to the locally running Ollama service. Tree does not include analytics, an account system, or a
cloud persistence layer.

## License

MIT
