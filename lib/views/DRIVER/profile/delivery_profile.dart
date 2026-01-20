import 'package:pharmo_app/views/index.dart';
import 'package:pharmo_app/views/DRIVER/payment/add_payment.dart';
import 'package:pharmo_app/views/DRIVER/delivery_history/shipment_history.dart';
import 'package:pharmo_app/views/profile.dart';
import 'package:pharmo_app/views/public/about_us.dart';
import 'package:pharmo_app/views/public/privacy_policy/privacy_policy.dart';
import 'package:pharmo_app/views/public/system_log.dart';
import 'package:pharmo_app/application/application.dart';

class DeliveryProfile extends StatelessWidget {
  const DeliveryProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, AuthController>(
      builder: (context, home, auth, child) => Scaffold(
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
                        child: const Text('Бүртгэл'),
                      ),
                      SideMenu(
                          title: 'Түгээлтийн түүх',
                          icon: Icons.history,
                          color: darkBlue,
                          ontap: () => goto(const ShipmentHistory())),
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
                        },
                      ),
                      SideMenu(
                        title: 'Системийн лог',
                        icon: Icons.pending_actions_sharp,
                        color: Colors.pink,
                        ontap: () => goto(SystemLog()),
                      ),
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
