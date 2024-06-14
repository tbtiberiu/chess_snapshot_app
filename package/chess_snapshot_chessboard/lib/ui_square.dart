import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:provider/provider.dart';
import 'board.dart';
import 'square.dart';
import 'ui_piece.dart';
import 'ui_tile.dart';

class UISquare extends StatelessWidget {
  final Square square;

  const UISquare({super.key, required this.square});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        UITile(
          color: square.color,
          size: square.size,
        ),
        _buildPiece(context),
      ],
    );
  }

  Widget _buildPiece(BuildContext context) {
    final board = Provider.of<Board>(context);
    return board.buildCustomPiece
        .flatMap((t) => Option.fromNullable(t(square)))
        .alt(() => square.piece.map((t) => UIPiece(
              squareName: square.name,
              squareColor: square.color,
              piece: t,
              size: square.size,
            )))
        .getOrElse(() => const SizedBox());
  }
}
