import 'package:aitapp/domain/types/identity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IdentityNotifier extends StateNotifier<Identity?> {
  IdentityNotifier() : super(null);

  // ignore: use_setters_to_change_properties
  void setIdPassword(Identity identity) {
    state = identity;
  }

  void clear() {
    state = null;
  }
}

final identityProvider = StateNotifierProvider<IdentityNotifier, Identity?>(
  (ref) {
    return IdentityNotifier();
  },
);
