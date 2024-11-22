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
    double height = MediaQuery.of(context).size.height;
    return InkWell(
      child: Stack(
        children: [
          Container(
            height: height * 0.37,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: shadow()),
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: height * .15,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(13),
                              topRight: Radius.circular(13)),
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            opacity: item.image != null ? 1 : 0.25,
                            image: item.image != null &&
                                    splitURL(item.image!).length == 2
                                ? NetworkImage(
                                    '${dotenv.env['IMAGE_URL']}${splitURL(item.image!)[0]}_150x150.${splitURL(item.image!)[1]}')
                                : const AssetImage(
                                    'assets/no-pictures.png',
                                  ) as ImageProvider<Object>,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7.5, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              Text(
                                toPrice(item.price),
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: height * 0.012,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      item.name!,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: height * 0.012),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: onButtonTab,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              'Сагсанд нэмэх',
                              softWrap: true,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                fontSize: height * 0.012,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // hasSale == true
                  //     ? Align(
                  //         alignment: Alignment.centerLeft,
                  //         child: Padding(
                  //           padding: const EdgeInsets.symmetric(horizontal: 10),
                  //           child: Text(
                  //             toPrice(item.price),
                  //             style:  TextStyle(
                  //               color: Colors.grey,
                  //               fontSize: height * 0.012,
                  //               decoration: TextDecoration.lineThrough,
                  //               fontWeight: FontWeight.w500,
                  //             ),
                  //           ),
                  //         ),
                  //       )
                  //     : const SizedBox(),
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
