import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sentence_shuffle_bloc.dart';
import 'events.dart';
import 'states.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final shuffledWords = '가게에 가서 쇼핑한다.'.split(' ');
    shuffledWords.shuffle(Random());

    return MaterialApp(
      title: 'Sentence Shuffle App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => SentenceShuffleBloc(
          sentence: '가게에 가서 쇼핑한다.',
          shuffledWords: shuffledWords,
        ),
        child: SentenceShufflePage(),
      ),
    );
  }
}

class SentenceShufflePage extends StatelessWidget {
  // Add the _buildDraggableBox function
  Widget _buildDraggableBox(String word) {
    return Draggable<String>(
      data: word,
      child: Container(
        height: 50,
        width: 100,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(word, style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      feedback: Container(
        height: 50,
        width: 100,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(word, style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      childWhenDragging: Container(),
    );
  }

  // Add the _buildDragTargetBox function
  Widget _buildDragTargetBox(BuildContext context, int index) {
    return DragTarget<String>(
      builder: (BuildContext context, List<String?> candidateData, List<dynamic> rejectedData) {
        final SentenceShuffleState state = BlocProvider.of<SentenceShuffleBloc>(context).state;
        return Container(
          height: 50,
          width: state.targetWords[index].isEmpty ? 100 : null,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: state.targetWords[index].isEmpty
                ? Text('')
                : Text(state.targetWords[index], style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),
        );
      },
      onWillAccept: (String? data) {
        final SentenceShuffleState state = BlocProvider.of<SentenceShuffleBloc>(context).state;
        return data != null && (state.targetWords[index] == '' || state.targetWords.contains(data));
      },
      onAccept: (String? data) {
        if (data != null) {
          final SentenceShuffleState state = BlocProvider.of<SentenceShuffleBloc>(context).state;
          int previousIndex = state.targetWords.indexOf(data);
          if (previousIndex != -1) {
            List<String> updatedTargetWords = List.from(state.targetWords);
            updatedTargetWords[previousIndex] = '';
            BlocProvider.of<SentenceShuffleBloc>(context)
                .add(SentenceWordDroppedEvent(word: '', targetIndex: previousIndex));
          }
          BlocProvider.of<SentenceShuffleBloc>(context)
              .add(SentenceWordDroppedEvent(word: data, targetIndex: index));
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
      body: BlocBuilder<SentenceShuffleBloc, SentenceShuffleState>(
        builder: (context, state) {
          if (state is SentenceShuffleInProgress) {
            return Center(
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
                    children: state.shuffledWords.map(_buildDraggableBox)
                        .toList(),
                  ),
                  SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(state.targetWords.length, (index) =>
                        _buildDragTargetBox(context, index)),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<SentenceShuffleBloc>(context).add(
                          SentenceCheckAnswerEvent());
                    },
                    child: Text('Check Answer'),
                  ),
                ],
              ),
            );
          } else if (state is SentenceShuffleCorrect) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Congratulations! You have reordered the sentence correctly!',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<SentenceShuffleBloc>(context).add(
                          SentenceResetEvent());
                    },
                    child: Text('Reset'),
                  ),
                ],
              ),
            );
          } else if (state is SentenceShuffleIncorrect) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Try again! The sentence is not in the correct order.',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<SentenceShuffleBloc>(context).add(
                          SentenceResetEvent());
                    },
                    child: Text('Reset'),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
