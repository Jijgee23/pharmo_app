import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:pharmo_app/application/application.dart';

class TrackPermissionPage extends StatefulWidget {
  const TrackPermissionPage({super.key});

  @override
  State<TrackPermissionPage> createState() => _TrackPermissionPageState();
}

class _TrackPermissionPageState extends State<TrackPermissionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String get _platformText => Platform.isIOS ? 'Always' : 'Allow all the time';

  @override
  Widget build(BuildContext context) {
    final isSeller = Authenticator.security!.isSaler;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: isSeller
          ? AppBar(
              title: const Text('Байршлын тохиргоо'),
              elevation: 0,
            )
          : null,
      body: Consumer<JaggerProvider>(
        builder: (context, jagger, child) {
          final permission = jagger.permission;
          final isAlwaysAllowed = permission == LocationPermission.always;
          final isPrecise = jagger.accuracy == LocationAccuracyStatus.precise;
          final allGranted = isAlwaysAllowed && isPrecise;

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Header section
                      _buildHeader(),

                      const SizedBox(height: 32),

                      // Illustration
                      _buildIllustration(allGranted),

                      const SizedBox(height: 32),

                      // Why we need this
                      _buildWhySection(),

                      const SizedBox(height: 24),

                      // Permission cards
                      _buildPermissionCards(
                        isAlwaysAllowed: isAlwaysAllowed,
                        isPrecise: isPrecise,
                      ),

                      const SizedBox(height: 32),

                      // Instructions
                      _buildInstructions(),

                      const SizedBox(height: 32),

                      // Action button
                      _buildActionButton(jagger, allGranted),

                      const SizedBox(height: 16),

                      // Help text
                      if (!allGranted) _buildHelpText(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.location_on,
            size: 48,
            color: Colors.blue[700],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Байршлын зөвшөөрөл',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Хүргэлт, борлуулалтын үйл явцыг хянах',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration(bool allGranted) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: allGranted
              ? [Colors.green[400]!, Colors.green[600]!]
              : [Colors.orange[400]!, Colors.deepOrange[600]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (allGranted ? Colors.green : Colors.orange).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated circles
          ...List.generate(3, (index) {
            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 1500 + (index * 200)),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: 1 - value,
                  child: Container(
                    width: 100 + (value * 100 * (index + 1)),
                    height: 100 + (value * 100 * (index + 1)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Center icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(
              allGranted ? Icons.check : Icons.location_searching,
              size: 60,
              color: allGranted ? Colors.green[600] : Colors.orange[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Яагаад шаардлагатай вэ?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBulletPoint(
            'Хүргэлтийн явцыг бодит цагаар хянах',
            Icons.local_shipping,
          ),
          _buildBulletPoint(
            'Борлуулалтын үйл явцыг баталгаажуулах',
            Icons.verified,
          ),
          _buildBulletPoint(
            'Ажлын цагийн бүртгэл хөтлөх',
            Icons.access_time,
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCards({
    required bool isAlwaysAllowed,
    required bool isPrecise,
  }) {
    return Column(
      children: [
        _buildPermissionCard(
          title: 'Байршил үргэлж зөвшөөрөх',
          subtitle: Platform.isIOS
              ? 'Settings → Always эсвэл "Үргэлж" сонгох'
              : 'Тохиргоо → "Allow all the time" сонгох',
          icon: Icons.location_on,
          isGranted: isAlwaysAllowed,
          requiredText: _platformText,
        ),
        const SizedBox(height: 12),
        _buildPermissionCard(
          title: 'Нарийвчилсан байршил',
          subtitle: 'Precise/Exact location идэвхжүүлэх',
          icon: Icons.gps_fixed,
          isGranted: isPrecise,
          requiredText: 'Precise Location',
        ),
      ],
    );
  }

  Widget _buildPermissionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isGranted,
    required String requiredText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted ? Colors.green[300]! : Colors.orange[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isGranted ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isGranted ? Colors.green[700] : Colors.orange[700],
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    requiredText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Status icon
          Icon(
            isGranted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isGranted ? Colors.green[600] : Colors.grey[400],
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber[900]),
              const SizedBox(width: 8),
              Text(
                'Хэрхэн тохируулах вэ?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (Platform.isIOS) ...[
            _buildInstructionStep('1', 'Тохиргоо товч дарна'),
            _buildInstructionStep('2', 'Location → Always сонгох'),
            _buildInstructionStep('3', 'Precise Location ON хийх'),
          ] else ...[
            _buildInstructionStep('1', 'Тохиргоо товч дарна'),
            _buildInstructionStep('2', '"Allow all the time" сонгох'),
            _buildInstructionStep('3', 'Precise location зөвшөөрөх'),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.amber[700],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(JaggerProvider jagger, bool allGranted) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await Settings.checkAlwaysLocationPermission();
          await jagger.loadPermission();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: allGranted ? Colors.green[600] : Colors.blue[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor:
              (allGranted ? Colors.green : Colors.blue).withOpacity(0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              allGranted ? Icons.refresh : Icons.settings,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              allGranted ? 'Шинэчлэх' : 'Тохиргоо нээх',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.help_outline, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Тохиргоо хийсний дараа "Шинэчлэх" товч дарна уу',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
