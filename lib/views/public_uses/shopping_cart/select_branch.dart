import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/models/sector.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/button.dart';
import 'package:provider/provider.dart';

class SelectBranchPage extends StatefulWidget {
  const SelectBranchPage({super.key});
  @override
  State<SelectBranchPage> createState() => _SelectBranchPageState();
}

class _SelectBranchPageState extends State<SelectBranchPage> {
  String _selectedRadioValue = 'C';
  int _selectedIndex = -1;
  int _selectedAddress = 0;
  bool delivery = false;
  final radioColor = const WidgetStatePropertyAll(AppColors.primary);
  late HomeProvider homeProvider;
  late BasketProvider basketProvider;

  @override
  void initState() {
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    super.initState();
  }

  createOrder() async {
    debugPrint(_selectedRadioValue);
    if (_selectedRadioValue == 'C') {
      if (_selectedAddress == 0 && delivery == true) {
        message(message: 'Салбар сонгоно уу!', context: context);
      } else {
        await basketProvider.createOrder(
            basket_id: basketProvider.basket.id,
            branch_id: _selectedAddress,
            note: '',
            context: context);
      }
    } else {
      if (_selectedAddress == 0 && delivery == true) {
        message(message: 'Салбар сонгоно уу!', context: context);
      } else {
        await basketProvider.createQR(
          basket_id: basketProvider.basket.id,
          branch_id: _selectedAddress,
          note: '',
          context: context,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var bd = BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey),
    );
    return Consumer<HomeProvider>(
      builder: (context, home, child) => Scaffold(
        appBar: const CustomAppBar(
            title: Text('Захиалга үүсгэх', style: TextStyle(fontSize: 14))),
        body: ChangeNotifierProvider(
          create: (context) => BasketProvider(),
          child: Container(
            margin: const EdgeInsets.all(15),
            child: Column(children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          button(
                              'Хүргэлтээр',
                              () => setState(() {
                                    delivery = true;
                                  }),
                              delivery == true
                                  ? AppColors.primary
                                  : Colors.grey,
                              delivery == true ? Colors.white : Colors.black),
                          button(
                              'Очиж авах',
                              () => setState(() {
                                    delivery = false;
                                    _selectedIndex = -1;
                                    _selectedAddress = 0;
                                  }),
                              delivery == false
                                  ? AppColors.primary
                                  : Colors.grey,
                              delivery == true ? Colors.black : Colors.white)
                        ],
                      ),
                      !delivery
                          ? Container()
                          : Expanded(
                              child: Column(
                                children: [
                                  Container(
                                      margin: const EdgeInsets.only(bottom: 5),
                                      child: const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text('Салбар сонгоно уу : '))),
                                  Expanded(
                                    child: ListView.builder(
                                        itemCount: home.branches.length,
                                        itemBuilder: (context, index) {
                                          final branch = home.branches[index];
                                          return Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 5),
                                            decoration: bd,
                                            child: BranchWidget(
                                              isSelected:
                                                  _selectedIndex == index,
                                              branch: branch,
                                              onTap: () {
                                                setState(() {
                                                  _selectedIndex = index;
                                                  _selectedAddress =
                                                      home.branches[index].id;
                                                });
                                              },
                                            ),
                                          );
                                        }),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: bd,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Column(children: [
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Төлбөрийн хэлбэр сонгоно уу : ')),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: 'L',
                        fillColor: radioColor,
                        groupValue: _selectedRadioValue,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedRadioValue = value!;
                          });
                        },
                      ),
                      const Text(
                        'Бэлнээр',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Radio(
                        value: 'C',
                        fillColor: radioColor,
                        groupValue: _selectedRadioValue,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedRadioValue = value!;
                          });
                        },
                      ),
                      const Text(
                        'Зээлээр',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ]),
              ),
              const SizedBox(height: 5),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Button(
                    text: 'Захиалга үүсгэх',
                    onTap: () => createOrder(),
                    color: AppColors.primary),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  InkWell button(
      String text, GestureTapCallback? onTap, Color color, Color textColor) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: color),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class BranchWidget extends StatefulWidget {
  final bool isSelected;
  final Sector branch;
  final GestureTapCallback onTap;

  const BranchWidget(
      {super.key,
      required this.isSelected,
      required this.branch,
      required this.onTap});

  @override
  State<BranchWidget> createState() => _BranchWidgetState();
}

class _BranchWidgetState extends State<BranchWidget> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.home_filled,
                        color: widget.isSelected == true
                            ? AppColors.secondary
                            : AppColors.primary),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        Text(
                          widget.branch.name!,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: widget.isSelected == true
                                  ? AppColors.secondary
                                  : AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => setState(() {
                    isExpanded = !isExpanded;
                  }),
                  child: const Icon(Icons.arrow_drop_down),
                )
              ],
            ),
            (isExpanded == true && widget.branch.address != null)
                ? Center(
                    child: Text(
                      widget.branch.address!['address'].toString(),
                      style: const TextStyle(
                        color: AppColors.main,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
