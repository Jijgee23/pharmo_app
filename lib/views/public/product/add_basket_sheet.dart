import 'package:pharmo_app/controller/providers/a_controlller.dart';
import 'package:pharmo_app/controller/models/products.dart';
import 'package:pharmo_app/views/cart/cart_item.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';

class AddBasketSheet extends StatefulWidget {
  final Product product;
  const AddBasketSheet({super.key, required this.product});

  @override
  State<AddBasketSheet> createState() => _AddBasketSheetState();
}

class _AddBasketSheetState extends State<AddBasketSheet> {
  late TextEditingController qty;

  @override
  void initState() {
    super.initState();
    qty = TextEditingController();
  }

  @override
  void dispose() {
    qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final fs = height * .013;
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Wrap(
        runSpacing: 20,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Text(
                    '${widget.product.name!} /${toPrice(widget.product.price)}/',
                    softWrap: true,
                    maxLines: 3,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontSize: fs,
                    ),
                  ),
                ),
              ),
              const PopSheet()
            ],
          ),
          TextFormField(
            autofocus: true,
            textAlign: TextAlign.end,
            controller: qty,
            keyboardType: TextInputType.numberWithOptions(
              decimal: true,
            ),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
              fontSize: fs,
            ),
            decoration: InputDecoration(
              hintText: 'Тоо ширхэг оруулна уу!',
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: primary.withOpacity(.5))),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: primary.withOpacity(.5))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: primary.withOpacity(.5))),
            ),
          ),
          CustomButton(
            text: 'Сагсанд нэмэх',
            ontap: () async {
              if (qty.text.isEmpty) {
                messageWarning('Тоо ширхэг оруулна уу!');
                return;
              }

              if (parseDouble(qty.text) == 0) {
                messageWarning('Тоо ширхэг 0 байж болохгүй!');
                return;
              }

              if (qty.text.isNotEmpty && parseDouble(qty.text) > 0) {
                Navigator.pop(context);
                await addBasket(widget.product, parseDouble(qty.text));
                return;
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> addBasket(Product item, double qty) async {
    try {
      LoadingService.show();
      final basketProvider = context.read<BasketProvider>();
      await basketProvider.addProduct(item.id, item.name ?? 'Бараа', qty);
    } catch (e) {
      throw Exception(e);
    } finally {
      LoadingService.hide();
    }
  }
}

class PopSheet extends StatelessWidget {
  const PopSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: Get.back,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade700,
            ),
            borderRadius: BorderRadius.circular(50)),
        child: Image.asset(
          'assets/cross-small.png',
          height: 16,
          color: Colors.black.withOpacity(.5),
        ),
      ),
    );
  }
}
