# ui_sdk_flutter

Behaviors and primitives for building accessible Flutter components, made for agents. An unofficial Flutter port of [UI SDK](https://github.com/vercel-labs/ui).

This package is a pre-release skeleton. Only the primitive kernel exists so far. See [ARCHITECTURE.md](../../ARCHITECTURE.md) for the plan.

## Define a primitive

A primitive holds a component's state, api and parts, with no rendering. Its `slots` are a record, so `muteButton.slots.root` is checked at compile time:

```dart
import 'package:flutter/semantics.dart';
import 'package:ui_sdk_flutter/ui_sdk_flutter.dart';

final class MuteApi {
  MuteApi(this.toggle);

  final void Function() toggle;
}

final muteButton = definePrimitive(
  name: 'mute-button',
  state: () => (muted: false),
  api: (context) =>
      MuteApi(() => context.store.set((muted: !context.state.muted))),
  slots: (slot) => (
    root: slot(
      semantics: (state) =>
          SemanticsProperties(button: true, toggled: state.muted),
      press: (api) => api.toggle(),
    ),
  ),
);

void main() {
  final instance = muteButton.create();
  muteButton.slots.root.press!(instance.api);
  print(instance.state.muted); // true
  instance.dispose();
}
```

Part widgets that render a slot don't exist yet.
