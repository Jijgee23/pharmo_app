import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/DRIVER/index_driver.dart';
import 'package:pharmo_app/views/REPMAN/visits.dart';
import 'package:pharmo_app/views/SELLER/report/seller_report.dart';
import 'package:pharmo_app/views/profile/app_info.dart';
import 'package:pharmo_app/views/profile/menu_item_builder.dart';
import 'package:pharmo_app/views/profile/menu_section.dart';
import 'package:pharmo_app/views/profile/profile_header.dart';
import 'package:pharmo_app/views/promotion/promotion_screen.dart';
import 'package:pharmo_app/views/public/about_us.dart';
import 'package:pharmo_app/views/public/privacy_policy/privacy_policy.dart';
import 'package:pharmo_app/views/public/systme_log/system_log.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, AuthController>(
      builder: (context, homeProvider, auth, child) {
        final security = Authenticator.security;

        if (security == null) {
          return Material(
            child: Center(child: PharmoIndicator()),
          );
        }

        bool isPharma = security.isPharmacist;
        bool isDMan = security.isDriver;
        bool isRep = security.isRepresentative;
        bool isSaler = security.isSaler || isDMan;

        return Scaffold(
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
                  children: [
                    const SizedBox(height: 20),

                    // Account section
                    if (isSaler || isPharma || isRep)
                      MenuSection(
                        context: context,
                        title: 'Бүртгэл',
                        icon: Icons.account_circle_outlined,
                        children: [
                          if (isSaler)
                            MenuItemBuilder(
                              title: 'Тайлан',
                              icon: Icons.assessment_outlined,
                              color: Colors.pink,
                              onTap: () => goto(const SellerReportPage()),
                            ),
                          if (isPharma)
                            MenuItemBuilder(
                              title: 'Урамшуулал',
                              icon: Icons.local_offer_outlined,
                              color: Colors.blue,
                              onTap: () => goto(const PromotionWidget()),
                            ),
                          if (isDMan)
                            MenuItemBuilder(
                              title: 'Түгээгчрүү шилжих',
                              icon: Icons.swap_horiz_rounded,
                              color: Colors.orange,
                              onTap: () {
                                homeProvider.changeIndex(0);
                                if (homeProvider.currentIndex == 0) {
                                  gotoRemoveUntil(const IndexDriver());
                                }
                              },
                            ),
                          if (isRep)
                            MenuItemBuilder(
                              title: 'Уулзалтууд',
                              icon: Icons.meeting_room_outlined,
                              color: Colors.purple,
                              onTap: () => goto(Visits()),
                            ),
                          if (isSaler)
                            MenuItemBuilder(
                              title: 'Системийн лог',
                              icon: Icons.history_outlined,
                              color: Colors.teal,
                              onTap: () => goto(SystemLog()),
                            ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    // General section
                    MenuSection(
                      context: context,
                      title: 'Ерөнхий',
                      icon: Icons.settings_outlined,
                      children: [
                        MenuItemBuilder(
                          title: 'Нууцлалын бодлого',
                          icon: Icons.privacy_tip_outlined,
                          color: Colors.blue,
                          onTap: () => goto(const PrivacyPolicy()),
                        ),
                        MenuItemBuilder(
                          title: 'Бидний тухай',
                          icon: Icons.info_outline,
                          color: Colors.green,
                          onTap: () => goto(const AboutUs()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // General section
                    MenuSection(
                      context: context,
                      title: 'Тохиргоо',
                      icon: Icons.settings_outlined,
                      children: [
                        MenuItemBuilder(
                          title: 'Тохиргоо',
                          icon: Icons.settings,
                          color: Colors.blueGrey,
                          onTap: () => goto(const SettingsPage()),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // App info
                    AppInfo(),

                    const SizedBox(height: kTextTabBarHeight + 30),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void logout(BuildContext context) async {
  final ok = await confirmDialog(
    title: "Системээс гарах",
    message: "Системээс гарахдаа итгэлтэй байна уу?",
  );
  if (ok) {
    await context.read<AuthController>().logout(context);
  }
}
