import 'package:flutter/material.dart';
import 'game_placeholder.dart';

class Game4PlaceholderScreen extends StatelessWidget {
  const Game4PlaceholderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const GamePlaceholder(
      title: 'Game 4',
      icon: Icons.casino,
      gradientColors: [Color(0xFFF093FB), Color(0xFFF5576C)],
      buttonColor: Color(0xFFF093FB),
    );
  }
}