import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/models/favorite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Идэвхтэй захиалдаг бараанууд',
          style: TextStyle(fontSize: size.height * 0.02, color: Colors.pink),
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
                ? Center(
                    child: SizedBox(
                      width: size.width * 0.8,
                      child: const Text(
                        'Тухайн харилцагчид дуртай барааны жагсаалт хоосон байна.',
                        style: TextStyle(fontSize: 18, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Expanded(
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
          ],
        ),
      ),
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
}
