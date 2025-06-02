import 'dart:math';

import 'package:flutter/material.dart';
import 'selection_sort_ffi.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SelectionSortAnimation(),
    );
  }
}

class SelectionSortAnimation extends StatefulWidget {
  const SelectionSortAnimation({super.key});

  @override
  State<SelectionSortAnimation> createState() => _SelectionSortAnimationState();
}

class _SelectionSortAnimationState extends State<SelectionSortAnimation> {
  List<int> numbers = List.generate(10, (index) => Random().nextInt(100));
  List<Color> colors = [];
  List<Map<String, dynamic>> steps = [];
  bool isSorting = false;

  @override
  void initState() {
    super.initState();
    _resetColors();
  }

  void _resetColors() {
    colors = List.filled(numbers.length, Colors.blue);
  }

  Future<void> startSorting() async {
    setState(() {
      isSorting = true;
      _resetColors();
    });

    final sorter = SelectionSort();
    final result = sorter.sortWithSteps(numbers);
    steps = result['steps'];
    numbers = result['sortedArray']; // Cập nhật cuối

    for (final step in steps) {
      setState(() {
        numbers = List<int>.from(step['array']);
        _resetColors();

        final int current = step['current']; // vị trí i (cũ)
        final int compare = step['compare']; // vị trí j
        final int min = step['min']; // vị trí min hiện tại
        final int type = step['stepType'];

        if (type == 0) {
          // So sánh: tô đỏ min và compare
          if (min >= 0) colors[min] = Colors.red;
          if (compare >= 0) colors[compare] = Colors.red;
        } else if (type == 1) {
          // Cập nhật min mới, tô xanh lá cho min mới
          if (min >= 0) colors[min] = Colors.green;
        } else if (type == 2) {
          // Hoán đổi: tô xanh lá cho current và min
          if (current >= 0) colors[current] = Colors.green;
          if (min >= 0) colors[min] = Colors.green;
        }
      });

      await Future.delayed(const Duration(milliseconds: 1000));
    }

    setState(() {
      _resetColors();
      colors = List.filled(numbers.length, Colors.green);
      isSorting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int maxNumber = numbers.reduce((a, b) => a > b ? a : b);
    const double minHeight = 40;
    const double maxHeight = 150;
    return Scaffold(
      appBar: AppBar(title: const Text("Selection Sort Animation")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.end, // canh thanh dưới cùng
              children: List.generate(numbers.length, (index) {
                double height =
                    minHeight +
                    (numbers[index] / maxNumber) * (maxHeight - minHeight);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 30,
                  height: height,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: colors[index],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        numbers[index].toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isSorting ? null : startSorting,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Bắt Đầu Sắp Xếp',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
