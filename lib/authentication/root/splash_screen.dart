import 'package:pharmo_app/application/application.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  late AnimationController _animationController;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/stickers/pharmacy.gif',
      title: 'Эмийн захиалга',
      subtitle: 'Хялбар, хурдан',
      description:
          'Эм ханган нийлүүлэх байгууллагаа сонгоод бүх төрлийн эмийг бөөний үнээр авах',
      color: Color(0xFF667eea),
      features: [
        Feature('1000+ бараа', Icons.inventory_2),
        Feature('Бөөний үнэ', Icons.price_check),
        Feature('Чанартай эм', Icons.verified),
      ],
    ),
    OnboardingPage(
      image: 'assets/stickers/delivery-truck.gif',
      title: 'Хүргэлт хяналт',
      subtitle: 'Бодит цагийн',
      description: 'Захиалгаа хаанаас ч хянаж, хүлээн авах боломжтой',
      color: Color(0xFF764ba2),
      features: [
        Feature('GPS хяналт', Icons.location_on),
        Feature('SMS мэдэгдэл', Icons.notifications_active),
        Feature('24/7 дэмжлэг', Icons.support_agent),
      ],
    ),
    OnboardingPage(
      image: 'assets/stickers/bag.gif',
      title: 'Эхлэхэд бэлэн',
      subtitle: 'Одоо эхлэе',
      description: 'Бизнесээ автоматжуулж, цаг хэмнээрэй',
      color: Color(0xFFf093fb),
      features: [
        Feature('Хялбар интерфэйс', Icons.touch_app),
        Feature('Түргэн суралцах', Icons.school),
        Feature('Найдвартай', Icons.security),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _pages[_currentPage].color,
                  _pages[_currentPage].color.withOpacity(0.6),
                  Colors.white,
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPageContent(_pages[index]);
                    },
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Progress indicator
          Row(
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: const EdgeInsets.only(right: 8),
                width: _currentPage == index ? 40 : 10,
                height: 4,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Skip button
          if (_currentPage < _pages.length - 1)
            TextButton(
              onPressed: () async {
                await Authenticator.saveSplashed(true);
                gotoRootPage();
              },
              child: Text(
                'Алгасах',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageContent(OnboardingPage page) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.05),

            // Title section with card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Subtitle badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: page.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      page.subtitle,
                      style: TextStyle(
                        color: page.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    page.title,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    page.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Features
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: page.features.map((feature) {
                      return _buildFeatureChip(feature, page.color);
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(Feature feature, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(feature.icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            feature.text,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final isLastPage = _currentPage == _pages.length - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back button
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                icon: Icon(Icons.arrow_back),
                label: Text('Буцах'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _pages[_currentPage].color,
                  side: BorderSide(
                    color: _pages[_currentPage].color,
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          if (_currentPage > 0) const SizedBox(width: 16),

          // Next/Start button
          Expanded(
            flex: _currentPage > 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: () async {
                if (isLastPage) {
                  await Authenticator.saveSplashed(true);
                  gotoRootPage();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _pages[_currentPage].color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
                shadowColor: _pages[_currentPage].color.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastPage ? 'Эхлэх' : 'Үргэлжлүүлэх',
                    softWrap: true,
                    style: TextStyle(
                      // fontSize: 18,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLastPage ? Icons.check_circle : Icons.arrow_forward,
                    // size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final List<Feature> features;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.features,
  });
}

class Feature {
  final String text;
  final IconData icon;

  Feature(this.text, this.icon);
}
