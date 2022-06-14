import 'dart:async';
import 'package:alura_2/components/response_dialog.dart';
import 'package:alura_2/components/transaction_auth_dialog.dart';
import 'package:alura_2/http/webclients/transactions_webclient.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';
import '../components/Progress.dart';
import '../http/web_client.dart';
import '../models/contact.dart';
import '../models/transaction.dart';

class TransactionForm extends StatefulWidget {
  final Contact contact;

  TransactionForm(this.contact);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final TextEditingController _valueController = TextEditingController();
  final TransactionWebClient _webClient = TransactionWebClient();
  final String transactionId = Uuid().v4();
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    print(transactionId);
    return Scaffold(
      appBar: AppBar(
        title: Text('New transaction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Visibility(
                visible: _sending,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Progress(message: 'Sending...'),
                ),
              ),
              Text(
                widget.contact.name,
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  widget.contact.accountNumber.toString(),
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: _valueController,
                  style: TextStyle(fontSize: 24.0),
                  decoration: InputDecoration(labelText: 'Value'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    child: Text('Transfer'),
                    onPressed: () {
                      final double? value =
                          double.tryParse(_valueController.text);
                      final transactionCreated =
                          Transaction(transactionId, value!, widget.contact);
                      showDialog(
                          context: context,
                          builder: (contextDialog) {
                            return TransactionAuthDialog(
                              onConfirm: (String password) {
                                _save(transactionCreated, password, context);
                              },
                            );
                          });
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _save(Transaction transactionCreated, String password,
      BuildContext context) async {
    setState(() {
      _sending = true;
    });

    Transaction? transaction =
        await _send(transactionCreated, password, context);
    _showSuccessfulMessage(transaction, context);
  }

  Future<void> _showSuccessfulMessage(
      Transaction? transaction, BuildContext context) async {
    if (transaction != null) {
      await showDialog(
          context: context,
          builder: (contextDialog) {
            return SuccessDialog('Sucessful transaction');
          });
      Navigator.pop(context);
    }
  }

  Future<Transaction?> _send(Transaction transactionCreated, String password,
      BuildContext context) async {
    final Transaction? transaction =
        await _webClient.save(transactionCreated, password).catchError((e) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exception', e.toString());
        FirebaseCrashlytics.instance
            .setCustomKey('Http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(e, null);
      }

      _showFailureMessage(context, message: e.message);
    }, test: (e) => e is HttpException).catchError((e) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.recordError(e, null);
        FirebaseCrashlytics.instance.setCustomKey('Htttp_Code', e.statusCode);
        FirebaseCrashlytics.instance
            .setCustomKey('Http_body', transactionCreated.toString());
      }

      _showFailureMessage(context,
          message: 'Timeout submitting the transaction');
    }, test: (e) => e is TimeoutException).catchError((e) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.recordError(e, null);
        FirebaseCrashlytics.instance.setCustomKey('exception', e.toString());
        FirebaseCrashlytics.instance
            .setCustomKey('Http_body', transactionCreated.toString());
      }

      _showFailureMessage(context);
    }).whenComplete(() {
      setState(() {
        _sending = false;
      });
    });
    return transaction;
  }

  void _showFailureMessage(BuildContext context,
      {String message = 'Unknown error'}) {

    // showDialog(
    //     context: context,
    //     builder: (_) => AssetGiffyDialog(
    //           image: Image.asset('assets/cachorro-assustado.gif'),
    //           title: Text(
    //             'OPSSS...',
    //             style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
    //           ),
    //           description: Text(
    //             message,
    //             textAlign: TextAlign.center,
    //           ),
    //           entryAnimation: EntryAnimation.TOP,
    //           onOkButtonPressed: () {},
    //         ));


    //showToast(message, gravity: Toast.bottom);


    showDialog(
        context: context,
        builder: (contextDialog) {
          return FailureDialog(message);
        });
  }

  void showToast(String msg, {int duration = 5, int? gravity}) {
    Toast.show(msg, duration: duration, gravity: gravity);
  }
}
