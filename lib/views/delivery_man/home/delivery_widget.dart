import 'package:flutter/material.dart';
import 'package:pharmo_app/models/delivery.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';

class DeliveryWidget extends StatefulWidget {
  final Order order;
  const DeliveryWidget({super.key, required this.order});

  @override
  State<DeliveryWidget> createState() => _DeliveryWidgetState();
}

class _DeliveryWidgetState extends State<DeliveryWidget> with SingleTickerProviderStateMixin {
  bool expanded = false;
  late AnimationController _controller;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _iconRotation = Tween<double>(begin: 0, end: 0.5).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleExpand() {
    setState(() {
      expanded = !expanded;
      if (expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  User getUser() {
    if (widget.order.user != null) {
      return widget.order.user!;
    } else if (widget.order.customer != null) {
      return widget.order.customer!;
    } else if (widget.order.orderer != null) {
      return widget.order.orderer!;
    } else {
      return User(id: '1', name: '');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> expandedFields = ['Нийт үнэ', 'Тоо ширхэг', 'Явц', 'Төлөв', 'Төлбөрийн хэлбэр'];
    List<String> expandedValues = [
      toPrice(widget.order.totalPrice),
      widget.order.totalCount.toString(),
      getOrderProcess(widget.order.process),
      getStatus(widget.order.status),
      getPayType(widget.order.payType)
    ];

    return InkWell(
      onTap: toggleExpand,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: padding15,
        width: double.maxFinite,
        decoration: BoxDecoration(color: zircon, borderRadius: border20),
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                colored(getUser().name, Icons.person, neonBlue.withOpacity(.8)),
                colored(widget.order.orderNo.toString(), Icons.numbers,
                    const Color.fromARGB(255, 66, 241, 145),
                    main: MainAxisAlignment.end),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: expanded
                  ? Column(
                      children: expandedFields
                          .map((v) => infoRow(v, expandedValues[expandedFields.indexOf(v)]))
                          .toList(),
                    )
                  : const SizedBox.shrink(),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: expanded
                  ? Container(
                      decoration:
                          BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: border20),
                      padding: const EdgeInsets.all(5),
                      child: SizedBox(
                        height: 160, // Ensure proper display height
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                widget.order.items.map((item) => product(item, context)).toList(),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Center(
              child: RotationTransition(
                turns: _iconRotation,
                child: const Icon(Icons.arrow_drop_down, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget product(Item item, BuildContext context) {
    double itemWidth = Sizes.width * 0.4;
    double maxItemWidth = 180;
    double minItemWidth = 140;
    return Container(
      width: itemWidth.clamp(minItemWidth, maxItemWidth),
      constraints: const BoxConstraints(
        minHeight: 180,
        maxHeight: 220,
        minWidth: 130,
        maxWidth: 140,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      padding: padding10,
      decoration: BoxDecoration(
        borderRadius: border20,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(2, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag, color: Colors.blueAccent, size: 30), // Product icon
          const SizedBox(height: 5),
          Text(
            '${item.itemName} (${item.itemQty})',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${toPrice(item.itemPrice.toString())} (Нэгж)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey.shade600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${toPrice(item.itemTotalPrice.toString())} (Нийт)',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget colored(String text, IconData icon, Color color, {MainAxisAlignment? main}) {
    return Expanded(
      // constraints: BoxConstraints(
      //   minWidth: 100,
      //   maxWidth: MediaQuery.of(context).size.width * 0.4,
      // ),
      child: Row(
        mainAxisAlignment: main ?? MainAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 5),
          Text(
            text,
            softWrap: true,
            maxLines: 2,
            style: const TextStyle(
              color: black,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
