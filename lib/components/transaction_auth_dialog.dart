import 'package:flutter/material.dart';

class TransactionAuthDialog extends StatefulWidget {
  final Function(String password) onConfirm;

  TransactionAuthDialog({required this.onConfirm});

  @override
  State<TransactionAuthDialog> createState() => _TransactionAuthDialogState();
}

class _TransactionAuthDialogState extends State<TransactionAuthDialog> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Authenticate'),
      content: TextField(
        controller: _passwordController,
        keyboardType: TextInputType.number,
        obscureText: true,
        maxLength: 4,
        textAlign: TextAlign.center,
        decoration: InputDecoration(border: OutlineInputBorder()),
        style: TextStyle(fontSize: 48, letterSpacing: 32),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("CANCEL")),
        TextButton(
            onPressed: () {
              widget.onConfirm(_passwordController.text);
              print("confirm clicado");
              Navigator.pop(context);
            },
            child: Text("CONFIRM")),
      ],
    );
  }
}
