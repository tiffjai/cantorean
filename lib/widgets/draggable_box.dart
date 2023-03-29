import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DraggableBox extends StatelessWidget {
  final String word;

  DraggableBox({required this.word});

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: word,
      child: Container(
        height: 50,
        width: 100,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0x8AABD1E8),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(word, style: TextStyle(color: CupertinoColors.activeOrange, fontSize: 16)),
      ),
      feedback: Container(
        height: 50,
        width: 100,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0x8AABD1E8).withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(word, style: TextStyle(color: CupertinoColors.activeOrange, fontSize: 16)),
      ),
      childWhenDragging: Container(),
    );
  }
}
