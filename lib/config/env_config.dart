class EnvConfig {
  static late String _env;

  static void initialize(String env) {
    _env = env;
  }

  static String get keycloak_clientId => _env == 'dev' ? 'mana-app' : 'production_client_id';
  static String get keycloak_baseUrl => _env == 'dev' ? 'http://192.168.0.210:7082' : 'production_keycloak_baseUrl';

  static String get keycloak_redirectUrl => _env == 'dev' 
    ? 'com.mana-mana.app:/redirect' 
    : 'production_redirect_url';

  static String get keycloak_discoveryUrl => _env == 'dev'
    ? 'http://192.168.0.210:7082/auth/realms/mana/.well-known/openid-configuration'
    : 'production_discovery_url';

  static String get keycloak_clientSecret => _env == 'dev'
    ? 'XvNSAcULiu1PIgSF41ogOsz21UaCnh4a'
    : 'production_client_secret';

  static String get api_baseUrl => _env == 'dev'
    ? 'http://192.168.0.210:4389'
    : 'production_baseUrl';

    
}
