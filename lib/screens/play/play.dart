import 'package:flutter/material.dart';
import 'package:simple_chess_board/models/board_arrow.dart';
import 'package:chess/chess.dart' as chesslib;
import 'package:simple_chess_board/simple_chess_board.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Snapshot App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const MyPlayScreen(title: 'Play Chess'),
    );
  }
}

class MyPlayScreen extends StatefulWidget {
  const MyPlayScreen({super.key, required this.title});

  final String title;

  @override
  State<MyPlayScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyPlayScreen> {
  final _chess = chesslib.Chess.fromFEN(chesslib.Chess.DEFAULT_POSITION);
  var _blackAtBottom = false;
  BoardArrow? _lastMoveArrowCoordinates;
  late ChessBoardColors _boardColors;

  @override
  void initState() {
    _boardColors = ChessBoardColors()
      ..lightSquaresColor = Colors.blue.shade200
      ..darkSquaresColor = Colors.blue.shade600
      ..coordinatesZoneColor = Colors.redAccent.shade200
      ..lastMoveArrowColor = Colors.cyan
      ..startSquareColor = Colors.orange
      ..endSquareColor = Colors.green
      ..circularProgressBarColor = Colors.red
      ..coordinatesColor = Colors.green;
    super.initState();
  }

  void tryMakingMove({required ShortMove move}) {
    final success = _chess.move(<String, String?>{
      'from': move.from,
      'to': move.to,
      'promotion': move.promotion?.name,
    });
    if (success) {
      setState(() {
        _lastMoveArrowCoordinates = BoardArrow(from: move.from, to: move.to);
      });
    }
  }

  Future<PieceType?> handlePromotion(BuildContext context) {
    final navigator = Navigator.of(context);
    return showDialog<PieceType>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Promotion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Queen"),
                onTap: () => navigator.pop(PieceType.queen),
              ),
              ListTile(
                title: const Text("Rook"),
                onTap: () => navigator.pop(PieceType.rook),
              ),
              ListTile(
                title: const Text("Bishop"),
                onTap: () => navigator.pop(PieceType.bishop),
              ),
              ListTile(
                title: const Text("Knight"),
                onTap: () => navigator.pop(PieceType.knight),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _blackAtBottom = !_blackAtBottom;
              });
            },
            icon: const Icon(Icons.swap_vert),
          )
        ],
      ),
      body: Center(
        child: SimpleChessBoard(
            chessBoardColors: _boardColors,
            engineThinking: false,
            fen: _chess.fen,
            onMove: tryMakingMove,
            blackSideAtBottom: _blackAtBottom,
            whitePlayerType: PlayerType.human,
            blackPlayerType: PlayerType.human,
            lastMoveToHighlight: _lastMoveArrowCoordinates,
            onPromote: () => handlePromotion(context),
            onPromotionCommited: ({
              required ShortMove moveDone,
              required PieceType pieceType,
            }) {
              moveDone.promotion = pieceType;
              tryMakingMove(move: moveDone);
            }),
      ),
    );
  }
}
