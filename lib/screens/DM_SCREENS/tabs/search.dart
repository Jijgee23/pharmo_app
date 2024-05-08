import 'package:flutter/material.dart';
import 'package:pharmo_app/widgets/product_detail.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchType = 'Нэрээр';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(size.height * 0.02),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: size.height * 0.08,
              pinned: true,
              flexibleSpace: TextField(
                decoration: InputDecoration(
                  hintText: 'Барааны $searchType хайх',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: () {
                      showMenu(
                        context: context,
                        position: const RelativeRect.fromLTRB(150, 20, 0, 0),
                        items: <PopupMenuEntry>[
                          PopupMenuItem(
                            value: 'item1',
                            onTap: () {
                              setState(() {
                                searchType = 'нэрээр';
                              });
                            },
                            child: const Text('нэрээр'),
                          ),
                          PopupMenuItem(
                            value: 'item2',
                            onTap: () {
                              setState(() {
                                searchType = 'баркодоор';
                              });
                            },
                            child: const Text('Баркодоор'),
                          ),
                          PopupMenuItem(
                            value: 'item3',
                            onTap: () {
                              setState(() {
                                searchType = 'ерөнхий нэршлээр';
                              });
                            },
                            child: const Text('Ерөнхий нэршлээр'),
                          ),
                        ],
                      ).then((value) {});
                    },
                    icon: const Icon(Icons.change_circle),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProductDetail(
                                  productName: 'Нэр $index',
                                  productPrice: 'price')));
                    },
                    title: Text('Item $index'),
                    subtitle: Text('Барааны нэр $index'),
                    trailing: const Text('price'),
                  );
                },
                childCount: 15, // Example list of items
              ),
            ),
          ],
        ),
      ),
    );
  }
}
