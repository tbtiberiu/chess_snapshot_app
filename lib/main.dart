import 'package:chess_snapshot_app/screens/detect/detect.dart';
import 'package:chess_snapshot_app/screens/play/play.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Snapshot App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
        ),
      ),
      home: PersistentTabView(
        tabs: [
          PersistentTabConfig(
            screen: const DetectScreen(),
            item: ItemConfig(
              icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
              title: "Detect",
              activeForegroundColor: Colors.purple,
            ),
          ),
          PersistentTabConfig(
            screen: const PlayScreen(),
            item: ItemConfig(
              icon: const FaIcon(FontAwesomeIcons.chessBoard),
              title: "Play",
              activeForegroundColor: Colors.purple,
            ),
          ),
        ],
        navBarBuilder: (navBarConfig) => Style2BottomNavBar(
          navBarConfig: navBarConfig,
        ),
      ),
    );
  }
}
