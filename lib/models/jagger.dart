import 'dart:ffi';

import 'package:pharmo_app/models/jagger_order.dart';

class Jagger {
  int id;
  String? startTime;
  String? endTime;
  String? lon;
  String? lat;
  String? progress;
  bool? isActive;
  String? createdOn;
  int? supplier;
  int? delman;
  String? expense;
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
      'inItems': inItems,
    };
  }
}
