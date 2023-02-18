import 'package:flutter/material.dart';

class Spark extends StatelessWidget {
  const Spark({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 70.0, centerTitle: false, title: const Text("Spark"), actions: const []),
      body: Container(),
    );
  }
}
