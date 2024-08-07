class OwnerPropertyList{
  int lseqid;
  String? email;
  String? location;
  String? type;
  String? unitno;
  String? coemail;
  String? unitstatus;
  String? bank;
  String? accountname;
  String? accountnumber;

  OwnerPropertyList({
    this.lseqid = 0,
    this.email,
    this.location,
    this.type,
    this.unitno,
    this.coemail,
    this.unitstatus,
    this.bank,
    this.accountname,
    this.accountnumber,
  });

  OwnerPropertyList.fromJson(Map<String, dynamic> json, int index, String prefix) : lseqid = json['lseqid'] ?? 0 {
    email = json['email'];
    location = json['location'];
    type = json['type'];
    unitno = json['unitno'];
    coemail = json['coemail'];
    unitstatus = json['unitstatus'];
    bank = json['bank'];
    accountname = json['accountname'];
    accountnumber = json['accountnumber'];
  }
}