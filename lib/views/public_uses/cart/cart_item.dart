// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:provider/provider.dart';

class CartItem extends StatefulWidget {
  final Map<String, dynamic> detail;
  final String type;
  final bool hasCover;
  const CartItem(
      {super.key,
      required this.detail,
      this.type = "cart",
      this.hasCover = true});

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  late BasketProvider basketProvider;
  @override
  void initState() {
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    // basketProvider.checkQTYs(context);
    checkErrorMessage();
    super.initState();
  }

  late int selectedItem = 0;
  bool checked = false;
  String error = '';
  final FocusNode focusNode = FocusNode();

  void checkErrorMessage() {
    final qtyId = widget.detail['qtyId'].toString();
    final foundError = basketProvider.qtys.any((item) => item.id == qtyId);
    if (foundError) {
      setState(() {
        error = 'Барааны үлдэгдэл хүрэлцэхгүй!';
      });
    }
  }

  Future<void> removeBasketItem() async {
    dynamic res = await basketProvider.removeBasketItem(
        basketId: basketProvider.basket.id, itemId: selectedItem);
    if (res['errorType'] == 1) {
    } else {
      message(message: res['message'], context: context);
    }
  }

  Future<void> changeBasketItem(int itemId, String type, int qty) async {
    dynamic check =
        await basketProvider.checkItemQty((widget.detail['qtyId']), qty);
    if (check['errorType'] == 0) {
      message(message: 'Бараа дууссан, сагснаас хасна уу!', context: context);
    } else if (check['errorType'] == 1) {
      dynamic res = await basketProvider.changeBasketItem(
          itemId: itemId, type: type, qty: qty);
      message(message: res['message'], context: context);
    } else {
      message(message: 'Үлдэгдэл хүрэлцэхгүй байна!', context: context);
    }
    await basketProvider.getBasket();
    print(check['errorType'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final height = MediaQuery.of(context).size.height;
        final fs = height * .013;
        return Slidable(
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                onPressed: (context) => removeBasketItem(),
                backgroundColor: Colors.red.withOpacity(0.8),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Хасах',
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: shadow(),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            margin: const EdgeInsets.only(bottom: 7.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        widget.detail['product_name'].toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fs * 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildQuantityEditor(fs)
                  ],
                ),
                const SizedBox(height: 8),
                _productInformation(fs),
                (error == '')
                    ? const SizedBox()
                    : Align(
                        alignment: Alignment.center,
                        child: Text(
                          error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuantityEditor(double fontSize) {
    final TextEditingController controller =
        TextEditingController(text: widget.detail['qty'].toString());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _iconButton(
            icon: Icons.remove,
            onTap: () {
              selectedItem = widget.detail['id'];
              changeBasketItem(
                  widget.detail['id'], 'minus', widget.detail['qty']);
            },
          ),
          SizedBox(
            width: 40,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              style: TextStyle(fontSize: fontSize),
              onSubmitted: (v) => _changeQTy(v),
            ),
          ),
          _iconButton(
            icon: Icons.add,
            onTap: () {
              selectedItem = widget.detail['id'];
              changeBasketItem(
                  widget.detail['id'], 'add', widget.detail['qty']);
              focusNode.unfocus();
            },
          ),
        ],
      ),
    );
  }

  _changeQTy(String v) async {
    if (v.isNotEmpty) {
      if (int.parse(v) == 0) {
        message(message: '0 байж болохгүй!', context: context);
      } else {
        if (widget.detail['qty'] != int.parse(v)) {
          dynamic res =
              changeBasketItem(widget.detail['id'], 'set', int.parse(v));
          if (res['errorType'] == 0) {}
        } else {
          message(message: 'Тоон утга өөрчлөгдөөгүй!', context: context);
        }
      }
    } else {
      message(message: 'Тоон утга оруулна уу!', context: context);
    }
    await basketProvider.getBasket();
  }

  Widget _productInformation(double fs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Дүн: ${toPrice(widget.detail['main_price'])}',
          style: TextStyle(fontSize: fs, color: AppColors.primary),
        ),
        Text(
          'Нийт: ${toPrice((widget.detail['qty'] * widget.detail['main_price']).toString())}',
          style: TextStyle(fontSize: fs, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}
