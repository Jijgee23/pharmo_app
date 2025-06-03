class QrData {
  String? invoiceId;
  String? qrTxt;
  List<Links>? urls;
  QrData({this.invoiceId, this.qrTxt, this.urls});
  QrData.fromJson(Map<String, dynamic> json)
      : invoiceId = json['invoiceId'],
        qrTxt = json['qrTxt'],
        urls =
            (json['urls'] as List).map((url) => Links.fromJson(url)).toList();
}

class Links {
  String? name;
  String? description;
  String? logo;
  String? link;
  Links({this.name, this.description, this.logo, this.link});
  Links.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        description = json['description'],
        logo = json['logo'],
        link = json['link'];
}
