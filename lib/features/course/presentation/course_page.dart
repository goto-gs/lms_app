import 'package:flutter/material.dart';

class CoursePage extends StatelessWidget {
  final String courseId;
  const CoursePage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Course $courseId')),
      body: Center(child: Text('Course: $courseId')),
    );
  }
}
