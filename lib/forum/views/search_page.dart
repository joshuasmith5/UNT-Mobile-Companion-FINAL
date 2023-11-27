import 'package:flutter/material.dart';
import '/forum/palette.dart';
import '/forum/views/app_bar.dart';
import '/forum/views/post_search_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Container(
        color: Palette.greentodark,
        child: Column(
          children: [
            Container(
              color: Palette.greentodark,
              padding: const EdgeInsets.only(
                  top: 16, bottom: 16, left: 16, right: 16),
              child: Row(
                children: const [
                  Text(
                    'Search for Posts',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        labelStyle: TextStyle(
                            color: Colors.white, fontSize: 20),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                        onPressed: () async {
                          var search = searchController.text;
                          if (search.isEmpty) {
                            //show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Please fill in all fields')));
                            return;
                          }

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PostPage(search: search)));
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('Search')),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
