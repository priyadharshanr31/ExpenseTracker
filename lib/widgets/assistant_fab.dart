import 'package:flutter/material.dart';

class AssistantFab extends StatelessWidget {
  const AssistantFab({super.key});

  void _showAssistant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Assistant',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('How can I help you with your finances today?'),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _AssistantButton(
                  label: 'Analyze spending',
                  onTap: () => Navigator.pop(context),
                ),
                _AssistantButton(
                  label: 'Set a budget',
                  onTap: () => Navigator.pop(context),
                ),
                _AssistantButton(
                  label: 'Find savings',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _showAssistant(context);
      },
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.auto_awesome, color: Colors.white),
    );
  }
}

class _AssistantButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AssistantButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }
}
