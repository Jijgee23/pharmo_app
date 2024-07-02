import 'package:flutter/material.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lime[50],
      appBar:const CustomAppBar(
        title: 'Мэдэгдэлүүд',
      ),
      body:const Center(
        child: Text('Notification Page'),
      ),
    );
  }
}
