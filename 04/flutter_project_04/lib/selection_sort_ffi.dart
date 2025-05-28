import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// Load thư viện động
final DynamicLibrary selectionSortLib = DynamicLibrary.open(
  '/Users/admin/testTechmaster/04/flutter_project_04/ios/Runner/selection_sort.dylib',
);

// Khai báo hàm C
typedef c_selection_sort = Void Function(Pointer<Int32> arr, Int32 n);
typedef dart_selection_sort = void Function(Pointer<Int32> arr, int n);

final dart_selection_sort selectionSort = selectionSortLib
    .lookupFunction<c_selection_sort, dart_selection_sort>("selectionSort");

// Hàm giúp chạy sắp xếp
void sortWithFFI(List<int> list) {
  final ptr = calloc<Int32>(list.length);

  // Copy dữ liệu từ List sang bộ nhớ C
  for (var i = 0; i < list.length; i++) {
    ptr[i] = list[i];
  }

  // Gọi hàm C sắp xếp
  selectionSort(ptr, list.length);

  // Copy dữ liệu đã sắp xếp ngược lại List
  for (var i = 0; i < list.length; i++) {
    list[i] = ptr[i];
  }

  calloc.free(ptr);
}
