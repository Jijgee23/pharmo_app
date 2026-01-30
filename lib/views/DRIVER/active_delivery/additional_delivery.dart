import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/application/application.dart';

class AdditionalDeliveries extends StatefulWidget {
  final List<DeliveryItem> items;
  const AdditionalDeliveries({super.key, required this.items});

  @override
  State<AdditionalDeliveries> createState() => _AdditionalDeliveriesState();
}

class _AdditionalDeliveriesState extends State<AdditionalDeliveries>
    with SingleTickerProviderStateMixin {
  final note1 = TextEditingController();

  Future additionalDelivery(JaggerProvider jagger) async {
    await mySheet(
      children: [
        CustomTextField(
          controller: note1,
          hintText: 'Тайлбар',
        ),
        CustomButton(
          text: 'Бүртгэх',
          ontap: () async {
            await jagger.registerAdditionalDelivery(note1.text);
            note1.clear();
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        final items = widget.items.map((item) => itemBuilder(item)).toList();
        return Container(
          color: grey100,
          padding: EdgeInsets.all(10),
          child: SectionCard(
            title: 'Нэмэлт хүргэлтүүд',
            child: SingleChildScrollView(
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...items,
                  ModernDetailRow('Нийт', widget.items.length.toString()),
                  DividerBuidler(),
                  Row(
                    children: [
                      Expanded(
                        child: ModernActionButton(
                          label: 'Бүртгэх',
                          icon: Icons.add,
                          color: Colors.green,
                          onTap: () => additionalDelivery(jagger),
                        ),
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ).paddingAll(10),
            ),
          ),
        );
      },
    );
  }

  Widget itemBuilder(DeliveryItem item) {
    return Column(
      children: [
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.note,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        item.visitedOn.toString().substring(0, 10),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        item.visitedOn.toString().substring(10, 19),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Ibtn(onTap: () => editItem(item), icon: Icons.edit)
            ],
          ),
        ),
        DividerBuidler(),
      ],
    ).paddingSymmetric(vertical: 5);
  }

  final note = TextEditingController();

  editItem(DeliveryItem item) {
    final jagger = Provider.of<JaggerProvider>(context, listen: false);
    setState(() {
      note.text = item.note;
    });
    mySheet(
      title: 'Мэдээлэл засах',
      children: [
        CustomTextField(controller: note),
        CustomButton(
          text: 'Хадгалах',
          ontap: () {
            jagger.editAdditionalDelivery(item.id, note.text);
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
