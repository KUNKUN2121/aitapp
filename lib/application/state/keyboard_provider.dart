import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final keyboardVisibilityProvider =
    StateNotifierProvider<KeyboardVisibilityNotifier, bool>((ref) {
  return KeyboardVisibilityNotifier();
});

class KeyboardVisibilityNotifier extends StateNotifier<bool>
    with WidgetsBindingObserver {
  KeyboardVisibilityNotifier() : super(false) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    state = bottomInset > 0.0;
  }
}
