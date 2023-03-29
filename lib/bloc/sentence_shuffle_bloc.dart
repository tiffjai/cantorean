import 'events.dart';

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'events.dart';
import 'states.dart';

class SentenceShuffleBloc extends Bloc<SentenceShuffleEvent, SentenceShuffleState> {
  String sentence;
  final List<String> shuffledWords;

  SentenceShuffleBloc({required this.sentence, required List<String> shuffledWords})
      : shuffledWords = List<String>.from(shuffledWords),
        super(SentenceShuffleInProgress(shuffledWords: shuffledWords, targetWords: List<String>.filled(shuffledWords.length, ''))) {
    on<SentenceWordDroppedEvent>((event, emit) async {
      List<String> targetWords = List.from(state.targetWords);
      targetWords[event.targetIndex] = event.word;

      emit(SentenceShuffleInProgress(shuffledWords: state.shuffledWords, targetWords: targetWords));
    });

    on<SentenceCheckAnswerEvent>((event, emit) async {
      bool isCorrect = listEquals(state.targetWords, sentence.split(' '));

      if (isCorrect) {
        emit(SentenceShuffleCorrect(shuffledWords: state.shuffledWords, targetWords: state.targetWords));
      } else {
        emit(SentenceShuffleIncorrect(shuffledWords: state.shuffledWords, targetWords: state.targetWords));
      }
    });

    on<SentenceResetEvent>((event, emit) async {
      List<String> targetWords = List<String>.filled(state.shuffledWords.length, '');

      emit(SentenceShuffleInProgress(shuffledWords: state.shuffledWords, targetWords: targetWords));
    });

    // Modify the event handling code
    on<SentenceNewQuestionEvent>((event, emit) async {
      sentence = event.sentence;
      List<String> newShuffledWords = event.shuffledWords;

      emit(SentenceShuffleInProgress(
        shuffledWords: newShuffledWords,
        targetWords: List.filled(newShuffledWords.length, ''),
      ));
    });
  }
}
