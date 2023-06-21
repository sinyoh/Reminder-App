import 'dart:async';

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

class Edit extends StatefulWidget {
  String edited = "";
  Edit({Key? key, required this.edited}) : super(key: key);

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  StreamSubscription<QuerySnapshot>? _reminderSubscription;
  List<Reminder> _reminder = [];
  List<Reminder> get reminder => _reminder;
  void showdate() {
    showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2023),
      lastDate: DateTime(3000),
    ).then((value) {
      setState(() {
        _dateTime = value!;
      });
    });
  }

  final _formKey = GlobalKey<FormState>();
  Reminder? reminderGlobal;
  TextEditingController Judul = TextEditingController();
  TextEditingController Isi = TextEditingController();
  DateTime _dateTime = DateTime.now();
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void _showTimePicker() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
  }

  void initialize() async {
    String edited = widget.edited;
    var rem = FirebaseFirestore.instance
        .collection("Reminderdb")
        .doc(edited)
        .snapshots()
        .listen((snapshot) {
      final doc = snapshot.data();
      setState(() {
        reminderGlobal = Reminder(
          edited,
          doc!["judul"].toString(),
          doc["isi"].toString(),
          int.parse(doc["tanggal"]),
          int.parse(doc["bulan"]),
          int.parse(doc["tahun"]),
          doc["jam"],
          doc["menit"],
        );

        Judul.text = reminderGlobal!.judul.toString();
        Isi.text = reminderGlobal!.isi.toString();
        _dateTime = DateTime(reminderGlobal!.tahun, reminderGlobal!.bulan,
            reminderGlobal!.tanggal);
        _selectedTime =
            TimeOfDay(hour: reminderGlobal!.jam, minute: reminderGlobal!.menit);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Reminder"),
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
                    labelText: "Judul Reminder",
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Text(
                    "${reminderGlobal?.tanggal.toString()} - ${reminderGlobal?.bulan.toString()} - ${reminderGlobal?.tahun.toString()}"),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Text(
                  _selectedTime != null
                      ? _selectedTime!.format(context)
                      : 'No time selected',
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('Reminderdb')
                          .doc(reminderGlobal!.id)
                          .set(
                        <String, dynamic>{
                          'judul': Judul.text,
                          'isi': Isi.text,
                          'tanggal': _dateTime.day.toString(),
                          'bulan': _dateTime.month.toString(),
                          'tahun': _dateTime.year.toString(),
                          'sender': FirebaseAuth.instance.currentUser?.uid,
                          'jam': _selectedTime?.hour,
                          'menit': _selectedTime?.minute,
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
}
