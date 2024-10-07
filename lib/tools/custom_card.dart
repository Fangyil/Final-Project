import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String text;

  const CustomCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }
}
