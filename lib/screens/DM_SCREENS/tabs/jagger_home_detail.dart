import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/models/jagger_order_item.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:provider/provider.dart';

class JaggerHomeDetail extends StatelessWidget {
  final List<JaggerOrderItem>? orderItems;
  const JaggerHomeDetail({super.key, required this.orderItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Түгээлтийн дэлгэрэнгүй',
      ),
      body: Consumer<JaggerProvider>(builder: (context, provider, _) {
        final jagger = provider.jaggers[0];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: orderItems!.isNotEmpty
              ? ListView.builder(
                  itemCount: orderItems?.length,
                  itemBuilder: (context, index) {
                    return Card(
                        child: InkWell(
                      onTap: () => {print('shineodko')},
                      child: Container(
                        margin: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderItems![0].itemName.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                            ),
                            RichText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              text: TextSpan(text: 'Үнэ : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                TextSpan(text: orderItems![0].itemPrice.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                              ]),
                            ),
                            RichText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              text: TextSpan(text: 'Тоо ширхэг : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                TextSpan(text: orderItems![0].itemQty.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                              ]),
                            ),
                            RichText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              text: TextSpan(text: 'Нийт дүн : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                TextSpan(text: orderItems![0].itemTotalPrice.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                              ]),
                            ),
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
