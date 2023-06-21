import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:reminder_app/Screen/edit.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
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
        final reminders = <Reminder>[];
        for (final document in snapshot.docs) {
          try {
            if (document.data()["sender"] ==
                FirebaseAuth.instance.currentUser!.uid) {
              reminders.add(Reminder(
                document.id,
                document.data()['judul'] as String,
                document.data()['isi'] as String,
                int.parse(document.data()['tanggal'] as String),
                int.parse(document.data()['bulan'] as String),
                int.parse(document.data()['tahun'] as String),
                document.data()['jam'] as int,
                document.data()['menit'] as int,
              ));
            }
          } catch (e) {
            print(e.toString());
          }
        }
        _reminder = reminders;
      });
    });
  }

  @override
  void dispose() {
    _reminderSubscription?.cancel();
    super.dispose();
  }

  Future<void> deletedata(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('Reminderdb')
          .doc(id)
          .delete();
      setState(() {
        _reminder.removeWhere((reminder) => reminder.id == id);
      });
    } catch (e) {
      print('Error deleting data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Reminderdb').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              final rem = _reminder.length > index ? _reminder[index] : null;
              final id = rem?.id ?? '';
              final judul = rem?.judul ?? '';
              final isi = rem?.isi ?? '';
              final tanggal = rem?.tanggal ?? 0;
              final bulan = rem?.bulan ?? 0;
              final tahun = rem?.tahun ?? 0;
              final jam = rem?.jam ?? 0;
              final menit = rem?.menit ?? 0;
              print("ID:" + id.toString());
              print("Tahun" + tahun.toString());

              return Visibility(
                  visible: judul.isNotEmpty,
                  child: Slidable(
                    endActionPane: ActionPane(
                      motion: const BehindMotion(),
                      children: [
                        SlidableAction(
                          icon: Icons.edit,
                          backgroundColor: Colors.blue,
                          onPressed: (context) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Edit(edited: id.toString())));
                          },
                        ),
                        SlidableAction(
                          icon: Icons.delete,
                          backgroundColor: Colors.red,
                          onPressed: (context) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete Reminder'),
                                  content: const Text(
                                    'Are you sure you want to delete this reminder?',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        deletedata(doc.id);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Delete'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),

                    child: Card(
                      shadowColor: Colors.red,
                      elevation: 8,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        width: 860,
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$isi',
                              style: TextStyle(fontSize: 20),
                            ),
                            Row(
                              children: [
                                Text(
                                  judul,
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    '$tanggal - $bulan - $tahun \t $jam:$menit',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    // child: ListTile(
                    //   leading: CircleAvatar(

                    //     child: Text('${index + 1}'),
                    //   ),
                    //   title: Text(judul),
                    //   subtitle: Text("$isi \n  $tanggal-$bulan-$tahun \n $jam:$menit"),
                    //   isThreeLine: true,
                    // ),
                  ));
            },
          );
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

class Reminder {
  final String id;
  final String judul;
  final String isi;
  final int tanggal;
  final int bulan;
  final int tahun;
  final int jam;
  final int menit;

  Reminder(this.id, this.judul, this.isi, this.tanggal, this.bulan, this.tahun,
      this.jam, this.menit);
}
