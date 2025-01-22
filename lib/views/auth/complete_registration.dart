import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/inputs/ibtn.dart';
import 'package:pharmo_app/widgets/ui_help/def_input_container.dart';
import 'package:provider/provider.dart';

class CompleteRegistration extends StatefulWidget {
  final String ema;
  final String pass;
  const CompleteRegistration(
      {super.key, required this.ema, required this.pass});

  @override
  State<CompleteRegistration> createState() => _CompleteRegistrationState();
}

class _CompleteRegistrationState extends State<CompleteRegistration> {
  final rd = TextEditingController();
  final name = TextEditingController();
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

  File? image;
  File? logo;
  Future<void> _pickLogo() async {
    await Permission.storage.request();
    await Permission.camera.request();
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      logo = File(pickedFile!.path);
    });
  }

  Future<void> _pickFromDevice() async {
    await Permission.storage.request();
    await Permission.camera.request();
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      image = File(pickedFile!.path);
    });
  }

  void _removeImage() {
    setState(() {
      image = null;
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
        padding: EdgeInsets.symmetric(horizontal: Sizes.mediumFontSize),
        child: Wrap(
          spacing: Sizes.width / 2,
          runSpacing: Sizes.bigFontSize,
          children: [
            const SizedBox(),
            CustomTextField(controller: rd, hintText: 'Байгууллагын РД'),
            CustomTextField(controller: name, hintText: 'Байгууллагын нэр'),
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
                        Ibtn(onTap: () => _removeLogo(), icon: Icons.delete)
                      ],
                    ),
            ),
            DefInputContainer(
              title: logo != null ? 'Тусгай зөвшөөрөл' : null,
              ontap: () => _pickFromDevice(),
              child: image == null
                  ? const Text('Тусгай зөвшөөрөл хавсаргах')
                  : Column(
                      children: [
                        Ibtn(onTap: () => _removeImage(), icon: Icons.delete),
                        Image.file(image!),
                      ],
                    ),
            ),
            CustomTextField(
                controller: additional, hintText: 'Нэмэлт мэдээлэл'),
            CustomTextField(controller: inviCode, hintText: 'Урилгын код'),
            Row(
              children: [
                Checkbox(value: picked, onChanged: (b) => setPicked(b!)),
                Text('Одоогийн байршилаар бүртгэх',
                    style: TextStyle(color: theme.primaryColor)),
              ],
            ),
            // DefInputContainer(
            //   child: const Text('Байршил сонгох'),
            //   ontap: () => goto(const LocationSelector()),
            // ),
            CustomTextField(
                controller: addressDetail, hintText: 'Хаягийн дэлгэрэнгүй'),
            CustomButton(
                text: 'Батлагаажуулах', ontap: () => _registerComplete()),
            const SizedBox()
          ],
        ),
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
              Sizes.width / 2, Sizes.height / 4, Sizes.bigFontSize, 0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(selectedType), const Icon(Icons.arrow_drop_down)],
      ),
    );
  }

  _registerComplete() async {
    final auth = Provider.of<AuthController>(context, listen: false);
    final home = Provider.of<HomeProvider>(context, listen: false);

    if (rd.text.isEmpty || name.text.isEmpty) {
      message('Талбарууд бөглөнө үү');
    } else {
      if (image == null) {
        message('Тусгай зөвшөөрөл хавсаргана уу!');
      } else if (selectedType == "Чиглэл") {
        message('Байгууллагын чиглэлээ сонгоно уу!');
      } else {
        dynamic res = await auth.completeRegistration(
          ema: widget.ema,
          pass: widget.pass,
          name: name.text,
          rd: rd.text,
          type: selectedType,
          license: image!,
          lat: picked ? home.currentLatitude : null,
          lng: picked ? home.currentLongitude : null,
          logo: logo,
        );
        message(res['message']);
        if (res['errorType'] == 1) {
          Navigator.pop(context);
        }
      }
    }
  }
}
