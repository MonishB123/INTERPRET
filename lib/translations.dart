import 'package:flutter/material.dart';

List<Padding> translateList = <Padding>[];

class SavedTranslationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Translations'),
      ),
      body: ListView(
        children: translateList,
      ),
    );
  }
}
