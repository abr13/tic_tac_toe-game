import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tic_tac_toe/util/shared_pref.dart';

import '../global/colors.dart';

enum GameMode {
  withCPU,
  withPerson,
}

class GameBoard extends StatefulWidget {
  final GameMode mode;

  const GameBoard({Key? key, required this.mode}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  bool oTurn = true;
  List<String> displayXO = List.filled(9, '');
  List<int> matchedIndexes = [];
  int attempts = 0;

  int oScore = 0;
  int xScore = 0;
  int filledBoxes = 0;
  String resultDeclaration = '';
  bool winnerFound = false;

  static var customFontWhite = GoogleFonts.pressStart2p(
    textStyle: TextStyle(
      color: GlobalColors.whiteColor,
      letterSpacing: 2,
      fontSize: 16,
    ),
  );

  @override
  void initState() {
    super.initState();

    getSavedScores();
  }

  Future<void> getSavedScores() async {
    if (widget.mode == GameMode.withPerson) {
      oScore = await LocalMemory.getPlayerOScore();
      xScore = await LocalMemory.getPlayerXScore();
      setState(() {});
    }
  }

  void _tapped(int index) {
    if (!winnerFound && displayXO[index].isEmpty) {
      setState(() {
        displayXO[index] = oTurn ? 'O' : 'X';
        filledBoxes++;

        _checkWinner();
        oTurn = !oTurn;

        // Check if it's the CPU's turn after updating oTurn
        if (widget.mode == GameMode.withCPU && !winnerFound && !oTurn) {
          _performCPUMove();
        }
      });
    }
  }

  void _performCPUMove() {
    // Check if it's the CPU's turn
    if (!oTurn) {
      // Implement CPU player logic here
      // For simplicity, it will make a random move
      int emptyIndex = _getRandomEmptyIndex();
      if (emptyIndex != -1) {
        _tapped(emptyIndex);
      }
    }
  }

  int _getRandomEmptyIndex() {
    List<int> emptyIndexes = List.generate(displayXO.length, (index) => index)
        .where((i) => displayXO[i].isEmpty)
        .toList();

    if (emptyIndexes.isNotEmpty) {
      Random random = Random();
      return emptyIndexes[random.nextInt(emptyIndexes.length)];
    } else {
      return -1; // No empty index available
    }
  }

  void _checkWinner() {
    // Define a function to update the score and set winnerFound
    void updateScoreAndWinner(String winner, List<int> winningIndexes) {
      setState(() {
        resultDeclaration = 'Player $winner Wins!';
        matchedIndexes.addAll(winningIndexes);
        _updateScore(winner);
      });
    }

    // Check for each winning condition
    List<List<int>> winConditions = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [6, 4, 2],
    ];

    for (var winningIndexes in winConditions) {
      String firstValue = displayXO[winningIndexes[0]];
      if (firstValue.isNotEmpty &&
          displayXO[winningIndexes[1]] == firstValue &&
          displayXO[winningIndexes[2]] == firstValue) {
        updateScoreAndWinner(firstValue, winningIndexes);
        break;
      }
    }

    // Check for a tie game
    if (!winnerFound && filledBoxes == 9) {
      setState(() {
        resultDeclaration = 'Nobody Wins!';
      });
    }
  }

  void _updateScore(String winner) {
    if (winner == 'O') {
      oScore++;
      if (widget.mode == GameMode.withPerson) {
        LocalMemory.setPlayerOScore(oScore);
      }
    } else if (winner == 'X') {
      xScore++;
      if (widget.mode == GameMode.withPerson) {
        LocalMemory.setPlayerXScore(xScore);
      }
    }
    winnerFound = true;
  }

  void _clearBoard() {
    setState(() {
      displayXO = List.filled(9, '');
      resultDeclaration = '';
      matchedIndexes = [];
      winnerFound = false;
      oTurn = true;
    });
    filledBoxes = 0;
  }

  Widget _buildPlayButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: GlobalColors.whiteColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      onPressed: () {
        _clearBoard();
        attempts++;
        if (widget.mode == GameMode.withCPU && !oTurn) {
          _performCPUMove();
        }
      },
      child: const Text(
        'Restart',
        style: TextStyle(fontSize: 20, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColors.secondaryColor,
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPlayerScore('Player(O)', oScore),
                  const SizedBox(width: 10),
                  _buildPlayerScore(
                    widget.mode == GameMode.withCPU ? 'CPU(X)' : 'Player(X)',
                    xScore,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: GridView.builder(
                  itemCount: 9,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        _tapped(index);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(0.8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            width: 6,
                            color: GlobalColors.primaryColor,
                          ),
                          color: matchedIndexes.contains(index)
                              ? GlobalColors.accentColor
                              : GlobalColors.secondaryColor,
                        ),
                        child: Center(
                          child: Text(
                            displayXO[index],
                            style: GoogleFonts.pressStart2p(
                                textStyle: TextStyle(
                              fontSize: 58,
                              color: matchedIndexes.contains(index)
                                  ? GlobalColors.secondaryColor
                                  : GlobalColors.primaryColor,
                            )),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(resultDeclaration, style: customFontWhite),
                    const SizedBox(height: 10),
                    _buildPlayButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerScore(String label, int score) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(label, style: customFontWhite),
        const SizedBox(height: 10),
        Text(score.toString(), style: customFontWhite),
      ],
    );
  }
}
