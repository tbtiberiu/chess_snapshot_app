import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chesslib;

class FenProvider extends ChangeNotifier {
  String fen;

  FenProvider({this.fen = chesslib.Chess.DEFAULT_POSITION});

  void changeFen(String newFen) async {
    fen = newFen;
    notifyListeners();
  }
}
