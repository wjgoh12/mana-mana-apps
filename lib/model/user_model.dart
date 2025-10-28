class User {
  String? email;
  String? firstName;
  String? lastName;
  String? token;
  String? role;
  String? ownerEmail;
  String? ownerAltEmail;
  String? ownerFullName;
  String? ownerNationality;
  String? ownerRefType;
  String? ownerRefNo;
  String? ownerContact;
  String? ownerAltContact;
  String? ownerAddress;

  User({
    this.email,
    this.role,
    this.token,
    this.firstName,
    this.lastName,
    this.ownerEmail,
    this.ownerAltEmail,
    this.ownerFullName,
    this.ownerNationality,
    this.ownerRefType,
    this.ownerRefNo,
    this.ownerContact,
    this.ownerAltContact,
    this.ownerAddress,
  });

  User.fromJson(Map<String, dynamic> json) {
    // ✅ CRITICAL FIX: Check for ownersinfo FIRST
    if (json.containsKey('ownersinfo') && json['ownersinfo'] != null) {
      // Production format with nested ownersinfo (impersonated user)
      final ownersinfo = json['ownersinfo'] as Map<String, dynamic>;

      // Use impersonated user's data for EVERYTHING
      email = ownersinfo['email'];
      ownerEmail = ownersinfo['email'];
      ownerAltEmail = ownersinfo['altEmail'];
      ownerFullName = ownersinfo['fullName'];
      ownerNationality = ownersinfo['nationality'];
      ownerRefType = ownersinfo['refType'];
      ownerRefNo = ownersinfo['refNo'];
      ownerContact = ownersinfo['contact'];
      ownerAltContact = ownersinfo['altContact'];
      ownerAddress = ownersinfo['address'];

      // ✅ IMPORTANT: Split fullName into firstName/lastName for display
      final nameParts = (ownerFullName ?? '').split(' ');
      if (nameParts.isNotEmpty) {
        firstName = nameParts.first;
        lastName = nameParts.skip(1).join(' ');
      }
    } else {
      // UAT format - flat structure (no impersonation)
      email = json['email'];
      firstName = json['firstName'];
      lastName = json['lastName'];
      ownerEmail = json['email'];
      ownerAltEmail = null;
      ownerFullName =
          '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim();
      ownerNationality = null;
      ownerRefType = null;
      ownerRefNo = null;
      ownerContact = null;
      ownerAltContact = null;
      ownerAddress = null;
    }

    // Handle roles - can be either a List or a String
    if (json['roles'] != null) {
      if (json['roles'] is List) {
        role = (json['roles'] as List).join(',');
      } else {
        role = json['roles'];
      }
    }

    token = json['token'];
  }

  Object? toJson() {}
}
