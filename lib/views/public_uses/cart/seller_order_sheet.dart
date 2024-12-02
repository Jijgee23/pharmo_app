
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
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

  // gotoBranch(BuildContext context) async {
  //   await basketProvider.checkQTYs();
  //   if (basketProvider.qtys.isNotEmpty) {
  //     message(
  //         message: 'Үлдэгдэл хүрэлцэхгүй барааны тоог өөрчилнө үү!',
  //         context: context);
  //   } else {
  //     if (basketProvider.basket.totalCount == 0) {
  //       message(message: 'Сагс хоосон байна!', context: context);
  //     } else if (double.parse(basketProvider.basket.totalPrice.toString()) <
  //         10) {
  //       message(
  //           message: 'Үнийн дүн 10₮-с бага байж болохгүй!', context: context);
  //     } else if (homeProvider.selectedCustomerId == 0) {
  //       message(message: 'Захиалагч сонгоно уу!', context: context);
  //       homeProvider.changeIndex(0);
  //     } else {
  //       goto(const SelectSellerBranchPage());
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Wrap(
        runSpacing: 15,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Заавал биш:'),
          ),
          CustomTextField(
            controller: noteController,
            hintText: 'Тайлбар',
            onChanged: (v) => homeProvider.setNote(v!),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Төлбөрийн хэлбэр сонгоно уу : '),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: .8),
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    myRadio('T', 'Дансаар'),
                    myRadio('C', 'Бэлнээр'),
                    myRadio('L', 'Зээлээр'),
                  ],
                ),
              ],
            ),
          ),
          CustomButton(
            text: 'Захиалах',
            ontap: () async {
              if (basketProvider.basket.totalCount == 0) {
                message(message: 'Сагс хоосон байна!', context: context);
              } else if (double.parse(
                      basketProvider.basket.totalPrice.toString()) <
                  10) {
                message(
                    message: 'Үнийн дүн 10₮-с бага байж болохгүй!',
                    context: context);
              } else if (homeProvider.selectedCustomerId == 0) {
                message(message: 'Захиалагч сонгоно уу!', context: context);
                homeProvider.changeIndex(0);
              } else {
                await basketProvider.checkQTYs();
                if (payType == '') {
                  message(
                      message: 'Төлбөрийн хэлбэр сонгоно уу!',
                      context: context);
                }
                //  else if (payType == 'T') {
                //   goto(const SellerQRCode());
                // }
                else {
                  homeProvider.createSellerOrder(context, payType);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget myRadio(String val, String title) {
    return Row(
      children: [
        Radio(
          value: val,
          groupValue: payType,
          onChanged: (String? value) {
            setPayType(value!);
          },
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12.0),
        )
      ],
    );
  }

  Widget info({required String title, required String text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
