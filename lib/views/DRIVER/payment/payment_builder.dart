import 'package:pharmo_app/application/application.dart';

class PaymentBuilder extends StatelessWidget {
  final Payment payment;
  final void Function() handler;
  const PaymentBuilder({
    super.key,
    required this.payment,
    required this.handler,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: handler,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Хэрэглэгчийн мэдээлэл (Badge хэлбэрээр)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.person_pin,
                            size: 18, color: primary.withOpacity(0.7)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            payment.cust.name ?? 'Тодорхойгүй',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildPayTypeBadge(payment.payType),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, thickness: 0.5),
              ),

              // 2. Мөнгөн дүн болон Огноо
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Төлсөн дүн',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        toPrice(payment.amount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors
                              .green, // Төлбөр учир ногоон өнгө илүү тохиромжтой
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _timeText(payment.paidOn.toString().substring(0, 10)),
                      const SizedBox(height: 2),
                      _timeText(payment.paidOn.toString().substring(11, 16),
                          isBold: true),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Төлбөрийн хэлбэрийг ялгах Badge
  Widget _buildPayTypeBadge(String type) {
    String typeName = getPayType(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        typeName,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
      ),
    );
  }

  Widget _timeText(String t, {bool isBold = false}) {
    return Text(
      t,
      style: TextStyle(
        fontSize: 13,
        fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
        color: Colors.grey.shade600,
      ),
    );
  }
}
