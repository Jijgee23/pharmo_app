import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/screens/DM_SCREENS/tabs/jagger_home_detail.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';

class HomeJagger extends StatefulWidget {
  const HomeJagger({super.key});
  @override
  State<HomeJagger> createState() => _HomeJaggerState();
}

class _HomeJaggerState extends State<HomeJagger> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    try {
      final jaggerProvider = Provider.of<JaggerProvider>(context, listen: false);
      dynamic res = await jaggerProvider.getJaggers();
      if (res['errorType'] == 1) {
        showSuccessMessage(message: res['message'], context: context);
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    } catch (e) {
      showFailedMessage(message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<JaggerProvider>(builder: (context, provider, _) {
        final jagger = provider.jaggers[0];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: jagger.jaggerOrders!.isNotEmpty
              ? ListView.builder(
                  itemCount: jagger.jaggerOrders?.length,
                  itemBuilder: (context, index) {
                    return Card(
                        child: InkWell(
                      onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => JaggerHomeDetail(
                                      orderItems: jagger.jaggerOrders![index].jaggerOrderItems,
                                    )))
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              jagger.jaggerOrders![0].user.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                            ),
                            RichText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              text: TextSpan(text: 'Захиалгын дугаар : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                TextSpan(text: jagger.jaggerOrders![0].orderNo.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                              ]),
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                text: TextSpan(text: 'Төлөв : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                  TextSpan(text: jagger.jaggerOrders![0].process.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                                ]),
                              ),
                              IconButton(
                                iconSize: 20,
                                icon: const Icon(Icons.text_increase_outlined),
                                onPressed: () {
                                  // ...
                                },
                              ),
                            ]),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const PharmaHomePage()), (route) => true);
                                    // provider.getBasket();
                                  },
                                  icon: const Icon(
                                    color: Colors.white,
                                    Icons.close,
                                    size: 24.0,
                                  ),
                                  label: const Text(
                                    'Дуусгах',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    dynamic res = await provider.startShipment(jagger.id);
                                    if (res['errorType'] == 1) {
                                      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OrderDone(orderNo: res['data']['orderNo'].toString())));
                                      showSuccessMessage(message: res['message'] + ' ' + res['data'], context: context);
                                    } else {
                                      showFailedMessage(message: res['message'], context: context);
                                    }
                                  },
                                  icon: const Icon(
                                    color: Colors.white,
                                    Icons.start,
                                    size: 24.0,
                                  ),
                                  label: const Text(
                                    'Эхлүүлэх',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ));
                  })
              : const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      "Түгээлтийн мэдээлэл олдсонгүй ...",
                    ),
                  ),
                ),
        );
      }),
    );
  }
}
