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
  const Add({super.key});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  void showdate() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2023),
            lastDate: DateTime(3000))
        .then((value) {
      setState(() {
        _dateTime = value!;
      });
    });
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController Judul = TextEditingController();
  TextEditingController Isi = TextEditingController();
  // TextEditingController Date = TextEditingController();
  DateTime _dateTime = DateTime.now();

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: Judul,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Judul Reminder"),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: Isi,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Isi"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Isi reminder tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: showdate,
                    child: const Text('Date'),
                  ),
                ),
              ),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Text(_dateTime.day.toString() +
                      "-" +
                      _dateTime.month.toString() +
                      "-" +
                      _dateTime.year.toString())),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('Reminderdb')
                          .add(<String, dynamic>{
                        'judul': Judul.text,
                        'isi': Isi.text,
                        'tanggal': _dateTime.day.toString(),
                        'bulan': _dateTime.month.toString(),
                        'tahun': _dateTime.year.toString(),
                        'sender': FirebaseAuth.instance.currentUser!.uid,
                      });
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen()));
                      // if (_formKey.currentState!.validate()) {
                      //   // Navigate the user to the Home page
                      // } else {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     const SnackBar(content: Text('Please fill input')),
                      //   );
                      // }
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
        options: DefaultFirebaseOptions.currentPlatform);
  }
}
