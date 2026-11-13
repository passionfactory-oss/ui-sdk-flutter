import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';

/// Holds one primitive instance's state and notifies listeners when it changes.
final class Store<S> extends ChangeNotifier {
  Store(this._state);

  S _state;

  S get state => _state;

  void set(S next) {
    if (next == _state) return;
    _state = next;
    notifyListeners();
  }
}

/// What a primitive's `api` builder receives.
final class PrimitiveContext<S> {
  PrimitiveContext(this.store);

  final Store<S> store;

  S get state => store.state;
}

/// One part of a primitive: when it exists, what it announces, and what a press does.
final class Slot<S, A> {
  const Slot({this.present, this.semantics, this.press});

  final bool Function(S state)? present;
  final SemanticsProperties Function(S state)? semantics;
  final void Function(A api)? press;
}

typedef SlotFactory<S, A> =
    Slot<S, A> Function({
      bool Function(S state)? present,
      SemanticsProperties Function(S state)? semantics,
      void Function(A api)? press,
    });

/// A component's state, api and parts, with no rendering.
///
/// [slots] is a record, so `primitive.slots.root` is checked at compile time.
final class Primitive<S, A, T extends Record> {
  Primitive._({
    required this.name,
    required S Function() state,
    required A Function(PrimitiveContext<S> context) api,
    required this.slots,
  }) : _state = state,
       _api = api;

  final String name;
  final T slots;
  final S Function() _state;
  final A Function(PrimitiveContext<S> context) _api;

  PrimitiveInstance<S, A> create() {
    final store = Store<S>(_state());
    return PrimitiveInstance._(name, store, _api(PrimitiveContext<S>(store)));
  }
}

/// One live use of a [Primitive], owned by the widget that created it.
final class PrimitiveInstance<S, A> {
  PrimitiveInstance._(this.name, this.store, this.api);

  final String name;
  final Store<S> store;
  final A api;

  S get state => store.state;

  void dispose() => store.dispose();
}

/// Defines a primitive. Type arguments are inferred from [state], [api] and [slots].
Primitive<S, A, T> definePrimitive<S, A, T extends Record>({
  required String name,
  required S Function() state,
  required A Function(PrimitiveContext<S> context) api,
  required T Function(SlotFactory<S, A> slot) slots,
}) {
  Slot<S, A> slot({
    bool Function(S state)? present,
    SemanticsProperties Function(S state)? semantics,
    void Function(A api)? press,
  }) => Slot<S, A>(present: present, semantics: semantics, press: press);

  return Primitive<S, A, T>._(
    name: name,
    state: state,
    api: api,
    slots: slots(slot),
  );
}
