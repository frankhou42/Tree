# Product vision

## The interface problem

Most AI chat products compress thinking into one chronological feed. That design is convenient for
turn taking, but it poorly represents how people reason. A user often wants to inspect one premise,
compare two directions, or ask a clarifying question without changing the main task.

Today the user must either continue in place and contaminate future context, or start over and
manually reconstruct what mattered. Both choices make the human adapt to the model's interface.

## Tree's thesis

The conversation should become a manipulable object. Users should be able to decide which context
is inherited, which exploration is temporary, and which conclusion becomes part of their durable
knowledge.

Tree treats a model response as a possible fork point. Each fork preserves provenance while giving
the user an isolated workspace. This makes context visible as a design material rather than an
invisible token buffer.

## Design principles

### User-owned context

The user chooses when a branch is created, what it inherits, and whether it persists. The model does
not silently rewrite the structure of the user's thinking.

### Reversible exploration

Low-cost temporary branches encourage curiosity because following a tangent cannot damage the main
conversation. Useful tangents can become permanent without being copied into a new chat.

### Visible provenance

Saved branches retain their parent conversation and source message. A future graph view can explain
not only what an idea says, but where it came from.

### Local by default

Personal reasoning can be sensitive. A local model and local persistence make privacy a system
property instead of a settings promise.

### Honest system boundaries

Tree distinguishes its implemented prototype from its roadmap. It currently demonstrates context
forking, isolation, provenance, recursive navigation, persistence, and local inference. Spatial
visualization, synthesis, and collaborative graphs remain future work.

## Long-term direction

Tree can grow from a branched chat client into a personal reasoning environment:

- A spatial map for navigating questions, evidence, alternatives, and decisions
- Branch comparison that exposes disagreements before synthesizing a conclusion
- User-approved memory that promotes only durable insights into future context
- Multiple local or hosted models assigned to different branches for comparison
- Exportable reasoning subtrees that become documents, plans, or study guides

The goal is not to make chat visually busier. It is to give people better control over how their
ideas evolve with AI.
