import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/main/delivery_man/home/delivery_widget.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:provider/provider.dart';

class StatusChanger extends StatefulWidget {
  final int delId;
  final int orderId;
  final String status;
  const StatusChanger({
    super.key,
    required this.delId,
    required this.orderId,
    required this.status,
  });

  @override
  State<StatusChanger> createState() => _StatusChangerState();
}

class _StatusChangerState extends State<StatusChanger> {
  List<String> statuses = [
    'Хүргэгдсэн',
    'Хаалттай',
    'Буцаагдсан',
    'Түгээлтэнд гарсан'
  ];

  setStatus() {}
  String selected = '';
  @override
  void initState() {
    super.initState();
    setState(() {
      selected = process(widget.status);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<JaggerProvider>(context, listen: false);
    return SheetContainer(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            spacing: 15,
            children: [
              ...statuses.map(
                (status) => pro(status, provider, context),
              )
            ],
          ),
        )
      ],
    );
  }

  InkWell pro(String status, JaggerProvider provider, BuildContext context) {
    bool sel = status == selected;
    return InkWell(
      onTap: () async {
        final data = {
          "delivery_id": widget.delId.toString(),
          "order_id": widget.orderId,
          "process": getOrderProcess(status)
        };
        final response = await api(Api.patch, 'delivery/order/', body: data);
        if (response!.statusCode == 200 || response.statusCode == 201) {
          message('Төлөв өөрчлөгдлөө', isSuccess: true);
          await provider.getDeliveries();
        } else if (response.statusCode == 400) {
          if (convertData(response)
              .toString()
              .contains('Delivery not started!')) {
            message('Түгээлт эхлээгүй!');
          } else {
            message('Амжилтгүй!');
          }
        } else {
          message(wait);
        }
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
            color: sel ? succesColor : transperant,
            border: Border.all(color: sel ? transperant : frenchGrey),
            borderRadius: BorderRadius.circular(15)),
        child: Row(
          spacing: 15,
          children: [
            SizedBox(width: 20),
            Text(status,
                style: TextStyle(color: sel ? white : black, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
