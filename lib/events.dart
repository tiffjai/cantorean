abstract class SentenceShuffleEvent {}

class SentenceWordDroppedEvent extends SentenceShuffleEvent {
  final String word;
  final int targetIndex;

  SentenceWordDroppedEvent({required this.word, required this.targetIndex});
}

class SentenceCheckAnswerEvent extends SentenceShuffleEvent {}

class SentenceResetEvent extends SentenceShuffleEvent {}
