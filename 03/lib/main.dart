import 'package:flutter/material.dart';
import 'dart:ffi' as ffi;
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart';

typedef GetSolutionsNative =
    ffi.Pointer<ffi.Int32> Function(ffi.Pointer<ffi.Int32>);
typedef GetSolutionsDart =
    ffi.Pointer<ffi.Int32> Function(ffi.Pointer<ffi.Int32>);
typedef FreeSolutionsNative = ffi.Void Function(ffi.Pointer<ffi.Int32>);
typedef FreeSolutionsDart = void Function(ffi.Pointer<ffi.Int32>);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChessBoardScreen(),
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
  }

  void loadSolutions() {
    try {
      final dylib = ffi.DynamicLibrary.open(
        '/Users/admin/testTechmaster/03/ios/Runner/libnqueens.dylib',
      );
      final getSolutions = dylib
          .lookupFunction<GetSolutionsNative, GetSolutionsDart>('getSolutions');
      final freeSolutions = dylib
          .lookupFunction<FreeSolutionsNative, FreeSolutionsDart>(
            'freeSolutions',
          );

      final countPtr = calloc<ffi.Int32>();
      final solutionsPtr = getSolutions(countPtr);
      final count = countPtr.value;

      if (solutionsPtr == ffi.Pointer<ffi.Int32>.fromAddress(0) ||
          count <= 0 ||
          count > 1000) {
        print(
          'No solutions or invalid count returned from native code: $count',
        );
        calloc.free(countPtr);
        return;
      }

      final totalInts = count * 8;
      final solutionsList = solutionsPtr.asTypedList(totalInts);

      solutions = List.generate(
        count,
        (i) => solutionsList.sublist(i * 8, (i + 1) * 8),
      );

      currentQueens = List.from(solutions[0]);
      currentSolutionIndex = 0;

      freeSolutions(solutionsPtr);
      calloc.free(countPtr);

      setState(() {});

      print('Loaded $count solutions from native code.');
    } catch (e, st) {
      print('Error loading solutions from native code: $e');
      print(st);
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
    final media = MediaQuery.of(context).size;
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
                padding: const EdgeInsets.all(8),
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
                    : 'Lời giải ${currentSolutionIndex + 1} / ${solutions.length}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
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
