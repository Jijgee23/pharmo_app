import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:pharmo_app/application/application.dart';

String platformBgText = Platform.isIOS ? 'Always' : 'ALLOW ALL TIME';

class TrackPermissionPage extends StatelessWidget {
  const TrackPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        LocationPermission? per = jagger.permission;
        bool backgrounEnabled = per != null && per == LocationPermission.always;
        final isSeller =
            LocalBase.security != null && LocalBase.security!.role == "S";
        return Scaffold(
          appBar: isSeller ? AppBar() : null,
          body: Center(
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      spacing: 10,
                      children: [
                        Container(
                          constraints: BoxConstraints(maxWidth: 350),
                          child: Text(
                            'Таны борлуулалт болон түгээлтийн үйл явцыг хянах зорилгоор дараах тохиргоо зайлшгүй шаарддлагатай.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(maxWidth: 350),
                          child: Text(
                            'Байршил тогтоогчийн тохиргоо буруу бол борлуулалт эсвэл түгээлт эхлүүлэх боломжгүй.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: backgrounEnabled,
                              onChanged: null,
                            ),
                            Expanded(
                              flex: 6,
                              child: Text(
                                'Байршил тогтоогч  $platformBgText',
                                textAlign: TextAlign.start,
                                style: TextStyle(),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: jagger.accuracy ==
                                      LocationAccuracyStatus.precise,
                                  onChanged: null,
                                ),
                                Expanded(
                                  child: Text(
                                    'Precise Location-г идэвхижүүлэх',
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: CustomButton(
                        text: 'Тохируулах',
                        ontap: () async {
                          await Settings.checkAlwaysLocationPermission()
                              .whenComplete(
                            () async => await jagger.loadPermission(),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
