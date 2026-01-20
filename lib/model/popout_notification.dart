class PopoutNotification {
  String? title;
  String? description;
  String? img;
  String? startDate;
  String? endDate;
  bool?
      status; // Assuming boolean, or maybe "1"/"0" string, handling both in fromJson is safer.

  PopoutNotification({
    this.title,
    this.description,
    this.img,
    this.startDate,
    this.endDate,
    this.status,
  });

  PopoutNotification.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    img = json['img'];
    startDate = json['startDate'] ?? json['start_date'];
    endDate = json['endDate'] ?? json['end_date'];

    if (json['status'] is bool) {
      status = json['status'];
    } else if (json['status'] is String) {
      status = json['status'].toString().toLowerCase() == 'true' ||
          json['status'] == '1';
    } else if (json['status'] is int) {
      status = json['status'] == 1;
    } else {
      status = false;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['img'] = img;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['status'] = status;
    return data;
  }
}
