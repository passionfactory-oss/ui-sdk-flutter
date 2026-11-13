# ADR-0001: Publish as an unofficial port named ui_sdk_flutter under Apache-2.0

## Status

Accepted

## Context

This project brings the ideas of [UI SDK](https://github.com/vercel-labs/ui) (`@ui-sdk/core`, by Vercel) to Flutter: tested behaviors, primitives built from them, a pattern testing kit, and an agent bridge. It is a public open-source library, published to pub.dev, so it needs a package name and a license before the first release. Both are hard to change once published: pub.dev never frees a package name, and a published name can only be discontinued.

Constraints:

- The name `ui_sdk` on pub.dev is already taken by an unrelated package (Tinker Box Ui Sdk, version 1.0.142+1 as of 2026-11-13).
- "UI SDK" is the name Vercel uses for its project. A Flutter package must not look like an official Vercel release.
- Upstream is licensed under Apache-2.0. We expect to port its API design, behavior rules, docs wording and test cases closely, and possibly some code.
- Docs and code are written in English so that contributors and agents outside the original team can use them.

## Decision

- Name every package with the `ui_sdk_flutter` prefix: `ui_sdk_flutter`, `ui_sdk_flutter_testing`, `ui_sdk_flutter_mcp`.
- Describe the project everywhere as an "unofficial Flutter port of UI SDK". Never use Vercel's logo or imply endorsement.
- License the project under Apache-2.0, the same license as upstream, and credit upstream in `NOTICE`.
- Write all code, docs and ADRs in English.

We chose a name that points at upstream because the project's value is the port itself: people who know UI SDK, and agents that were trained on its docs, can find it and map its concepts directly. Using the same license as upstream means ported material keeps one set of terms, with attribution in `NOTICE`, instead of mixing licenses file by file.

## Consequences

### Positive

- People and agents searching pub.dev for UI SDK on Flutter find the package.
- Material ported from upstream needs only the attribution Apache-2.0 already requires.
- The patent grant in Apache-2.0 covers contributors, as it does upstream.

### Negative

- The name ties the project to a brand we don't control. If Vercel objects, renaming means publishing new packages and discontinuing the old ones.
- The name sets an expectation of parity with upstream that the project has to meet or explain.
- Apache-2.0 asks contributors to keep `NOTICE` up to date when they port more material.

### Neutral

- Upstream's API names (`definePrimitive`, `createRovingFocus`, `snapshot`, `act`) are kept where Dart allows, which follows from presenting it as a port.

## Alternatives Considered

- **An independent brand name**: avoids any trademark question, but loses the discoverability that is the main reason to call it a port. Still available if the risk above materializes.
- **`ui_sdk`**: taken on pub.dev.
- **MIT license**: more common in the Flutter ecosystem, but material ported from an Apache-2.0 project would still carry Apache-2.0 terms, leaving two licenses in one package.

## References

- [UI SDK repository](https://github.com/vercel-labs/ui) and its `LICENSE`
- [`ui_sdk` on pub.dev](https://pub.dev/packages/ui_sdk)
- `NOTICE`

---

**Created**: 2026-11-13
**Author**: Minsu Lee (@amondnet)
**Last Updated**: 2026-11-13
