import 'package:aitapp/application/auth/lcam_session.dart';
import 'package:aitapp/domain/features/get_lcam_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'get_lcam_data.g.dart';

@Riverpod(keepAlive: true)
class GetLcamDataNotifier extends _$GetLcamDataNotifier {
  @override
  GetLcamData build() {
    return GetLcamData();
  }

  Future<void> create() async {
    // 共有セッションのCookieを受け取る(ログインは LcamSession が一元管理)。
    final cookies = await ref.read(lcamSessionProvider.notifier).ensure();
    state.useSession(cookies);
  }
}
