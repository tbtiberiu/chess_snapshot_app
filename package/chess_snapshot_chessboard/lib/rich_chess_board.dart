import 'package:chess_snapshot_chessboard/piece.dart';
import 'package:chess_snapshot_chessboard/square.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'board.dart';
import 'ui_square.dart';

class ChessBoard extends StatelessWidget {
  final String fen;
  final void Function(int file, int rank) onSquareClicked;
  final void Function(
          int fromFile, int fromRank, int toFile, int toRank, Piece? piece)
      onPieceMoved;

  const ChessBoard(
      {super.key,
      required this.fen,
      required this.onSquareClicked,
      required this.onPieceMoved});

  Widget _buildPlayerTurn({required double size}) {
    final isWhiteTurn = fen.split(' ')[1] == 'w';
    return Positioned(
      bottom: size * 0.001,
      right: size * 0.001,
      child: _PlayerTurn(size: size * 0.05, whiteTurn: isWhiteTurn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((ctx, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final boardSize = size * 0.9;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              color: const Color(0xFF8476BA),
              width: size,
              height: size,
              child: Stack(
                children: [
                  ...getFilesCoordinates(
                    boardSize: size,
                    top: true,
                  ),
                  ...getFilesCoordinates(
                    boardSize: size,
                    top: false,
                  ),
                  ...getRanksCoordinates(
                    boardSize: size,
                    left: true,
                  ),
                  ...getRanksCoordinates(
                    boardSize: size,
                    left: false,
                  ),
                  _buildPlayerTurn(size: size),
                ],
              ),
            ),
            _Chessboard(
              fen: fen,
              size: boardSize,
              onSquareClicked: onSquareClicked,
              onPieceMoved: onPieceMoved,
            ),
          ],
        );
      }),
    );
  }
}

class _Chessboard extends StatefulWidget {
  final Board board;
  final void Function(int file, int rank) onSquareClicked;
  final void Function(
          int fromFile, int fromRank, int toFile, int toRank, Piece? piece)
      onPieceMoved;

  _Chessboard({
    required String fen,
    required double size,
    required this.onSquareClicked,
    required this.onPieceMoved,
    Color lightSquareColor = const Color.fromRGBO(240, 217, 181, 1),
    Color darkSquareColor = const Color.fromRGBO(181, 136, 99, 1),
    BuildPiece? buildPiece,
    BuildSquare? buildSquare,
    BuildCustomPiece? buildCustomPiece,
  }) : board = Board(
          fen: fen,
          size: size,
          lightSquareColor: lightSquareColor,
          darkSquareColor: darkSquareColor,
          buildPiece: buildPiece,
          buildSquare: buildSquare,
          buildCustomPiece: buildCustomPiece,
        );

  @override
  State<StatefulWidget> createState() => _ChessboardState();
}

class _ChessboardState extends State<_Chessboard> {
  Widget _buildPiece(Piece? piece, double size) {
    if (piece == Piece.whiteRook) {
      return WhiteRook(size: size);
    } else if (piece == Piece.whiteKnight) {
      return WhiteKnight(size: size);
    } else if (piece == Piece.whiteBishop) {
      return WhiteBishop(size: size);
    } else if (piece == Piece.whiteKing) {
      return WhiteKing(size: size);
    } else if (piece == Piece.whiteQueen) {
      return WhiteQueen(size: size);
    } else if (piece == Piece.whitePawn) {
      return WhitePawn(size: size);
    } else if (piece == Piece.blackRook) {
      return BlackRook(size: size);
    } else if (piece == Piece.blackKnight) {
      return BlackKnight(size: size);
    } else if (piece == Piece.blackBishop) {
      return BlackBishop(size: size);
    } else if (piece == Piece.blackKing) {
      return BlackKing(size: size);
    } else if (piece == Piece.blackQueen) {
      return BlackQueen(size: size);
    } else if (piece == Piece.blackPawn) {
      return BlackPawn(size: size);
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: widget.board,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          width: widget.board.size,
          height: widget.board.size,
          child: Stack(
            alignment: AlignmentDirectional.topStart,
            children: [
              ...widget.board.squares.map((it) {
                return Positioned(
                  left: it.x,
                  top: it.y,
                  width: it.size,
                  height: it.size,
                  child: DragTarget<Square>(
                    onAcceptWithDetails: (details) {
                      final fromSquare = details.data;
                      final fromFile =
                          fromSquare.file.codeUnitAt(0) - 'a'.codeUnitAt(0);
                      final fromRank =
                          fromSquare.rank.codeUnitAt(0) - '1'.codeUnitAt(0);
                      final toFile = it.file.codeUnitAt(0) - 'a'.codeUnitAt(0);
                      final toRank = it.rank.codeUnitAt(0) - '1'.codeUnitAt(0);
                      Piece? selectedPiece = fromSquare.piece.toNullable();

                      if (selectedPiece == null) return;
                      if (fromFile == toFile && fromRank == toRank) return;

                      widget.onPieceMoved(
                          fromFile, fromRank, toFile, toRank, selectedPiece);
                    },
                    builder: (context, candidateData, rejectedData) {
                      return InkWell(
                          onTap: () {
                            final file =
                                it.file.codeUnitAt(0) - 'a'.codeUnitAt(0);
                            final rank =
                                it.rank.codeUnitAt(0) - '1'.codeUnitAt(0);

                            widget.onSquareClicked(file, rank);
                          },
                          child: Draggable<Square>(
                            data: it,
                            feedback: Material(
                              color: Colors.transparent,
                              child:
                                  _buildPiece(it.piece.toNullable(), it.size),
                            ),
                            child: UISquare(
                              square: it,
                            ),
                          ));
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerTurn extends StatelessWidget {
  final double size;
  final bool whiteTurn;

  const _PlayerTurn({required this.size, required this.whiteTurn});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.only(
        left: 10,
      ),
      decoration: BoxDecoration(
        color: whiteTurn ? Colors.white : Colors.black,
        border: Border.all(
          width: 0.7,
          color: Colors.black,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}

Iterable<Widget> getFilesCoordinates({
  required double boardSize,
  required bool top,
}) {
  final commonTextStyle = TextStyle(
    color: const Color(0xFFF0F1F0),
    fontWeight: FontWeight.bold,
    fontSize: boardSize * 0.04,
  );

  return [0, 1, 2, 3, 4, 5, 6, 7].map(
    (file) {
      final letterOffset = file;
      final letter = String.fromCharCode('A'.codeUnitAt(0) + letterOffset);
      return Positioned(
        top: boardSize * (top ? 0.005 : 0.955),
        left: boardSize * (0.09 + 0.113 * file),
        child: Text(
          letter,
          style: commonTextStyle,
        ),
      );
    },
  );
}

Iterable<Widget> getRanksCoordinates({
  required double boardSize,
  required bool left,
}) {
  final commonTextStyle = TextStyle(
    color: const Color(0xFFF0F1F0),
    fontWeight: FontWeight.bold,
    fontSize: boardSize * 0.04,
  );

  return [0, 1, 2, 3, 4, 5, 6, 7].map((rank) {
    final letterOffset = 7 - rank;
    final letter = String.fromCharCode('1'.codeUnitAt(0) + letterOffset);
    return Positioned(
      left: boardSize * (left ? 0.012 : 0.965),
      top: boardSize * (0.09 + 0.113 * rank),
      child: Text(
        letter,
        style: commonTextStyle,
      ),
    );
  });
}
