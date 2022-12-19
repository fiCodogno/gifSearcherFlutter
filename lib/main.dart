import 'package:flutter/material.dart';
import 'package:gif_searcher/ui/home_page.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const HomePage(),
    title: "Buscador de GIFs",
    color: Colors.black,
    theme: ThemeData(
      hintColor: Colors.white,
      primaryColor: Colors.white
    ),
  ));
}