import 'package:pharmo_app/views/SELLER/customer/customer_location_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pharmo_app/application/application.dart';

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
                  d.addedById == Authenticator.security!.id);

              return Scaffold(
                backgroundColor: Colors.grey.shade50,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  iconTheme: IconThemeData(color: white),
                  title: const Text(
                    'Харилцагч',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
                  ),
                  actions: [
                    if (isEditable)
                      IconButton(
                        onPressed: () => editCustomer(d, pp, [
                          'Мейл',
                          'Регистр',
                          'Утас',
                          'Утас 2',
                          'Утас 3',
                          'Тайлбар'
                        ]),
                        icon: const Icon(Icons.edit_note_rounded, size: 28),
                      ),
                  ],
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(d),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildInfoSection(
                              title: 'Холбоо барих',
                              items: [
                                _infoTile(Icons.alternate_email_rounded,
                                    'Мэйл хаяг', d.email),
                                _infoTile(Icons.phone_iphone_rounded,
                                    'Үндсэн утас', d.phone),
                                if (d.phone2 != null)
                                  _infoTile(Icons.phone_enabled_rounded,
                                      'Нэмэлт утас 1', d.phone2),
                                if (d.phone3 != null)
                                  _infoTile(Icons.phone_enabled_rounded,
                                      'Нэмэлт uтас 2', d.phone3),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoSection(
                              title: 'Санхүүгийн мэдээлэл',
                              items: [
                                _infoTile(
                                    Icons.account_balance_wallet_rounded,
                                    'Зээлийн лимит',
                                    (d.loanLimitUse == true)
                                        ? toPrice(d.loanLimit)
                                        : 'Ашиглахгүй'),
                                _infoTile(Icons.badge_rounded,
                                    'Регистрийн дугаар', d.rn),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoSection(
                              title: 'Бусад',
                              items: [
                                _infoTile(Icons.description_rounded,
                                    'Тэмдэглэл', d.note,
                                    isMultiLine: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  // 1. Header хэсэг: Нэр болон Social товчлуурууд
  Widget _buildHeader(CustomerDetail d) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Text(
                d.name?.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold, color: primary),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            d.name ?? 'Нэргүй харилцагч',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                contacting.entries.map((e) => _buildQuickAction(e, d)).toList(),
          ),
        ],
      ),
    );
  }

  // Quick Action Buttons (Call, Mail, Location, FB)
  Widget _buildQuickAction(MapEntry<String, IconData> e, CustomerDetail d) {
    return Column(
      children: [
        InkWell(
          onTap: () => handleSocial(e.key, d),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Icon(e.value, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(e.key, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  // Мэдээллийн бүлэг (Card style)
  Widget _buildInfoSection(
      {required String title, required List<Widget> items}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: primary)),
          ),
          const Divider(height: 1),
          ...items,
        ],
      ),
    );
  }

  // Мэдээллийн мөр бүр
  Widget _infoTile(IconData icon, String label, String? value,
      {bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment:
            isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 2),
                Text(
                  (value == null || value.isEmpty) ? '-' : value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  handleSocial(String key, CustomerDetail d) {
    switch (key) {
      case 'Мейл':
        if (d.email == null || d.email!.isEmpty) {
          messageWarning('Мэйл хаяг байхгүй байна');
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
          messageWarning('Утасны дугаар байхгүй байна');
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
        goto(LocationPicker(customer: widget.customer));
        break;
      default:
        break;
    }
  }

  Widget contactWidget(String title, List<String> vals, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        spacing: 10.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: mediumFontSize,
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
