import 'dart:math';
import 'package:flutter/material.dart';

Color randomCardColor() {
  final colors = Colors.primaries;
  return colors[Random().nextInt(colors.length)].shade100;
}
