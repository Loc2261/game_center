import 'package:flutter/material.dart';
import 'game_placeholder.dart';

class Game3PlaceholderScreen extends StatelessWidget {
  const Game3PlaceholderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const GamePlaceholder(
      title: 'Game 3',
      icon: Icons.sports_esports,
      gradientColors: [Color(0xFF667EEA), Color(0xFF764BA2)],
      buttonColor: Color(0xFF667EEA),
    );
  }
}