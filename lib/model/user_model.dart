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
    email = json['email'];

    // Handle roles - can be either a List or a String
    if (json['roles'] != null) {
      if (json['roles'] is List) {
        // UAT returns roles as a List, join them into a string
        role = (json['roles'] as List).join(',');
      } else {
        // Production might return as a String
        role = json['roles'];
      }
    }

    token = json['token'];
    firstName = json['firstName'];
    lastName = json['lastName'];

    // Handle both UAT (flat structure) and Production (nested ownersinfo)
    if (json.containsKey('ownersinfo') && json['ownersinfo'] != null) {
      // Production format with nested ownersinfo
      ownerEmail = json['ownersinfo']['email'];
      ownerAltEmail = json['ownersinfo']['altEmail'];
      ownerFullName = json['ownersinfo']['fullName'];
      ownerNationality = json['ownersinfo']['nationality'];
      ownerRefType = json['ownersinfo']['refType'];
      ownerRefNo = json['ownersinfo']['refNo'];
      ownerContact = json['ownersinfo']['contact'];
      ownerAltContact = json['ownersinfo']['altContact'];
      ownerAddress = json['ownersinfo']['address'];
    } else {
      // UAT format - flat structure, use top-level fields
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
  }

  Object? toJson() {}
}
