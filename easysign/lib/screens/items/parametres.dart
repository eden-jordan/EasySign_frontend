import 'package:flutter/material.dart';

class Parametres extends StatelessWidget {
  const Parametres({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
      ),
      body: const Center(child: Text("Page de parametres")),
    );
  }
}
