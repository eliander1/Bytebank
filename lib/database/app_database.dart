import 'package:alura_2/database/DAO/contact_DAO.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> getDatabase() async {
  final String path = join(await getDatabasesPath(), 'bytebank.db');
  return openDatabase(path, onCreate: (db, version) {
    db.execute(Contact_DAO.tableSql);

  }, version: 1);
}


