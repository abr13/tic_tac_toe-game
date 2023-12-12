import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tic_tac_toe/global/colors.dart';
import 'package:tic_tac_toe/util/shared_pref.dart';

import 'game_board.dart';

class StartPage extends StatelessWidget {
  const StartPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColors.accentColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: GlobalColors.primaryColor,
        title: Text(
          'Tic Tac Toe',
          style: GoogleFonts.pressStart2p(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGameButton(
              context,
              'Play with CPU',
              GameMode.withCPU,
            ),
            const SizedBox(height: 20),
            _buildGameButton(
              context,
              'Play with Friend',
              GameMode.withPerson,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                LocalMemory.resetScores();
              },
              child: Container(
                color: Colors.red.withOpacity(0.5),
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  "Reset scores",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGameButton(
    BuildContext context,
    String text,
    GameMode mode,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameBoard(mode: mode),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: GlobalColors.blackColor,
        backgroundColor: GlobalColors.whiteColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      child: Text(
        text,
        style: GoogleFonts.pressStart2p(
          fontSize: 18,
        ),
      ),
    );
  }
}
