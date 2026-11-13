# ui_sdk_flutter

An unofficial Flutter port of [UI SDK](https://github.com/vercel-labs/ui): a library of behaviors for agents to build user interfaces with. Keyboard navigation, focus, selection, dismissal, popups and the semantics they need, as building blocks for any component, with a testing kit and an agent bridge.

This project is not affiliated with or endorsed by Vercel.

> [!WARNING]
> Pre-release. Only the primitive kernel exists so far, and nothing is published to pub.dev yet.

## Packages

| Package                                                     | What it is                                                         |
| ----------------------------------------------------------- | ------------------------------------------------------------------ |
| [`ui_sdk_flutter`](packages/ui_sdk_flutter)                 | Kernel, behaviors, components and the in-app agent bridge          |
| [`ui_sdk_flutter_testing`](packages/ui_sdk_flutter_testing) | Pattern checks for keyboard, focus, semantics and right to left    |
| [`ui_sdk_flutter_mcp`](packages/ui_sdk_flutter_mcp)         | MCP server that lets coding agents operate a running app           |

## Develop

The repository is a pub workspace. With [FVM](https://fvm.app):

```bash
fvm install
fvm flutter pub get
fvm flutter analyze
cd packages/ui_sdk_flutter && fvm flutter test
```

Read [ARCHITECTURE.md](ARCHITECTURE.md) for how the code is shaped, and [docs/adr/](docs/adr/index.md) for why.

## License

[Apache-2.0](LICENSE). See [NOTICE](NOTICE) for attribution to UI SDK.
