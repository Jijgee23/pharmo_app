import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/views/cart/pharm_order_sheet.dart';
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

  List<String> payTypes = ['Дансаар', 'Бэлнээр', 'Зээлээр'];
  List<String> payS = ['T', 'C', 'L'];

  @override
  Widget build(BuildContext context) {
    return SheetContainer(
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
    );
  }

  _createOrder() async {
    if (basketProvider.basket.totalCount == 0) {
      message('Сагс хоосон байна!');
    } else if (double.parse(basketProvider.basket.totalPrice.toString()) < 10) {
      message('Үнийн дүн 10₮-с бага байж болохгүй!');
    } else if (homeProvider.selectedCustomerId == 0) {
      message('Захиалагч сонгоно уу!');
      homeProvider.changeIndex(0);
    } else {
      await basketProvider.checkQTYs();
      if (payType == '') {
        message('Төлбөрийн хэлбэр сонгоно уу!');
      } else {
        homeProvider.createSellerOrder(context, payType);
      }
    }
  }
}
