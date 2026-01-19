import 'package:pharmo_app/controller/a_controlller.dart';
import 'package:pharmo_app/application/services/local_base.dart';
import 'package:pharmo_app/views/delivery_man/index_delivery_man.dart';
import 'package:pharmo_app/views/pharmacy/my_orders/my_orders.dart';
import 'package:pharmo_app/views/pharmacy/promotion/promotion_screen.dart';
import 'package:pharmo_app/views/rep_man/visits.dart';
import 'package:pharmo_app/views/public/about_us.dart';
import 'package:pharmo_app/views/public/privacy_policy/privacy_policy.dart';
import 'package:pharmo_app/views/seller/order/seller_orders.dart';
import 'package:pharmo_app/views/seller/report/seller_report.dart';
import 'package:pharmo_app/views/public/system_log.dart';
import 'package:pharmo_app/widgets/indicator/pharmo_indicator.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, AuthController>(
      builder: (context, homeProvider, auth, child) {
        final Security? security = LocalBase.security;
        if (security == null) {
          return Material(
            child: Center(child: PharmoIndicator()),
          );
        }
        bool isPharma = security.role == "PA";
        bool isDMan = security.role == "D";
        bool isRep = security.role == 'R';
        bool isSeller = security.role == 'S' || isDMan;
        return Scaffold(
          body: Center(
            child: Column(
              spacing: 15,
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
                          if (isSeller || isPharma)
                            SideMenu(
                              title: isPharma
                                  ? 'Захиалгууд'
                                  : 'Борлуулалтын захиалгууд',
                              icon: Icons.lock_clock,
                              ontap: () => goto(isPharma
                                  ? const MyOrder()
                                  : const SellerOrders()),
                              color: Colors.amber,
                            ),
                          if (isSeller)
                            SideMenu(
                              title: 'Тайлан',
                              icon: Icons.report,
                              ontap: () => goto(const SellerReportPage()),
                              color: Colors.pink,
                            ),
                          if (isPharma)
                            SideMenu(
                              title: 'Урамшуулал',
                              icon: Icons.local_offer,
                              ontap: () => goto(const PromotionWidget()),
                              color: Colors.blue,
                            ),
                          if (isDMan)
                            SideMenu(
                              title: 'Түгээгчрүү шилжих',
                              icon: Icons.change_circle,
                              color: Colors.pink,
                              ontap: () {
                                homeProvider.changeIndex(0);
                                if (homeProvider.currentIndex == 0) {
                                  gotoRemoveUntil(const IndexDeliveryMan());
                                }
                              },
                            ),
                          if (isRep)
                            SideMenu(
                              title: 'Уулзалтууд',
                              icon: Icons.meeting_room,
                              color: Colors.pink,
                              ontap: () => goto(Visits()),
                            ),
                          if (isSeller)
                            SideMenu(
                              title: 'Системийн лог',
                              icon: Icons.pending_actions_sharp,
                              color: Colors.pink,
                              ontap: () => goto(SystemLog()),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            child: const Text('Ерөнхий'),
                          ),
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
      },
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final Security? security = LocalBase.security;
    if (security == null) {
      return Material(
        child: Center(child: PharmoIndicator()),
      );
    }
    return Consumer<AuthController>(
      builder: (context, auth, child) => Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
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
            if (security.name != 'null')
              Text(
                security.name,
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
                  security.email,
                  style: TextStyle(
                    color: grey500,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  security.companyName,
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
      ),
    );
  }
}

class SideMenu extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;
  final Function() ontap;

  const SideMenu(
      {super.key,
      required this.title,
      required this.icon,
      this.color,
      required this.ontap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      splashColor: Colors.black12,
      highlightColor: Colors.black12,
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
                      color: color != null ? color!.withOpacity(.3) : grey100,
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

Widget menu(String title, IconData icon,
    {required Function() ontap, Color? color}) {
  return InkWell(
    onTap: ontap,
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
                    onPressed: () => context.read<AuthController>().logout(),
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
