import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/overlay_helper.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  int selectedIndex = 0;
  final GlobalKey _inkWellKey = GlobalKey(); // InkWell-д зориулсан Key
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Demo Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 10,
              right: 10,
              child: InkWell(
                key: _inkWellKey,
                onTap: () {
                  OverlayHelper().showOverlay(
                    context,
                    child: _buildOverlayWidget(),
                    key: _inkWellKey,
                  );
                },
                child: Container(
                  height: Sizes.height * .17,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          )
        ],
      ),
      child: Center(
        child: const Text(
          'This is an overlay widget!',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
