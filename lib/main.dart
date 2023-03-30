import 'package:cantorean/cheatsheet_page.dart';
import 'package:cantorean/widgets/drag_target_box.dart';
import 'package:cantorean/widgets/draggable_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/sentence_shuffle_bloc.dart';
import 'bloc/events.dart';
import 'bloc/states.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
//fetch CSV
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'model/firebase_options.dart';

const Color pantoneOrange = Color(0xFFDEA07D);
const Color pantoneBlue = Color(0x8AABD1E8);

Future<Map<String, dynamic>> fetchSentences() async {
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
    String randomSentence = randomRow[0].toString();

    // Get all sentences
    List<String> sentences = csvTable.sublist(1).map((row) => row[0].toString()).toList();

    return {
      'randomSentence': randomSentence,
      'sentences': sentences,
    };
  } catch (error) {
    print('Error in fetchSentences: $error');
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoSentenceShufflePage(),
    );
  }
}

class CupertinoSentenceShufflePage extends StatefulWidget {
  @override
  _CupertinoSentenceShufflePageState createState() => _CupertinoSentenceShufflePageState();
}

class _CupertinoSentenceShufflePageState extends State<CupertinoSentenceShufflePage> {
  int gamesPlayed = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  String? sentence;
  void _incrementGamesPlayed() {
    setState(() {
      gamesPlayed++;
    });
  }

  void _incrementCorrectAnswers() {
    setState(() {
      correctAnswers++;
    });
  }

  void _incrementWrongAnswers() {
    setState(() {
      wrongAnswers++;
    });
  }
  @override
  void initState() {
    super.initState();
    loadSentence();
  }

  Future<void> loadSentence() async {
    final newSentence = await fetchRandomSentence();
    setState(() {
      sentence = newSentence;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.book_solid,
              color: CupertinoColors.white,
              size: 20, // Adjust the icon size here
            ),
            SizedBox(width: 4), // Adjust the space between icon and text
            Text(
              'Cantorean',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 16, // Adjust the font size here
              ),
            ),
          ],
        ),
        backgroundColor: pantoneOrange,
        border: Border.all(width: 0, color: pantoneOrange), // Remove the border
      ),
      child: Stack(
          children: [
            FutureBuilder(
              future: fetchSentences(),
              builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                if (snapshot.hasData) {
                  final sentence = snapshot.data!['randomSentence'] as String;
                  final sentences = snapshot.data!['sentences'] as List<String>;

          final shuffledWords = sentence.split(' ')..shuffle();
          return BlocProvider(
              create: (context) => SentenceShuffleBloc(sentence: sentence, shuffledWords: shuffledWords),
              child: BlocListener<SentenceShuffleBloc, SentenceShuffleState>(
                listener: (context, state) {
                  if (state is SentenceShuffleCorrect) {
                    _incrementCorrectAnswers();
                  } else if (state is SentenceShuffleIncorrect) {
                    _incrementWrongAnswers();
                  }
                },
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
                            children: state.shuffledWords
                                .map((word) => DraggableBox(word: word))
                                .toList(),
                          ),
                          SizedBox(height: 20),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: List.generate(
                              state.targetWords.length,
                                  (index) => DragTargetBox(index: index),
                            ),
                          ),
                          SizedBox(height: 20),
                          CupertinoButton(
                            color: pantoneOrange,
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
                            if (gamesPlayed < 5) // Only show the "Next Sentence" button if the user has not reached the limit
                              CupertinoButton(
                                color: pantoneOrange,
                                onPressed: () async {
                                  final newSentence = await fetchRandomSentence();
                                  final newShuffledWords = newSentence.split(' ')..shuffle();
                                  BlocProvider.of<SentenceShuffleBloc>(context).add(
                                      SentenceNewQuestionEvent(
                                          sentence: newSentence, shuffledWords: newShuffledWords));
                                  _incrementGamesPlayed(); // Call the callback here
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
                            CupertinoButton(
                              color: pantoneOrange,
                              onPressed: () {
                                BlocProvider.of<SentenceShuffleBloc>(context).add(SentenceResetEvent());
                                setState(() {
                                  wrongAnswers++;
                                });
                              },
                              child: Text('Reset'),
                            ),
                            CupertinoButton(
                              color: pantoneOrange,
                              onPressed: () async {
                                final newSentence = await fetchRandomSentence();
                                final newShuffledWords = newSentence.split(' ')..shuffle();
                                BlocProvider.of<SentenceShuffleBloc>(context).add(
                                    SentenceNewQuestionEvent(
                                        sentence: newSentence, shuffledWords: newShuffledWords));
                                _incrementGamesPlayed();
                                setState(() {
                                  correctAnswers++;
                                });
                              },
                              child: Text('Next Sentence'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(child: CupertinoActivityIndicator());
                    }
                  },
                ),
              ),
          );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error loading sentence"));
                } else {
                  return Center(child: CupertinoActivityIndicator());
                }
              },
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Correct: $correctAnswers',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Wrong: $wrongAnswers',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              top: 16,
              child: CupertinoButton(
                onPressed: () async {
                  final sentences = await fetchSentences();
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => CheatsheetPage(sentences: sentences['sentences']),
                    ),
                  );
                },
                child: Text('Cheatsheet'),
              ),
            ),
          ],
      ),
    );
  }
}
