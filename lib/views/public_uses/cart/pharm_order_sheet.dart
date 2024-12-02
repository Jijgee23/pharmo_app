
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/others/my_radio.dart';
import 'package:provider/provider.dart';

class PharmOrderSheet extends StatefulWidget {
  const PharmOrderSheet({super.key});

  @override
  State<PharmOrderSheet> createState() => _PharmOrderSheetState();
}

class _PharmOrderSheetState extends State<PharmOrderSheet> {
  late HomeProvider homeProvider;
  late BasketProvider basketProvider;
  final noteController = TextEditingController();
  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
  }

  String deliveryType = '';
  String payType = '';
  int selectedBranchId = -1;
  setDeliverType(String v) {
    setState(() {
      deliveryType = v;
    });
  }

  setPayType(String v) {
    setState(() {
      payType = v;
    });
  }

  setBranch(String v, dynamic id) {
    setState(() {
      selectedBranch = v;
      selectedBranchId = id;
    });
  }

  String selectedBranch = 'Салбар сонгоно уу!';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Wrap(
        runSpacing: 15,
        children: [
          Container(
            decoration: bd,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MyRadio(
                  value: 'N',
                  groupValue: deliveryType,
                  title: 'Очиж авах',
                  onChanged: (v) => setDeliverType(v!),
                ),
                MyRadio(
                  value: 'D',
                  groupValue: deliveryType,
                  title: 'Хүргэлтээр',
                  onChanged: (v) => setDeliverType(v!),
                )
              ],
            ),
          ),
          (deliveryType == 'D')
              ? InkWell(
                  onTap: selectBranch,
                  child: Container(
                      decoration: bd,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedBranch),
                          const Icon(Icons.arrow_drop_down)
                        ],
                      )),
                )
              : const SizedBox(),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Заавал биш:'),
          ),
          CustomTextField(
            controller: noteController,
            hintText: 'Тайлбар',
            onChanged: (v) => homeProvider.setNote(v!),
          ),
          Container(
            decoration: bd,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MyRadio(
                  value: 'C',
                  groupValue: payType,
                  title: 'Бэлнээр',
                  onChanged: (v) => setPayType(v!),
                ),
                MyRadio(
                  value: 'L',
                  groupValue: payType,
                  title: 'Зээлээр',
                  onChanged: (v) => setPayType(v!),
                )
              ],
            ),
          ),
          CustomButton(text: 'Захиалах', ontap: () => order())
        ],
      ),
    );
  }

  selectBranch() {
    showMenu(
      color: Colors.white,
      context: context,
      position: const RelativeRect.fromLTRB(0, 500, 0, 0),
      items: homeProvider.branches
          .map(
            (e) => PopupMenuItem(
              onTap: () => setBranch(e.name!, e.id),
              child: Row(
                children: [
                  Text(e.name!),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  order() async {
    await basketProvider.checkQTYs();
    if (basketProvider.qtys.isNotEmpty) {
      message(
          message: 'Үлдэгдэл хүрэлцэхгүй барааны тоог өөрчилнө үү!',
          context: context);
    } else {
      createOrder();
    }
  }

  createOrder() async {
    await basketProvider.checkQTYs();
    if (deliveryType == '') {
      message(message: 'Хүргэлтийн хэлбэр сонгоно уу!', context: context);
    } else if (deliveryType == 'D') {
      if (selectedBranchId == -1) {
        message(message: 'Салбар сонгоно уу!', context: context);
      } else {
        if (payType == '') {
          message(message: 'Төлбөрийн хэлбэр сонгоно уу!', context: context);
        } else if (payType == 'C') {
          await basketProvider.createQR(
            basketId: basketProvider.basket.id,
            branchId: selectedBranchId,
            note: noteController.text,
            context: context,
          );
        } else if (payType == 'L') {
          await basketProvider.createOrder(
              basketId: basketProvider.basket.id,
              branchId: selectedBranchId,
              note: noteController.text,
              context: context);
        }
      }
    } else if (deliveryType == 'N') {
      if (payType == '') {
        message(message: 'Төлбөрийн хэлбэр сонгоно уу!', context: context);
      } else if (payType == 'C') {
        await basketProvider.createQR(
          basketId: basketProvider.basket.id,
          branchId: selectedBranchId,
          note: noteController.text,
          context: context,
        );
      } else if (payType == 'L') {
        await basketProvider.createOrder(
            basketId: basketProvider.basket.id,
            branchId: selectedBranchId,
            note: noteController.text,
            context: context);
      }
    }
  }

  var bd = BoxDecoration(
    border: Border.all(color: AppColors.primary, width: .8),
    borderRadius: BorderRadius.circular(5),
  );
}