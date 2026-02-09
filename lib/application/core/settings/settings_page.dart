import 'package:pharmo_app/application/application.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: Text('Төхөөрөмжийн тохиргоо'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.refresh),
            )
          ],
        ),
        body: Column(
          children: [
            Text('Баттерэйн түвшин: ${value.batteryLevel}'),
          ],
        ).paddingAll(20),
      ),
    );
  }
}
