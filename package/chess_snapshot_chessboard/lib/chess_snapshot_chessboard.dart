library chess_snapshot_chessboard;

import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;

import 'board_color.dart';
import 'rich_chess_board.dart';
import 'selection_zone.dart';
import 'piece.dart';
import 'advanced_options.dart';
import 'utils.dart';

class Labels {
  final String playerTurnLabel = 'Player turn:';
  final String whitePlayerLabel = 'White player';
  final String blackPlayerLabel = 'Black player';
  final String currentPositionLabel = 'Current position: ';
  final String copyFenLabel = 'Copy position';
  final String pasteFenLabel = 'Paste position';
  final String resetPosition = 'Reset position';
  final String standardPosition = 'Standard position';
  final String erasePosition = 'Erase position';
}

class EditableChessBoard extends StatefulWidget {
  final double boardSize;
  final String fen;

  final void Function(String newFen) onFenChanged;

  const EditableChessBoard({
    super.key,
    required this.boardSize,
    required this.fen,
    required this.onFenChanged,
  });

  @override
  State<EditableChessBoard> createState() => _EditableChessBoardState();
}

class _EditableChessBoardState extends State<EditableChessBoard> {
  late String _fen;
  Piece? _editingPieceType;

  @override
  void initState() {
    super.initState();
    _fen = widget.fen;
  }

  void _onSquareClicked(int file, int rank) {
    _updateFenPiece(file: file, rank: rank, pieceType: _editingPieceType);
  }

  void _onPiecedMoved(
      int fromFile, int fromRank, int toFile, int toRank, Piece? piece) {
    _updateFenPiece(file: fromFile, rank: fromRank, pieceType: null);
    _updateFenPiece(file: toFile, rank: toRank, pieceType: piece);
  }

  void _updateFenPiece(
      {required int file, required int rank, required Piece? pieceType}) {
    var fenParts = _fen.split(' ');
    var piecesArray = getPiecesArray(_fen);
    piecesArray[7 - rank][file] = pieceType != null
        ? (pieceType.color == BoardColor.black
            ? pieceType.type.toLowerCase()
            : pieceType.type.toUpperCase())
        : '';

    final newFenBoardPart = piecesArray
        .map((currentLine) {
          var holes = 0;
          var result = "";
          for (var currentElement in currentLine) {
            if (currentElement.isEmpty) {
              holes++;
            } else {
              if (holes > 0) {
                result += "$holes";
              }
              holes = 0;
              result += currentElement;
            }
          }
          if (holes > 0) {
            result += "$holes";
          }

          return result;
        })
        .toList()
        .join("/");

    fenParts[0] = newFenBoardPart;

    final newFen = fenParts.join(" ");

    setState(() {
      _fen = newFen;
      widget.onFenChanged(_fen);
    });
  }

  void _onSelection({required Piece type}) {
    setState(() {
      _editingPieceType = type;
    });
  }

  void _onTrashSelection() {
    setState(() {
      _editingPieceType = null;
    });
  }

  void _onTurnChanged(bool turn) {
    var parts = _fen.split(' ');
    final newTurnStr = turn ? 'w' : 'b';
    parts[1] = newTurnStr;

    setState(() {
      _fen = parts.join(' ');
      widget.onFenChanged(_fen);
    });
  }

  void _onPositionFenSubmitted(String position) {
    if (chess.Chess.validate_fen(position)['valid']) {
      setState(() {
        _fen = position;
        widget.onFenChanged(_fen);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = <Widget>[
      Column(
        children: [
          SizedBox(
            width: widget.boardSize,
            child: ChessBoard(
              fen: _fen,
              onSquareClicked: _onSquareClicked,
              onPieceMoved: _onPiecedMoved,
            ),
          ),
          WhitePieces(
            maxWidth: widget.boardSize,
            onSelection: _onSelection,
          ),
          BlackPieces(
            maxWidth: widget.boardSize,
            onSelection: _onSelection,
          ),
          TrashAndPreview(
            maxWidth: widget.boardSize,
            selectedPiece: _editingPieceType,
            onTrashSelection: _onTrashSelection,
          ),
        ],
      ),
      AdvancedOptions(
        currentFen: _fen,
        onTurnChanged: _onTurnChanged,
        onPositionFenSubmitted: _onPositionFenSubmitted,
      )
    ];
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      final isPortrait =
          viewportConstraints.maxHeight > viewportConstraints.maxWidth;
      if (isPortrait) {
        return Column(
          children: content,
        );
      } else {
        return Row(
          children: content,
        );
      }
    });
  }
}
