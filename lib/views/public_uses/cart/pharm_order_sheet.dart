import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/product/add_basket_sheet.dart';
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
  String selectedBranch = 'Салбар сонгоно уу!';

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

  List<String> payTypes = ['Дансаар', 'Бэлнээр', 'Зээлээр'];
  List<String> payS = ['T', 'C', 'L'];

  List<String> deliveryTypes = ['Очиж авах', 'Хүргэлтээр'];
  List<String> delS = ['N', 'D'];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final fs = height * 0.014;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Wrap(
        runSpacing: 20,
        children: [
          // Хүргэлтийн төрөл сонгох
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...deliveryTypes.map((dt) => MyChip(
                  title: dt,
                  v: delS[deliveryTypes.indexOf(dt)],
                  selected: (delS[deliveryTypes.indexOf(dt)] == deliveryType),
                  ontap: () => setDeliverType(delS[deliveryTypes.indexOf(dt)])))
            ],
          ),
          // Салбар сонгох
          if (deliveryType == 'D') ...[
            InkWell(
              onTap: selectBranch,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedBranch,
                      style: TextStyle(fontSize: fs),
                    ),
                    const Icon(Icons.arrow_drop_down)
                  ],
                ),
              ),
            ),
          ],
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Заавал биш:'), PopSheet()],
          ),
          // Тайлбар
          CustomTextField(
            controller: noteController,
            hintText: 'Тайлбар',
            onChanged: (v) => homeProvider.setNote(v!),
          ),
          // Төлбөрийн хэлбэр сонгох
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
          CustomButton(
            text: 'Захиалах',
            ontap: () => order(),
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
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
}

class MyChip extends StatelessWidget {
  final String title;
  final String v;
  final bool selected;
  final Function() ontap;
  const MyChip({
    super.key,
    required this.title,
    required this.v,
    required this.selected,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Text(title),
      ),
    );
  }
}
