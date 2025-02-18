import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:provider/provider.dart';

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
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextFormField(
                autofocus: true,
                textAlign: TextAlign.end,
                controller: qty,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                  fontSize: fs,
                ),
                decoration: InputDecoration(
                  hintText: 'Тоо ширхэг оруулна уу!',
                  contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          CustomButton(
            text: 'Сагсанд нэмэх',
            ontap: () async {
              if (qty.text.isNotEmpty && int.parse(qty.text) > 0) {
                await addBasket(widget.product, int.parse(qty.text))
                    .then((e) => Navigator.pop(context));
              } else if (qty.text.isEmpty) {
                message('Тоо ширхэг оруулна уу!');
              } else {
                message('Тоо ширхэг 0 байж болохгүй!');
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> addBasket(Product item, int qty) async {
    final basketProvider = Provider.of<BasketProvider>(context, listen: false);
    dynamic res = await basketProvider.addProduct(qty: qty, product: item);
    message(res['message']);
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
