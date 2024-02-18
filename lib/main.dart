import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:editable_chess_board/editable_chess_board.dart';
import 'package:chess_snapshot_app/chess_position_detection.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.yellow,
        ),
      ),
      home: const MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final imagePicker = ImagePicker();

  ChessPositionDetection? chessPositionDetection;
  late String fen;
  late ValueNotifier<String> fenNotifier;

  @override
  void initState() {
    super.initState();
    chessPositionDetection = ChessPositionDetection();
    fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR';
    fenNotifier = ValueNotifier<String>(fen);
  }

  @override
  void dispose() {
    fenNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<String>(
          valueListenable: fenNotifier,
          builder: (context, fen, _) {
            return Text('Chess position: $fen');
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: ValueListenableBuilder<String>(
                  valueListenable: fenNotifier,
                  builder: (context, fen, _) {
                    return EditableChessBoard(
                      key: UniqueKey(),
                      boardSize: 400.0,
                      controller: PositionController('$fen b KQkq - 0 1'),
                      labels: Labels(
                        playerTurnLabel: 'Player turn :',
                        whitePlayerLabel: 'White',
                        blackPlayerLabel: 'Black',
                        availableCastlesLabel: 'Available castles :',
                        whiteOOLabel: 'White O-O',
                        whiteOOOLabel: 'White O-O-O',
                        blackOOLabel: 'Black O-O',
                        blackOOOLabel: 'Black O-O-O',
                        enPassantLabel: 'En passant square :',
                        drawHalfMovesCountLabel: 'Draw half moves count : ',
                        moveNumberLabel: 'Move number : ',
                        submitFieldLabel: 'Validate field',
                        currentPositionLabel: 'Current position: ',
                        copyFenLabel: 'Copy position',
                        pasteFenLabel: 'Paste position',
                        resetPosition: 'Reset position',
                        standardPosition: 'Standard position',
                        erasePosition: 'Erase position',
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (Platform.isAndroid || Platform.isIOS)
                    IconButton(
                      onPressed: () async {
                        final result = await imagePicker.pickImage(
                          source: ImageSource.camera,
                        );
                        if (result != null) {
                          fen = await chessPositionDetection!
                              .analyseImage(result.path);
                          fenNotifier.value = fen;
                          log(fen);
                        }
                      },
                      icon: const Icon(
                        Icons.camera,
                        size: 64,
                      ),
                    ),
                  IconButton(
                    onPressed: () async {
                      final result = await imagePicker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (result != null) {
                        fen = await chessPositionDetection!
                            .analyseImage(result.path);
                        fenNotifier.value = fen;
                        log(fen);
                      }
                    },
                    icon: const Icon(
                      Icons.photo,
                      size: 64,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
