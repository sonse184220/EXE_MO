import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TokenExpiryDialog extends ConsumerWidget {
  final VoidCallback onRefreshSuccess;
  final VoidCallback onRefreshFailed;

  const TokenExpiryDialog({
    super.key,
    required this.onRefreshSuccess,
    required this.onRefreshFailed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Session Expired'),
      content: const Text(
        'Your session has expired. Would you like to refresh your session or login again?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRefreshFailed();
          },
          child: const Text('Login Again'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();

            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Refreshing session...'),
                  ],
                ),
              ),
            );

            // Simulate refresh attempt
            await Future.delayed(const Duration(seconds: 1));

            if (context.mounted) {
              Navigator.of(context).pop(); // Close loading dialog

              // You would call your actual refresh method here
              // For now, we'll just call the callback
              onRefreshSuccess();
            }
          },
          child: const Text('Refresh Session'),
        ),
      ],
    );
  }
}