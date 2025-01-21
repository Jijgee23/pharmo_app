import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/delivery_man/tabs/home/jagger_home.dart';
import 'package:pharmo_app/views/delivery_man/drawer_menus/shipment_history/shipment_history.dart';
import 'package:pharmo_app/views/index.dart';
import 'package:pharmo_app/widgets/appbar/dm_app_bar.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/drawer/drawer_item.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/inputs/ibtn.dart';
import 'package:provider/provider.dart';

import '../../widgets/bottom_bar/bottom_bar.dart';
import '../../widgets/drawer/my_drawer.dart';
import 'tabs/expend/shipment_expense.dart';

class IndexDeliveryMan extends StatefulWidget {
  const IndexDeliveryMan({super.key});

  @override
  State<IndexDeliveryMan> createState() => _IndexDeliveryManState();
}

class _IndexDeliveryManState extends State<IndexDeliveryMan> {
  final List _pages = [
    const HomeJagger(),
    const ShipmentExpensePage(),
  ];
  late HomeProvider homeProvider;
  late JaggerProvider jaggerProvider;

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    jaggerProvider = Provider.of<JaggerProvider>(context, listen: false);
    homeProvider.getUserInfo();
    jaggerProvider.fetchJaggers();
    homeProvider.getPosition();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(
            create: (context) => AuthController())
      ],
      child: Consumer2<AuthController, HomeProvider>(
        builder: (context, authController, home, _) {
          return Scaffold(
            extendBody: true,
            drawer: MyDrawer(
              drawers: [
                DrawerItem(
                  title: 'Түгээлтийн түүх',
                  asset: 'assets/icons_2/time-past.png',
                  onTap: () => goto(const ShipmentHistory()),
                ),
                DrawerItem(
                  title: 'Борлуулагчруу шилжих',
                  asset: 'assets/icons_2/swap.png',
                  onTap: () {
                    homeProvider.changeIndex(0);
                    gotoRemoveUntil(const IndexPharma());
                  },
                ),
              ],
            ),
            appBar: DMAppBar(
              title: (homeProvider.currentIndex == 0)
                  ? 'Өнөөдрийн түгээлтүүд'
                  : 'Зарлагууд',
              actions: [getAction()],
            ),
            body: _pages[home.currentIndex],
            bottomNavigationBar: BottomBar(icons: icons, labels: labels),
          );
        },
      ),
    );
  }

  List<String> icons = ['truck-side', 'time-past'];
  List<String> labels = ['Түгээлт', 'Зарлагууд'];
  Widget getAction() {
    if (homeProvider.currentIndex == 0) {
      return const SizedBox();
    } else if (homeProvider.currentIndex == 1) {
      return Ibtn(
        onTap: () => addExpense(),
        icon: Icons.add,
        color: Theme.of(context).primaryColor,
      );
    }
    return const SizedBox();
  }

  final TextEditingController amount = TextEditingController();
  final TextEditingController note = TextEditingController();

  addExpense() {
    mySheet(
      title: 'Түгээлтийн зарлага нэмэх',
      children: [
        CustomTextField(controller: note, hintText: 'Тайлбар'),
        CustomTextField(controller: amount, hintText: 'Дүн'),
        CustomButton(text: 'Бүртгэх', ontap: () => addExpenseAmount()),
      ],
    );
  }

  addExpenseAmount() {
    Future(() async {
      dynamic res =
          await jaggerProvider.addExpense(note.text, amount.text, context);
      print(res['errorType']);
      message(res['message']);
    }).whenComplete(() async {
      await jaggerProvider.getExpenses();
      amount.clear();
      note.clear();
      Navigator.pop(context);
    });
  }
}
