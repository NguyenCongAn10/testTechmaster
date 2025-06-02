import 'package:flutter/material.dart';

void main() => runApp(TriangleApp());

class TriangleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Kéo Từng Đỉnh Tam Giác')),
        body: TriangleEditor(),
      ),
    );
  }
}

class TriangleEditor extends StatefulWidget {
  @override
  _TriangleEditorState createState() => _TriangleEditorState();
}

class _TriangleEditorState extends State<TriangleEditor> {
  List<Offset> points = [
    Offset(100, 100), // A
    Offset(200, 100), // B
    Offset(150, 200), // C
  ];

  int? draggingIndex;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onPanStart: (details) {
        print('Pan Start: ${details.localPosition}');
        setState(() {
          for (int i = 0; i < points.length; i++) {
            final distance = (details.localPosition - points[i]).distance;
            print('Distance to point $i: $distance');
            if (distance < 30) {
              draggingIndex = i;
              print('Selected point: $i');
              break;
            }
          }
        });
      },
      onPanUpdate: (details) {
        if (draggingIndex != null) {
          setState(() {
            // Tạo một bản sao mới của danh sách points
            final newPoints = List<Offset>.from(points);
            // Cập nhật tọa độ mới với Offset mới
            newPoints[draggingIndex!] = Offset(
              details.localPosition.dx.clamp(0, size.width),
              details.localPosition.dy.clamp(0, size.height),
            );
            points = newPoints;
            print('Updated points: $points');
          });
        }
      },
      onPanEnd: (_) {
        setState(() {
          draggingIndex = null;
          print('Pan End');
        });
      },
      child: Stack(
        children: [
          CustomPaint(painter: TrianglePainter(points), size: Size.infinite),
          Container(
            color: Colors.transparent,
            width: size.width,
            height: size.height,
          ),
        ],
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final List<Offset> points;

  TrianglePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
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

    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = Colors.red;
    for (final p in points) {
      canvas.drawCircle(p, 8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TrianglePainter oldDelegate) {
    // So sánh từng tọa độ để đảm bảo vẽ lại khi có thay đổi
    for (int i = 0; i < points.length; i++) {
      if (points[i] != oldDelegate.points[i]) {
        return true;
      }
    }
    return false;
  }
}
