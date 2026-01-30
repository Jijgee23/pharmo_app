import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:pharmo_app/application/application.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    // Сошиал холбоосууд
    final List<Map<String, String>> socials = [
      // {
      //   'url': 'https://www.facebook.com/infosystems.mn',
      //   'icon':
      //       'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Facebook_Logo_2023.png/600px-Facebook_Logo_2023.png',
      // },
      {
        'url': 'https://www.youtube.com/',
        'icon':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/YouTube_full-color_icon_%282017%29.svg/1024px-YouTube_full-color_icon_%282017%29.svg.png',
      },
      {
        'url': 'https://x.com/',
        'icon':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/X_logo_2023.svg/600px-X_logo_2023.svg.png',
      },
    ];

    return DataScreen(
      loading: false,
      empty: false,
      appbar: const SideAppBar(text: 'Бидний тухай'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Компанийн лого болон танилцуулга
            _buildCompanyHeader(),
            const SizedBox(height: 24),

            // Үндсэн мэдээллийн картууд
            _buildInfoCard(
              'Үүсэл хөгжил',
              'Манай компани 1997 оноос эхлэн Мэдээллийн технологийн салбарт програм хангамжийн чиглэлээр ажиллаж зах зээлд өөрийн гэсэн байр сууриа эзэлж, тэргүүлэгч компаниудын нэг болсон.',
              Icons.history_edu,
            ),
            _buildInfoCard(
              'Зорилт',
              'Бид үйл ажиллагааны хүрээгээ өргөтгөн, хэрэглэгчиддээ чанартай, олон улсын түвшинд хүрсэн бүтээгдэхүүнээр хангахын тулд зорилтуудыг дэвшүүлэн ажиллаж байна.',
              Icons.rocket_launch_outlined,
            ),

            const SizedBox(height: 10),
            _buildSectionTitle('Холбоо барих'),

            // Холбоо барих хэсэг
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _contactTile(
                    Icons.call,
                    '70116399, 70126399, 91916549',
                    onTap: () => makePhoneCall('70116399'),
                  ),
                  _buildDivider(),
                  _contactTile(
                    Icons.email_outlined,
                    'contact@infosystems.mn',
                    onTap: () => sendEmail('contact@infosystems.mn'),
                  ),
                  _buildDivider(),
                  _contactTile(
                    Icons.location_on_outlined,
                    'Улаанбаатар, Чингэлтэй дүүрэг, 5-р хороо, Баянбогд плаза 402 тоот',
                    isLast: true,
                    onTap: () => _openMap(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Сошиал сувгууд
            _buildSectionTitle('Биднийг дагаарай'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children:
                  socials.map((social) => _buildSocialItem(social)).toList(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return Column(
      children: [
        // Container(
        //   height: 80,
        //   width: 80,
        //   padding: const EdgeInsets.all(12),
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     shape: BoxShape.circle,
        //     boxShadow: [
        //       BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        //     ],
        //   ),
        //   child: const FlutterLogo(
        //     size: 40,
        //   ), // Энд өөрийн логог Image.asset-аар солино уу
        // ),
        // const SizedBox(height: 16),
        const Text(
          'ИНФО-СИСТЕМС ХХК',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        const SizedBox(height: 4),
        Text(
          'Мэдээллийн технологийн салбарт 25+ жил',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primary, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
                color: Colors.grey.shade700, height: 1.5, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _contactTile(IconData icon, String text,
      {required VoidCallback onTap, bool isLast = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(16))
          : BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.grey.shade50, shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialItem(Map<String, String> social) {
    return InkWell(
      onTap: () => launchUrlString(social['url']!),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(social['icon']!),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildDivider() =>
      Divider(height: 1, indent: 60, color: Colors.grey.shade100);

  void _openMap(BuildContext context) {
    goto(Scaffold(
      appBar: const SideAppBar(text: 'Инфо-Системс ХХК'),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(47.92484953743797, 106.90244796842113),
          zoom: 16,
        ),
        markers: {
          const Marker(
            markerId: MarkerId('is'),
            position: LatLng(47.92484953743797, 106.90244796842113),
          )
        },
      ),
    ));
  }

  void makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}

void sendEmail(String email) async {
  final Uri emailUri = Uri(scheme: 'mailto', path: email);
  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  }
}
