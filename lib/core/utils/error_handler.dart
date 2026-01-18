import 'package:flutter/material.dart';

class GlobalErrorHandler {
  static void handleError(BuildContext context, dynamic error) {
    String message = "An unexpected error occurred.";

    if (error.toString().contains("permission-denied")) {
      message = "You do not have permission to perform this action.";
    } else if (error.toString().contains("network-request-failed")) {
      message = "Please check your internet connection.";
    } else {
      message = error.toString();
    }

    final snackBar = SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {},
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
