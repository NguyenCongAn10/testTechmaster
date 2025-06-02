link video[https://youtu.be/GYO53th01hA]


1. Tạo danh sách lưu vị trí quân hậu
  List<int> currentQueens = List.filled(8, -1);
  - Mỗi phần tử đại diện cho một hàng (row).
  - Giá trị phần tử là vị trí cột (column) mà quân hậu đang được đặt.
  - Giá trị -1 nghĩa là chưa có quân hậu trên hàng đó.
    
2. Hàm xử lí đặt quân hậu placeQueen
  - Hàm được gọi khi muốn đặt quân hậu.
  - Kiểm tra điều kiện để tránh truy cập sai mảng.
  - Reset toàn bộ bàn cờ (List.filled(8, -1)).
  - Đặt quân hậu tại vị trí (row, column) -1 vì index bắt đầu từ 0.
  - Gọi setState() để cập nhật lại giao diện.

3. Xây dựng bàn cờ 8x8 bằng GridView.builder
  - GridView.builder: tạo danh sách 64 ô.
  - crossAxisCount: 8: 8 tạo lưới 8x8.
  - Tính toán row và col dựa trên index từ 0 đến 63.
  - Tô màu xen kẽ: nếu (row + col) là lẻ tô ô màu đen, ngược lại là trắng
  - Kiểm tra có đặt được quân hậu không, nếu có hiển thị Icon.
4. Nút đặt quân hậu
  - Khi bấm nút gọi placeQueen để đặt quân hậu.

