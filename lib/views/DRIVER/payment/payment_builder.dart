import 'package:pharmo_app/application/application.dart';

class PaymentBuilder extends StatelessWidget {
  final Payment payment;
  final void Function() handler;
  const PaymentBuilder(
      {super.key, required this.payment, required this.handler});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: grey500),
      ),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: handler,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 7.5,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1).withBlue(50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      payment.cust.name!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${toPrice(payment.amount)} (${getPayType(payment.payType)})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  timeText(payment.paidOn.toString().substring(0, 10)),
                  timeText(payment.paidOn.toString().substring(10, 19)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Text timeText(String t) {
    return Text(
      t,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade700,
      ),
    );
  }
}
