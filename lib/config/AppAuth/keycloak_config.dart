class KeycloakConfig {
  static late String _env;

  static void initialize(String env) {
    _env = env;
  }

  static String get clientId => _env == 'dev' ? 'mana-app' : 'production_client_id';

  static String get redirectUrl => _env == 'dev' 
    ? 'com.mana-mana.app:/redirect' 
    : 'production_redirect_url';

  static String get discoveryUrl => _env == 'dev'
    ? 'http://192.168.0.210:7082/auth/realms/mana/.well-known/openid-configuration'
    : 'production_discovery_url';

  static String get clientSecret => _env == 'dev'
    ? 'XvNSAcULiu1PIgSF41ogOsz21UaCnh4a'
    : 'production_client_secret';
}
