import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/controller/providers/a_controlller.dart';
import 'package:pharmo_app/controller/models/products.dart';
import 'package:pharmo_app/application/services/a_services.dart';
import 'package:pharmo_app/views/public/product/add_basket_sheet.dart';
import 'package:pharmo_app/views/public/product/product_detail_page.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';

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
    double fontSize = Sizes.height * 0.0135;
    return Consumer<HomeProvider>(
      builder: (context, home, child) {
        final secutity = LocalBase.security;
        bool isNotPharm = (secutity!.role != 'PA');
        return InkWell(
          onTap: () => goto(ProductDetail(prod: item)),
          splashColor: Colors.grey,
          highlightColor: Colors.grey,
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Sizes.smallFontSize - 2),
                  color: Colors.white,
                  border: Border.all(
                    color: const Color.fromARGB(255, 207, 206, 206),
                    width: 1,
                  ),
                ),
                margin: const EdgeInsets.all(Sizes.smallFontSize / 3),
                padding: const EdgeInsets.all(Sizes.smallFontSize / 2),
                child: InkWell(
                  onTap: () => goto(ProductDetail(prod: item)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      image(Sizes.height, fontSize),
                      Text(
                        item.name!,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: Sizes.mediumFontSize - 2,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            toPrice(item.price),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: Sizes.mediumFontSize - 2,
                            ),
                          ),
                          if (isNotPharm)
                            Text(
                              'Үлд: ${maybeNull(item.qty.toString())}',
                              style: TextStyle(
                                fontSize: Sizes.smallFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          InkWell(
                            highlightColor: Colors.grey,
                            splashColor: Colors.grey,
                            onTap: () =>
                                Get.bottomSheet(AddBasketSheet(product: item)),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: theme.primaryColor, width: 1.5),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Icon(Icons.add, color: theme.primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              (hasSale == true)
                  ? Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 5),
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
                  : const SizedBox(),
            ],
          ),
        );
      },
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
              opacity: item.image != null ? 1 : 0.1,
              image: item.image != null && splitURL(item.image!).length == 2
                  ? NetworkImage(
                      '${dotenv.env['IMAGE_URL']}${splitURL(item.image!)[0]}_150x150.${splitURL(item.image!)[1]}')
                  : const AssetImage(
                      'assets/no-pictures.png',
                    ) as ImageProvider<Object>,
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
    final fs = Sizes.height * .013;
    return InkWell(
      onTap: () => goto(ProductDetail(prod: item)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: theme.cardColor,
            border: Border.all(
                color: const Color.fromARGB(255, 207, 206, 206), width: 1)),
        margin: const EdgeInsets.symmetric(vertical: 2.5),
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
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          toPrice(item.price),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: fs,
                          ),
                        ),
                      ),
                      if (LocalBase.security!.role != 'PA')
                        Expanded(
                            child: Text(
                          'Үлд: ${maybeNull(item.qty.toString())}',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: Sizes.smallFontSize,
                          ),
                        ))
                    ],
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => Get.bottomSheet(AddBasketSheet(product: item)),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color.fromARGB(255, 207, 206, 206),
                    ),
                    borderRadius: BorderRadius.circular(15)),
                child: Text(
                  'Сагслах',
                  softWrap: true,
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis,
                    fontSize: fs,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
