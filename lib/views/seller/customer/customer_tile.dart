import 'package:pharmo_app/views/SELLER/customer/customer_details_paga.dart';
import 'package:pharmo_app/application/application.dart';

class CustomerTile extends StatelessWidget {
  final Customer customer;
  const CustomerTile({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    var redText = TextStyle(
      color: Colors.red,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );
    return Card(
      color: white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () => goto(CustomerDetailsPage(customer: customer)),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  spacing: 20,
                  children: [
                    Column(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        greyText(customer.name!, black),
                        if (customer.rn != null) greyText(customer.rn!, black),
                        if (customer.loanBlock == true)
                          Text(
                            'Харилцагч дээр захиалга зээлээр өгөхгүй!',
                            style: redText,
                          ),
                        if (customer.location == false)
                          Text('Байршил тодорхойгүй', style: redText)
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: frenchGrey,
              )
            ],
          ),
        ),
      ),
    );
  }

  Text greyText(String t, Color? color) {
    return Text(
      t,
      style: TextStyle(
        color: color ?? black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
