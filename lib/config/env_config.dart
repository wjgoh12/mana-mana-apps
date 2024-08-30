class EnvConfig {
  static late String _env;

  static void initialize(String env) {
    _env = env;
  }

  static const int tokenExpirationMinutes = 20;
  static String get keycloak_clientId =>
      _env == 'prod' ? 'mana-app' : 'mana-app';
      
  static String get keycloak_baseUrl => _env == 'prod'
      ? 'https://admin.manamanasuites.com'
      : 'http://192.168.0.210:7082';

  static String get keycloak_redirectUrl => _env == 'prod'
      ? 'com.mana-mana.app:/redirect'
      : 'com.mana-mana.app:/redirect';

  static String get keycloak_discoveryUrl => _env == 'prod'
      ? 'https://admin.manamanasuites.com/auth/realms/mana/.well-known/openid-configuration'
      : 'http://192.168.0.210:7082/auth/realms/mana/.well-known/openid-configuration';

  static String get keycloak_clientSecret => _env == 'prod'
      ? 'DhYoNv9v7l1k91Q6UYN1LsnWc78L688D'
      : 'XvNSAcULiu1PIgSF41ogOsz21UaCnh4a';

  static String get api_baseUrl => _env == 'prod'
      ? 'https://admin.manamanasuites.com'
      : 'http://192.168.0.210:4389';
}
