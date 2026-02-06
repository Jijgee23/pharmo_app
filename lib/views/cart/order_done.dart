import 'package:pharmo_app/views/index.dart';
import 'package:pharmo_app/application/application.dart';

class OrderDone extends StatefulWidget {
  final String orderNo;
  const OrderDone({super.key, required this.orderNo});

  @override
  State<OrderDone> createState() => _OrderDoneState();
}

class _OrderDoneState extends State<OrderDone> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        goHome(context.read<CartProvider>());
      }
    });
  }

  goHome(CartProvider provider) async {
    final home = context.read<HomeProvider>();
    await home.changeIndex(0);
    await provider.clearBasket();
    await provider.getBasket();
    gotoRemoveUntil(const IndexPharma());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Consumer<CartProvider>(
            builder: (context, provider, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Баталгаажуулсан GIF эсвэл Icon
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: white,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Image.asset(
                          AssetIcon.orderSuccess,
                          width: 100,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    'Баярлалаа!',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      color: primary,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Таны захиалга амжилттай үүслээ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Захиалгын дугаар харуулах карт
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Захиалгын дугаар: ',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14),
                        ),
                        Text(
                          widget.orderNo,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Нүүр хуудас руу очих товч
                  CustomButton(
                    text: 'Нүүр хуудас руу буцах',
                    ontap: () => goHome(provider),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '3 секундын дараа автоматаар шилжинэ...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
