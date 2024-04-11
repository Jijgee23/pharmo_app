import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/widgets/custom_button.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetail extends StatefulWidget {
  final Product prod;

  const ProductDetail({Key? key, required this.prod}) : super(key: key);

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  List<Widget> carouselItems = [
    Image.network('https://12bb6ecf-bda5-4c99-816b-12bda79f6bd9.selcdn.net/upload//Photo_Tovar/396999_2_1687352103.jpeg'),
    Image.network('https://iskamed.by/wp-content/uploads/1433.jpg'),
    Image.network(
        'https://612611.selcdn.ru/prod-s3/resize_cache/1583648/8d98eab21f83652e055a2f8c91f3543a/iblock/2dd/2dddefb762666acf79f34cdeb455be4b/617f02e7aaece58849e3acf3e5651c89.png'),
  ];
  @override
  void initState() {
    // TODO: implement initState
    getData();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getData() async {
    try {
      print('odko');
    } catch (e) {
      showFailedMessage(message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Барааны дэлгэрэнгүй',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
              icon: const Icon(
                Icons.notifications,
                color: Colors.blue,
              ),
              onPressed: () {}),
          IconButton(
              icon: const Icon(
                Icons.shopping_basket,
                color: Colors.red,
              ),
              onPressed: () {}),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: CarouselSlider(
                  items: carouselItems,
                  options: CarouselOptions(
                    height: size.height * 0.2, // Customize the height of the carousel
                    autoPlay: true, // Enable auto-play
                    enlargeCenterPage: true, // Increase the size of the center item
                    enableInfiniteScroll: true, // Enable infinite scroll
                    onPageChanged: (index, reason) {
                      // Optional callback when the page changes
                      // You can use it to update any additional UI components
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  direction: Axis.vertical,
                  children: [
                    Text(
                      widget.prod.name.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text('Баркод: ${widget.prod.barcode}'),
                    Text('Үнэ: ${widget.prod.price}'),
                    Text('Барааны дуусах хугацаа	:${widget.prod.expDate}'),
                    Text('Бөөний үнэ: ${widget.prod.discount}'),
                    Text('Бөөний тоо: ${widget.prod.in_stock}'),
                    Text('Хямдрал: ${widget.prod.sale_price}'),
                    Text('Үйлдвэрлэгч: ${widget.prod.supplier}'),
                    const Expanded(child: Text('')),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Тоо ширхэг',
                          style: TextStyle(
                            fontSize: size.height * 0.025,
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.4,
                          height: size.width * 0.05,
                          child: const TextField(),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: size.width * 0.4,
                      height: size.width * 0.1,
                      child: CustomButton(
                          text: 'Сагсанд нэмэх',
                          ontap: () {
                            print('odkooooo');
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RemoteApi {
  static Future<List<dynamic>?> getProdList(
    int page,
    int limit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(Uri.parse('http://192.168.88.39:8000/api/v1/product/?page=$page&page_size=$limit'), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': bearerToken,
      });
      if (response.statusCode == 200) {
        Map res = jsonDecode(response.body);
        List<Product> prods = (res['results'] as List).map((data) => Product.fromJson(data)).toList();
        print(prods[0].images?.first['url']);
        return prods;
      }
    } catch (e) {
      print("Error $e");
    }
    return null;
  }
}
