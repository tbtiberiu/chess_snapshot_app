import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chess_snapshot_app/chess_position_detection.dart';
import 'package:chess_snapshot_chessboard/chess_snapshot_chessboard.dart';

class DetectScreen extends StatelessWidget {
  const DetectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
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
  late String fen;
  late ValueNotifier<String> fenNotifier;

  bool isLoading = false;

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
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.purple)
                    : ValueListenableBuilder<String>(
                        valueListenable: fenNotifier,
                        builder: (context, fen, _) {
                          return EditableChessBoard(
                            key: UniqueKey(),
                            boardSize: 400.0,
                            fen: '$fen b KQkq - 0 1',
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

      fen = await chessPositionDetection!.analyseImage(result.path);
      fenNotifier.value = fen;

      setState(() {
        isLoading = false;
      });
    }
  }
}
