# Architecture

## Bird's-eye overview

ui_sdk_flutter is an unofficial Flutter port of [UI SDK](https://github.com/vercel-labs/ui). It isn't a component library. It's the layer underneath one: keyboard navigation, focus, selection, dismissal, popups, drag and drop, and the semantics they need, as small building blocks that people and their agents combine into components. When an agent builds a component the library doesn't ship, like a kanban board or a timeline, it uses the same tested behaviors as the components that do ship, instead of rebuilding focus and keyboard handling from scratch.

The design rests on one shape for everything. Behaviors combine into a **primitive** (`definePrimitive`), which holds a component's state, api and parts with no rendering. App code renders the parts with its own widgets and styles. Because every component is a primitive, two tools can see all of them: the **testing kit** checks each against its accessibility pattern, and the **agent bridge** lists each live instance's state and actions so an agent can call `setValue` instead of tapping at coordinates.

```text
 behaviors ──► primitive ──► part widgets ──► app widgets and styles
 (focus,       (state, api,   (library or
  popups, …)    slots)         hand-written)
                   │
                   ├──► ui_sdk_flutter_testing  (pattern checks in widget tests)
                   └──► agent registry ──► VM service extension ──► ui_sdk_flutter_mcp ──► coding agent
```

The project is a pre-release skeleton. Only the primitive kernel exists. Sections below mark what is planned.

## Entry points

The best starting point is `packages/ui_sdk_flutter/lib/src/kernel/primitive.dart`, which defines `definePrimitive`, `Primitive`, `Slot`, `Store` and `PrimitiveInstance`.

- `packages/ui_sdk_flutter/test/primitive_test.dart`: a complete primitive (a mute button) and how its slots, api and state work together.
- `packages/ui_sdk_flutter/lib/ui_sdk_flutter.dart`: the public library, and so the list of what is exported.
- `docs/adr/`: why the project is shaped this way. Start with [ADR-0002](docs/adr/0002-record-typed-primitives-without-codegen.md).
- `pubspec.yaml` at the root: the pub workspace that ties the packages together.

## Module structure

The repository is a [pub workspace](https://dart.dev/tools/pub/workspaces) with one lockfile at the root. Package boundaries follow dependency boundaries: a package exists when its dependencies must not reach an app that doesn't use it.

### `packages/ui_sdk_flutter/`

The library apps depend on: kernel, behaviors, components and the in-app side of the agent bridge. It depends only on the Flutter SDK. Upstream splits core from five framework adapters; Flutter has one renderer, so here they are one package, and upstream's subpath entries (`@ui-sdk/core/tabs`) become libraries in the package (`package:ui_sdk_flutter/tabs.dart`).

Its `lib/src/` is layered, and code imports downward only:

| Layer      | Path                         | Owns                                                                                     | Status  |
| ---------- | ---------------------------- | ---------------------------------------------------------------------------------------- | ------- |
| Kernel     | `lib/src/kernel/`            | `definePrimitive`, the store, instances, slots, change details and reasons, controllers  | Started |
| Foundation | `lib/src/foundation/<job>/`  | One folder per behavior job, named like upstream's: `focus`, `selection`, `popups`, …    | Planned |
| Components | `lib/src/components/<name>/` | Each component's primitive and its hand-written part widgets                             | Planned |
| Agent      | `lib/src/agent/`             | The instance registry, `snapshot`, `act`, `query`, `allow`, and VM service registration  | Planned |

**Key abstractions**: `Primitive`, `PrimitiveInstance`, `Slot`, `Store`.

### `packages/ui_sdk_flutter_testing/`

Pattern checks for widget tests, the counterpart of upstream's `@ui-sdk/core/testing`: keyboard behavior, focus order, semantics, and the same checks under `TextDirection.rtl`. It depends on `flutter_test`, which is why it is a separate package: apps add it as a dev dependency. Planned; the library is empty.

### `packages/ui_sdk_flutter_mcp/`

A pure-Dart MCP server that runs as its own process, connects to a debug or profile app over the VM service, and exposes `snapshot`, `act` and `query` to coding agents. It depends on `dart_mcp` and `vm_service`, which must never reach an app. See [ADR-0003](docs/adr/0003-agent-bridge-over-vm-service-and-mcp.md). Planned; the library is empty.

### `docs/adr/`

Architecture decision records. [`docs/adr/index.md`](docs/adr/index.md) lists them.

## How upstream concepts map to Flutter

| Upstream (web)                                        | Here                                                                         |
| ----------------------------------------------------- | ---------------------------------------------------------------------------- |
| ARIA attributes from `attrs()`                        | `SemanticsProperties` from a slot's `semantics`                              |
| `data-*` state attributes and CSS variables           | Slot state passed to the part's builder                                      |
| `on`, `press` and keydown handlers                    | `Shortcuts`, `Actions` and `Intent`s, `FocusNode`, gesture detectors         |
| `bind(el)` once an element is in the page             | The part widget's `State` lifecycle                                          |
| Popup top layer and `position()`                      | `OverlayPortal` and a follower layout                                        |
| `createParts` mapped types                            | A record of slots, plus hand-written part widgets for library components     |
| Five framework adapters                               | One package                                                                  |
| Server rendering and hydration                        | Not applicable                                                               |
| Right to left without a provider                      | `Directionality.of(context)`, with behaviors using logical start and end     |
| WebMCP                                                | VM service extensions and `ui_sdk_flutter_mcp`, WebMCP later for web         |

## Architecture invariants

**No Material or Cupertino**: `ui_sdk_flutter` imports `package:flutter/foundation.dart`, `semantics.dart`, `services.dart`, `rendering.dart` and `widgets.dart`, never `material.dart` or `cupertino.dart`. Components render no styles of their own.

**No third-party runtime dependencies in `ui_sdk_flutter`**: only the Flutter SDK. Anything that needs a package lives in a separate package, like the MCP server. See [ADR-0004](docs/adr/0004-independent-of-naked-ui.md).

**Build on Flutter, don't replace it**: behaviors use `Shortcuts`, `Actions`, `FocusTraversalGroup`, `OverlayPortal` and `Semantics`. We do not write a parallel focus system, a parallel shortcut system or our own overlay stack.

**One shape everywhere**: every component, ours or an agent's, is a primitive built from the same behaviors, with a root and parts. A component that bypasses the kernel is invisible to the testing kit and the agent bridge, so it is a bug.

**No code generation required**: defining or using a primitive never requires `build_runner`. An optional generator, if one is ever added, emits the API a person would write by hand. See [ADR-0002](docs/adr/0002-record-typed-primitives-without-codegen.md).

**No reflection**: Flutter has no `dart:mirrors`. Anything the agent bridge calls or reports is declared in the primitive, in its action table and `report` function.

**No agent access in release builds or over the network**: the VM service transport works only in debug and profile builds, and no network listener is ever opened inside the app.

**Imports go downward only**: kernel, then foundation, then components and agent. The kernel imports nothing else from the package, and a component never imports another component, except where an ADR records the exception.

**Logical directions**: behaviors speak of start and end, never left and right, and read the direction from `Directionality`.

## API boundaries

**Public** (covered by semver once published):

- Everything exported from `package:ui_sdk_flutter/ui_sdk_flutter.dart` and the per-component libraries
- The tool names and JSON Schemas of `snapshot`, `act` and `query`
- The public library of `ui_sdk_flutter_testing`

**Internal** (may change at any time):

- Everything under `lib/src/` that a public library doesn't export
- The VM service extension names and payloads between the app and `ui_sdk_flutter_mcp`, which always ship at matching versions

## Cross-cutting concerns

These are the rules new code follows. Except for language, license and toolchain, none of them has code yet.

**Change details** (planned): every `on<Key>Change` callback receives the reason, the source (`pointer`, `keyboard`, `agent`, …) and a way to cancel, as upstream does. Changes an agent makes go through the same path as a person's.

**Semantics as the accessibility contract** (planned): a part's accessible name, role and state come from its slot's `semantics`. The agent bridge reads labels from the same place, so a control a screen reader can name is a control an agent can find.

**Testing**: unit and widget tests use `flutter_test`. Once the testing kit and bridge exist, every component gets a pattern check from `ui_sdk_flutter_testing` and an agent test that drives it through the bridge.

**Docs for agents**: each package will ship Markdown docs for its version, indexed by an `llms.txt`, and an agent skill, as upstream's packages do.

**Language and license**: code and docs are English. The project is Apache-2.0 and credits upstream in `NOTICE`. See [ADR-0001](docs/adr/0001-unofficial-port-name-and-license.md).

**Toolchain**: `.fvmrc` pins Flutter 3.41.9 for development. The pubspecs declare Dart `^3.8.0` and Flutter 3.32 or later, and CI (`.github/workflows/ci.yml`) checks both the pinned version and 3.32.x. The workspace resolves every package together, and `flutter_test` pins some packages to the SDK's own versions, so a dependency of `ui_sdk_flutter_mcp` must accept the version the oldest supported Flutter pins. For `vm_service` that is 15.0.0 on Flutter 3.32.

---

_Last updated: 2026-11-13 — initial skeleton: workspace, kernel, ADR-0001 to ADR-0004._

_See `docs/adr/` for the decisions behind this structure._
