link video [https://youtu.be/rogbpk_oFUA]


Ý tưởng và giải pháp

1.Thuật toán giải bài toán 8 quân hậu:
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
  
- Một lời giải là một danh sách gồm 8 số nguyên, mỗi số đại diện cho vị trí cột của quân hậu trên hàng tương ứng. Mỗi lời giải được lưu trong List<List<int>> solutions.

- Hàm isSafe() đảm bảo rằng không có quân hậu nào tấn công nhau (theo hàng, cột, và đường chéo).
  
                bool isSafe(List<int> queens, int row, int col) {
                for (int i = 0; i < row; i++) {
                  int placedCol = queens[i];              //Lấy cột cảu quân hậu ở hàng thứ i
                  if (
                      placedCol == col ||                 // nếu cùng cột, đường chéo chính, đường chéo phụ
                      placedCol - i == col - row ||         
                      placedCol + i == col + row           
                  ) {
                    return false;                         // trả về false tức bị tấn công
                  }
                }
                return true;                              // trả về true  
              
              }

-Hàm solveNQeens tạo danh sách queens và gọi hàm backtrack.

- initState() gọi solveNQueens() khi khởi tạo màn hình, và hiển thị lời giải đầu tiên.

  
2.Giao diện:
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
  
