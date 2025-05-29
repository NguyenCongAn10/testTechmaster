import 'dart:ffi';
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

// Khai báo hàm native
typedef SelectionSortWithStepsNative =
    Void Function(Pointer<Int32>, Int32, Pointer<SortStep>, Pointer<Int32>);

typedef SelectionSortWithStepsFunc =
    void Function(Pointer<Int32>, int, Pointer<SortStep>, Pointer<Int32>);

// Cấu trúc SortStep trong Dart
base class SortStep extends Struct {
  @Int32()
  external int current;

  @Int32()
  external int compare;

  @Int32()
  external int min;

  @Int32()
  external int swap;

  @Int32()
  external int stepType;

  @Array(100)
  external Array<Int32> array;
}

// Class quản lý thư viện và xử lý
class SelectionSort {
  late DynamicLibrary _lib;
  late SelectionSortWithStepsFunc _selectionSortWithSteps;

  SelectionSort() {
    // Load dynamic library theo nền tảng
    _lib = DynamicLibrary.open(
      '/Users/admin/testTechmaster/04/flutter_project_04/ios/Runner/selection_sort.dylib',
    );

    _selectionSortWithSteps =
        _lib
            .lookup<NativeFunction<SelectionSortWithStepsNative>>(
              'selectionSortWithSteps',
            )
            .asFunction<SelectionSortWithStepsFunc>();
  }

  // Trả về Map gồm steps và sortedArray
  Map<String, dynamic> sortWithSteps(List<int> arr) {
    final n = arr.length;
    final arrPtr = malloc<Int32>(n);
    final stepsPtr = malloc<SortStep>(100); // tối đa 100 bước
    final stepCountPtr = malloc<Int32>();

    try {
      final intList = arrPtr.asTypedList(n);
      intList.setAll(0, arr);

      _selectionSortWithSteps(arrPtr, n, stepsPtr, stepCountPtr);

      final stepCount = stepCountPtr.value;
      final steps = <Map<String, dynamic>>[];

      for (int i = 0; i < stepCount; i++) {
        final step = stepsPtr[i];
        steps.add({
          'current': step.current,
          'compare': step.compare,
          'min': step.min,
          'swap': step.swap,
          'stepType': step.stepType,
          'array': List<int>.generate(n, (j) => step.array[j]),
        });
      }

      // Mảng đã sắp xếp sau thuật toán
      final sortedArray = List<int>.generate(n, (i) => intList[i]);

      return {'steps': steps, 'sortedArray': sortedArray};
    } finally {
      malloc.free(arrPtr);
      malloc.free(stepsPtr);
      malloc.free(stepCountPtr);
    }
  }
}
