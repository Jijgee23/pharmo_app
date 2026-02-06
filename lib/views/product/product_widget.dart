import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/views/product/product_detail_page.dart';
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
    // double fontSize = Sizes.height * 0.0135;
    return Consumer<HomeProvider>(
      builder: (context, home, child) {
        final secutity = Authenticator.security;
        bool isNotPharm = (!secutity!.isPharmacist);
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: image(Sizes.height),
                      ),
                      Text(
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
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 5,
                                children: [
                                  Expanded(
                                    child: Text(
                                      toPrice(item.price),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: Sizes.mediumFontSize - 2,
                                      ),
                                    ),
                                  ),
                                  if (isNotPharm)
                                    Expanded(
                                      child: Text(
                                        'Үлд: ${parseDouble(item.qty)}',
                                        style: TextStyle(
                                          fontSize: Sizes.mediumFontSize - 2,
                                          color: item.qty > 0
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Get.bottomSheet(
                                isScrollControlled: true,
                                ChangeQtyPad(
                                  title: 'Тоо хэмжээ оруулна уу',
                                  initValue: '',
                                  onSubmit: (value) async => await addBasket(
                                    item,
                                    parseDouble(value),
                                    context,
                                  ).then((e) => Navigator.pop(context)),
                                ),
                              ),
                              style: IconButton.styleFrom(
                                shape: CircleBorder(
                                  side: BorderSide(color: primary, width: 2),
                                ),
                              ),
                              icon: Icon(
                                Icons.add,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Positioned(
            //   bottom: 10,
            //   right: 10,
            //   child: IconButton(
            //     onPressed: () => Get.bottomSheet(
            //       isScrollControlled: true,
            //       ChangeQtyPad(
            //         title: 'Тоо хэмжээ оруулна уу',
            //         initValue: '',
            //         onSubmit: (value) async => await addBasket(
            //           item,
            //           parseDouble(value),
            //           context,
            //         ).then((e) => Navigator.pop(context)),
            //       ),
            //     ),
            //     style: IconButton.styleFrom(
            //       shape: CircleBorder(
            //         side: BorderSide(color: primary, width: 2),
            //       ),
            //     ),
            //     icon: Icon(
            //       Icons.add,
            //       color: theme.primaryColor,
            //     ),
            //   ),
            // ),
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

  Widget image(double height) {
    return Stack(
      children: [
        Container(
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

Future<void> addBasket(Product item, double qty, BuildContext context) async {
  await LoadingService.run(
    () async {
      try {
        final cart = context.read<CartProvider>();
        await cart.addProduct(item.id, item.name ?? 'Бараа', qty);
      } catch (e) {
        throw Exception(e);
      }
    },
  );
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
                      if (Authenticator.security!.isPharmacist)
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
              onPressed: () => Get.bottomSheet(
                isScrollControlled: true,
                ChangeQtyPad(
                  title: 'Тоо хэмжээ оруулна уу',
                  initValue: '',
                  onSubmit: (value) => addBasket(
                    item,
                    parseDouble(value),
                    context,
                  ).then((e) => Navigator.pop(context)),
                ),
                // AddBasketSheet(product: item),
              ),
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
