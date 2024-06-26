

// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/models/favorite.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/SELLER_SCREENS/seller_home.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteList extends StatefulWidget {
  final int customerId;
  const FavoriteList({
    super.key,
    required this.customerId,
  });

  @override
  State<FavoriteList> createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  List<Favorite> favorites = <Favorite>[];

  @override
  void initState() {
    getFavListByCustomerId(widget.customerId.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<HomeProvider>(
      builder: (_, homeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Идэвхтэй захиалдаг бараанууд',
              style:
                  TextStyle(fontSize: size.height * 0.02, color: Colors.pink),
            ),
            centerTitle: true,
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                favorites.isEmpty
                    ? Expanded(
                      flex: 9,
                      child: Center(
                          child: SizedBox(
                            width: size.width * 0.8,
                            child: const Text(
                              'Тухайн харилцагчид дуртай барааны жагсаалт хоосон байна.',
                              style: TextStyle(fontSize: 18, color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    )
                    : Expanded(
                        flex: 9,
                        child: ListView.builder(
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                title: Text(favorites[index].name),
                                subtitle: Text(
                                    'Нийт захиалсан: ${favorites[index].orders.toString()}'),
                                trailing: Text(
                                  'Дундаж: ${favorites[index].avgQty.toString()}',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                Expanded(
                  child: CustomButton(
                    text: 'Захиалах',
                    ontap: () {
                      for (var i = 0; i < favorites.length; i++) {
                        addBasket(
                          favorites[i].id,
                          favorites[i].itemNameId,
                          favorites[i].avgQty,
                        );
                      }
                      homeProvider.changeIndex(2);
                      gotoRemoveUntil(const SellerHomePage(), context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  getFavListByCustomerId(String customerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    final response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}seller/fav_products/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'customerId': widget.customerId}));
    if (response.statusCode == 200) {
      List<dynamic> favList = jsonDecode(utf8.decode(response.bodyBytes));
      favorites.clear();
      setState(() {
        for (int i = 0; i < favList.length; i++) {
          favorites.add(Favorite.fromJson((favList[i])));
        }
      });
    }
  }

  void addBasket(int productID, int itemNameId, int avgQty) async {
    try {
      final basketProvider =
          Provider.of<BasketProvider>(context, listen: false);
      Map<String, dynamic> res = await basketProvider.addBasket(
          product_id: productID, itemname_id: itemNameId, qty: avgQty);
      if (res['errorType'] == 1) {
        basketProvider.getBasket();
      }
    } catch (e) {
      showFailedMessage(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа.!', context: context);
    }
  }
}
