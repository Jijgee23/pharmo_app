import 'package:flutter/material.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/application/utilities/utils.dart';
import 'package:pharmo_app/controller/models/customer.dart';
import 'package:pharmo_app/controller/providers/basket_provider.dart';
import 'package:pharmo_app/controller/providers/home_provider.dart';
import 'package:pharmo_app/views/cart/pharm_order_sheet.dart';
import 'package:pharmo_app/views/delivery_man/widgets/choose_customer.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:provider/provider.dart';

class SellerOrderSheet extends StatefulWidget {
  const SellerOrderSheet({
    super.key,
  });

  @override
  State<SellerOrderSheet> createState() => _SellerOrderSheetState();
}

class _SellerOrderSheetState extends State<SellerOrderSheet> {
  late HomeProvider homeProvider;
  late BasketProvider basketProvider;
  final noteController = TextEditingController();
  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
  }

  String payType = '';
  setPayType(String v) {
    setState(() {
      payType = v;
    });
  }

  List<String> payTypes = ['Бэлнээр', 'Дансаар', 'Зээлээр'];
  List<String> payS = ['C', 'T', 'L'];

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, child) => SheetContainer(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Төлбөрийн хэлбэр сонгоно уу : '),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...payTypes.map((p) => MyChip(
                  title: p,
                  v: payS[payTypes.indexOf(p)],
                  selected: (payS[payTypes.indexOf(p)] == payType),
                  ontap: () => setPayType(payS[payTypes.indexOf(p)]))),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Заавал биш:')],
          ),
          Builder(builder: (context) {
            bool hasCustomer = home.customer != null;
            return ElevatedButton(
              onPressed: () async {
                Customer? value = await goto<Customer?>(ChooseCustomer());
                if (value != null) {
                  home.setCustomer(value);
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: hasCustomer ? primary : white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: hasCustomer ? transperant : Colors.grey.shade400,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 15,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hasCustomer ? home.customer!.name! : 'Захиалагч сонгох',
                    style: TextStyle(
                      color: hasCustomer ? white : null,
                    ),
                  ),
                  if (home.customer != null)
                    InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        home.setCustomer(null);
                        setState(() {});
                      },
                      child: Icon(
                        Icons.cancel,
                        color: white,
                        size: 26,
                      ),
                    )
                ],
              ),
            );
          }),
          CustomTextField(
            controller: noteController,
            hintText: 'Тайлбар',
            onChanged: (v) => homeProvider.setNote(v!),
          ),
          CustomButton(
            text: 'Захиалах',
            ontap: () => _createOrder(),
          ),
        ],
      ),
    );
  }

  Future _createOrder() async {
    if (payType == '') {
      message('Төлбөрийн хэлбэр сонгоно уу!');
      return;
    }

    if (basketProvider.basket!.totalCount == 0) {
      message('Сагс хоосон байна!');
      return;
    }
    if (double.parse(basketProvider.basket!.totalPrice.toString()) < 10) {
      message('Үнийн дүн 10₮-с бага байж болохгүй!');
      return;
    }
    if (context.read<HomeProvider>().customer == null) {
      message('Захиалагч сонгоно уу!');
      return;
    }
    await homeProvider.createSellerOrder(context, payType);
  }
}
