import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:student_crud/models/student.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'StudentData.db';
  static const _databaseVersion = 1;

  //singleton class
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory dataDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(dataDirectory.path, _databaseName);
    return await openDatabase(dbPath,
        version: _databaseVersion, onCreate: _onCreateDB);
  }

  _onCreateDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE ${Student.tblStudent}(
      ${Student.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${Student.colName} TEXT NOT NULL,
      ${Student.colMobile} TEXT NOT NULL
    )
    ''');
  }

  Future<int> insertStudent(Student student) async {
    Database? db = await database;
    return await db!.insert(Student.tblStudent, student.toMap());
  }

  Future<int> updateStudent(Student student) async {
    Database? db = await database;
    return await db!.update(Student.tblStudent, student.toMap(),
        where: '${Student.colId}=?', whereArgs: [student.id]);
  }

  Future<int> deleteStudent(int id) async {
    Database? db = await database;
    return await db!.delete(Student.tblStudent,
        where: '${Student.colId}=?', whereArgs: [id]);
  }

  Future<List<Student>> fetchStudents() async {
    Database? db = await database;
    List<Map<String, dynamic>> students = await db!.query(Student.tblStudent);
    return students.length == 0
        ? []
        : students.map((e) => Student.fromMap(e)).toList();
  }
}
