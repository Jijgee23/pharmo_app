import 'package:pharmo_app/controller/a_controlller.dart';
import 'package:pharmo_app/views/order_history/seller_order_history/order_item_card.dart';
import 'package:pharmo_app/widgets/others/no_result.dart';
import 'package:get/get.dart';
class OrderItemsTab extends StatelessWidget {
  final List<dynamic> products;
  final int orderId;
  final void Function()? onTapProduct;
  const OrderItemsTab({
    super.key,
    required this.products,
    required this.orderId,
    this.onTapProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: Builder(
        builder: (context) {
          if (products.isEmpty) {
            return Column(
              children: [NoResult()],
            );
          }
          return ListView.separated(
            itemCount: products.length,
            separatorBuilder: (context, index) => SizedBox(height: 10),
            itemBuilder: (context, idx) {
              var order = products[idx];
              return OrderItemCard(
                orderId: orderId,
                ontap: onTapProduct ?? () {},
                item: order,
              );
            },
          ).paddingAll(10);
        },
      ),
    );
  }
}
