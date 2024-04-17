import 'package:flutter/material.dart';

class ShoppingCartView extends StatefulWidget {
  final Map<String, dynamic> detail;
  final String type;
  final bool hasCover;

  const ShoppingCartView({super.key, required this.detail, this.type = "cart", this.hasCover = true});

  @override
  State<ShoppingCartView> createState() => _ShoppingCartViewState();
}

class _ShoppingCartViewState extends State<ShoppingCartView> {
  void _showModal(detail) {}

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Card(
        child: Container(
            margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  text: TextSpan(text: '', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                    TextSpan(text: '${widget.detail['product_name'].toString()}\n', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                  ]),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      text: TextSpan(text: 'Тоо ширхэг: ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                        TextSpan(text: '${widget.detail['qty'].toString()}\n', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                      ]),
                    ),
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      text: TextSpan(text: 'Үнэ: ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                        TextSpan(text: '${widget.detail['main_price']} ₮', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  RichText(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    text: TextSpan(text: 'Нийт үнэ: ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                      TextSpan(text: '${widget.detail['qty'] * widget.detail['main_price']} ₮', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.red, fontSize: 16.0)),
                    ]),
                  ),
                ]),
              ],
            )),
      );
    });
  }
}
