import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sentence_shuffle_bloc.dart';
import 'events.dart';
import 'states.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
//fetch CSV
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<String> fetchRandomSentence() async {
  try {
    // Replace this with the path to your CSV file in Firebase Storage
    const String firebaseStorageCsvPath = 'koreansentences.csv';

    // Download the CSV file
    final csvContent = await FirebaseStorage.instance.ref(firebaseStorageCsvPath).getData();

    // Parse the CSV data
    final csvTable = CsvToListConverter().convert(utf8.decode(csvContent!));

    // Randomly select a row from the CSV table, skipping the header row
    final randomRow = csvTable[Random().nextInt(csvTable.length - 1) + 1];

    // Assume the sentence is in the first column of the row
    return randomRow[0].toString();
  } catch (error) {
    print('Error in fetchRandomSentence: $error');
    throw error;
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  // Create a future to store the Firebase initialization
  late Future<FirebaseApp> _initialization;

  // Add a new variable for the sentence future
  late Future<String> _sentenceFuture;

  @override
  void initState() {
    super.initState();
    _initialization = Firebase.initializeApp();
    _sentenceFuture = fetchRandomSentence();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text("Error initializing Firebase"),
              ),
            ),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return FutureBuilder<String>(
            future: _sentenceFuture,
            builder: (context, sentenceSnapshot) {
              if (sentenceSnapshot.connectionState == ConnectionState.done) {
                if (sentenceSnapshot.hasError) {
                  return MaterialApp(
                    home: Scaffold(
                      body: Center(
                        child: Text("Error loading sentence"),
                      ),
                    ),
                  );
                }

                return MaterialApp(
                  home: BlocProvider(
                    create: (context) => SentenceShuffleBloc(
                      sentence: sentenceSnapshot.data!,
                      shuffledWords: sentenceSnapshot.data!.split(' ').toList()..shuffle(),
                    ),
                    child: SentenceShufflePage(),
                  ),
                );
              } else {
                return MaterialApp(
                  home: Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
            },
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
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
      body: FutureBuilder(
        future: fetchRandomSentence(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            final sentence = snapshot.data!;
            final shuffledWords = sentence.split(' ')..shuffle();
            return BlocProvider(
              create: (context) => SentenceShuffleBloc(sentence: sentence, shuffledWords: shuffledWords),
              child: BlocBuilder<SentenceShuffleBloc, SentenceShuffleState>(
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
                            children: state.shuffledWords.map(_buildDraggableBox).toList(),
                          ),
                          SizedBox(height: 20),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(state.targetWords.length, (index) => _buildDragTargetBox(context, index)),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              BlocProvider.of<SentenceShuffleBloc>(context).add(SentenceCheckAnswerEvent());
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
                            onPressed: () async {
                              final newSentence = await fetchRandomSentence();
                              final newShuffledWords = newSentence.split(' ')..shuffle();
                              BlocProvider.of<SentenceShuffleBloc>(context)
                                  .add(SentenceNewQuestionEvent(sentence: newSentence, shuffledWords: newShuffledWords));
                            },
                            child: Text('Next Sentence'),
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
                              BlocProvider.of<SentenceShuffleBloc>(context).add(SentenceResetEvent());
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
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading sentence"));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}