import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ChessBoardScreen(),
    );
  }
}

class ChessBoardScreen extends StatefulWidget {
  const ChessBoardScreen({super.key});

  @override
  _ChessBoardScreenState createState() => _ChessBoardScreenState();
}

class _ChessBoardScreenState extends State<ChessBoardScreen> {
  List<List<int>> solutions = [];
  int currentSolutionIndex = 0;
  List<int> currentQueens = List.filled(8, -1);

  @override
  void initState() {
    super.initState();
    solveNQueens();
    if (solutions.isNotEmpty) {
      currentQueens = List.from(solutions[0]);
    }
  }

  bool isSafe(List<int> queens, int row, int col) {
    for (int i = 0; i < row; i++) {
      int placedCol = queens[i];
      if (placedCol == col ||
          placedCol - i == col - row ||
          placedCol + i == col + row) {
        return false;
      }
    }
    return true;
  }

  void solveNQueens() {
    List<int> queens = List.filled(8, -1);
    backtrack(queens, 0);
  }

  void backtrack(List<int> queens, int row) {
    if (row == 8) {
      solutions.add(List.from(queens));
      return;
    }
    for (int col = 0; col < 8; col++) {
      if (isSafe(queens, row, col)) {
        queens[row] = col;
        backtrack(queens, row + 1);
        queens[row] = -1;
      }
    }
  }

  void handleSwipe(DragEndDetails details) {
    if (solutions.isEmpty) return;
    setState(() {
      if (details.primaryVelocity! < 0) {
        if (currentSolutionIndex < solutions.length - 1) {
          currentSolutionIndex++;
          currentQueens = List.from(solutions[currentSolutionIndex]);
        }
      } else if (details.primaryVelocity! > 0) {
        if (currentSolutionIndex > 0) {
          currentSolutionIndex--;
          currentQueens = List.from(solutions[currentSolutionIndex]);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: GestureDetector(
        onHorizontalDragEnd: handleSwipe,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: media.width,
                height: 500,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: 64,
                  itemBuilder: (context, index) {
                    final row = index ~/ 8;
                    final col = index % 8;
                    final isDark = (row + col) % 2 == 1;
                    final hasQueen = currentQueens[row] == col;

                    return Container(
                      color: isDark ? Colors.black : Colors.white,
                      child: Center(
                        child:
                            hasQueen
                                ? const Icon(
                                  Icons.star,
                                  color: Colors.red,
                                  size: 40,
                                )
                                : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                solutions.isEmpty
                    ? 'Không có lời giải'
                    : currentSolutionIndex >= 0
                    ? 'Lời giải ${currentSolutionIndex + 1}/${solutions.length}'
                    : 'Đặt quân hậu tùy chỉnh',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Vuốt sang trái/phải để xem lời giải khác',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
