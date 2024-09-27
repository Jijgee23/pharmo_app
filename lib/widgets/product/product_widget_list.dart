import 'package:flutter/material.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/utilities/colors.dart';

class ProductWidgetListView extends StatelessWidget {
  final Product item;
  final Function()? onTap;
  final Function()? onButtonTab;
  const ProductWidgetListView(
      {super.key, required this.item, this.onButtonTab, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name!,
                    style: const TextStyle(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    '${item.price} ₮',
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.secondary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onButtonTab,
              child: Image.asset(
                'assets/icons_2/cart.png',
                height: 24,
                width: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
