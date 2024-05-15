import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:chess/chess.dart' as chess;
import 'chess_snapshot_chessboard.dart';

class AdvancedOptions extends StatefulWidget {
  final String currentFen;
  final Labels labels = Labels();

  final void Function(bool value) onTurnChanged;
  final void Function(String) onPositionFenSubmitted;

  AdvancedOptions({
    super.key,
    required this.currentFen,
    required this.onTurnChanged,
    required this.onPositionFenSubmitted,
  });

  @override
  State<AdvancedOptions> createState() => _AdvancedOptionsState();
}

class _AdvancedOptionsState extends State<AdvancedOptions> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FenControlsWidget(
              currentFen: widget.currentFen,
              labels: widget.labels,
              onPositionFenSubmitted: widget.onPositionFenSubmitted,
            ),
            const Divider(
              color: Colors.black,
            ),
            TurnWidget(
              labels: widget.labels,
              currentFen: widget.currentFen,
              onTurnChanged: widget.onTurnChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class TurnWidget extends StatelessWidget {
  final Labels labels;
  final String currentFen;
  final void Function(bool turn) onTurnChanged;

  const TurnWidget({
    super.key,
    required this.labels,
    required this.currentFen,
    required this.onTurnChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isWhiteTurn = currentFen.split(' ')[1] == 'w';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labels.playerTurnLabel,
        ),
        ListTile(
          title: Text(
            labels.whitePlayerLabel,
            style: const TextStyle(fontSize: 13),
          ),
          leading: Radio<bool>(
            groupValue: isWhiteTurn,
            value: true,
            onChanged: (value) {
              onTurnChanged(value ?? true);
            },
          ),
        ),
        ListTile(
          title: Text(
            labels.blackPlayerLabel,
            style: const TextStyle(fontSize: 13),
          ),
          leading: Radio<bool>(
            groupValue: isWhiteTurn,
            value: false,
            onChanged: (value) {
              onTurnChanged(value ?? false);
            },
          ),
        ),
      ],
    );
  }
}

class FenControlsWidget extends StatelessWidget {
  final Labels labels;
  final String currentFen;
  final void Function(String) onPositionFenSubmitted;

  const FenControlsWidget({
    super.key,
    required this.labels,
    required this.currentFen,
    required this.onPositionFenSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(labels.currentPositionLabel),
              ),
              FittedBox(
                child: Text(currentFen),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              FlutterClipboard.copy(currentFen);
            },
            child: Text(labels.copyFenLabel),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              FlutterClipboard.paste().then((value) {
                if (chess.Chess.validate_fen(value)['valid']) {
                  onPositionFenSubmitted(value);
                }
              });
            },
            child: Text(labels.pasteFenLabel),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              onPositionFenSubmitted(
                  "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
            },
            child: Text(labels.resetPosition),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              onPositionFenSubmitted("8/8/8/8/8/8/8/8 w - - 0 1");
            },
            child: Text(labels.erasePosition),
          ),
        )
      ],
    );
  }
}
