

import 'package:pharmo_app/models/jagger_order.dart';

class Jagger {
  int id;
  String? startTime;
  String? endTime;
  double? lon;
  double? lat;
  int? progress;
  bool? isActive;
  String? createdOn;
  int? supplier;
  int? ordersCnt;
  int? delman;
  double? expense;
  List<dynamic>? inItems;  
  List<JaggerOrder>? jaggerOrders;  

  Jagger(
    this.id,
    this.startTime,
    this.endTime,
    this.lon,
    this.lat,
    this.progress,
    this.isActive,
    this.createdOn,
    this.supplier,
    this.ordersCnt,
    this.delman,
    this.expense,
    this.inItems,
  );

  Jagger.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        startTime = json['startTime'],
        endTime = json['endTime'],
        lon = json['lon'],
        lat = json['lat'],
        progress = json['progress'],
        isActive = json['isActive'],
        createdOn = json['createdOn'],
        supplier = json['supplier'],
        delman = json['delman'],
        expense = json['expense'],
        ordersCnt = json['ordersCnt'],
        inItems = json['inItems'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'lon': lon,
      'lat': lat,
      'progress': progress,
      'isActive': isActive,
      'createdOn': createdOn,
      'supplier': supplier,
      'delman': delman,
      'expense': expense,
      'ordersCnt': ordersCnt,
      'inItems': inItems,
    };
  }
}
