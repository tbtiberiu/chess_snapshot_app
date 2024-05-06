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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8476BA),
        ),
      ),
      home: const MyPlayScreen(),
    );
  }
}

class MyPlayScreen extends StatefulWidget {
  const MyPlayScreen({super.key});

  @override
  State<MyPlayScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyPlayScreen> {
  ChessPositionDetection? chessPositionDetection;
  late chesslib.Chess _chess;
  late ValueNotifier<chesslib.Chess> _chessNotifier;
  BoardArrow? _bestMoveArrowCoordinates;
  late ChessBoardColors _boardColors;
  var _blackAtBottom = false;
  bool _playingAgainstBot = false;
  bool _showingBestMove = true;
  bool _playingAsWhite = true;
  PlayerType _whitePlayerType = PlayerType.human;
  PlayerType _blackPlayerType = PlayerType.human;

  @override
  void initState() {
    super.initState();
    chessPositionDetection = ChessPositionDetection();
    _chess = chesslib.Chess.fromFEN(chesslib.Chess.DEFAULT_POSITION);
    _chessNotifier = ValueNotifier<chesslib.Chess>(_chess);
    _boardColors = ChessBoardColors()
      ..lightSquaresColor = const Color.fromRGBO(240, 217, 181, 1)
      ..darkSquaresColor = const Color.fromRGBO(181, 136, 99, 1)
      ..coordinatesZoneColor = const Color.fromRGBO(154, 113, 79, 1)
      ..lastMoveArrowColor = const Color(0xFFF0F1F0)
      ..startSquareColor = const Color.fromRGBO(154, 113, 79, 1)
      ..endSquareColor = const Color.fromRGBO(154, 113, 79, 1)
      ..circularProgressBarColor = Colors.black
      ..coordinatesColor = const Color(0xFFF0F1F0)
      ..dndIndicatorColor = const Color.fromRGBO(240, 217, 181, 1);
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
                          whitePlayerType: _whitePlayerType,
                          blackPlayerType: _blackPlayerType,
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
              width: 500,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Play against a bot:',
                        ),
                        Switch(
                          value: _playingAgainstBot,
                          onChanged: (value) {
                            setState(() {
                              _playingAgainstBot = value;
                              updatePlayerTypes();
                              updateBestMove();
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Show the best move:',
                        ),
                        Switch(
                          value: _showingBestMove,
                          onChanged: (value) {
                            setState(() {
                              _showingBestMove = value;
                              updateBestMove();
                            });
                          },
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Play as:',
                        ),
                        ListTile(
                          title: const Text('White'),
                          leading: Radio<bool>(
                            groupValue: _playingAsWhite,
                            value: true,
                            onChanged: (value) {
                              setState(() {
                                _playingAsWhite = value ?? true;
                                updatePlayerTypes();
                                updateBestMove();
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('Black'),
                          leading: Radio<bool>(
                            groupValue: _playingAsWhite,
                            value: false,
                            onChanged: (value) {
                              setState(() {
                                _playingAsWhite = value ?? false;
                                updatePlayerTypes();
                                updateBestMove();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
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

  void updatePlayerTypes() {
    if (_playingAgainstBot) {
      _whitePlayerType =
          _playingAsWhite ? PlayerType.human : PlayerType.computer;
      _blackPlayerType =
          _playingAsWhite ? PlayerType.computer : PlayerType.human;
    } else {
      _whitePlayerType = PlayerType.human;
      _blackPlayerType = PlayerType.human;
    }
  }

  Future<void> updateBestMove() async {
    if (!_playingAgainstBot && !_showingBestMove) return;

    String? bestMove = await chessPositionDetection!.getBestMove(_chess.fen);
    if (bestMove != null) {
      String from = bestMove.substring(0, 2);
      String to = bestMove.substring(2);

      if (_playingAgainstBot) {
        chesslib.Color playerColor =
            (_playingAsWhite) ? chesslib.Chess.WHITE : chesslib.Chess.BLACK;

        if (playerColor != _chess.turn) {
          tryMakingMove(move: ShortMove(from: from, to: to));
        }
      }

      updateBestMoveArrowCoordinates(from, to);
    }
  }

  void updateBestMoveArrowCoordinates(String from, String to) {
    setState(() {
      _bestMoveArrowCoordinates =
          (_showingBestMove) ? BoardArrow(from: from, to: to) : null;
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
