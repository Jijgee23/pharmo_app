import 'package:pharmo_app/views/SELLER/customer/customer_details_page.dart';
import 'package:pharmo_app/application/application.dart';

class CustomerTile extends StatelessWidget {
  final Customer customer;
  const CustomerTile({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    // Анхааруулга байгаа эсэхийг шалгах
    bool hasWarning =
        (customer.loanBlock == true) || (customer.location == false);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasWarning ? Colors.red.shade100 : Colors.grey.shade200,
          width: hasWarning ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => goto(CustomerDetailsPage(customer: customer)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  // 1. Avatar - Харилцагчийн нэрний эхний үсэг
                  _buildAvatar(),
                  const SizedBox(width: 15),

                  // 2. Үндсэн мэдээлэл
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name ?? 'Нэргүй харилцагч',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (customer.rn != null && customer.rn!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'РД: ${customer.rn}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ],
              ),

              // 3. Анхааруулгын хэсэг (Warning Chips)
              if (hasWarning) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (customer.loanBlock == true)
                      _buildWarningChip('Зээл хаагдсан', Icons.block_flipped),
                    if (customer.location == false)
                      _buildWarningChip(
                          'Байршилгүй', Icons.location_off_outlined),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Анхааруулга харуулах жижиг Badge
  Widget _buildWarningChip(String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.red),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // Нэрний эхний үсэгтэй Avatar
  Widget _buildAvatar() {
    String initial = (customer.name != null && customer.name!.isNotEmpty)
        ? customer.name![0].toUpperCase()
        : '?';

    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: primary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
