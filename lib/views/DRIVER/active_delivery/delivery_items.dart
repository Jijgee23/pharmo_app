import 'package:flutter/material.dart';
import 'package:pharmo_app/controller/providers/jagger_provider.dart';
import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/application/color/colors.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/inputs/ibtn.dart';
import 'package:provider/provider.dart';

class DeliveryItemsWidget extends StatefulWidget {
  final List<DeliveryItem> items;
  const DeliveryItemsWidget({super.key, required this.items});

  @override
  State<DeliveryItemsWidget> createState() => _DeliveryItemsWidgetState();
}

class _DeliveryItemsWidgetState extends State<DeliveryItemsWidget>
    with SingleTickerProviderStateMixin {
  bool expanded = false;

  void setExpanded() {
    setState(() {
      expanded = !expanded;
    });
  }

  final note1 = TextEditingController();

  additionalDelivery(JaggerProvider jagger) {
    mySheet(
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
    return Card(
      color: neonBlue.withAlpha(50),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade500),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: setExpanded,
        child: AnimatedSize(
          duration: Duration(milliseconds: 300),
          child: Container(
            padding: EdgeInsets.all(14.5),
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header(),
                if (expanded) ...[
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        widget.items.map((item) => itemBuilder(item)).toList(),
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget itemBuilder(DeliveryItem item) {
    return Card(
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: neonBlue.withAlpha(150),
        ),
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.note,
                  style: TextStyle(
                      color: white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      item.visitedOn.toString().substring(0, 10),
                      style: TextStyle(
                        color: white,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      item.visitedOn.toString().substring(10, 19),
                      style: TextStyle(
                        color: white,
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
    );
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

  Align header() {
    final jagger = Provider.of<JaggerProvider>(context, listen: false);
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 10,
        children: [
          Ibtn(onTap: () => additionalDelivery(jagger), icon: Icons.add),
          Text(
            'Нэмэлт хүргэлтүүд',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: white, width: 3),
              shape: BoxShape.circle,
            ),
            child: Text(
              widget.items.length.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
