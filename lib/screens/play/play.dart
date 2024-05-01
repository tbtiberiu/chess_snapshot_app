import 'package:chess_snapshot_app/providers/fen_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:simple_chess_board/models/board_arrow.dart';
import 'package:chess/chess.dart' as chesslib;
import 'package:chess_snapshot_app/chess_position_detection.dart';
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
  ChessPositionDetection? chessPositionDetection;
  late chesslib.Chess _chess;
  late ValueNotifier<chesslib.Chess> _chessNotifier;
  var _blackAtBottom = false;
  BoardArrow? _bestMoveArrowCoordinates;
  late ChessBoardColors _boardColors;

  @override
  void initState() {
    super.initState();
    chessPositionDetection = ChessPositionDetection();
    _chess = chesslib.Chess.fromFEN(chesslib.Chess.DEFAULT_POSITION);
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
    updateBestMove();
  }

  @override
  void dispose() {
    _chessNotifier.dispose();
    super.dispose();
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
                          lastMoveToHighlight: _bestMoveArrowCoordinates,
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

  void tryMakingMove({required ShortMove move}) {
    final success = _chess.move(<String, String?>{
      'from': move.from,
      'to': move.to,
      'promotion': move.promotion?.name,
    });
    if (success) {
      updateBestMove();
    }
  }

  Future<void> updateBestMove() async {
    BoardArrow? bestMoveArrow;
    String? bestMove = await chessPositionDetection!.getBestMove(_chess.fen);
    if (bestMove != null) {
      String from = bestMove.substring(0, 2);
      String to = bestMove.substring(2);
      bestMoveArrow = BoardArrow(from: from, to: to);
    }
    setState(() {
      _bestMoveArrowCoordinates = bestMoveArrow;
    });
  }

  Future<PieceType?> handlePromotion(BuildContext context) async {
    final PieceType? result = await showDialog<PieceType>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Choose a piece'),
          children: <Widget>[
            SimpleDialogOption(
              child: const Text('Queen'),
              onPressed: () {
                Navigator.of(context).pop(PieceType.queen);
              },
            ),
            SimpleDialogOption(
              child: const Text('Rook'),
              onPressed: () {
                Navigator.of(context).pop(PieceType.rook);
              },
            ),
            SimpleDialogOption(
              child: const Text('Bishop'),
              onPressed: () {
                Navigator.of(context).pop(PieceType.bishop);
              },
            ),
            SimpleDialogOption(
              child: const Text('Knight'),
              onPressed: () {
                Navigator.of(context).pop(PieceType.knight);
              },
            ),
          ],
        );
      },
    );

    return result;
  }

  void updateBoard(BuildContext context) {
    final fenProvider = Provider.of<FenProvider>(context, listen: false);
    if (chesslib.Chess.validate_fen(fenProvider.fen)['valid']) {
      _chess = chesslib.Chess.fromFEN(fenProvider.fen);
      _chessNotifier.value = _chess;
      updateBestMove();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Invalid FEN'),
            content: const Text(
                'The provided FEN is invalid. Please check and try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
