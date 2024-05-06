import 'dart:io';

import 'package:chess_snapshot_app/providers/fen_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chess_snapshot_app/chess_position_detection.dart';
import 'package:chess_snapshot_chessboard/chess_snapshot_chessboard.dart';
import 'package:provider/provider.dart';

class DetectScreen extends StatelessWidget {
  const DetectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8476BA),
        ),
      ),
      home: const MyDetectScreen(),
    );
  }
}

class MyDetectScreen extends StatefulWidget {
  const MyDetectScreen({super.key});

  @override
  State<MyDetectScreen> createState() => _MyDetectScreenState();
}

class _MyDetectScreenState extends State<MyDetectScreen> {
  final imagePicker = ImagePicker();

  ChessPositionDetection? chessPositionDetection;
  late String _fen;
  late ValueNotifier<String> _fenNotifier;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    chessPositionDetection = ChessPositionDetection();
    _fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w - - 0 1';
    _fenNotifier = ValueNotifier<String>(_fen);
  }

  @override
  void dispose() {
    _fenNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.purple)
                    : ValueListenableBuilder<String>(
                        valueListenable: _fenNotifier,
                        builder: (context, fen, _) {
                          return EditableChessBoard(
                            key: UniqueKey(),
                            boardSize: 400.0,
                            fen: fen,
                            onFenChanged: (String newFen) {
                              updateFenInProvider(newFen);
                            },
                          );
                        },
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
                    if (Platform.isAndroid || Platform.isIOS)
                      IconButton(
                        onPressed: () async {
                          await loadChessPosition(ImageSource.camera);
                        },
                        icon: const FaIcon(
                          FontAwesomeIcons.camera,
                          size: 36,
                        ),
                      ),
                    IconButton(
                      onPressed: () async {
                        await loadChessPosition(ImageSource.gallery);
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.image,
                        size: 36,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        rotateRightBoard(_fen);
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.rotateRight,
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

  Future<void> loadChessPosition(ImageSource source) async {
    final result = await imagePicker.pickImage(source: source);

    if (result != null) {
      setState(() {
        isLoading = true;
      });

      String partialFen =
          await chessPositionDetection!.analyseImage(result.path);
      _fen = '$partialFen w - - 0 1';
      _fenNotifier.value = _fen;
      updateFenInProvider(_fen);

      setState(() {
        isLoading = false;
      });
    }
  }

  void updateFenInProvider(String newFen) {
    final provider = Provider.of<FenProvider>(context, listen: false);
    provider.changeFen(newFen);
  }

  void rotateRightBoard(String oldFen) {
    _fen = rotateFen(oldFen);
    _fenNotifier.value = _fen;
    updateFenInProvider(_fen);
  }

  String rotateFen(String fen) {
    List<String> parts = fen.split(' ');
    String fenState = parts[0];
    List<List<String>> matrixBoardState = fenStateToMatrix(fenState);
    List<List<String>> rotatedBoardState = rotateRightMatrix(matrixBoardState);
    String rotatedFenState = matrixToFenState(rotatedBoardState);

    String rotatedFen =
        '$rotatedFenState ${parts[1]} ${parts[2]} ${parts[3]} ${parts[4]} ${parts[5]}';

    return rotatedFen;
  }

  List<List<String>> fenStateToMatrix(String fenState) {
    List<String> rows = fenState.split('/');
    List<List<String>> matrix = [];

    for (final String row in rows) {
      List<String> newRow = [];
      for (int i = 0; i < row.length; i++) {
        String char = row[i];
        if (int.tryParse(char) != null) {
          int emptySpaces = int.parse(char);
          for (int j = 0; j < emptySpaces; j++) {
            newRow.add("-");
          }
        } else {
          newRow.add(char);
        }
      }
      matrix.add(newRow);
    }

    return matrix;
  }

  String matrixToFenState(List<List<String>> matrix) {
    String fenState = '';

    for (List<String> row in matrix) {
      int emptyCount = 0;
      for (String square in row) {
        if (square == '-') {
          emptyCount++;
        } else {
          if (emptyCount > 0) {
            fenState += emptyCount.toString();
            emptyCount = 0;
          }
          fenState += square;
        }
      }
      if (emptyCount > 0) {
        fenState += emptyCount.toString();
      }
      fenState += '/';
    }

    fenState = fenState.substring(0, fenState.length - 1);
    return fenState;
  }

  List<List<String>> rotateRightMatrix(List<List<String>> matrix) {
    int n = matrix.length;
    List<List<String>> rotatedMatrix =
        List.generate(n, (index) => List.filled(n, ''));

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        rotatedMatrix[i][j] = matrix[n - 1 - j][i];
      }
    }

    return rotatedMatrix;
  }
}
