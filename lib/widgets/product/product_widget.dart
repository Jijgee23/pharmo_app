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
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTueR-EitVLUmrOKHMmAujo8S9uV7geSq0Gw&s';
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade500),
          borderRadius: BorderRadius.circular(13),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 5),
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(13),
                      topRight: Radius.circular(13)),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: item.image != null
                        ? NetworkImage(
                            '${dotenv.env['IMAGE_URL']}${item.image.toString().substring(1)}')
                        : NetworkImage(
                            noImageUrl,
                            scale: 1,
                          ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                item.name!,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.price.toString()} ₮',
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: onButtonTab,
                    child: Image.asset(
                      'assets/icons/add-basket.png',
                      height: 24,
                      width: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
