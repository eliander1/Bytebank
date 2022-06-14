import 'package:alura_2/screens/contact_form.dart';
import 'package:alura_2/screens/transaction_form.dart';
import 'package:flutter/material.dart';
import '../components/Progress.dart';
import '../database/DAO/contact_DAO.dart';
import '../models/contact.dart';

class ContactsList extends StatefulWidget {
  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  final Contact_DAO _dao = Contact_DAO();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer'),
      ),
      body: FutureBuilder<List<Contact>?>(
        initialData: [],
        future: _dao.findAll(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              //Colocar algum widget que permita o usuario recarregar ou ligar internet
              break;
            case ConnectionState.waiting:
              Progress();
              break;
            case ConnectionState.active:
              //A ideia é retornar a informacao em partes, por exemplo partes de um download
              break;
            case ConnectionState.done:
              final List<Contact> contacts = snapshot.data as List<Contact>;
              return ListView.builder(
                itemBuilder: (context, index) {
                  final Contact contact = contacts[index];

                  return _ContactItem(contact, onCLick: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TransactionForm(contact),
                      ),
                    );
                  });
                },
                itemCount: contacts.length,
              );
              break;
          }
          return Text('Unknown Error');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => ContactForm(),
                ),
              )
              .then((value) => setState(() {}));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final Contact contact;
  final Function onCLick;

  _ContactItem(this.contact, {required this.onCLick});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TransactionForm(contact),
            ),);
            },
        title: Text(
          contact.name,
          style: TextStyle(fontSize: 24),
        ),
        subtitle: Text(
          contact.accountNumber.toString(),
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
