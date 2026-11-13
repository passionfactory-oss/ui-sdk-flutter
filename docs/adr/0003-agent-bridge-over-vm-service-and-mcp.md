# ADR-0003: Expose the agent bridge through VM service extensions and a separate MCP server

## Status

Accepted

## Context

Upstream's agent bridge (`createAgent()`) lets an agent read every component on a page and call its actions: `snapshot` lists components with their label, state and available actions, `act` runs steps like `{ ref: "Project name", action: "setValue", args: ["Atlas"] }`, and `query` searches. Changes made this way reach the component's change callbacks with `source: "agent"`, and an `allow` callback can refuse a step. In upstream's project-settings benchmark, an agent using the bridge needed 69% fewer tool calls and read 83% less text than one using browser tools.

In a browser, upstream hands these tools to the browser's agent through WebMCP. Flutter has no equivalent on mobile or desktop, so we need a way to connect the bridge to an agent. Three options were on the table: an MCP server for coding agents during development, an agent embedded in the app, and WebMCP on Flutter web. The first users are agents that build components and need to check them in a running app, so development-time access comes first.

Existing Flutter tools already connect agents to running apps. `marionette_mcp` describes itself as letting agents "inspect and interact with running Flutter apps", starting with taps. `mcp_toolkit` adds Flutter-specific methods to an MCP server. Neither knows about component state or actions, so an agent using them works at the level of gestures and widgets, as upstream's browser-tools baseline does.

## Decision

- **In the app**: `createAgent()` in `ui_sdk_flutter` keeps a registry of live primitive instances and registers `snapshot`, `act` and `query` as VM service extensions through `dart:developer`. It adds no third-party dependency. The `allow` callback and `source: "agent"` work in the app, as upstream does.
- **Out of the app**: `ui_sdk_flutter_mcp` is a separate pure-Dart package. It connects to the app's VM service with `package:vm_service` and exposes the same three tools over MCP with `package:dart_mcp`, using upstream's tool names and JSON Schemas.
- An in-app agent transport and WebMCP for Flutter web come later. They reuse the same registry and tools.

## Consequences

### Positive

- Coding agents operate components through their actions, not taps, which is where upstream measured its gains.
- The app package stays free of MCP, networking and third-party dependencies. The server's dependencies never reach an app's release build.
- Tool names and schemas match upstream's, so prompts and agent knowledge carry over.

### Negative

- Release builds have no VM service, so this transport works only in debug and profile builds. Production use of the bridge waits for the in-app transport.
- The server needs the app's VM service URI, which adds a setup step for users.
- `dart_mcp` is still on 0.x, so its API may change under us.

### Neutral

- The bridge does not replace semantics. Screen readers keep using Flutter's semantics tree, and the bridge reads labels from the same source.

## Alternatives Considered

- **Drive the app through semantics or the widget tree** (as `marionette_mcp` and the Dart MCP server do): works without any library support, but stays at the gesture level that upstream's benchmark shows is slower and costlier.
- **Run an MCP server inside the app**: removes the URI step, but adds dependencies and an open network listener to every app that uses the library.
- **Embedded agent first**: closest to a production feature, but it needs app-specific model wiring and doesn't help agents that are building and checking components.
- **WebMCP first**: web only, and it needs a browser that provides `document.modelContext`. Upstream's `registerTools` does nothing in browsers without it.

## References

- Upstream docs: "Built for Agents" and "WebMCP" pages, `packages/core/src/page/agent/agent.ts`
- [`marionette_mcp`](https://pub.dev/packages/marionette_mcp), [`mcp_toolkit`](https://pub.dev/packages/mcp_toolkit), [`dart_mcp`](https://pub.dev/packages/dart_mcp)

---

**Created**: 2026-11-13
**Author**: Minsu Lee (@amondnet)
**Last Updated**: 2026-11-13
