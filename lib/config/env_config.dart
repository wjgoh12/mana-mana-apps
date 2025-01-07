class EnvConfig {
  static late String _env;

  static void initialize(String env) {
    _env = env;
  }

  static const int tokenExpirationMinutes = 20;
  static String get keycloakClientId =>
      _env == 'prod' ? 'mana-app' : 'mana-app';
      
  static String get keycloakBaseUrl => _env == 'prod'
      ? 'https://admin.manamanasuites.com'
      : 'http://192.168.0.124:7080';

  static String get keycloakRedirectUrl => _env == 'prod'
      ? 'com.mana-mana.app:/redirect'
      : 'com.mana-mana.app:/redirect';

  static String get keycloakDiscoveryUrl => _env == 'prod'
      ? 'https://admin.manamanasuites.com/auth/realms/mana/.well-known/openid-configuration'
      : 'http://192.168.0.124:7080/auth/realms/mana/.well-known/openid-configuration';

  static String get keycloakClientSecret => _env == 'prod'
      ? 'DhYoNv9v7l1k91Q6UYN1LsnWc78L688D'
      : '**********';

  static String get apiBaseUrl => _env == 'prod'
      ? 'https://admin.manamanasuites.com'
      : 'http://192.168.0.210:4389';
}
