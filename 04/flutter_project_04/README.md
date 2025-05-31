link clip [https://youtube.com/shorts/0VLGpQKoT4c]


Ý tưởng giải pháp:

  - Hiển thị trực quan thuật toán Selection Sort bằng Flutter, sử dụng FFI (Foreign Function Interface) để kết nối với thư viện native C. Ý tưởng chính là theo dõi từng bước sắp xếp và trực quan hóa bằng animation.

1. Thuật toán selection sort.
   - Để hiển thị các bước bằng animation phải lưu lại từng bước của thuật toán toán.
   - Ý tưởng bài toán:
     + Duyệt qua từng phần tử cảu mảng.
     + Tìm phần tử nhỏ nhất.
     + Hoán đổi phần tử nhỏ nhất với phần tử đầu tiên của mảng chưa sắp xếp.
     + Lặp lại cho tới khi toàn bộ mảng được sắp xếp.
   - Viết selection_sort.c phải ghi lại toàn bộ các bước của thuật toán(so sánh, hoán đổi, cập nhật min).

                            #include <stdint.h>
                            
                            // Cấu trúc để lưu trạng thái của mỗi bước
                            typedef struct {
                                int current;      // Vị trí hiện tại (i)
                                int compare;      // Vị trí đang so sánh (j)
                                int min;          // Vị trí nhỏ nhất hiện tại
                                int swap;         // Có hoán đổi không (1: có, 0: không)
                                int stepType;     // Loại bước: 0 = So sánh, 1 = Cập nhật min, 2 = Hoán đổi
                                int array[100];   // Trạng thái mảng tại thời điểm đó
                            } SortStep;
                            
                            // Hàm chính: selection sort và ghi lại các bước
                            void selectionSortWithSteps(int arr[], int n, SortStep steps[], int* stepCount) {
                                int stepIndex = 0;
                            
                                for (int i = 0; i < n - 1; i++) {
                                    int min_idx = i;
                            
                                    // Duyệt phần tử sau i để tìm phần tử nhỏ nhất
                                    for (int j = i + 1; j < n; j++) {
                                        // Bước 1: Ghi lại thao tác so sánh arr[j] với arr[min_idx]
                                        steps[stepIndex] = (SortStep){
                                            .current = i,
                                            .compare = j,
                                            .min = min_idx,
                                            .swap = 0,
                                            .stepType = 0
                                        };
                                        for (int k = 0; k < n; k++)
                                            steps[stepIndex].array[k] = arr[k];
                                        stepIndex++;
                            
                                        // Nếu tìm thấy phần tử nhỏ hơn -> cập nhật min
                                        if (arr[j] < arr[min_idx]) {
                                            min_idx = j;
                            
                                            // Bước 2: Ghi lại thao tác cập nhật min
                                            steps[stepIndex] = (SortStep){
                                                .current = i,
                                                .compare = -1,
                                                .min = min_idx,
                                                .swap = 0,
                                                .stepType = 1
                                            };
                                            for (int k = 0; k < n; k++)
                                                steps[stepIndex].array[k] = arr[k];
                                            stepIndex++;
                                        }
                                    }
                            
                                    // Sau khi duyệt xong, nếu cần thì hoán đổi i với min_idx
                                    if (min_idx != i) {
                                        int temp = arr[i];
                                        arr[i] = arr[min_idx];
                                        arr[min_idx] = temp;
                            
                                        // Bước 3: Ghi lại thao tác hoán đổi
                                        steps[stepIndex] = (SortStep){
                                            .current = i,
                                            .compare = -1,
                                            .min = min_idx,
                                            .swap = 1,
                                            .stepType = 2
                                        };
                                        for (int k = 0; k < n; k++)
                                            steps[stepIndex].array[k] = arr[k];
                                        stepIndex++;
                                    }
                                }
                            
                                // Gán tổng số bước vào stepCount
                                *stepCount = stepIndex;
                            }



2.Kết nối FFI trong Dart

Bước 1: Định nghĩa cấu trúc dữ liệu C tương ứng trong Dart

- Ta tạo một class SortStep kế thừa Struct, tương ứng với struct SortStep bên C:

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
- Đây là phần ánh xạ 1:1 giữa Dart và C để có thể sử dụng trong FFI.

Bước 2: Khai báo typedef cho hàm native

                    typedef SelectionSortWithStepsNative =
                        Void Function(Pointer<Int32>, Int32, Pointer<SortStep>, Pointer<Int32>);
                    
                    typedef SelectionSortWithStepsFunc =
                        void Function(Pointer<Int32>, int, Pointer<SortStep>, Pointer<Int32>);
Bước 3: Load thư viện native

- Trong constructor SelectionSort(), dùng DynamicLibrary.open(...) để load thư viện .dylib ,sau đó ánh xạ hàm native về hàm Dart:
                  
                  _lib = DynamicLibrary.open('.../selection_sort.dylib');
                  _selectionSortWithSteps = _lib
                    .lookup<NativeFunction<SelectionSortWithStepsNative>>('selectionSortWithSteps')
                    .asFunction<SelectionSortWithStepsFunc>();
  
Bước 4: Gọi hàm native và trích xuất dữ liệu
- Tạo hàm sortWithSteps() nhận mảng arr và:

- Cấp phát bộ nhớ native (malloc) cho:
  + Mảng đầu vào
  + Mảng kết quả steps
  + Con trỏ đếm số bước stepCountPtr
- Gọi hàm native:
            _selectionSortWithSteps(arrPtr, n, stepsPtr, stepCountPtr);
- Đọc số bước từ stepCountPtr
- Lặp qua từng bước và tạo Map<String, dynamic> để dùng trong Flutter
- Tạo List<int> từ arrPtr để lấy mảng đã sắp xếp
  
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

3. Hiển thị Animation trong Flutter

 Bước 1: Gọi hàm FFI để nhận kết quả

            final sorter = SelectionSort();
            final result = sorter.sortWithSteps(numbers);
            steps = result['steps'];
            numbers = result['sortedArray'];
- Gọi hàm sortWithSteps() đã kết nối với thư viện C, lấy:
  + Các bước animation (steps)
  + Mảng đã sắp xếp hoàn chỉnh (sortedArray)
    
Bước 2: Thực hiện animation từng bước

            for (final step in steps) {
              setState(() {
                numbers = List<int>.from(step['array']);
                ...
              });
              await Future.delayed(const Duration(milliseconds: 1000));
            }
            
- Duyệt từng bước step:
- Cập nhật lại mảng số hiện tại.
- Cập nhật lại màu sắc dựa vào loại bước:
  + stepType == 0: So sánh → tô đỏ min và compare
  + stepType == 1: Ghi nhận min mới → tô xanh lá min
  + stepType == 2: Hoán đổi → tô xanh lá current và min
- Delay 1 giây để tạo hiệu ứng animation mượt.

4. Giao diện

- maxNumber
  + Dùng để tìm phần tử lớn nhất trong danh sách numbers.
  + Giúp chuẩn hóa chiều cao thanh, đảm bảo thanh cao nhất sẽ có chiều cao max (maxHeight).
- Row và List.generate
  + Tạo một hàng ngang gồm nhiều thanh biểu diễn từng phần tử mảng.
  + List.generate(numbers.length, (index) => ...) sinh ra từng thanh tương ứng phần tử.
- AnimatedContainer
  + Cho phép tạo hiệu ứng mượt khi chiều cao hoặc màu sắc của thanh thay đổi.
  + Mỗi khi setState() gọi cập nhật trạng thái (mảng hoặc màu), AnimatedContainer sẽ chuyển động dần thay vì nhảy ngay.
- Tính chiều cao thanh
  + double height = minHeight + (numbers[index] / maxNumber) * (maxHeight - minHeight);
  + Chiều cao được tính theo tỉ lệ phần tử hiện tại so với phần tử lớn nhất.
  + minHeight là chiều cao thấp nhất để các thanh không bị quá thấp, dễ quan sát.
- Màu thanh
  + color: colors[index] lấy màu theo trạng thái đang có, ví dụ màu xanh dương mặc định, đỏ cho phần tử đang so sánh, xanh lá cho phần tử đang được chọn hoặc hoán đổi.
- Nút bấm bắt đầu sắp xếp
  + Khi isSorting đang true (đang chạy sắp xếp), nút bị vô hiệu hóa (onPressed: null).
  + Khi nhấn nút, gọi hàm startSorting để bắt đầu animation.
