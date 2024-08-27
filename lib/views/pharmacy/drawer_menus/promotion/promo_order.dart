import 'package:flutter/material.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';

class PromoOrder extends StatelessWidget {
  const PromoOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: Text('Урамшууллын захиалга'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, idx) {
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
