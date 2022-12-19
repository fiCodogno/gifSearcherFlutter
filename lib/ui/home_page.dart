import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gif_searcher/ui/gif_page.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _search;
  int _offset = 0;

  Future<Map> _getSearch() async {
    http.Response response;

    if (_search == null || _search!.isEmpty) {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/trending?api_key=3f8u1Zr8wclGeGR0KQ94XUnVKJdKZ09L&limit=19&rating=g"));
    } else {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/search?api_key=3f8u1Zr8wclGeGR0KQ94XUnVKJdKZ09L&q=$_search&limit=19&offset=$_offset&rating=g&lang=en"));
    }

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    _getSearch().then((map) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                  labelText: "Pesquise Aqui!",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2))),
              style: const TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
              child: FutureBuilder(
                  future: _getSearch(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Container(
                          width: 200.0,
                          height: 200.0,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 5.0,
                          ),
                        );

                      default:
                        if (snapshot.hasError) {
                          return const Text(
                            "Erro ao carregar GIFs!",
                            style: TextStyle(fontSize: 20),
                          );
                        } else {
                          return _createGIFTable(context, snapshot);
                        }
                    }
                  }))
        ],
      ),
    );
  }

  Widget _createGIFTable(
      BuildContext context, AsyncSnapshot<Object?> snapshot) {
    return GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: (snapshot.data! as Map<String, dynamic>)['data'].length + 1,
        itemBuilder: (context, index) {
          if (index < (snapshot.data! as Map<String, dynamic>)['data'].length) {
            var snap = (snapshot.data! as Map<String, dynamic>)['data'][index]
                ['images']['fixed_height']['url'];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) =>
                            GifPage((snapshot.data! as Map<String, dynamic>)['data'][index])
                        )
                    )
                );
              },
              onLongPress: (){
                Share.share(snap);
              },
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage, 
                image: snap,
                height: 300,
                fit: BoxFit.cover,
              ),
            );
          } else {
            return Container(
                child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add, color: Colors.white, size: 70.0),
                  Text("Carregar mais...",
                      style: TextStyle(color: Colors.white, fontSize: 22.0))
                ],
              ),
              onTap: () {
                setState(() {
                  _offset += 19;
                });
              },
            ));
          }
        });
  }
}
