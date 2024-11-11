import 'package:flutter/material.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';

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
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: shadow()),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
                    toPrice(item.price!),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onButtonTab,
              child: Image.asset(
                'assets/icons_2/add.png',
                color: AppColors.primary,
                height: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
