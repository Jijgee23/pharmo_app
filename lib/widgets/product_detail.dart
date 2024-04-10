import 'package:flutter/material.dart';
import 'package:pharmo_app/widgets/custom_button.dart';

class ProductDetail extends StatelessWidget {
  final String productName;
  final String productPrice;

  const ProductDetail({
    super.key,
    required this.productName,
    required this.productPrice,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.chevron_left,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Image.network(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwrng-1Q_xEhlRgtdU9Ljy5PoPNVjYYcTfZQ&s',
                    fit: BoxFit.fitHeight,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(productName),
                      const Text('Баркод: 1234567890'),
                      Text('Үнэ: $productPrice₮'),
                      Text('Барааны дуусах хугацаа	: $DateTime'),
                      Text('Бөөний үнэ: $productPrice₮'),
                      Text('Бөөний тоо: $productPrice₮'),
                      Text('Хямдрал: $productPrice₮'),
                      Text('Үйлдвэрлэгч: $productPrice₮'),
                      Text('Ерөнхий нэршил: $productPrice₮'),
                      const Expanded(child: Text('')),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                const Text('Тоо ширхэг'),
                                SizedBox(
                                  width: size.width * 0.4,
                                  height: size.width * 0.1,
                                  child: const TextField(),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: size.width * 0.4,
                              height: size.width * 0.1,
                              child: CustomButton(
                                  text: 'Сагсанд нэмэх', ontap: () {}),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
