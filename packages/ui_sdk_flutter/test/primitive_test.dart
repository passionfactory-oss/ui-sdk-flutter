import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
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
  test('a press on a slot runs the api and updates state', () {
    final instance = muteButton.create();
    addTearDown(instance.dispose);
    var notified = 0;
    instance.store.addListener(() => notified++);

    muteButton.slots.root.press!(instance.api);

    expect(instance.state.muted, isTrue);
    expect(notified, 1);
    expect(muteButton.slots.root.semantics!(instance.state).toggled, isTrue);
  });

  test('instances of one primitive keep separate state', () {
    final a = muteButton.create();
    final b = muteButton.create();
    addTearDown(a.dispose);
    addTearDown(b.dispose);

    a.api.toggle();

    expect(a.state.muted, isTrue);
    expect(b.state.muted, isFalse);
  });
}
