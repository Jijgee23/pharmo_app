import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/widgets/bottomSheet/mySheet.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
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
    final theme = Theme.of(context);
    return SheetContainer(
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
            onTap: () => selectBranch(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                border: Border.all(color: theme.primaryColor, width: 1.2),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
          children: [Text('Заавал биш:')],
        ),
        // Тайлбар
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            border: Border.all(color: theme.primaryColor, width: 1.2),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            style: TextStyle(fontSize: fs),
            onChanged: (v) => homeProvider.setNote(v),
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: 'Тайлбар',
            ),
          ),
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
          color: theme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ],
    );
  }

  selectBranch() async {
    await homeProvider.getBranches();
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
        'Үлдэгдэл хүрэлцэхгүй барааны тоог өөрчилнө үү!',
      );
    } else {
      createOrder();
    }
  }

  createOrder() async {
    await basketProvider.checkQTYs();
    if (deliveryType == '') {
      message(
        'Хүргэлтийн хэлбэр сонгоно уу!',
      );
    } else if (deliveryType == 'D') {
      if (selectedBranchId == -1) {
        message(
          'Салбар сонгоно уу!',
        );
      } else {
        if (payType == '') {
          message(
            'Төлбөрийн хэлбэр сонгоно уу!',
          );
        } else if (payType == 'C') {
          await basketProvider.createQR(
              basketId: basketProvider.basket.id,
              branchId: selectedBranchId,
              note: noteController.text,
              context: context);
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
        message(
          'Төлбөрийн хэлбэр сонгоно уу!',
        );
      } else if (payType == 'C') {
        await basketProvider.createQR(
            basketId: basketProvider.basket.id,
            branchId: selectedBranchId,
            note: noteController.text,
            context: context);
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
    final theme = Theme.of(context);
    double fontSize = Sizes.height * .012;
    return InkWell(
      onTap: ontap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? theme.primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: selected ? theme.primaryColor : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
