import 'package:pharmo_app/controller/a_controlller.dart';
import 'package:pharmo_app/application/utilities/colors.dart';

class SystemLog extends StatefulWidget {
  const SystemLog({super.key});

  @override
  State<SystemLog> createState() => _SystemLogState();
}

class _SystemLogState extends State<SystemLog> {
  @override
  void initState() {
    super.initState();
    getLOgs();
  }

  void getLOgs() async {
    final log = context.read<LogProvider>();
    await log.getLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Системийн лог',
          style: TextStyle(fontSize: 14),
        ),
        centerTitle: false,
      ),
      body: Consumer<LogProvider>(
        builder: (context, value, child) => ListView.builder(
          itemCount: value.logs.length,
          itemBuilder: (context, i) {
            var item = value.logs[i];
            var date = item.date;
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.cleanBlack),
                ),
              ),
              child: ListTile(
                title: Text(
                  item.desc,
                  style: TextStyle(color: black),
                ),
                dense: true,
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date.split('T')[0],
                      style: TextStyle(color: black),
                    ),
                    Text(
                      date.split('T')[1].substring(0, 5),
                      style: TextStyle(color: black),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
