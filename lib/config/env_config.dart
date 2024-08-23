class EnvConfig {
  static late String _env;

  static void initialize(String env) {
    _env = env;
  }
  static const int tokenExpirationMinutes = 20;
  static String get keycloak_clientId => _env == 'dev' ? 'mana-app' : 'mana-app';
  static String get keycloak_baseUrl => _env == 'dev' ? 'http://192.168.0.210:7082' : 'https://admin.manamanasuites.com';

  static String get keycloak_redirectUrl => _env == 'dev' 
    ? 'com.mana-mana.app:/redirect' 
    : 'com.mana-mana.app:/redirect';

  static String get keycloak_discoveryUrl => _env == 'dev'
    ? 'http://192.168.0.210:7082/auth/realms/mana/.well-known/openid-configuration'
    : 'https://admin.manamanasuites.com/auth/realms/mana/.well-known/openid-configuration';

  static String get keycloak_clientSecret => _env == 'dev'
    ? 'XvNSAcULiu1PIgSF41ogOsz21UaCnh4a'
    : 'DhYoNv9v7l1k91Q6UYN1LsnWc78L688D';

  static String get api_baseUrl => _env == 'dev'
    ? 'http://192.168.0.210:4389'
    : 'https://admin.manamanasuites.com';

    
}
