import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';
import 'register.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // new
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import '../firebase_options.dart';

class Add extends StatefulWidget {
  const Add({Key? key}) : super(key: key);

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  void showdate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(3000),
    ).then((value) {
      setState(() {
        _dateTime = value!;
      });
    });
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController Judul = TextEditingController();
  TextEditingController Isi = TextEditingController();
  DateTime _dateTime = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  void _showTimePicker() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Reminder"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: Judul,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Judul Reminder",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: Isi,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Isi",
                  ),
                  maxLines: 5,
                  minLines: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Isi reminder tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: showdate,
                    child: const Text('Date'),
                  ),
                  ElevatedButton(
                    onPressed: _showTimePicker,
                    child: const Text('Time'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20.0),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 16),
                child: Text(
                  "${_dateTime.day}-${_dateTime.month}-${_dateTime.year}",
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 16),
                child: Text(
                  _selectedTime != null
                      ? _selectedTime.format(context)
                      : 'No time selected',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 16),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('Reminderdb')
                          .add(
                        <String, dynamic>{
                          'judul': Judul.text,
                          'isi': Isi.text,
                          'tanggal': _dateTime.day.toString(),
                          'bulan': _dateTime.month.toString(),
                          'tahun': _dateTime.year.toString(),
                          'sender':
                              FirebaseAuth.instance.currentUser!.uid,
                          'jam': _selectedTime.hour,
                          'menit': _selectedTime.minute,
                        },
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}