import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pharmo_app/views/auth/login.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Box box1;
  int page = 0;
  bool isSplashed = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((c) {
      _openBox();
    });
  }

  Future<void> _openBox() async {
    try {
      box1 = await Hive.openBox('auth');
      getLocalData();
    } catch (e) {
      debugPrint('Error opening Hive box: $e');
    }
  }

  void getLocalData() {
    if (box1.get('splash') != null) {
      Future.delayed(Duration.zero, () => goto(const LoginPage()));
      setState(() {
        isSplashed = box1.get('splash');
      });
    }
  }

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
                onPageChanged: (p) {
                  setPage(p);
                },
                allowImplicitScrolling: true,
                children: urls.map((u) => splash(u, urls.indexOf(u))).toList(),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () async {
                if (page == urls.length - 1) {
                  await box1.put('splash', true).whenComplete(() {
                    goto(const LoginPage());
                  });
                } else {
                  setPage(page + 1);
                  _pageController.nextPage(
                      duration: const Duration(seconds: 1),
                      curve: Curves.fastLinearToSlowEaseIn);
                }
              },
              splashColor: AppColors.primary.withOpacity(.5),
              highlightColor: AppColors.primary.withOpacity(.5),
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(50),
                    gradient: LinearGradient(colors: [
                      AppColors.primary.withOpacity(0.9),
                      AppColors.primary.withOpacity(0.6)
                    ])),
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.symmetric(horizontal: 20),
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
                      Icons.chevron_right,
                      color: Colors.white,
                    )
                  ],
                ),
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

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) => _indicator(index)),
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
            ? AppColors.primary.withOpacity(0.7)
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
                    color: AppColors.main.withOpacity(.7)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
