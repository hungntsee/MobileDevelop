// ignore_for_file: deprecated_member_use, prefer_final_fields, prefer_is_empty, prefer_const_constructors, curly_braces_in_flow_control_structures

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:student_crud/models/student.dart';
import 'package:student_crud/utils/database_helper.dart';

const pinkColor = Color(0xFFE01D5E);
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Management',
      theme: ThemeData(
        primaryColor: pinkColor,
      ),
      home: const MyHomePage(title: 'Student Management'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  DatabaseHelper? _dbHelper;
  Student _student = Student();
  List<Student> _students = [];

  final _formKey = GlobalKey<FormState>();
  final _ctrlName = TextEditingController();
  final _ctrlMobile = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });
    _refreshStudentList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: pinkColor,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Center(
          child: Text(
            widget.title,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[_form(), _list()],
        ),
      ),
    );
  }

  _form() => Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _ctrlName,
              decoration: InputDecoration(labelText: 'Full Name'),
              onSaved: (val) => setState(() => _student.name = val),
              validator: (val) =>
                  (val!.length == 0 ? 'This field is required' : null),
            ),
            TextFormField(
              controller: _ctrlMobile,
              decoration: InputDecoration(labelText: 'Mobile'),
              onSaved: (val) => setState(() => _student.mobile = val),
              validator: (val) =>
                  (val!.length < 10 ? 'This field has 10 digits' : null),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RaisedButton(
                      onPressed: () => _onNew(),
                      child: Text('New'),
                      color: pinkColor,
                      textColor: Colors.white),
                  RaisedButton(
                    onPressed: () => _onSubmit(),
                    child: Text('Submit'),
                    color: pinkColor,
                    textColor: Colors.white,
                  )
                ],
              ),
            )
          ],
        ),
      ));

  _refreshStudentList() async {
    List<Student> x = await _dbHelper!.fetchStudents();
    setState(() {
      _students = x;
    });
  }

  _onNew() async {
    _resetForm();
  }

  _onSubmit() async {
    var form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      if (_student.id == null)
        await _dbHelper!.insertStudent(_student);
      else
        await _dbHelper!.updateStudent(_student);
      _refreshStudentList();
      _resetForm();
    }
  }

  _resetForm() {
    setState(() {
      _formKey.currentState!.reset();
      _ctrlName.clear();
      _ctrlMobile.clear();
      _student.id = null;
    });
  }

  _list() => Expanded(
        child: Card(
          margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              var mobile2 = _students[index].mobile!;
              return Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(
                      Icons.account_circle,
                      color: pinkColor,
                      size: 40.0,
                    ),
                    title: Text(
                      _students[index].name!.toUpperCase(),
                      style: TextStyle(
                          color: pinkColor, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(mobile2),
                    trailing: IconButton(
                        icon: Icon(
                          Icons.delete_sweep,
                          color: pinkColor,
                        ),
                        onPressed: () async {
                          await _dbHelper!.deleteStudent(_students[index].id!);
                          _resetForm();
                          _refreshStudentList();
                        }),
                    onTap: () {
                      _resetForm();
                      setState(() {
                        _student = _students[index];
                        _ctrlName.text = _students[index].name!;
                        _ctrlMobile.text = _students[index].mobile!;
                      });
                    },
                  ),
                  Divider(
                    height: 5.0,
                  )
                ],
              );
            },
            itemCount: _students.length,
          ),
        ),
      );
}
