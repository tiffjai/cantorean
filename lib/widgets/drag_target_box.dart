import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cantorean/bloc/sentence_shuffle_bloc.dart';
import 'package:cantorean/bloc/events.dart';
import 'package:cantorean/bloc/states.dart';

class DragTargetBox extends StatelessWidget {
  final int index;

  DragTargetBox({required this.index});

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      builder: (BuildContext context, List<String?> candidateData, List<dynamic> rejectedData) {
        final SentenceShuffleState state = BlocProvider.of<SentenceShuffleBloc>(context).state;
        return Container(
          height: 50,
          width: state.targetWords[index].isEmpty ? 100 : null,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0x8AABD1E8)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: state.targetWords[index].isEmpty
                ? Text('')
                : Text(state.targetWords[index], style: TextStyle(color: Color(0x8AABD1E8), fontSize: 16)),
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
}
