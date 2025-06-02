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
  List<int> currentQueens = List.filled(8, -1);

  void placeQueen(int row, int column) {
    if (row < 0 || row >= 8 || column < 0 || column >= 8) return;
    setState(() {
      currentQueens = List.filled(8, -1);
      currentQueens[row - 1] = column - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: media.width,
            height: 500,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
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
          ElevatedButton(
            onPressed: () {
              placeQueen(3, 4);
            },
            child: const Text('Đặt quân hậu tại (3,4)'),
          ),
        ],
      ),
    );
  }
}
