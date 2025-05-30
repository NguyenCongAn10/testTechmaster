link video [https://youtu.be/KjRdVZXX22E]

Ý tưởng và giải pháp.

1.Thuật toán giải bài toán 8 quân hậu:
  - Hàm isSafe() kiểm tra vị trí đặt quân hậu.(không cùng hàng, cột và đường chéo).
    
          int isSafe(List<int> queens, int row, int col) {
            for (int i = 0; i < row; i++) {
              int placedCol = queens[i];              //Lấy cột của quân hậu ở hàng thứ i
              if (
                  placedCol == col ||                 // nếu cùng cột, đường chéo chính, đường chéo phụ
                  placedCol - i == col - row ||         
                  placedCol + i == col + row           
              ) {
                return 0;                         // trả về 0 tức bị tấn công
              }
            }
            return 1;                              // trả về 1  An toàn
          }
  - Sử dụng phương pháp Backtracking (quay lui) để tìm tất cả lời giải.
    + Mỗi lời giải phải có đủ 8 phần tử queens[row] = col,sau đó thêm vào danh sách lời giải.
    + Duyệt cột từ 0->7 tại tất cả các hàng. Nếu an toàn đặt quân hậu, gọi đệ quy đến hàng tiếp theo.

          void backtrack(List<int> queens, int row) {
            if (row == 8) {
              solutions.add(List.from(queens)); // Đã đặt đủ 8 quân, lưu lại lời giải
              return;
            }
          
            for (int col = 0; col < 8; col++) {
              if (isSafe(queens, row, col)) {
                queens[row] = col; // Đặt quân hậu
                backtrack(queens, row + 1); // Thử tiếp hàng sau
                queens[row] = -1; // Quay lui (reset vị trí)
              }
            }
          }
  - Hàm getSolutions() trả về danh sách nghiệm cho Flutter.
    
            int* getSolutions(int* count) {
                int queens[BOARD_SIZE] = { -1 };    // Khởi tạo mảng để lưu vị trí các quân hậu
                solutionCount = 0;
                backtrack(queens, 0);               //Hàm backtrack(queens, 0) bắt đầu tìm lời giải từ hàng 0.
  
                *count = solutionCount;             //Sau khi backtracking xong, cập nhật lại số lời giải 
            
                int* flat = (int*)malloc(sizeof(int) * solutionCount * BOARD_SIZE);    //Cấp phát bộ nhớ động để lưu tất cả lời giải theo dạng mảng 1 chiều
                for (int i = 0; i < solutionCount; i++) {       //Lặp qua tất cả các lời giải đã lưu trong mảng 2 chiều tempSolutions 
                    for (int j = 0; j < BOARD_SIZE; j++) {
                        flat[i * BOARD_SIZE + j] = tempSolutions[i][j];
                    }
                }
                return flat;     //Trả về con trỏ flat, trỏ đến mảng 1 chiều chứa toàn bộ các lời giải
            }
    - loadSolutions() Flutter gọi Native Code sử dụng FFI để gọi hàm C từ thư viện .dylib.
      
              typedef GetSolutionsNative =
                  ffi.Pointer<ffi.Int32> Function(ffi.Pointer<ffi.Int32>); //định nghĩa kiểu hàm tương ứng với C 
              typedef GetSolutionsDart =
                  ffi.Pointer<ffi.Int32> Function(ffi.Pointer<ffi.Int32>); // định nghĩa kiểu hàm tương tự nhưng dành cho Dart sử dụng trực tiếp.

              typedef FreeSolutionsNative = ffi.Void Function(ffi.Pointer<ffi.Int32>);
              typedef FreeSolutionsDart = void Function(ffi.Pointer<ffi.Int32>);

              void loadSolutions() {
                try {
                  // Mở file thư viện động .dylib chứa hàm C getSolutions
                  final dylib = ffi.DynamicLibrary.open(
                    '/Users/admin/testTechmaster/03/flutter_project_03/ios/Runner/libnqueens.dylib',
                  );

                  //Ánh xạ hàm getSolutions từ thư viện C sang một biến Dart có thể gọi được        
                  final getSolutions = dylib
                      .lookupFunction<GetSolutionsNative, GetSolutionsDart>('getSolutions');   
                  //Ánh xạ hàm freeSolutions từ thư viện C sang một biến Dart có thể gọi được
                  final freeSolutions = dylib
                      .lookupFunction<FreeSolutionsNative, FreeSolutionsDart>(
                        'freeSolutions',
                      ); 
                  //Cấp phát bộ nhớ cho một biến int trong C (tương đương với int* count).
                  final countPtr = calloc<ffi.Int32>();
      
                  // Gọi hàm C getSolutions và truyền countPtr.
                  //Trả về một con trỏ đến mảng các lời giải (kiểu int* trong C)
                  final solutionsPtr = getSolutions(countPtr);
      
                  //Đọc giá trị từ countPtr, tức là số lượng lời giải mà hàm C đã tìm được và gán vào *count.
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

                  
                  //Mỗi lời giải có 8 số (vì là bài toán 8 quân hậu), nên totalInts = count * 8.
                  final totalInts = count * 8;
      
                  //Tạo danh sách TypedList gồm tất cả các số nguyên từ mảng C.
                  final solutionsList = solutionsPtr.asTypedList(totalInts);

                  //Tách solutionsList thành danh sách các lời giải, mỗi lời giải là danh sách 8 số nguyên (vị trí quân hậu theo cột của từng hàng).
                  solutions = List.generate(
                    count,
                    (i) => solutionsList.sublist(i * 8, (i + 1) * 8),
                  );
                  //Gán lời giải đầu tiên để hiển thị
                  currentQueens = List.from(solutions[0]);
                  currentSolutionIndex = 0;
            
                  freeSolutions(solutionsPtr);
                  calloc.free(countPtr);
            
                  setState(() {});    // cập nhật UI sau khi có dữ liệu
            
                  print('Loaded $count solutions from native code.');
                } catch (e, st) {
                  print('Error loading solutions from native code: $e');
                  print(st);
                }
              }

2. Hiển thị danh sách nghiệm trên UI
  - Dùng GridView.builder để vẽ bàn cờ 8x8 và thông tin lời giải.
  - Icon hình ngôi sao đỏ đại diện cho một quân hậu. Dựa vào danh sách currentQueens để đặt biểu tượng quân hậu
  - Vuốt ngang trên màn hình (sử dụng GestureDetector với thuộc tính onHorizontalDragEnd: handleSwipe ) để chuyển qua lời giải tiếp theo hoặc quay lại lời giải trước.
    + Kiểm tra xem có lời giải không.
    + Gọi setState để cập nhật lời giải khi thay đổi currentQueens.

   
           void handleSwipe(DragEndDetails details) {
              if (solutions.isEmpty) return;
              setState(() {
                if (details.primaryVelocity! < 0) {                          // Vuốt từ phải → trái (hướng âm), tức là muốn chuyển tới lời giải tiếp theo
                  if (currentSolutionIndex < solutions.length - 1) {              //Nếu chưa đến lời giải cuối cùng:
                    currentSolutionIndex++;                                       //Tăng currentSolutionIndex
                    currentQueens = List.from(solutions[currentSolutionIndex]);   //Cập nhật currentQueens theo lời giải mới (cần List.from để tạo bản sao, tránh sửa mảng gốc)
            
                    }
                } else if (details.primaryVelocity! > 0) {             // Vuốt từ trái → phải (hướng dương), tức là muốn quay lại lời giải trước
                  if (currentSolutionIndex > 0) {                      //Nếu không phải lời giải đầu tiên,giảm chỉ số và cập nhật quân hậu đang hiển thị
                    currentSolutionIndex--;
                    currentQueens = List.from(solutions[currentSolutionIndex]);
                  }
                }
              });
            }
  

