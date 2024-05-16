import 'package:flutter/foundation.dart';
import 'package:stated/src/core/core.dart';
import 'package:stated/src/stated/stated_builder.dart';

/// A Custom [ValueListenable] implementation
/// Can be used in with [ListenableBuilder] or [StatedBuilder]
/// The [value] is never assigned directly, but rather built using [build]
abstract class Stated<T> with Disposer, Tasks implements ValueListenable<T> {
  final Notifier _notifier = Notifier();

  /// The current value of the [Stated].
  T? _value;

  /// The current value of the [Stated].
  /// If [value] is null, [build] is called to build the value.
  T get value => _value ??= build();

  var _disposed = false;

  /// Returns `true` if [dispose] has been called.
  bool get disposed => _disposed;

  /// This methods needs to be overridden to produce [value].
  @protected
  T build();

  /// After the [callback] it produces the [value].
  /// Notifies listeners only when [value] changes.
  @protected
  @mustCallSuper
  void setState([VoidCallback? callback]) async {
    if (_disposed) return;

    callback?.call();
    final oldValue = _value;
    _value = build();

    if (oldValue != _value) {
      _notifier.notify();
    }
  }

  @override
  @mustCallSuper
  void addListener(VoidCallback callback) {
    if (_disposed) return;

    _notifier.addListener(callback);
  }

  @override
  @mustCallSuper
  void removeListener(VoidCallback callback) {
    if (_disposed) return;

    _notifier.removeListener(callback);
  }

  @mustCallSuper
  @override
  void dispose() {
    disposeTasks();
    _notifier.dispose();
    _disposed = true;
    super.dispose();
  }
}
