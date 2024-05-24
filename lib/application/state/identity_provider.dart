import 'package:aitapp/domain/types/identity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IdentityNotifier extends StateNotifier<Identity?> {
  IdentityNotifier() : super(null);

  void setIdPassword(String id, String password) {
    state = Identity(id: id, password: password);
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
