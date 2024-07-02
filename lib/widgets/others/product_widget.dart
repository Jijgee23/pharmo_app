
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/models/products.dart';

class ProductWidget extends StatelessWidget {
  final Product item;
  final Function()? onTap;
  final Function()? onButtonTab;

  const ProductWidget(
      {super.key, required this.item, this.onTap, this.onButtonTab});
  final String noImageUrl =
      'https://st4.depositphotos.com/14953852/24787/v/380/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg';
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(13),
        ),
        margin: const EdgeInsets.only(right: 10,left: 15, bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(9),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: item.image != null
                        ? NetworkImage(
                            '${dotenv.env['IMAGE_URL']}${item.image.toString().substring(1)}')
                        : NetworkImage(noImageUrl, scale: 1,),
                  ),
                ),
              ),
            ),
            Text(
              item.name!,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item.price.toString()} ₮',
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w500),
                ),
                IconButton(
                  onPressed: onButtonTab,
                  icon: Image.asset('assets/icons/add-basket.png', height: 24, width: 24,)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
