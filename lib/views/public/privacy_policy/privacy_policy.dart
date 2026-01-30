import 'package:pharmo_app/application/application.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const SideAppBar(text: 'Нууцлалын бодлого'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Толгой хэсэг
            _buildHeader(),
            const SizedBox(height: 20),

            // Бодлогын заалтууд
            _buildSection(
              title: '1. Танилцуулга',
              content:
                  'Энэхүү Нууцлалын бодлого нь Инфо-Системс ХХК-ийн удирддаг Pharmo.mn програмд ​​хамаарна. Энэ нь бид хэрэглэгчийн хувийн болон нууц мэдээллийг хэрхэн цуглуулж, ашиглаж, хуваалцдаг талаар тайлбарладаг. Бидний зорилго бол манай үйлчилгээнд нэвтрэхдээ ил тод байдал, хэрэглэгчийн нууцлалыг хангах явдал юм. Хэрэв танд асуух зүйл байвал pharmo2023@gmail.com хаягаар бидэнтэй холбогдоно уу.',
              icon: Icons.info_outline,
            ),
            _buildSection(
              title: '2. Бидний цуглуулдаг өгөгдөл',
              content:
                  'Pharmo.mn нь дараах төрлийн хувийн болон эмзэг хэрэглэгчийн мэдээллийг цуглуулдаг.\n\n• Хувийн мэдээлэл: Нэр, имэйл хаяг, утасны дугаар, хүргэх хаяг.\n• Дансны өгөгдөл: Имэйл хаяг, нууц үг (шифрлэгдсэн).\n• Захиалгын мэдээлэл: Захиалсан бүтээгдэхүүн, захиалгын түүх, сонголт.\n• Байршлын суурь өгөгдөл: Хэрэв та зөвшөөрөл өгвөл бид байршилд суурилсан үйлчилгээ, тухайлбал хүргэлтийг хянах, ойролцоох эмийн сангийн үйлчилгээг санал болгохын тулд байршлын мэдээллийг далд хэлбэрээр цуглуулдаг.',
              icon: Icons.storage_rounded,
            ),
            _buildSection(
              title: '3. Мэдээллийг хэрхэн ашиглах вэ?',
              content:
                  'Pharmo.mn цуглуулсан мэдээллийг дараах зорилгоор ашигладаг:\n\n• Захиалга боловсруулах, хүргэх.\n• Байршилд суурилсан үйлчилгээ үзүүлэх.\n• Аюулгүй байдлыг баталгаажуулах.\n• Тантай холбоо барих.\n\nБид таны хувийн мэдээллийг гуравдагч этгээдэд зарахгүй, хуваалцахгүй.',
              icon: Icons.settings_suggest_rounded,
            ),
            _buildSection(
              title: '4. Байршлын мэдээлэл цуглуулах',
              content:
                  'Pharmo систем нь түгээлтийн явцыг хянах зорилгоор байршлын мэдээллийг цуглуулдаг. Түгээлтийн ажилтны байршлыг апп нээлттэй (foreground) болон хаалттай (background) үед бодит цаг хугацаанд хянана. Түгээлт дууссаны дараа өгөгдөл дамжуулахгүй.',
              icon: Icons.location_on_outlined,
            ),
            _buildSection(
              title: '5. Мэдээлэл хадгалах, устгах',
              content:
                  'Та өөрийн өгөгдөлд хандах, залруулах болон устгах хүсэлт гаргах эрхтэй. Хүсэлтээ contact@infosystems.mn хаягаар ирүүлнэ үү.',
              icon: Icons.delete_outline_rounded,
            ),

            const SizedBox(height: 30),

            // Холбоо барих карт
            _buildContactCard(),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.shield_outlined, size: 60, color: primary),
          const SizedBox(height: 10),
          const Text(
            'Pharmo Нууцлалын Бодлого',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Сүүлд шинэчлэгдсэн: 2024.01.01',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title,
      required String content,
      required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: primary, size: 22),
        title: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.topLeft,
        shape: const Border(), // Заавал байх зураасыг арилгана
        children: [
          Text(
            content,
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade800, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Холбоо барих',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _contactItem(Icons.business, 'Инфо-Системс ХХК'),
          _contactItem(Icons.email_outlined, 'contact@infosystems.mn'),
          _contactItem(Icons.phone_android, '70116399, 91916549'),
        ],
      ),
    );
  }

  Widget _contactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
