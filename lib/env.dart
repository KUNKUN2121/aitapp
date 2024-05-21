import 'package:envied/envied.dart';
part 'env.g.dart';

// ignore: avoid_classes_with_only_static_members
@Envied(path: 'env/.env')
abstract class Env {
  @EnviedField(varName: 'BLOWFISHKEY', obfuscate: true)
  static final String blowfishKey = _Env.blowfishKey;
}
