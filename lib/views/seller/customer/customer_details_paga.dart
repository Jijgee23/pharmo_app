// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/views/auth/login.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/ui_help/default_box.dart';
import 'package:provider/provider.dart';

class CustomerDetailsPage extends StatefulWidget {
  final Customer customer;
  const CustomerDetailsPage({super.key, required this.customer});
  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  final TextEditingController name = TextEditingController();
  final TextEditingController rn = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController phone2 = TextEditingController();
  final TextEditingController phone3 = TextEditingController();
  final TextEditingController note = TextEditingController();
  late PharmProvider pharm;
  dynamic data = {};
  bool fetching = false;
  setFetching(bool n) {
    setState(() {
      fetching = n;
    });
  }

  @override
  void initState() {
    pharm = Provider.of<PharmProvider>(context, listen: false);
    getDetail();
    super.initState();
  }

  getDetail() async {
    setFetching(true);
    await pharm.getCustomerDetail(widget.customer.id!, context);
    setFetching(false);
  }

  @override
  Widget build(BuildContext context) {
    final home = Provider.of<HomeProvider>(context, listen: false);
    return (fetching == true)
        ? const Scaffold(
            body: Center(
              child: PharmoIndicator(),
            ),
          )
        : Consumer<PharmProvider>(
            builder: (context, pp, child) {
              final d = pp.customerDetail;
              bool isEditable =
                  (d.addedById != null && d.addedById! == home.userId);
              bool notLocated = (d.lat == null && d.lng == null);
              return DefaultBox(
                title: d.name!,
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        runSpacing: 15,
                        children: [
                          (isEditable)
                              ? info('Нэр:', d.name ?? '', name, null)
                              : const SizedBox(),
                          info('РД', d.rn ?? '', rn, null),
                          info('И-Мейл', d.email ?? '', email, validateEmail),
                          info('Утас', d.phone ?? '', phone, validatePhone),
                          info('Утас 2', d.phone2 ?? '', phone2, validatePhone),
                          info('Утас 2', d.phone3 ?? '', phone3, validatePhone),
                          info('Тайлбар', d.note ?? '', note, null),
                          (d.loanLimitUse == true && d.loanLimit! >= 0.0)
                              ? info('Зээлийн лимит', d.loanLimit.toString(),
                                  TextEditingController(), null)
                              : const SizedBox(),
                          (isEditable)
                              ? CustomButton(
                                  text: 'Хадгалах',
                                  ontap: () {
                                    pp.editCustomer(
                                        id: d.id!,
                                        name: name.text.isNotEmpty
                                            ? name.text
                                            : d.name!,
                                        rn: rn.text.isNotEmpty
                                            ? rn.text
                                            : d.rn!,
                                        email: email.text.isNotEmpty
                                            ? email.text
                                            : d.email!,
                                        phone: phone.text.isNotEmpty
                                            ? phone.text
                                            : d.phone!,
                                        note: note.text.isNotEmpty
                                            ? note.text
                                            : d.note!,
                                        context: context,
                                        phone2: phone2.text.isNotEmpty
                                            ? phone2.text
                                            : d.phone2,
                                        phone3: phone3.text.isNotEmpty
                                            ? phone3.text
                                            : d.phone3,
                                        lat: (notLocated)
                                            ? home.currentLatitude
                                            : null,
                                        lng: (notLocated)
                                            ? home.currentLongitude
                                            : null);
                                  })
                              : const SizedBox(),
                          (notLocated)
                              ? CustomButton(
                                  text: 'Байршил илгээх',
                                  ontap: () =>
                                      pp.sendCustomerLocation(d.id!, context),
                                )
                              : const SizedBox()
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}

class EmailHelper {
  static String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}

info(String v, String v2, TextEditingController controller,
    String? Function(String?)? validator) {
  return Container(
    width: double.infinity,
    height: 50,
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    decoration: BoxDecoration(
        color: AppColors.background, borderRadius: BorderRadius.circular(10)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(v,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ),
        Expanded(
          flex: 6,
          child: TextFormField(
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.end,
            controller: controller,
            validator: validator,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 7),
                focusedBorder: InputBorder.none,
                border: InputBorder.none,
                hintText: v2,
                hintStyle: const TextStyle(color: Colors.black54)),
          ),
        ),
      ],
    ),
  );
}
