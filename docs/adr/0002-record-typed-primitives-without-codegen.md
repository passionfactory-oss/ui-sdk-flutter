# ADR-0002: Type primitives with records instead of code generation

## Status

Accepted

## Context

Upstream defines a component with `definePrimitive({ name, state, api, slots, agent })`, and `createParts(primitive, tags)` turns it into typed parts (`parts.Root`, `parts.Input`). The typing relies on TypeScript mapped types, which rename and transform an object type's keys. Dart has no mapped types and Flutter has no runtime reflection (`dart:mirrors` is not available), so we have to choose how primitives get typed parts, how state is updated, and how the agent bridge finds and calls api methods.

The main authors of primitives are agents building components the library doesn't ship. Upstream's principle is that the API is small and predictable "so a model writes them correctly in few tokens". Any step an agent must remember, like running a generator before the analyzer passes, is a step it will sometimes forget.

We checked what Dart can do without generation (Dart 3.11.5, Flutter 3.41.9). When `slots` returns a record, inference flows from `state` and `api` into the `slots` closure, so `primitive.slots.root` has the type `Slot<({bool muted}), MuteApi>`, and a typo like `primitive.slots.rooot` fails `dart analyze` with `undefined_getter`. `packages/ui_sdk_flutter/test/primitive_test.dart` exercises this.

## Decision

Use a hybrid with no required code generation:

- **Primitives written by users and agents** declare `slots` as a Dart record. Slot names, slot state and api types are checked at compile time.
- **Components the library ships** expose hand-written, typed widgets per part (for example `TabsList`, `TabsTrigger`), each with dartdoc, built on the same primitives. Upstream's Svelte adapter makes the same trade.
- **The agent bridge uses an explicit action table** in the primitive definition, for example `'setValue': action1<String>(api.setValue)`. The table is also the allowlist of what an agent may call, as upstream's `agent.actions` is.
- **Snapshot state is reported explicitly** through a `report` function that returns JSON-safe values.

A code generator may be added later as an optional package. If it is, it must emit the same API a person would write by hand, so generated and hand-written primitives stay interchangeable.

## Consequences

### Positive

- Defining a primitive needs no build step. Save the file and `dart analyze` checks it.
- Part names and types are checked at compile time, for library and user primitives alike.
- No generator to keep compatible with analyzer API changes.
- Agent actions are listed where the primitive is defined, so a reviewer sees what an agent can do.

### Negative

- Dart records have no `copyWith`. Updating one field of a multi-field state means rebuilding the record or writing a state class with its own `copyWith`.
- Each primitive writes its action table and `report` function by hand, roughly 10 to 20 lines that a generator would write.
- Library part widgets are hand-written, so each new component costs more code in the library.

### Neutral

- Part widgets in the library get Pascal-case names like upstream's React parts, but they are written by hand, not derived.

## Alternatives Considered

- **Mandatory `build_runner` generation**: the strongest typing and the least code per primitive, with generated `copyWith`, action dispatch and JSON Schema. Rejected because every user and agent must run the generator, and the analyzer reports errors until it does.
- **Runtime string slot keys**: simplest to build, but a misspelled part only fails at run time. Records give compile-time checks at the same cost.
- **Dart macros**: the Dart team stopped work on macros in January 2025 because they slowed down analysis and hot reload, so they are not an option.

## References

- Upstream `contributing/architecture.md`, sections "definePrimitive" and "Rendering contract"
- `packages/ui_sdk_flutter/lib/src/kernel/primitive.dart`
- [An update on Dart macros & data serialization](https://dart.dev/blog/an-update-on-dart-macros-data-serialization), Dart blog, 2025-01-29

---

**Created**: 2026-11-13
**Author**: Minsu Lee (@amondnet)
**Last Updated**: 2026-11-13
