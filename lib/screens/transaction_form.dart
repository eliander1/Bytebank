import 'dart:async';
import 'package:alura_2/components/response_dialog.dart';
import 'package:alura_2/components/transaction_auth_dialog.dart';
import 'package:alura_2/http/webclients/transactions_webclient.dart';
import 'package:alura_2/screens/contacts_list.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';
import '../components/Container.dart';
import '../components/Progress.dart';
import '../components/error.dart';
import '../http/web_client.dart';
import '../models/contact.dart';
import '../models/transaction.dart';

@immutable
abstract class TransactionFormState {
  const TransactionFormState();
}

@immutable
class SendingState extends TransactionFormState {
  const SendingState();
}

@immutable
class ShowFormState extends TransactionFormState {
  const ShowFormState();
}

@immutable
class SentState extends TransactionFormState {
  const SentState();
}

@immutable
class FatalErrorFormState extends TransactionFormState {
  final String message;

  FatalErrorFormState(this.message);
}

class TransactionFormCubit extends Cubit<TransactionFormState> {
  TransactionFormCubit() : super(ShowFormState());
  final TransactionWebClient _webClient = TransactionWebClient();

  void save(Transaction transactionCreated, String password,
      BuildContext context) async {
    emit(SendingState());

    await _send(transactionCreated, password, context);
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

  _send(Transaction transactionCreated, String password,
      BuildContext context) async {
    await _webClient
        .save(transactionCreated, password)
        .then((transaction) => emit(SentState()))
        .catchError((e) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exception', e.toString());
        FirebaseCrashlytics.instance
            .setCustomKey('Http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(e, null);
      }

      emit(FatalErrorFormState(e.message));
    }, test: (e) => e is HttpException).catchError((e) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.recordError(e, null);
        FirebaseCrashlytics.instance.setCustomKey('Htttp_Code', e.statusCode);
        FirebaseCrashlytics.instance
            .setCustomKey('Http_body', transactionCreated.toString());
      }

      emit(FatalErrorFormState('Timeout submitting the transaction'));
    }, test: (e) => e is TimeoutException).catchError((e) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.recordError(e, null);
        FirebaseCrashlytics.instance.setCustomKey('exception', e.toString());
        FirebaseCrashlytics.instance
            .setCustomKey('Http_body', transactionCreated.toString());
      }

      emit(FatalErrorFormState(e.message));
    });
  }

  void _showFailureMessage(BuildContext context,
      {String message = 'UNKNOWN ERROR'}) {
    showDialog(
        context: context,
        builder: (contextDialog) {
          return FailureDialog(message);
        });
  }
}

class TransactionFormContainer extends BlocContainer {
  final Contact _contact;

  TransactionFormContainer(this._contact);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionFormCubit>(
      create: (BuildContext context) {
        return TransactionFormCubit();
      },
      child: BlocListener<TransactionFormCubit, TransactionFormState>
        (child: TransactionFormStateless(_contact),
      listener: (context, state){
        if(state is SentState){
          Navigator.pop(context);
        }
      },),
    );
  }
}

class TransactionFormStateless extends StatelessWidget {
  final TransactionWebClient _webClient = TransactionWebClient();
  final Contact _contact;

  TransactionFormStateless(this._contact);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionFormCubit, TransactionFormState>(
        builder: (context, state) {

      if (state is ShowFormState) {
        return _BasicForm(_contact);
      }
      if (state is SendingState) {
        return ProgressView();
      }
      if (state is SentState) {
        return ProgressView();
      }
      if (state is FatalErrorFormState) {
        return ErrorView(state.message);
      }

      return ErrorView("Unknown Error");
    });
  }
}

class _BasicForm extends StatelessWidget {
  final Contact _contact;

  _BasicForm(this._contact);

  final String transactionId = Uuid().v4();
  final TextEditingController _valueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
              Text(
                _contact.name,
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _contact.accountNumber.toString(),
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
                          Transaction(transactionId, value!, _contact);
                      showDialog(
                          context: context,
                          builder: (contextDialog) {
                            return TransactionAuthDialog(
                              onConfirm: (String password) {
                                BlocProvider.of<TransactionFormCubit>(context)
                                    .save(
                                        transactionCreated, password, context);
                                //_save(transactionCreated, password, context);
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
}
