import 'package:pharmo_app/views/index.dart';
import 'package:pharmo_app/views/DRIVER/payment/add_payment.dart';
import 'package:pharmo_app/views/DRIVER/delivery_history/delivery_history.dart';
import 'package:pharmo_app/views/profile/app_info.dart';
import 'package:pharmo_app/views/profile/menu_item_builder.dart';
import 'package:pharmo_app/views/profile/menu_section.dart';
import 'package:pharmo_app/views/profile/profile.dart';
import 'package:pharmo_app/views/profile/profile_header.dart';
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
        backgroundColor: Colors.grey.shade50,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                background: ProfileHeader(),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: () => logout(context),
                    icon: const Icon(Icons.logout_rounded, color: white),
                    tooltip: 'Гарах',
                  ),
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Column(
                spacing: 20,
                children: [
                  SizedBox(),
                  MenuSection(
                    context: context,
                    title: 'Бүртгэл',
                    icon: Icons.account_circle_outlined,
                    children: [
                      MenuItemBuilder(
                        title: 'Түгээлтийн түүх',
                        icon: Icons.history,
                        color: darkBlue,
                        onTap: () => goto(const ShipmentHistory()),
                      ),
                      MenuItemBuilder(
                        title: 'Төлбөрийн жагсаалт',
                        icon: Icons.money,
                        color: Colors.green,
                        onTap: () => goto(const AddPayment()),
                      ),
                      MenuItemBuilder(
                        title: 'Борлуулагчруу шилжих',
                        icon: Icons.change_circle,
                        color: Colors.pink,
                        onTap: () {
                          home.changeIndex(0);
                          gotoRemoveUntil(const IndexPharma());
                        },
                      ),
                      MenuItemBuilder(
                        title: 'Системийн лог',
                        icon: Icons.pending_actions_sharp,
                        color: Colors.pink,
                        onTap: () => goto(SystemLog()),
                      ),

                      const SizedBox(height: 16),

                      // General section
                    ],
                  ),
                  MenuSection(
                    context: context,
                    title: 'Ерөнхий',
                    icon: Icons.settings_outlined,
                    children: [
                      MenuItemBuilder(
                          title: 'Нууцлалын бодлого',
                          icon: Icons.privacy_tip_outlined,
                          color: Colors.blue,
                          onTap: () => goto(const PrivacyPolicy())),
                      MenuItemBuilder(
                        title: 'Бидний тухай',
                        icon: Icons.info_outline,
                        color: Colors.green,
                        onTap: () => goto(const AboutUs()),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                  AppInfo(),
                  const SizedBox(height: kTextTabBarHeight + 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
