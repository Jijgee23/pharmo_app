import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/application/application.dart';

class CartItem extends StatefulWidget {
  final Map<String, dynamic> detail;
  final String type;
  final bool hasCover;
  const CartItem({
    super.key,
    required this.detail,
    this.type = "cart",
    this.hasCover = true,
  });

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  Future<void> removeBasketItem() async {
    final basket = context.read<BasketProvider>();
    await basket.removeBasketItem(itemId: widget.detail['id']);
  }

  Future changeBasketItem(int itemId, double qty) async {
    try {
      LoadingService.show();
      final basket = context.read<BasketProvider>();
      await basket.addProduct(itemId, widget.detail['name'], qty);
    } catch (e) {
      messageError('Алдаа гарлаа: $e');
      throw Exception(e);
    } finally {
      LoadingService.hide();
    }
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
                flex: 1,
                onPressed: (context) => removeBasketItem(),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.red,
                icon: Icons.delete,
                label: 'Хасах',
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
          child: Card(
            color: white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade500, width: 1),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          widget.detail['name'].toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: fs * 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildQuantityEditor(fs),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _productInformation(fs),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ButtonStyle bstyle(bool isCircle) {
    return ElevatedButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: isCircle ? Size(32, 32) : Size(60, 32),
      shape: isCircle
          ? CircleBorder(
              side: BorderSide(color: Colors.grey.shade400, width: 1),
            )
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade400, width: 1),
            ),
      elevation: 0,
      backgroundColor: Colors.white,
    );
  }

  Widget _buildQuantityEditor(double fontSize) {
    final basket = context.read<BasketProvider>();
    return Row(
      children: [
        IconButton(
          style: bstyle(true),
          color: Colors.red,
          icon: Icon(
            Icons.remove,
            color: black,
          ),
          onPressed: () async {
            await changeBasketItem(widget.detail['product_id'],
                (parseDouble(widget.detail['qty'])) - 1);
          },
        ),
        SizedBox(
          child: ElevatedButton(
            onPressed: () => Get.bottomSheet(
              ChangeQtyPad(
                onSubmit: () => _changeQTy(basket.qty.text),
                initValue: widget.detail['qty'].toString(),
              ),
            ),
            style: bstyle(false),
            child: Text(
              widget.detail['qty'].toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: black,
              ),
            ),
          ),
        ),
        IconButton(
          style: bstyle(true),
          color: Colors.red,
          icon: Icon(
            Icons.add,
            color: black,
          ),
          onPressed: () {
            changeBasketItem(widget.detail['product_id'],
                parseInt(widget.detail['qty']) + 1);
          },
        ),
      ],
    );
  }

  _changeQTy(String v) async {
    if (v.isNotEmpty) {
      if (parseDouble(v) == 0) {
        messageWarning('0 байж болохгүй!');
        return;
      }
      if (widget.detail['qty'] != parseDouble(v)) {
        Navigator.pop(context);
        await changeBasketItem(widget.detail['product_id'], parseDouble(v));
        return;
      }
      messageWarning('Тоон утга өөрчлөгдөөгүй!');
    } else {
      messageWarning('Тоон утга оруулна уу!');
    }
  }

  Widget _productInformation(double fs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Дүн: ${toPrice(widget.detail['price'].toString())} ₮',
          style: TextStyle(
              fontSize: 12, color: black, fontWeight: FontWeight.bold),
        ),
        Text(
          'Нийт: ${toPrice((widget.detail['qty'] * widget.detail['price']).toString())}',
          style: TextStyle(
            fontSize: 12,
            color: black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class ChangeQtyPad extends StatefulWidget {
  final String? title;
  final String initValue;
  final VoidCallback onSubmit;

  const ChangeQtyPad({
    super.key,
    required this.onSubmit,
    required this.initValue,
    this.title,
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
      builder: (context, basket, child) => SheetContainer(
        children: [
          if (widget.title != null && widget.title!.isNotEmpty)
            Container(
              alignment: Alignment.center,
              child: Text(
                widget.title!,
                style: TextStyle(
                  fontSize: Sizes.mediumFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(.7),
                    width: 1.5),
                borderRadius: BorderRadius.circular(10)),
            child: TextFormField(
              controller: basket.qty,
              readOnly: true,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 16 / 12,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                childAspectRatio: 1.5,
              ),
              itemCount: 13,
              itemBuilder: (context, index) {
                if (index == 12) {
                  return _buildComma();
                }
                if (index < 9) {
                  return _buildNumberButton((index + 1).toString());
                } else if (index == 9) {
                  return _buildNumberButton('0');
                } else if (index == 10) {
                  return _buildBackspaceButton();
                } else {
                  return _buildSubmitButton();
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return _btn(
      onTap: () => basketProvider.write(number),
      color: Theme.of(context).primaryColor,
      child: Text(
        number,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return _btn(
      onTap: () => basketProvider.clear(),
      color: failedColor,
      child: const Icon(
        Icons.backspace,
        color: white,
      ),
    );
  }

  Widget _buildComma() {
    return _btn(
      onTap: () => basketProvider.write('.'),
      color: failedColor,
      child: Text(
        '.',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return _btn(
      onTap: widget.onSubmit,
      color: succesColor,
      child: const Icon(
        Icons.check,
        color: Colors.white,
      ),
    );
  }

  Widget _btn(
      {required Function() onTap,
      required Color color,
      required Widget child}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}

class LoadingService {
  static OverlayEntry? _entry;
  static Future<T> run<T>(Future<T> Function() runner) async {
    show();
    try {
      return await runner();
    } catch (e) {
      rethrow;
    } finally {
      hide();
    }
  }

  static void show() {
    if (_entry != null) return;
    final state = GlobalKeys.navigatorKey.currentState;
    if (state == null) return;
    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: const [
          ModalBarrier(dismissible: false, color: Colors.black38),
          Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ],
      ),
    );

    if (state.overlay == null) return;

    state.overlay!.insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}
