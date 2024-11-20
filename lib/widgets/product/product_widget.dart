import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';

class ProductWidget extends StatelessWidget {
  final Product item;
  final bool? hasSale;
  final double? sale;
  final Function()? onTap;
  final Function()? onButtonTab;

  const ProductWidget(
      {super.key,
      required this.item,
      this.onTap,
      this.onButtonTab,
      this.hasSale,
      this.sale});
  splitURL(String url) {
    List<String> strings = url.split('.');
    return strings;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                // border: Border.all(color: AppColors.primary, width: 0.5),
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: shadow()),
            margin: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 5),
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey.shade300)),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(13),
                            topRight: Radius.circular(13)),
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          opacity: item.image != null ? 1 : 0.2,
                          image: item.image != null &&
                                  splitURL(item.image!).length == 2
                              ? NetworkImage(
                                  '${dotenv.env['IMAGE_URL']}${splitURL(item.image!)[0]}_150x150.${splitURL(item.image!)[1]}')
                              : const AssetImage(
                                  'assets/restrict-photography.png',
                                ) // Fallback image
                                  as ImageProvider<Object>,
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
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              (hasSale == true && sale != null)
                                  ? toPrice({
                                      item.price == 0
                                          ? '0'
                                          : (item.price! -
                                                  (item.price! /
                                                      100 *
                                                      item.discount!))
                                              .toString()
                                              .substring(0, 7)
                                    })
                                  : toPrice(item.price),
                              style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: onButtonTab,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              'Сагсанд нэмэх',
                              softWrap: true,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  hasSale == true
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(toPrice(item.price),
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    decoration: TextDecoration.lineThrough,
                                    fontWeight: FontWeight.w500)),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
          hasSale == true
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
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
