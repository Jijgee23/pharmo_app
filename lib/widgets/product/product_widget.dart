import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/product/add_basket_sheet.dart';
import 'package:pharmo_app/widgets/product/product_detail_page.dart';

//GRID VIEW
class ProductWidget extends StatelessWidget {
  final Product item;
  final bool? hasSale;
  final double? sale;

  const ProductWidget({super.key, required this.item, this.hasSale, this.sale});
  splitURL(String url) {
    List<String> strings = url.split('.');
    return strings;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double fontSize = height * 0.0135;
    return InkWell(
      onTap: () => goto(ProductDetail(prod: item)),
      child: Stack(
        children: [
          Container(
            height: height * 0.37,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: shadow()),
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                image(height, fontSize),
                Text(
                  item.name!,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize,
                  ),
                ),
                InkWell(
                  onTap: () => Get.bottomSheet(AddBasketSheet(product: item)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      'Сагсанд нэмэх',
                      softWrap: true,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        overflow: TextOverflow.ellipsis,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          (hasSale == true)
              ? Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      hasSale == true ? '${item.discount}%' : '',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }

  Widget image(double height, double fontSize) {
    return Stack(
      children: [
        Container(
          height: height * .12,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              fit: BoxFit.scaleDown,
              filterQuality: FilterQuality.high,
              opacity: item.image != null ? 1 : 0.25,
              image: item.image != null && splitURL(item.image!).length == 2
                  ? NetworkImage(
                      '${dotenv.env['IMAGE_URL']}${splitURL(item.image!)[0]}_150x150.${splitURL(item.image!)[1]}')
                  : const AssetImage(
                      'assets/no-pictures.png',
                    ) as ImageProvider<Object>,
            ),
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(.55),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Text(
                  toPrice(item.price),
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

//LIST VIEW
class ProductWidgetListView extends StatelessWidget {
  final Product item;
  const ProductWidgetListView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final fs = height * .013;
    return InkWell(
      onTap: () => goto(ProductDetail(prod: item)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: shadow()),
        margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: fs,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    toPrice(item.price!),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                      fontSize: fs,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => Get.bottomSheet(AddBasketSheet(product: item)),
              child: Text(
                'Сагсанд нэмэх',
                softWrap: true,
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis,
                    fontSize: fs),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
