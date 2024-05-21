import 'package:aitapp/application/state/id_password_provider.dart';
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
    final identity = ref.read(idPasswordProvider);
    await state.create(identity[0], identity[1]);
  }
}
