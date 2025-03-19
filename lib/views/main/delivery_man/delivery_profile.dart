import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/index.dart';
import 'package:pharmo_app/views/main/delivery_man/add_payment.dart';
import 'package:pharmo_app/views/main/delivery_man/shipment_history.dart';
import 'package:pharmo_app/views/main/profile.dart';
import 'package:pharmo_app/views/public_uses/about_us.dart';
import 'package:pharmo_app/views/public_uses/privacy_policy/privacy_policy.dart';
import 'package:provider/provider.dart';

class DeliveryProfile extends StatelessWidget {
  const DeliveryProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, child) => Scaffold(
        body: Column(
          children: [
            const ProfileHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(color: softGrey),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          child: const Text('Бүртгэл')),
                      // menu('Тохиргоо', Icons.settings, color: primary),
                      // menu('Мэдэгдэл', Icons.notifications,
                      //     color: neonBlue, page: const NotificationPage()),
                      SideMenu(
                          title: 'Түгээлтийн түүх',
                          icon: Icons.history,
                          color: darkBlue,
                          ontap: () => goto(const ShipmentHistory())),
                      // SideMenu(
                      //   title: 'Түгээлтийн зарлага',
                      //   icon: Icons.account_balance_wallet,
                      //   color: neonBlue,
                      //   ontap: () => goto(const ShipmentExpensePage()),
                      // ),
                      SideMenu(
                          title: 'Төлбөрийн жагсаалт',
                          icon: Icons.money,
                          color: Colors.green,
                          ontap: () => goto(const AddPayment())),
                      SideMenu(
                          title: 'Борлуулагчруу шилжих',
                          icon: Icons.change_circle,
                          color: Colors.pink,
                          ontap: () {
                            home.changeIndex(0);
                            gotoRemoveUntil(const IndexPharma());
                          }),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          child: const Text('Ерөнхий')),
                      SideMenu(
                          title: 'Нууцлалын бодлого',
                          icon: Icons.lock,
                          color: Colors.blue,
                          ontap: () => goto(const PrivacyPolicy())),
                      SideMenu(
                          title: 'Бидний тухай',
                          icon: Icons.house,
                          color: Colors.purple,
                          ontap: () => goto(const AboutUs())),
                      SideMenu(
                        title: 'Системээс гарах',
                        icon: Icons.logout,
                        color: Colors.red,
                        ontap: () => logout(context),
                      ),
                      const SizedBox(height: kTextTabBarHeight + 30)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
