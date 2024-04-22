class Order {
  int id;
  int orderNo;
  String totalPrice;
  int totalCount;
  String status;
  String process;
  bool isChanging;
  bool isBilled;
  String payType;
  bool qp;
  String createdOn;
  String? extra;
  Map user;
  String supplier;
  Map address;
  String? seller;
  String? delman;
  String? packer;
  Order(this.id, this.orderNo, this.totalPrice, this.totalCount, this.process, this.isChanging, this.isBilled, this.payType, this.qp, this.user, this.supplier, this.address, this.seller, this.delman, this.packer, this.createdOn, this.extra,
      this.status);

  Order.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        orderNo = json['orderNo'],
        totalPrice = json['totalPrice'],
        totalCount = json['totalCount'],
        process = json['process'],
        isChanging = json['isChanging'],
        isBilled = json['isBilled'],
        qp = json['qp'],
        user = json['user'],
        supplier = json['supplier'],
        address = json['address'],
        seller = json['seller'],
        delman = json['delman'],
        packer = json['packer'],
        createdOn = json['createdOn'],
        extra = json['extra'],
        status = json['status'],
        payType = json['payType'];
}
