import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmo_app/application/application.dart';

class CompleteRegistration extends StatefulWidget {
  final String ema;
  final String pass;
  const CompleteRegistration({
    super.key,
    required this.ema,
    required this.pass,
  });

  @override
  State<CompleteRegistration> createState() => _CompleteRegistrationState();
}

class _CompleteRegistrationState extends State<CompleteRegistration> {
  final rd = TextEditingController();
  final name = TextEditingController();
  final publicName = TextEditingController();
  final address = TextEditingController();
  final additional = TextEditingController();
  final inviCode = TextEditingController();
  final addressDetail = TextEditingController();
  String selectedType = 'Чиглэл';
  setType(String n) {
    setState(() {
      selectedType = n;
    });
  }

  bool picked = false;
  setPicked(bool b) {
    setState(() {
      picked = b;
    });
  }

  // File? image;
  File? logo;
  Future<void> _pickLogo() async {
    await Permission.storage.request();
    await Permission.camera.request();
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      logo = File(pickedFile!.path);
    });
  }

  List<File> licenses = [];

  addImageToLicenses(File file) {
    setState(() {
      licenses.add(file);
    });
  }

  Future<void> _pickFromDevice() async {
    await Permission.storage.request();
    await Permission.camera.request();
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    addImageToLicenses(File(pickedFile!.path));
  }

  void _removeImage(File file) {
    setState(() {
      licenses.remove(file);
    });
  }

  void _removeLogo() {
    setState(() {
      logo = null;
    });
  }

  List<String> types = ['Эмийн сан', 'Эм ханган нийлүүлэгч'];
  late HomeProvider home;
  @override
  initState() {
    super.initState();
    home = Provider.of<HomeProvider>(context, listen: false);
    home.getPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SideAppBar(text: 'Бүртгэл гүйцээх'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: mediumFontSize),
        child: Wrap(
          spacing: context.width / 2,
          runSpacing: bigFontSize,
          children: [
            const SizedBox(),
            CustomTextField(controller: rd, hintText: 'Байгууллагын РД'),
            CustomTextField(controller: name, hintText: 'Байгууллагын нэр'),
            CustomTextField(controller: publicName, hintText: 'Түгээмэл нэр'),
            typeSelector(context),
            DefInputContainer(
              title: logo != null ? 'Лого' : null,
              ontap: () => _pickLogo(),
              child: (logo == null)
                  ? const Text('Лого хавсаргах')
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.file(
                          logo!,
                          height: 50,
                          width: 50,
                        ),
                        IconButton(
                          onPressed: () => _removeLogo(),
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
            ),
            DefInputContainer(
              title: logo != null ? 'Тусгай зөвшөөрөл' : null,
              ontap: () => _pickFromDevice(),
              child: licenses.isEmpty
                  ? const Text('Тусгай зөвшөөрөл хавсаргах')
                  : Column(
                      spacing: 10,
                      children: [
                        IconButton(
                          onPressed: () => _pickFromDevice(),
                          icon: Icon(Icons.add),
                        ),
                        ...licenses.map((l) => selectedLic(l))
                      ],
                    ),
            ),
            CustomTextField(
                controller: additional, hintText: 'Нэмэлт мэдээлэл'),
            CustomTextField(controller: inviCode, hintText: 'Урилгын код'),
            Row(
              children: [
                Checkbox(
                  value: picked,
                  onChanged: (b) => setPicked(b!),
                ),
                Text(
                  'Одоогийн байршилаар бүртгэх',
                  style: TextStyle(color: context.theme.primaryColor),
                ),
              ],
            ),
            CustomTextField(
              controller: addressDetail,
              hintText: 'Хаягийн дэлгэрэнгүй',
            ),
            CustomButton(
              text: 'Баталгаажуулах',
              ontap: () => _registerComplete(),
            ),
            const SizedBox()
          ],
        ),
      ),
    );
  }

  Container selectedLic(File l) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Image.file(l),
          Positioned(
            right: 0,
            child: IconButton(
              onPressed: () => _removeImage(l),
              icon: Icon(Icons.delete),
            ),
          )
        ],
      ),
    );
  }

  Widget typeSelector(BuildContext context) {
    return DefInputContainer(
      ontap: () => showMenu(
          context: context,
          items: [
            ...types.map(
                (t) => PopupMenuItem(onTap: () => setType(t), child: Text(t)))
          ],
          position: RelativeRect.fromLTRB(
              context.width / 2, context.height / 4, bigFontSize, 0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(selectedType), const Icon(Icons.arrow_drop_down)],
      ),
    );
  }

  _registerComplete() async {
    final auth = Provider.of<AuthController>(context, listen: false);
    final home = Provider.of<HomeProvider>(context, listen: false);

    if (rd.text.isEmpty || name.text.isEmpty || publicName.text.isEmpty) {
      messageWarning('Талбарууд бөглөнө үү');
      return;
    }
    // if (image == null) {
    //   message('Тусгай зөвшөөрөл хавсаргана уу!');
    //   return;
    // }
    if (selectedType == "Чиглэл") {
      messageWarning('Байгууллагын чиглэлээ сонгоно уу!');
      return;
    }
    if (publicName.text.isEmpty) {
      messageWarning('Байгууллагын чиглэлээ сонгоно уу!');
      return;
    }
    if (logo == null) {
      messageWarning('Лого хавсаргана уу!');
      return;
    }
    if (licenses.isEmpty) {
      messageWarning('Тусгай зөвшөөрөл хавсаргана уу!');
      return;
    }
    dynamic res = await auth.completeRegistration(
      ema: widget.ema,
      pass: widget.pass,
      name: name.text,
      publicName: publicName.text,
      rd: rd.text,
      type: selectedType,
      license: licenses,
      lat: picked ? home.currentLatitude : null,
      lng: picked ? home.currentLongitude : null,
      logo: logo,
    );
    messageWarning(res['message']);
    if (res['errorType'] == 1) {
      Navigator.pop(context);
    }
  }
}
