// lib/env/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: "TOKEN", obfuscate: true)
  static final String token = _Env.token;

  @EnviedField(varName: "API_KEY", obfuscate: true)
  static final String apiKey = _Env.apiKey;

  @EnviedField(varName: "BASE_URL", obfuscate: true)
  static final String baseUrl = _Env.baseUrl;
}
