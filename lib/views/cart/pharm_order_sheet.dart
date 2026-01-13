import 'package:flutter/material.dart';
import 'package:pharmo_app/controller/providers/basket_provider.dart';
import 'package:pharmo_app/controller/providers/home_provider.dart';
import 'package:pharmo_app/application/utilities/sizes.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
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
    if (homeProvider.branches.length == 1) {
      setBranch(homeProvider.branches[0].name!, homeProvider.branches[0].id);
    }
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

  List<String> payTypes = ['Бэлнээр', 'Дансаар', 'Зээлээр'];
  List<String> payS = ['C', 'T', 'L'];

  List<String> deliveryTypes = ['Очиж авах', 'Хүргэлтээр'];
  List<String> delS = ['N', 'D'];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final fs = height * 0.014;
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
        ...[
          InkWell(
            onTap:
                homeProvider.branches.length != 1 ? () => selectBranch() : null,
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
                  if (homeProvider.branches.length != 1)
                    Icon(Icons.arrow_drop_down)
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
    homeProvider.getBranches();
    showMenu(
      color: Colors.white,
      context: context,
      position: RelativeRect.fromLTRB(Sizes.width * .7, 500, 20, 0),
      items: homeProvider.branches
          .map(
            (e) => PopupMenuItem(
              onTap: () => setBranch(e.name!, e.id),
              child: Row(
                children: [
                  Text(e.name!, style: const TextStyle(color: Colors.black)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  order() async {
    // await basketProvider.checkQTYs();
    // if (basketProvider.qtys.isNotEmpty) {
    //   message(
    //     'Үлдэгдэл хүрэлцэхгүй барааны тоог өөрчилнө үү!',
    //   );
    // } else {
    createOrder();
    // }
  }

  createOrder() async {
    // await basketProvider.checkQTYs();
    if (deliveryType == '') {
      messageWarning('Хүргэлтийн хэлбэр сонгоно уу!');
      return;
    }
    if (deliveryType == 'D') {
      if (selectedBranchId == -1) {
        messageWarning('Салбар сонгоно уу!');
        return;
      }
      selectPayType();
    } else if (deliveryType == 'N') {
      selectPayType();
    }
  }

  selectPayType() async {
    if (payType == '') {
      messageWarning('Төлбөрийн хэлбэр сонгоно уу!');
      return;
    }
    if (payType == 'C') {
      await basketProvider.createQR(
        basketId: basketProvider.basket!.id,
        branchId: selectedBranchId,
        note: noteController.text,
        deliveryType: deliveryType,
        context: context,
      );
      return;
    }
    await basketProvider.createOrder(
      basketId: basketProvider.basket!.id,
      branchId: selectedBranchId,
      note: noteController.text,
      deliveryType: deliveryType,
      pt: payType,
      context: context,
    );
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
