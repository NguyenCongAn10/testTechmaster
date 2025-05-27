import 'package:flutter/material.dart';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'dart:io' show Platform;

typedef GetSolutionsFunc = ffi.Pointer<ffi.Int> Function(ffi.Pointer<ffi.Int>);
typedef GetSolutions = ffi.Pointer<ffi.Int> Function(ffi.Pointer<ffi.Int>);

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
    loadSolutions();
    if (solutions.isNotEmpty) {
      currentQueens = List.from(solutions[0]);
    }
  }

  void loadSolutions() {
    try {
      final dylib =
          Platform.isIOS || Platform.isMacOS
              ? ffi.DynamicLibrary.open('lib/libnqueens.dylib')
              : Platform.isWindows
              ? ffi.DynamicLibrary.open('lib/nqueens.dll')
              : ffi.DynamicLibrary.open('lib/libnqueens.so');
      final getSolutions = dylib.lookupFunction<GetSolutionsFunc, GetSolutions>(
        'getSolutions',
      );

      final countPtr = calloc<ffi.Int>();
      final solutionsPtr = getSolutions(countPtr);
      final count = countPtr.value;

      for (int i = 0; i < count; i++) {
        final solution = <int>[];
        for (int j = 0; j < 8; j++) {
          solution.add(solutionsPtr[i * 8 + j]);
        }
        solutions.add(solution);
      }

      calloc.free(countPtr);
    } catch (e) {
      throw Exception("loi $e");
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
