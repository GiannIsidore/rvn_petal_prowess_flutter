import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Pending':
        bgColor = Color(0xFFFFF3CD);
        textColor = Color(0xFF856404);
        break;
      case 'Processing':
        bgColor = Color(0xFFCCE5FF);
        textColor = Color(0xFF0066CC);
        break;
      case 'Ready':
        bgColor = Color(0xFFE6F3FF);
        textColor = Color(0xFF004080);
        break;
      case 'Rejected':
        bgColor = Color(0xFFF8D7DA);
        textColor = Color(0xFF721C24);
        break;
      case 'Completed':
        bgColor = Color(0xFFD4EDDA);
        textColor = Color(0xFF155724);
        break;
      default:
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
