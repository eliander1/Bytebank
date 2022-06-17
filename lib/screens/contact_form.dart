import 'package:alura_2/components/Container.dart';
import 'package:alura_2/database/DAO/contact_DAO.dart';
import 'package:flutter/material.dart';
import '../models/contact.dart';



class ContactForm extends StatefulWidget {
  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final Contact_DAO _dao = Contact_DAO();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Contact'),
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Full Name'),
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextField(
              controller: _accountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Account Number'),
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () {
                  final String name = _nameController.text;
                  final int? accountNumber =
                      int.tryParse(_accountController.text);
                  final Contact newContact = Contact(0, name, accountNumber!);
                  _dao.save(newContact).then((id) => Navigator.pop(context));
                },
                child: Text('Create'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
