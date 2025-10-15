import 'package:flutter/material.dart';
import 'package:pharmo_app/models/customer.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/services/a_services.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/main/seller/customer_location_picker.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/indicator/pharmo_indicator.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/inputs/ibtn.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerDetailsPage extends StatefulWidget {
  final Customer customer;
  const CustomerDetailsPage({super.key, required this.customer});
  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  bool fetching = false;
  setFetching(bool n) {
    setState(() {
      fetching = n;
    });
  }

  @override
  void initState() {
    getDetail();
    super.initState();
  }

  getDetail() async {
    setFetching(true);
    await context.read<PharmProvider>().getCustomerDetail(widget.customer.id!);
    setFetching(false);
  }

  Map<String, IconData> contacting = {
    'Мейл': Icons.email,
    'Утас': Icons.phone,
    'FB': Icons.facebook,
    'Байршил': Icons.location_on,
  };

  @override
  Widget build(BuildContext context) {
    return (fetching == true)
        ? const Scaffold(body: Center(child: PharmoIndicator()))
        : Consumer<PharmProvider>(
            builder: (context, pp, child) {
              final d = pp.customerDetail;
              bool isEditable = (d.addedById != null &&
                  d.addedById == LocalBase.security!.id);
              Map<String, String> params = {
                'Мейл': maybeNull(d.email),
                'Регистр': maybeNull(d.rn),
                'Утас': maybeNull(d.phone),
                'Утас 2': maybeNull(d.phone2),
                'Утас 3': maybeNull(d.phone3),
                'Тайлбар': maybeNull(d.note)
              };
              return Scaffold(
                appBar: AppBar(
                  centerTitle: false,
                  title: Text(
                    'Харилцагчийн мэдээлэл',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  actions: [
                    if (isEditable)
                      Ibtn(
                          onTap: () =>
                              editCustomer(d, pp, params.keys.toList()),
                          icon: Icons.edit),
                    // if (notLocated)
                    //   Ibtn(
                    //       onTap: () => goto(LocationPicker(cusotmerId: d.id!)),
                    //       icon: Icons.location_city)
                  ],
                ),
                body: Column(
                  spacing: 10.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IntrinsicHeight(
                      child: Container(
                        width: double.maxFinite,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(Sizes.bigFontSize),
                            bottomRight: Radius.circular(Sizes.bigFontSize),
                          ),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: Sizes.width * .07,
                              backgroundColor: Colors.white,
                              child: Text(
                                d.name?.substring(0, 1).toUpperCase() ?? '',
                                style: TextStyle(
                                  fontSize: Sizes.width * .05,
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              d.name ?? 'Харилцагчийн нэр',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              d.rn ?? 'Регистрийн дугааргүй',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              spacing: 10,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ...contacting.entries.map(
                                  (e) => social(e, d),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    contactWidget(
                        'Мэйл', [maybeNull(d.email ?? '')], Icons.email),
                    contactWidget(
                      'Утас',
                      [
                        maybeNull(d.phone ?? ''),
                        maybeNull(d.phone2 ?? ''),
                        maybeNull(d.phone3 ?? '')
                      ].where((e) => e.isNotEmpty).toList(),
                      Icons.phone,
                    ),
                    contactWidget(
                      'Тайлбар',
                      [maybeNull(d.note ?? '')],
                      Icons.note,
                    ),
                    contactWidget(
                      'Зээлийн мэдээлэл',
                      [
                        (d.loanLimitUse == true &&
                                double.parse(
                                        maybeNull(d.loanLimit.toString())) >=
                                    0.0)
                            ? 'Зээлийн лимит: ${toPrice(d.loanLimit)}'
                            : 'Зээлийн лимит ашиглахгүй',
                      ],
                      Icons.credit_card,
                    ),
                  ],
                ),
              );
            },
          );
  }

  Expanded social(MapEntry<String, IconData> e, CustomerDetail d) {
    return Expanded(
      child: InkWell(
        splashColor: Colors.white.withAlpha(100),
        highlightColor: Colors.white.withAlpha(50),
        onTap: () => handleSocial(e.key, d),
        child: Container(
          decoration: BoxDecoration(
            color: primary.withAlpha(150),
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              color: Colors.white.withAlpha(125),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Column(
            children: [
              Icon(
                e.value,
                color: Colors.white,
                size: 24.0,
              ),
              const SizedBox(height: 2.0),
              Text(
                e.key,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  handleSocial(String key, CustomerDetail d) {
    switch (key) {
      case 'Мейл':
        if (d.email == null || d.email!.isEmpty) {
          message('Мэйл хаяг байхгүй байна');
          return;
        }
        final Uri emailLaunchUri = Uri(
          scheme: 'mailto',
          path: d.email ?? '',
          query: EmailHelper.encodeQueryParameters({
            'subject': 'Харилцагчийн мэдээлэл',
            'body': 'Сайн байна уу, ${d.name ?? ''}!',
          }),
        );
        launchUrl(
          emailLaunchUri,
          mode: LaunchMode.externalApplication,
        );
        break;
      case 'Утас':
        if (d.phone == null || d.phone!.isEmpty) {
          message('Утасны дугаар байхгүй байна');
          return;
        }
        callPhoneNumber(d.phone ?? '');
        break;
      case 'FB':
        final Uri fbLaunchUri = Uri.parse('https://www.facebook.com/');
        launchUrl(
          fbLaunchUri,
          mode: LaunchMode.externalApplication,
        );
        break;
      case 'Байршил':
        goto(LocationPicker(cusotmerId: widget.customer.id!));
        break;
      default:
        break;
    }
  }

  Widget contactWidget(String title, List<String> vals, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        spacing: 10.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: Sizes.mediumFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          ...vals.map(
            (c) => Row(
              children: [
                Icon(icon, color: primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    c,
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  final TextEditingController name = TextEditingController();
  final TextEditingController rn = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController phone2 = TextEditingController();
  final TextEditingController phone3 = TextEditingController();
  final TextEditingController note = TextEditingController();

  editCustomer(CustomerDetail det, PharmProvider pp, List<String> titles) {
    setState(() {
      name.text = det.name ?? '';
      email.text = det.email ?? '';
      rn.text = det.rn ?? '';
      phone.text = det.phone ?? '';
      phone2.text = det.phone2 ?? '';
      phone3.text = det.phone3 ?? '';
      note.text = det.note ?? '';
    });
    mySheet(
      title: 'Харилцагчийн мэдээлэл засах',
      children: [
        CustomTextField(controller: name, hintText: 'Нэр'),
        CustomTextField(controller: email, hintText: titles[0]),
        CustomTextField(controller: rn, hintText: titles[1]),
        CustomTextField(controller: phone, hintText: titles[2]),
        CustomTextField(controller: phone2, hintText: titles[3]),
        CustomTextField(controller: phone3, hintText: titles[4]),
        CustomTextField(controller: note, hintText: titles[5]),
        CustomButton(
            text: 'Хадгалах',
            ontap: () {
              pp.editCustomer(
                  id: parseInt(det.id),
                  name: name.text.isNotEmpty
                      ? name.text
                      : maybeNullToJson(det.name),
                  rn: rn.text.isNotEmpty ? rn.text : maybeNullToJson(det.rn),
                  email: email.text.isNotEmpty
                      ? email.text
                      : maybeNullToJson(det.email),
                  phone: phone.text.isNotEmpty
                      ? phone.text
                      : maybeNullToJson(det.phone),
                  note: note.text.isNotEmpty
                      ? note.text
                      : maybeNullToJson(det.note),
                  context: context,
                  phone2: phone2.text.isNotEmpty
                      ? phone2.text
                      : maybeNullToJson(det.phone2),
                  phone3: phone3.text.isNotEmpty
                      ? phone3.text
                      : maybeNullToJson(det.phone3));
              getDetail();
              Navigator.pop(context);
            }),
      ],
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

void callPhoneNumber(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );

  if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
  } else {
    print('Could not launch $launchUri');
  }
}
