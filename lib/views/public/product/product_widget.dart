import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/views/public/product/add_basket_sheet.dart';
import 'package:pharmo_app/views/public/product/product_detail_page.dart';
import 'package:pharmo_app/application/application.dart';

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
        return Stack(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              margin: EdgeInsets.zero,
              surfaceTintColor: Colors.amber,
              child: InkWell(
                onTap: () => goto(ProductDetail(prod: item)),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(7.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      image(Sizes.height, fontSize),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.name!,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            toPrice(item.price),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: Sizes.mediumFontSize - 2,
                            ),
                          ),
                          if (isNotPharm)
                            Text(
                              'Үлд: ${parseDouble(item.qty)}',
                              style: TextStyle(
                                fontSize: Sizes.mediumFontSize - 2,
                                color: item.qty > 0 ? Colors.green : Colors.red,
                              ),
                            )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: InkWell(
                highlightColor: Colors.grey,
                splashColor: Colors.grey,
                onTap: () => Get.bottomSheet(
                  AddBasketSheet(product: item),
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: theme.primaryColor,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    Icons.add,
                    color: theme.primaryColor,
                  ),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.cardColor,
        border: Border.all(
          color: const Color.fromARGB(255, 207, 206, 206),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      width: double.infinity,
      child: InkWell(
        onTap: () => goto(ProductDetail(prod: item)),
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
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
                            fontSize: 12,
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
                              fontSize: 12,
                            ),
                          ),
                        )
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.bottomSheet(AddBasketSheet(product: item)),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(
                    color: primary,
                  ),
                ),
              ),
              child: Text(
                'Сагслах',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
