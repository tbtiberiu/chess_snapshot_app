import 'package:chess_snapshot_app/providers/fen_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
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
  late String _fen;
  late chesslib.Chess _chess;
  late ValueNotifier<chesslib.Chess> _chessNotifier;
  var _blackAtBottom = false;
  BoardArrow? _lastMoveArrowCoordinates;
  late ChessBoardColors _boardColors;

  @override
  void initState() {
    _fen = chesslib.Chess.DEFAULT_POSITION;
    _chess = chesslib.Chess.fromFEN(_fen);
    _chessNotifier = ValueNotifier<chesslib.Chess>(_chess);
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

  @override
  void dispose() {
    _chessNotifier.dispose();
    super.dispose();
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
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: ValueListenableBuilder<chesslib.Chess>(
                    valueListenable: _chessNotifier,
                    builder: (context, chess, _) {
                      return SimpleChessBoard(
                          chessBoardColors: _boardColors,
                          engineThinking: false,
                          fen: chess.fen,
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
                          });
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              child: Container(
                padding: const EdgeInsets.all(3.0),
                decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(width: 1), bottom: BorderSide(width: 1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _blackAtBottom = !_blackAtBottom;
                        });
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.rotate,
                        size: 36,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        updateBoard(context);
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.upload,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateBoard(BuildContext context) {
    final fenProvider = Provider.of<FenProvider>(context, listen: false);
    _fen = fenProvider.fen;
    _chess = chesslib.Chess.fromFEN(_fen);
    _chessNotifier.value = _chess;
  }
}
