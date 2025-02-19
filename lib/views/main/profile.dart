import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/main/delivery_man/shipment_expense.dart';
import 'package:pharmo_app/views/main/delivery_man/shipment_history.dart';
import 'package:pharmo_app/views/main/pharmacy/my_orders/my_orders.dart';
import 'package:pharmo_app/views/main/pharmacy/promotion/promotion_screen.dart';
import 'package:pharmo_app/views/public_uses/notification/notification.dart';
import 'package:pharmo_app/views/public_uses/privacy_policy/privacy_policy.dart';
import 'package:pharmo_app/views/main/seller/seller_orders.dart';
import 'package:pharmo_app/views/main/seller/seller_report.dart';
import 'package:provider/provider.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, AuthController>(
      builder: (context, homeProvider, auth, child) {
        bool isPharma = homeProvider.userRole == "PA";
        bool isDMan = homeProvider.userRole == "D";
        String? companyName = auth.account.companyName!;
        return Scaffold(
          body: Container(
            // padding: const EdgeInsets.all(15),
            child: Center(
              child: Column(
                spacing: 15,
                children: [
                  Column(
                    spacing: 10,
                    children: [
                      const SizedBox(height: 0),
                      Container(
                        decoration: BoxDecoration(color: grey100, shape: BoxShape.circle),
                        padding: const EdgeInsets.all(5),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/icons/boy.png',
                            height: Sizes.height * 0.054,
                          ),
                        ),
                      ),
                      if (auth.account.name != null)
                        Text(
                          auth.account.name!,
                          style: TextStyle(
                            color: theme.primaryColor.withOpacity(.8),
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 20,
                        children: [
                          Text(
                            auth.account.email,
                            style: TextStyle(
                              color: grey500,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          if (companyName != null)
                            Text(
                              auth.account.companyName!,
                              style: TextStyle(
                                color: theme.primaryColor.withOpacity(.8),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(color: softGrey),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                child: const Text('Бүртгэл')),
                            // menu('Тохиргоо', Icons.settings, color: primary),
                            menu('Мэдэгдэл', Icons.notifications,
                                color: neonBlue, page: const NotificationPage()),
                            menu('Захиалгууд', Icons.lock_clock,
                                color: Colors.amber,
                                page: isPharma ? const MyOrder() : const SellerOrders()),
                            if (!isPharma)
                              menu('Тайлан', Icons.report,
                                  color: Colors.pink, page: const SellerReportPage()),
                            if (isPharma)
                              menu('Урамшуулал', Icons.local_offer,
                                  color: Colors.pink, page: const PromotionWidget()),
                            if (isDMan)
                              menu('Түгээлтийн түүх', Icons.history,
                                  color: darkBlue, page: const ShipmentHistory()),
                            if (isDMan)
                              menu('Түгээлтийн зарлага', Icons.account_balance_wallet,
                                  color: darkBlue, page: const ShipmentExpensePage()),
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                child: const Text('Ерөнхий')),
                            menu('Нууцлалын бодлого', Icons.lock,
                                color: Colors.blue, page: const PrivacyPolicy()),
                            menu('Системээс гарах', Icons.logout,
                                color: Colors.red, context: context),
                            const SizedBox(height: kTextTabBarHeight + 30)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  menu(String title, IconData icon, {Widget? page, Color? color, BuildContext? context}) {
    return InkWell(
      onTap: () {
        if (page != null) {
          goto(page);
        } else {
          logout(context!);
        }
      },
      child: Container(
        decoration: const BoxDecoration(),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 20,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: color != null ? color.withOpacity(.3) : grey100,
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(10),
                  child: Icon(icon, size: 24, color: color ?? black),
                ),
                Text(title, style: const TextStyle(fontSize: 16)),
              ],
            ),
            Icon(
              Icons.chevron_right,
              size: 30,
              color: theme.primaryColor.withOpacity(.5),
            )
          ],
        ),
      ),
    );
  }
}
// IconButton(
//       //   onPressed: () => homeProvider.toggleTheme(),
//       //   icon: Icon(
//       //     color: black,
//       //     homeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
//       //   ),
//       // ),

void logout(BuildContext context) {
  Get.dialog(
    Dialog(
      backgroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Системээс гарах',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Системээс гарахдаа итгэлтэй байна уу?',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Үгүй'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<AuthController>(context, listen: false).logout(context);
                      Provider.of<AuthController>(context, listen: false).toggleVisibile();
                      Provider.of<HomeProvider>(context, listen: false).changeIndex(0);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Тийм'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}
