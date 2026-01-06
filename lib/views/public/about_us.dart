import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/application/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    // String logoUrl =
    //     'https://infosystems.mn/api/uploads/white_logo_cae13554c4.png';
    List<String> socialUrls = [
      'https://img.freepik.com/premium-vector/art-illustration_929495-41.jpg?semt=ais_hybrid',
      'https://img.freepik.com/premium-vector/red-youtube-logo-social-media-logo_197792-1803.jpg?semt=ais_hybrid',
      'https://static.vecteezy.com/system/resources/previews/006/057/998/non_2x/twitter-logo-on-transparent-background-free-vector.jpg',
    ];
    List<String> urls = [
      'https://www.facebook.com/infosystems.mn',
      'https://www.youtube.com/',
      'https://x.com/'
    ];

    return DataScreen(
      loading: false,
      empty: false,
      appbar: SideAppBar(text: 'Бидний тухай'),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          spacing: 10,
          children: [
            // Container(
            //   height: 100,
            //   padding: EdgeInsets.symmetric(horizontal: 10),
            //   decoration: BoxDecoration(
            //       // color: Colors.black87,
            //       borderRadius: BorderRadius.circular(10)),
            //   child: Image.network(logoUrl, fit: BoxFit.cover),
            // ),
            div('Үүсэл хөгжил',
                'Манай компани 1997 оноос эхлэн Мэдээллийн технологийн салбарт програм хангамжийн чиглэлээр ажиллаж зах зээлд өөрийн гэсэн байр сууриа эзэлж, тэргүүлэгч компаниудын нэг болсон.'),
            div('Зорилт',
                'Цаашид Монголын мэдээллийн технологи хөгжиж, өдөр тутмын хэрэглээ болохын хирээр програм хангамжийн хэрэгцээ нэмэгдэх нь зайлшгүй юм. Ийм учраас бид үйл ажиллагааны хүрээгээ өргөтгөн, хэрэглэгчиддээ чанартай, олон улсын түвшинд хүрсэн бүтээгдэхүүнээр хангахын тулд дараах зорилтуудыг дэвшүүлэн ажиллах байна.'),
            contact(Icons.call, '70116399, 70126399, 91916549',
                ontap: () => makePhoneCall('70116399')),
            contact(
              Icons.location_city,
              'Улаанбаатар хот Чингэлтэй дүүрэг 5-р хороо Баянбогд плаза 402 тоот',
              ontap: () => goto(Scaffold(
                appBar: SideAppBar(text: 'Инфо-Системс ХХК'),
                body: GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: LatLng(47.92484953743797, 106.90244796842113),
                      zoom: 14),
                  markers: {
                    Marker(
                      markerId: MarkerId('is'),
                      position: LatLng(47.92484953743797, 106.90244796842113),
                      icon: BitmapDescriptor.defaultMarker,
                    )
                  },
                ),
              )),
            ),
            contact(
              Icons.email,
              'contact@infosystems.mn',
              ontap: () => sendEmail('contact@infosystems.mn'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ...socialUrls.map(
                  (url) => InkWell(
                    onTap: () => launchUrlString(urls[socialUrls.indexOf(url)]),
                    child: SizedBox(
                      height: 50,
                      child: CircleAvatar(backgroundImage: NetworkImage(url)),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  contact(IconData icon, String text, {Function()? ontap}) {
    return InkWell(
      onTap: ontap ?? () {},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          spacing: 10,
          children: [
            Icon(icon),
            Expanded(flex: 4, child: Text(text)),
          ],
        ),
      ),
    );
  }

  div(String title, String text) {
    var side = Expanded(child: Container(color: neonBlue, height: 1));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 10,
          children: [
            side,
            Align(
              alignment: Alignment.center,
              child: Text(
                title,
                textAlign: TextAlign.end,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            side,
          ],
        ),
        Text(
          text,
          style: TextStyle(color: grey600),
        )
      ],
    );
  }

  void makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }
}

void sendEmail(String email) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
    queryParameters: {
      'subject': 'Inquiry about your service',
      'body': 'Hello, I would like to ask about...',
    },
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    throw 'Could not launch $emailUri';
  }
}
