import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:inner_child_app/main.dart';

class NotifyAnotherFlushBar {
  static void showFlushbar(
      // BuildContext context,
      String message, {
        bool isError = false,
      }) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Flushbar(
          message: message,
          duration: const Duration(seconds: 3),
          backgroundColor: isError ? Colors.redAccent : Colors.green,
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          flushbarPosition: FlushbarPosition.TOP,
          icon: Icon(
            isError ? Icons.error : Icons.check_circle,
            color: Colors.white,
          ),
        ).show(context);
      }
    });
  }
  // static void showFlushbar(
  //     BuildContext context,
  //     String message, {
  //       bool isError = false,
  //     }) {
  //   Flushbar(
  //     message: message,
  //     duration: const Duration(seconds: 3),
  //     backgroundColor: isError ? Colors.redAccent : Colors.green,
  //     margin: const EdgeInsets.all(8),
  //     borderRadius: BorderRadius.circular(8),
  //     flushbarPosition: FlushbarPosition.TOP,
  //     icon: Icon(
  //       isError ? Icons.error : Icons.check_circle,
  //       color: Colors.white,
  //     ),
  //   ).show(context);
  // }
}
