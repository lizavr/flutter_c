import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: 'lib/environment/.env', obfuscate: true)
class Env {
  @EnviedField(obfuscate: true)
  static final String apiKey = _Env.apiKey;
}
