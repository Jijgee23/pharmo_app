// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/widgets/custom_alert_dialog.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';

class ShoppingCartView extends StatefulWidget {
  final Map<String, dynamic> detail;
  final String type;
  final bool hasCover;

  const ShoppingCartView({super.key, required this.detail, this.type = "cart", this.hasCover = true});

  @override
  State<ShoppingCartView> createState() => _ShoppingCartViewState();
}

class _ShoppingCartViewState extends State<ShoppingCartView> {
  late int selectedItem = 0;
  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context, listen: true);
    Future<void> removeBasketItem() async {
      dynamic res = await basketProvider.removeBasketItem(basket_id: basketProvider.basket.id, item_id: selectedItem);
      if (res['errorType'] == 1) {
        Navigator.pop(context);
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    }

    Future<void> changeBasketItem(int item_id, String type, int qty) async {
      dynamic res = await basketProvider.changeBasketItem(item_id: item_id, type: type, qty: qty);
      if (res['errorType'] == 1) {
        showSuccessMessage(message: res['message'], context: context);
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    }

    void showAlertDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            submitFunction: removeBasketItem,
            text: "Та устгахдаа итгэлтэй байна уу? ",
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Card(
          child: Container(
            margin: const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  text: TextSpan(
                    text: '',
                    style: TextStyle(
                      color: Colors.blueGrey.shade800,
                      fontSize: 13.0,
                    ),
                    children: [
                      TextSpan(
                        text: widget.detail['product_name'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
                      IconButton.filledTonal(
                        iconSize: 25,
                        color: Colors.red,
                        icon: const Icon(
                          Icons.remove,
                        ),
                        onPressed: () {
                          selectedItem = widget.detail['id'];
                          changeBasketItem(widget.detail['id'], 'minus', widget.detail['qty']);
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 0),
                        child: RichText(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          text: TextSpan(text: 'Тоо ширхэг : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                            TextSpan(text: '${widget.detail['qty'].toString()}\n', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                          ]),
                        ),
                      ),
                      IconButton.filledTonal(
                        iconSize: 25,
                        color: Colors.green,
                        icon: const Icon(
                          Icons.add,
                        ),
                        onPressed: () {
                          selectedItem = widget.detail['id'];
                          changeBasketItem(widget.detail['id'], 'add', widget.detail['qty']);
                        },
                      ),
                    ]),
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      text: TextSpan(text: 'Үнэ : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                        TextSpan(text: '${widget.detail['main_price']} ₮', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0)),
                      ]),
                    ),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                  RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(text: 'Нийт үнэ : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                      TextSpan(text: '${widget.detail['qty'] * widget.detail['main_price']} ₮', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.red, fontSize: 16.0)),
                    ]),
                  ),
                  IconButton.filled(
                    iconSize: 25,
                    color: Colors.white,
                    icon: const Icon(
                      Icons.delete_forever,
                    ),
                    onPressed: () {
                      selectedItem = widget.detail['id'];
                      showAlertDialog();
                    },
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }
}
