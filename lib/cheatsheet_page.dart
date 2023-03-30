import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CheatsheetPage extends StatefulWidget {
  final List<String> sentences;

  CheatsheetPage({required this.sentences});

  @override
  _CheatsheetPageState createState() => _CheatsheetPageState();
}

class _CheatsheetPageState extends State<CheatsheetPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Cheatsheet'),
        trailing: CupertinoButton(
          padding: EdgeInsets.all(0),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Back'),
        ),
      ),
      child: SafeArea(
        child: ListView.builder(
          itemCount: widget.sentences.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.sentences[index]),
            );
          },
        ),
      ),
    );
  }
}
