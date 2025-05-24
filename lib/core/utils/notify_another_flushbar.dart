import 'package:another_flushbar/flushbar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:inner_child_app/main.dart';

class Notify {
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

  static void showAwesomeDialog({
    required String title,
    required String message,
    DialogType dialogType = DialogType.info,
    String btnOkText = 'OK',
    String? btnCancelText,
    VoidCallback? onOkPress,
    VoidCallback? onCancelPress,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    AwesomeDialog(
      context: context,
      dialogType: dialogType,
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnOkText: btnOkText,
      btnOkOnPress: onOkPress,
      btnCancelText: btnCancelText,
      btnCancelOnPress: onCancelPress,
      dismissOnTouchOutside: false,
      borderSide: const BorderSide(color: Colors.blue, width: 2),
      buttonsBorderRadius: const BorderRadius.all(Radius.circular(2)),
    ).show();
  }
}
