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
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Image.network(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwrng-1Q_xEhlRgtdU9Ljy5PoPNVjYYcTfZQ&s',
                  fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  direction: Axis.vertical,
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
                    
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      child:
                          CustomButton(text: 'Сагсанд нэмэх', ontap: () {}),
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
