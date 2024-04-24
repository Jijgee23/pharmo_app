import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
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
    final basketProvider = Provider.of<BasketProvider>(context, listen: false);
    Future<void> removeBasketItem() async {
      dynamic res = await basketProvider.removeBasketItem(basket_id: basketProvider.basket.id, item_id: selectedItem);
      if (res['errorType'] == 1) {
        Navigator.pop(context);
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
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
                      IconButton(
                        iconSize: 22,
                        color: Colors.black,
                        icon: const Icon(
                          Icons.remove,
                        ),
                        onPressed: () {
                          selectedItem = widget.detail['id'];
                          showAlertDialog();
                        },
                      ),
                      RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        text: TextSpan(text: 'Тоо ширхэг: ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                          TextSpan(text: '${widget.detail['qty'].toString()}\n', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                        ]),
                      ),
                      IconButton(
                        iconSize: 22,
                        color: Colors.black,
                        icon: const Icon(
                          Icons.add,
                        ),
                        onPressed: () {
                          selectedItem = widget.detail['id'];
                          showAlertDialog();
                        },
                      ),
                    ]),
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
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                  RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(text: 'Нийт үнэ: ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                      TextSpan(text: '${widget.detail['qty'] * widget.detail['main_price']} ₮', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.red, fontSize: 16.0)),
                    ]),
                  ),
                  IconButton(
                    iconSize: 25,
                    color: AppColors.secondary,
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
