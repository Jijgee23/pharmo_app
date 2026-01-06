import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/adapters.dart';
import 'package:pharmo_app/application/services/a_services.dart';
import 'package:pharmo_app/application/utilities/sizes.dart';
import 'package:pharmo_app/views/auth/login/login.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/application/utilities/utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int page = 0;

  setPage(int newPage) {
    setState(() {
      page = newPage;
    });
  }

  final PageController _pageController = PageController();
  List<String> urls = [
    'assets/stickers/pharmacy.gif',
    'assets/stickers/delivery-truck.gif',
    'assets/stickers/bag.gif',
  ];
  List<String> texts = [
    'Эмийн бөөний захиалга, худалдаа',
    'Захиалгын хүргэлт',
    'Яг одоо захиалахад бэлэн үү'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                scrollDirection: Axis.horizontal,
                pageSnapping: true,
                onPageChanged: (p) => setPage(p),
                allowImplicitScrolling: true,
                children: urls.map((u) => splash(u, urls.indexOf(u))).toList(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (page == urls.length - 1) {
                  await LocalBase.saveSplashed(true).whenComplete(
                    () => goto(LoginPage()),
                  );
                  return;
                }
                setPage(page + 1);
                _pageController.nextPage(
                  duration: const Duration(seconds: 1),
                  curve: Curves.fastLinearToSlowEaseIn,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(10),
                backgroundColor: theme.primaryColor.withAlpha(225),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  Text(
                    (page == urls.length - 1) ? 'Эхлэх' : 'Дараагийн',
                    style: const TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 32,
                    color: Colors.white,
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  List.generate(urls.length, (index) => _indicator(index)),
            ),
          ],
        ),
      ),
    );
  }

  // Single indicator widget
  Widget _indicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: page == index ? 24 : 8,
      decoration: BoxDecoration(
        color: page == index
            ? theme.primaryColor.withAlpha(25 * 7)
            : Colors.grey.shade700,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget splash(String url, int idx) {
    final size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Image.asset(url, height: size.height * 0.3),
            Container(
              padding: const EdgeInsets.all(5),
              child: Text(
                texts[idx],
                maxLines: 10,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: size.height * 0.028,
                  // fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: AppColors.main.withAlpha(25 * 7),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
