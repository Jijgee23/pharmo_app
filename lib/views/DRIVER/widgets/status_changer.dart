import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/application/application.dart';

class StatusChanger extends StatefulWidget {
  final DeliveryOrder order;
  const StatusChanger({
    super.key,
    required this.order,
  });

  @override
  State<StatusChanger> createState() => _StatusChangerState();
}

class _StatusChangerState extends State<StatusChanger> {
  OrderProcess pro = OrderProcess.unknown;
  @override
  void initState() {
    super.initState();
    setState(() {
      pro = widget.order.orderProcess;
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
              ...OrderProcess.deliveryProcess.map(
                (process) => processBuilder(process, provider, context),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget processBuilder(
    OrderProcess process,
    JaggerProvider provider,
    BuildContext context,
  ) {
    bool selected = pro == process;
    return ElevatedButton(
      onPressed: () async {
        Navigator.pop(context);
        await LoadingService.run(
          () async {
            final data = {
              "delivery_id": widget.order.deliveryId,
              "order_id": widget.order.id,
              "process": process.code,
            };
            final r = await api(Api.patch, 'delivery/order/', body: data);
            if (r == null) return;
            print(r.statusCode);
            print(r.body);
            if (r.statusCode == 200 || r.statusCode == 201) {
              messageComplete('Төлөв өөрчлөгдлөө');
              await provider.getDeliveries();
            } else if (r.statusCode == 400) {
              if (convertData(r).toString().contains('Delivery not started!')) {
                messageWarning('Түгээлт эхлээгүй!');
              } else {
                messageWarning('Амжилтгүй!');
              }
            } else {
              messageError(wait);
            }
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? Colors.green.shade50 : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(12),
          side: BorderSide(
            color: selected ? Colors.green.shade300 : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            process.name,
            style: TextStyle(
              color: selected ? Colors.green.shade900 : Colors.black87,
              fontSize: 16,
            ),
          ),
        ],
      ).paddingOnly(left: 10),
    );
  }
}
