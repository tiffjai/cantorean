import 'package:flutter/foundation.dart';

abstract class SentenceShuffleState {
  final List<String> shuffledWords;
  final List<String> targetWords;

  SentenceShuffleState({required this.shuffledWords, required this.targetWords});
}

class SentenceShuffleInitial extends SentenceShuffleState {
  SentenceShuffleInitial({
    required List<String> shuffledWords,
    required List<String> targetWords,
  }) : super(shuffledWords: shuffledWords, targetWords: targetWords);
}

class SentenceShuffleInProgress extends SentenceShuffleState {
  SentenceShuffleInProgress({
    required List<String> shuffledWords,
    required List<String> targetWords,
  }) : super(shuffledWords: shuffledWords, targetWords: targetWords);
}

class SentenceShuffleCorrect extends SentenceShuffleState {
  SentenceShuffleCorrect({
    required List<String> shuffledWords,
    required List<String> targetWords,
  }) : super(shuffledWords: shuffledWords, targetWords: targetWords);
}

class SentenceShuffleIncorrect extends SentenceShuffleState {
  SentenceShuffleIncorrect({
    required List<String> shuffledWords,
    required List<String> targetWords,
  }) : super(shuffledWords: shuffledWords, targetWords: targetWords);
}
