import 'package:flutter/material.dart';
import 'selection_sort_ffi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Selection Sort FFI',
      debugShowCheckedModeBanner: false,
      home: SelectionSortScreen(),
    );
  }
}

class SelectionSortScreen extends StatefulWidget {
  @override
  State<SelectionSortScreen> createState() => _SelectionSortScreenState();
}

class _SelectionSortScreenState extends State<SelectionSortScreen> {
  List<int> numbers = [64, 25, 12, 22, 11];

  void _sortNumbers() {
    setState(() {
      sortWithFFI(numbers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selection Sort with FFI')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Danh sách số:', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children:
                  numbers
                      .map(
                        (e) => Chip(
                          label: Text(e.toString()),
                          backgroundColor: Colors.blue.shade100,
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sortNumbers,
              child: const Text('Sắp xếp'),
            ),
          ],
        ),
      ),
    );
  }
}
