// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/button.dart';
import 'package:pharmo_app/widgets/others/twoItemsRow.dart';
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
        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary.withOpacity(.5),
                width: 1,
              )),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.detail['product_name'].toString(),
                    style: TextStyle(
                        color: Colors.blueGrey.shade800,
                        fontSize: 16.0,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                  InkWell(
                    onTap: () {
                      selectedItem = widget.detail['id'];
                      showAlertDialog();
                    },
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Тоо ширхэг: ',
                          style: TextStyle(
                            color: Colors.blueGrey.shade800,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2.5, horizontal: 5),
                          width: 100,
                          child: EditableText(
                              onSubmitted: (v) {
                                if (widget.detail['qty'] != int.parse(v)) {
                                  selectedItem = widget.detail['id'];
                                  changeBasketItem(
                                      widget.detail['id'], 'set', int.parse(v));
                                }
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              keyboardType: TextInputType.number,
                              controller: TextEditingController(
                                  text: widget.detail['qty'].toString()),
                              focusNode: FocusNode(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                              cursorColor: Colors.red,
                              backgroundCursorColor: Colors.black),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            selectedItem = widget.detail['id'];
                            changeBasketItem(widget.detail['id'], 'minus',
                                widget.detail['qty']);
                          },
                          child: const Icon(
                            Icons.remove_circle_outline_sharp,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 20),
                        InkWell(
                          onTap: () {
                            selectedItem = widget.detail['id'];
                            changeBasketItem(widget.detail['id'], 'add',
                                widget.detail['qty']);
                          },
                          child: const Icon(
                            Icons.add_circle_outline_sharp,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              TwoitemsRow(
                  title: 'Үнэ:', text: '${widget.detail['main_price']} ₮'),
              TwoitemsRow(
                  title: 'Нийт үнэ:',
                  text:
                      '${widget.detail['qty'] * widget.detail['main_price']} ₮'),
            ],
          ),
        );
      },
    );
  }
}
