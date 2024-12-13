// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/product/add_basket_sheet.dart';
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
    basketProvider.checkQTYs();
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
    await basketProvider.removeBasketItem(itemId: widget.detail['id']);
    await basketProvider.getBasket();
  }

  Future<void> changeBasketItem(int itemId, String type, int qty) async {
    dynamic check =
        await basketProvider.checkItemQty((widget.detail['qtyId']), qty);
    if (check['errorType'] == 0) {
      message('Бараа дууссан, сагснаас хасна уу!');
    } else if (check['errorType'] == 1) {
      dynamic res = await basketProvider.changeBasketItem(
          itemId: itemId, type: type, qty: qty);
      message(res['message']);
    } else {
      message('Үлдэгдэл хүрэлцэхгүй байна!');
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
        final theme = Theme.of(context);
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
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(5),
              // boxShadow: shadow(),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.primaryColor),
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
            child: InkWell(
              onTap: () => Get.bottomSheet(ChangeQtyPad(
                onSubmit: () => _changeQTy(basketProvider.qty.text),
                initValue: widget.detail['qty'].toString(),
              )),
              child: Text(
                widget.detail['qty'].toString(),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
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
        message('0 байж болохгүй!');
      } else {
        if (widget.detail['qty'] != int.parse(v)) {
          await changeBasketItem(widget.detail['id'], 'set', int.parse(v));
        } else {
          message('Тоон утга өөрчлөгдөөгүй!');
        }
      }
    } else {
      message('Тоон утга оруулна уу!');
    }
    Navigator.pop(context);
    await basketProvider.getBasket();
  }

  Widget _productInformation(double fs) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Дүн: ${toPrice(widget.detail['main_price'])}',
          style: TextStyle(fontSize: fs, color: theme.primaryColor),
        ),
        Text(
          'Нийт: ${toPrice((widget.detail['qty'] * widget.detail['main_price']).toString())}',
          style: TextStyle(fontSize: fs, color: theme.primaryColor),
        ),
      ],
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: theme.primaryColor),
      ),
    );
  }
}

class ChangeQtyPad extends StatefulWidget {
  final String initValue;
  final VoidCallback onSubmit;

  const ChangeQtyPad({
    super.key,
    required this.onSubmit,
    required this.initValue,
  });

  @override
  State<ChangeQtyPad> createState() => _ChangeQtyPadState();
}

class _ChangeQtyPadState extends State<ChangeQtyPad> {
  late BasketProvider basketProvider;
  @override
  void initState() {
    super.initState();
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((c) {
      basketProvider.setQTYvalue(widget.initValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BasketProvider>(
      builder: (context, basket, child) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 35, right: 35, bottom: 10),
              alignment: Alignment.centerRight,
              child: const PopSheet(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: TextFormField(
                controller: basket.qty,
                readOnly: true,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  if (index < 9) {
                    return _buildNumberButton((index + 1).toString());
                  } else if (index == 9) {
                    return _buildBackspaceButton();
                  } else if (index == 10) {
                    return _buildNumberButton('0');
                  } else {
                    return _buildSubmitButton();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return ElevatedButton(
      onPressed: () => basketProvider.write(number),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
      ),
      child: Text(
        number,
        style: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return ElevatedButton(
      onPressed: () => basketProvider.clear(),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: failedColor,
      ),
      child: const Icon(
        Icons.backspace,
        color: white,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: widget.onSubmit,
      style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
          backgroundColor: succesColor),
      child: const Icon(
        Icons.check,
        color: white,
      ),
    );
  }
}
