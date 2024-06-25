import 'package:flutter/material.dart';

class RectangleModel {
  final Offset start;
  final double width;
  final double height;
  final int? id;

  RectangleModel({
    required this.start,
    required this.width,
    required this.height,
    this.id,
  });

  RectangleModel copyWith({
    Offset? start,
    double? width,
    double? height,
  }) {
    return RectangleModel(
      id: id,
      start: start ?? this.start,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
