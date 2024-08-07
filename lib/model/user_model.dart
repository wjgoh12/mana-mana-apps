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
    role = json['roles'];
    token = json['token'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    ownerEmail = json['ownersinfo']['email'];
    ownerAltEmail = json['ownersinfo']['altEmail'];
    ownerFullName = json['ownersinfo']['fullName'];
    ownerNationality = json['ownersinfo']['nationality'];
    ownerRefType = json['ownersinfo']['refType'];
    ownerRefNo = json['ownersinfo']['refNo'];
    ownerContact = json['ownersinfo']['contact'];
    ownerAltContact = json['ownersinfo']['altContact'];
    ownerAddress = json['ownersinfo']['address'];
  }

  Object? toJson() {}
}
