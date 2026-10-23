import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/order_history/pharm_order_history/pharmo_order_history.dart';
import 'package:pharmo_app/views/order_history/seller_order_history/seller_orders.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  @override
  Widget build(BuildContext context) {
    final user = Authenticator.security;
    if (user == null) {
      return const EmptyState(
        icon: Icons.person_off_outlined,
        title: 'Хэрэглэгч олдсонгүй',
        message: 'Дахин нэвтэрнэ үү.',
      );
    }
    if (user.isPharmacist) {
      return PharmOrderHistory();
    }
    return SellerOrderHistory();
  }
}
