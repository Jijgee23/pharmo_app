// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/icon/my_icon.dart';
import 'package:pharmo_app/widgets/inputs/button.dart';
import 'package:provider/provider.dart';

class ShoppingCartView extends StatefulWidget {
  final Map<String, dynamic> detail;
  final String type;
  final bool hasCover;
  const ShoppingCartView(
      {super.key,
      required this.detail,
      this.type = "cart",
      this.hasCover = true});

  @override
  State<ShoppingCartView> createState() => _ShoppingCartViewState();
}

class _ShoppingCartViewState extends State<ShoppingCartView> {
  late BasketProvider basketProvider;
  @override
  void initState() {
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    // basketProvider.checkQTYs(context);
    getErrorMessage();
    super.initState();
  }

  late int selectedItem = 0;
  bool checked = false;
  String error = '';
  final FocusNode focusNode = FocusNode();
  getErrorMessage() {
    for (int i = 0; i < basketProvider.qtys.length; i++) {
      if (basketProvider.qtys[i].id == widget.detail['qtyId'].toString()) {
        print(basketProvider.qtys[i].id);
        setState(() {
          error = 'Барааны үлдэгдэл хүрэлцэхгүй!';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context, listen: true);
    // String getErrorMessage(int id) {
    //   basketProvider.qtys.map(
    //     (q) {
    //       print(q.id);
    //       if (q.id == id.toString()) {
    //         return 'Бараа хэвийн';
    //       } else {
    //         return 'Үлдэгдэл хүрэлцахгүй байна';
    //       }
    //     }
    //   );
    //   return '';
    // }

    Future<void> removeBasketItem() async {
      dynamic res = await basketProvider.removeBasketItem(
          basket_id: basketProvider.basket.id, item_id: selectedItem);
      if (res['errorType'] == 1) {
        Navigator.pop(context);
      } else {
        message(message: res['message'], context: context);
      }
    }

    Future<void> changeBasketItem(int itemId, String type, int qty) async {
      // print(widget.detail['itemId']);
      // await basketProvider.checkItemQty(itemId, qty, context);

      dynamic check =
          await basketProvider.checkItemQty((widget.detail['qtyId']), qty);
      // await basketProvider.removeBasketItem(
      //     basket_id: basketProvider.basket.id, item_id: itemId);
      if (check['v'] == 0) {
        message(message: 'Бараа дууссан, сагснаас хасна уу!', context: context);
      } else if (check['v'] == 1) {
        dynamic res = await basketProvider.changeBasketItem(
            item_id: itemId, type: type, qty: qty);
        if (res['errorType'] == 1) {
          message(message: res['message'], context: context);
        } else {
          message(message: res['message'], context: context);
        }
      } else {
        message(message: 'Үлдэгдэл хүрэлцэхгүй байна!', context: context);
      }
      print(check['v'].toString());
      // dynamic res = await basketProvider.changeBasketItem(
      //     item_id: itemId, type: type, qty: qty);
      // if (res['errorType'] == 1) {
      //   message(message: res['message'], context: context);
      // } else {
      //   message(message: res['message'], context: context);
      // }
    }

    void showAlertDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Та устгахдаа итгэлтэй байна уу?',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Button(
                          text: 'Буцах',
                          width: 100,
                        ),
                        Button(
                          text: 'Устгах',
                          onTap: () => removeBasketItem(),
                          width: 100,
                          color: Colors.red,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              InkWell(
                  onTap: () {
                    selectedItem = widget.detail['id'];
                    showAlertDialog();
                  },
                  child: const MyIcon(name: 'trash.png')),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: shadow(),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text(
                        widget.detail['product_name'].toString(),
                        softWrap: true,
                        style: const TextStyle(
                            color: AppColors.cleanBlack,
                            fontSize: 14.0,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold),
                        maxLines: 3,
                      ),
                    ),
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(7)),
                        child: Row(
                          children: [
                            iconButton(
                              onTap: () {
                                selectedItem = widget.detail['id'];
                                changeBasketItem(widget.detail['id'], 'minus',
                                    widget.detail['qty']);
                              },
                              icon: Icons.remove,
                            ),
                            IntrinsicWidth(
                              child: EditableText(
                                  textAlign: TextAlign.center,
                                  onSubmitted: (v) {
                                    if (widget.detail['qty'] != int.parse(v)) {
                                      // selectedItem = widget.detail['id'];
                                      dynamic res = changeBasketItem(
                                          widget.detail['id'],
                                          'set',
                                          int.parse(v));
                                      if (res['errorType'] == 0) {}
                                    }
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  keyboardType: TextInputType.number,
                                  controller: TextEditingController(
                                      text: widget.detail['qty'].toString()),
                                  focusNode: focusNode,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                  cursorColor: AppColors.primary,
                                  backgroundCursorColor: Colors.black),
                            ),
                            iconButton(
                              onTap: () {
                                selectedItem = widget.detail['id'];
                                changeBasketItem(widget.detail['id'], 'add',
                                    widget.detail['qty']);
                                focusNode.unfocus();
                              },
                              icon: Icons.add,
                            )
                          ],
                        ))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      toPrice(widget.detail['main_price']),
                      style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      toPrice(
                          (widget.detail['qty'] * widget.detail['main_price'])
                              .toString()),
                      style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                (error == '')
                    ? const SizedBox()
                    : Align(
                        alignment: Alignment.center,
                        child: Text(
                          error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        )),
                // getErrorMessage(),
              ],
            ),
          ),
        );
      },
    );
  }

  iconButton({required Function() onTap, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2),
      child: InkWell(
        onTap: onTap,
        child: Icon(
          icon,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
