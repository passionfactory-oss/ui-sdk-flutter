# ADR-0004: Implement behaviors independently of naked_ui

## Status

Accepted

## Context

[`naked_ui`](https://pub.dev/packages/naked_ui) (part of the `btwld/remix` repository, version 1.5.0 as of 2026-11-13) is an active headless widget library for Flutter. It ships components such as `NakedButton`, `NakedCheckbox`, `NakedSelect`, `NakedTabs` and `NakedDialog`, with semantics and observable states like hovered, focused and pressed. Its README doesn't mention an agent bridge or MCP.

This project overlaps with it at the component level, so we had to decide whether to build on it. What upstream UI SDK adds beyond headless components depends on every component sharing one shape:

- Behaviors are public building blocks, so an agent can build a component the library doesn't ship with the same keyboard and focus rules as the ones it does.
- Every component is a primitive, so the agent bridge can list each instance's state and actions, and the testing kit can check each against its pattern.
- `ui_sdk_flutter` has no runtime dependencies beyond the Flutter SDK.

## Decision

Implement the kernel, behaviors and components in `ui_sdk_flutter` without depending on `naked_ui`. Build them on Flutter's own building blocks, like `Shortcuts`, `Actions`, `FocusTraversalGroup`, `OverlayPortal` and `Semantics`, instead of replacing those.

A wrapped third-party component would not be a primitive: the agent registry could not see its state, and the testing kit could not reach its parts. It would also tie our public API to another project's release cycle.

## Consequences

### Positive

- One shape for every component, which the agent bridge, the testing kit and the agent skill depend on.
- No runtime dependency outside the Flutter SDK.
- We control the API that semver promises cover.

### Negative

- We redo work `naked_ui` has already done for common components, and must reach comparable quality before the library is useful on its own.
- Two headless libraries for Flutter may split users and contributors.

### Neutral

- `naked_ui` stays a useful reference for Flutter-specific accessibility details, and its components can be compared against our testing kit.

## Alternatives Considered

- **Build components on `naked_ui`** and add only the agent bridge, testing kit and skill: faster to a first release, but the bridge would need a second integration path for components that aren't primitives, which breaks the one-shape rule.
- **Contribute the agent layer to `naked_ui` upstream**: depends on another project accepting a large design change, and leaves the behavior kit for custom components unsolved.
- **Wrap `naked_ui` behind an adapter**: keeps the option of swapping it out, but costs an adapter layer for every component and still leaves its state invisible to the registry.

## References

- [`naked_ui` on pub.dev](https://pub.dev/packages/naked_ui)
- [ADR-0002: Type primitives with records instead of code generation](0002-record-typed-primitives-without-codegen.md)
- [ADR-0003: Expose the agent bridge through VM service extensions and a separate MCP server](0003-agent-bridge-over-vm-service-and-mcp.md)

---

**Created**: 2026-11-13
**Author**: Minsu Lee (@amondnet)
**Last Updated**: 2026-11-13
