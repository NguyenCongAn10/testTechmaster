link clip[https://youtube.com/shorts/8R5LrWeErXM]





Ý tưởng:
- Hiển thị một tam giác trên giao diện, với các đỉnh rõ ràng.
- Xác định khi nào người dùng chạm gần một đỉnh.
- Cho phép kéo đỉnh đó bằng thao tác tay và cập nhật lại vị trí.
- Vẽ lại tam giác tương ứng với các tọa độ mới.

Giải pháp:
- StatefulWidget : Dùng để lưu và cập nhật tọa độ của các đỉnh tam giác.
- GestureDetector: Bắt thao tác tay: bắt đầu kéo, kéo, thả tay.
- CustomPainter : Vẽ tam giác và các đỉnh trên canvas.
- Offset : Đại diện cho vị trí từng đỉnh trong hệ toạ độ màn hình.

Bước 1: Vẽ tam giác ban đầu bằng TrianglePainter.

- Dùng CustomPaint với lớp TrianglePainter để vẽ tam giác theo 3 đỉnh đó:
  + Sử dụng Path để nối lần lượt 3 đỉnh tạo thành tam giác.

                  final paint =
                      Paint()
                        ..color = Colors.blue
                        ..strokeWidth = 3
                        ..style = PaintingStyle.stroke;
              
                  final path =
                      Path()
                        ..moveTo(points[0].dx, points[0].dy)
                        ..lineTo(points[1].dx, points[1].dy)
                        ..lineTo(points[2].dx, points[2].dy)
                        ..close();
    
  + Sau đó dùng canvas.drawPath(...) để vẽ đường viền bằng màu xanh.
  + Dùng canvas.drawCircle(...) để đánh dấu các đỉnh, giúp người dùng dễ kéo đúng vị trí.
  + Dùng TextPainter và TextSpan để vẽ chữ lên Canvas.
                  

Bước 2: Khi người dùng nhấn lên màn hình, kiểm tra xem có gần đỉnh nào không (kiểm tra khoảng cách).

                    onPanStart: (details) {
                      setState(() {
                        for (int i = 0; i < points.length; i++) {
                          final distance = (details.localPosition - points[i]).distance;
                          if (distance < 30) {
                            draggingIndex = i; // Lưu lại chỉ số của đỉnh đang được kéo
                            break;
                          }
                        }
                      });
                    },
- Duyệt qua từng đỉnh.
- Tính khoảng cách từ vị trí chạm tới từng đỉnh.
- Nếu khoảng cách nhỏ hơn 30 pixel → xem như người dùng muốn kéo đỉnh đó.
- Gán draggingIndex = i để ghi nhớ ta đang kéo đỉnh nào.

Bước 3: Khi người dùng kéo tay (onPanUpdate).

                      onPanUpdate: (details) {
                        if (draggingIndex != null) {
                          setState(() {
                            final newPoints = List<Offset>.from(points);
                            newPoints[draggingIndex!] = details.localPosition;
                            points = newPoints;
                          });
                        }
                      },

- Chỉ thực hiện khi đang kéo một đỉnh (draggingIndex != null).
- Tạo bản sao mới của danh sách points.
- Cập nhật vị trí mới cho đỉnh đó bằng details.localPosition.
- Gán lại points để Flutter biết cần vẽ lại tam giác.

Bước 4: Khi người dùng thả tay.

                    onPanEnd: (_) {
                      setState(() {
                        draggingIndex = null;
                      });
                    },

- Gán draggingIndex = null để reset trạng thái kéo


