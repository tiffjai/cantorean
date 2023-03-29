


abstract class SentenceShuffleEvent {}

class SentenceWordDroppedEvent extends SentenceShuffleEvent {
  final String word;
  final int targetIndex;

  SentenceWordDroppedEvent({required this.word, required this.targetIndex});
}

class SentenceCheckAnswerEvent extends SentenceShuffleEvent {}

class SentenceResetEvent extends SentenceShuffleEvent {}

//next question event
class SentenceNewQuestionEvent extends SentenceShuffleEvent {
  final String sentence;
  final List<String> shuffledWords;

  SentenceNewQuestionEvent({required this.sentence, required this.shuffledWords});

  @override
  List<Object> get props => [sentence, shuffledWords];
}

