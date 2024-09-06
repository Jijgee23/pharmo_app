import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:provider/provider.dart';

class NoData extends StatelessWidget {
  const NoData({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, child) => SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size(double.infinity, 60),
            child: Container(
              decoration: const BoxDecoration(color: Colors.greenAccent),
            ),
          ),
          body: Container(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Column(
                children: [
                  TextField(
                    controller: TextEditingController(),
                    onChanged: (value) {
                      home.changeDemo(value);
                    },
                  ),
                  InkWell(
                      onTap: () {
                        
                      },
                      child: Text(home.demo)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
