import 'package:equatable/equatable.dart';

class SentenceLoadEvent extends Equatable {
  final Future<String> Function() fetchRandomSentence;

  SentenceLoadEvent(this.fetchRandomSentence);

  @override
  List<Object> get props => [fetchRandomSentence];
}
