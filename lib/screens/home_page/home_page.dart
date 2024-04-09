import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_controller.dart';
import 'package:pharmo_app/screens/login_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List _pages = [
    const HomeTab(),
    const Center(
      child: Text("About"),
    ),
    const Center(
      child: Text("Products"),
    ),
    const Center(
      child: Text("Contact"),
    ),
  ];
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    //  final authController = Provider.of<AuthController>(context);

    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: SafeArea(
        child: Scaffold(
          drawer: Drawer(
            child: ListView(
              children: [
                const DrawerHeader(
                  curve: Curves.bounceIn,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Text('Profile'),
                        Column(
                          children: [],
                        )
                      ],
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Item 1'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('logout'),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => const LoginPage())),
                        (route) => false);
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Хэрэглэгчийн байршил'),
            actions: [
              IconButton(
                  icon: const Icon(
                    Icons.notifications,
                    color: Colors.blue,
                  ),
                  onPressed: () {}),
            ],
          ),
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Нүүр',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Хайх',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shop_2),
                label: 'Бараа',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_sharp),
                label: 'Бүртгэл',
              ),
            ],
            backgroundColor: Colors.blue,
            selectedItemColor: Colors.pink[500],
            unselectedItemColor: Colors.blue,
          ),
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      child: Column(
        children: [
          Text('Home Tab'),
        ],
      ),
    );
  }
}
