import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/utilities/colors.dart';

class ProductWidget extends StatelessWidget {
  final Product item;
  final Function()? onTap;
  final Function()? onButtonTab;

  const ProductWidget(
      {super.key, required this.item, this.onTap, this.onButtonTab});
  final String noImageUrl =
      'https://static.vecteezy.com/system/resources/thumbnails/004/141/669/small/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg';
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: item.image != null
                        ? NetworkImage(
                            '${dotenv.env['IMAGE_URL']}${item.image.toString().substring(1)}')
                        : NetworkImage(noImageUrl),
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
                  icon: const Icon(
                    Icons.add_shopping_cart,
                    size: 15,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
