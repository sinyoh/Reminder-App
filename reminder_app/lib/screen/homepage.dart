import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'reminder.dart';
import 'AddReminder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<QuerySnapshot>? _reminderSubscription;
  List<Reminder> _reminder = [];
  List<Reminder> get reminder => _reminder;

  void _showTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() {
    _reminderSubscription = FirebaseFirestore.instance
        .collection('Reminderdb')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _reminder = [];
        for (final document in snapshot.docs) {
          try {
            // print(document.toString());
            _reminder.add(Reminder(
              document.data()['judul'] as String,
              document.data()['isi'] as String,
              int.parse(document.data()['tanggal'] as String),
              int.parse(document.data()['bulan'] as String),
              int.parse(document.data()['tahun'] as String),
            ));
          } catch (e) {
            // print(e.toString());
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _reminderSubscription?.cancel();
    super.dispose();
  }

  deletedata(id) async {
    await FirebaseFirestore.instance.collection('Reminderdb').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
      ),
      body: ListView.builder(
        itemCount: _reminder.length,
        itemBuilder: (context, index) {
          initialize();
          final rem = _reminder[index];
          final judul = rem.judul;
          final isi = rem.isi;
          final tanggal = rem.tanggal;
          final bulan = rem.bulan;
          final tahun = rem.tahun;
          // print(judul);

          return Slidable(
              endActionPane: ActionPane(
                motion: const BehindMotion(),
                children: [
                  SlidableAction(
                    icon: Icons.edit,
                    backgroundColor: Colors.blue,
                    onPressed: (context) => {},
                  ),
                  SlidableAction(
                    icon: Icons.delete,
                    backgroundColor: Colors.red,
                    onPressed: (context) => {
                      //delete document dari firebase juga
                      deletedata('${index + 1}')
                    },
                  ),
                ],
              ),
              child:
                  //   ListTile(
                  //   leading: CircleAvatar(
                  //     child: Text('${index + 1}'),
                  //   ),
                  //   title: Text(judul),
                  //   subtitle: Text("$isi \n $tanggal - $bulan - $tahun"),
                  //   isThreeLine: true,

                  // ),
                  Card(
                      shadowColor: Colors.red,
                      elevation: 8,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$isi',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                '$tanggal - $bulan - $tahun',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                judul,
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ))));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Add()),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
