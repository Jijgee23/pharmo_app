// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
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
  late int selectedItem = 0;
  bool checked = false;
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context, listen: true);
    Future<void> removeBasketItem() async {
      dynamic res = await basketProvider.removeBasketItem(
          basket_id: basketProvider.basket.id, item_id: selectedItem);
      if (res['errorType'] == 1) {
        Navigator.pop(context);
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    }

    Future<void> changeBasketItem(int itemId, String type, int qty) async {
      dynamic res = await basketProvider.changeBasketItem(
          item_id: itemId, type: type, qty: qty);
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
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 5)
                ]),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
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
                        style:const TextStyle(
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
                                      selectedItem = widget.detail['id'];
                                      changeBasketItem(widget.detail['id'],
                                          'set', int.parse(v));
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
                      '${widget.detail['main_price']} ₮',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${widget.detail['qty'] * widget.detail['main_price']} ₮',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  iconButton({required Function() onTap, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
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
