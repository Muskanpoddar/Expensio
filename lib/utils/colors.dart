import 'package:flutter/material.dart';

Color getColorForCategory(String category) {
  switch (category) {
    case 'Food':
      return Colors.red;
    case 'Rent':
      return Colors.blue;
    case 'Shopping':
      return const Color.fromARGB(255, 167, 31, 177);
    case 'Bills':
      return Colors.orange;
    case 'Other':
      return Colors.grey;
    default:
      return Colors.black;
  }
}
