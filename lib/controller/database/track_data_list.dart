import 'package:pharmo_app/controller/a_controlller.dart';

class TrackDataList extends StatelessWidget {
  const TrackDataList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        return Scaffold(
          appBar: AppBar(),
          body: Builder(builder: (context) {
            return ListView.builder(
              itemCount: jagger.trackDatas.length,
              itemBuilder: (context, index) {
                final data = jagger.trackDatas[index];
                final dates = data.date.toIso8601String().split("T");
                return ListTile(
                  dense: true,
                  tileColor: data.sended ? Colors.teal : Colors.redAccent,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dates[0]),
                      Text(dates[1].split('.')[0]),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(data.latitude.toString()),
                      Text(data.longitude.toString()),
                    ],
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }
}
