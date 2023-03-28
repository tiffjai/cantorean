import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentence Shuffle App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SentenceShufflePage(),
    );
  }
}

class SentenceShufflePage extends StatefulWidget {
  @override
  _SentenceShufflePageState createState() => _SentenceShufflePageState();
}

class _SentenceShufflePageState extends State<SentenceShufflePage> {
  final String sentence = '가게에 가서 쇼핑한다.';
  late List<String> shuffledWords;
  late List<String> targetWords;

  @override
  void initState() {
    super.initState();
    shuffledWords = sentence.split(' ');
    shuffledWords.shuffle();
    targetWords = List.filled(shuffledWords.length, '');
  }

  Widget _buildDraggableBox(String word) {
    return Draggable<String>(
      data: word,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(word, style: TextStyle(color: Colors.white)),
      ),
      feedback: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(word, style: TextStyle(color: Colors.white)),
      ),
      childWhenDragging: Container(),
    );
  }

  Widget _buildDragTargetBox(int index) {
    return DragTarget<String>(
      builder: (BuildContext context, List<String?> candidateData, List<dynamic> rejectedData) {
        return Container(
          height: 50,
          width: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(child: Text(targetWords[index])),
        );
      },
      onWillAccept: (String? data) => data != null && targetWords[index] == '',
      onAccept: (String? data) {
        if (data != null) {
          setState(() {
            int originalIndex = targetWords.indexOf(data);
            if (originalIndex != -1) {
              targetWords[originalIndex] = '';
            }
            targetWords[index] = data;
          });
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sentence Shuffle App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Drag the words to the boxes to form the correct sentence:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: shuffledWords.map(_buildDraggableBox).toList(),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(targetWords.length, _buildDragTargetBox),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (targetWords.join(' ') == sentence) {
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text
                          ('Congratulations!'),
                        content: Text(
                            'You have reordered the sentence correctly!'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Try again!'),
                        content: Text(
                            'The sentence is not in the correct order.'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Check Answer'),
            ),
          ],
        ),
      ),
    );
  }
}