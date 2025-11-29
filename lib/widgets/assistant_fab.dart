import 'package:flutter/material.dart';

class AssistantFab extends StatelessWidget {
  final VoidCallback onPressed;

  const AssistantFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.auto_awesome, color: Colors.white),
    );
  }
}


