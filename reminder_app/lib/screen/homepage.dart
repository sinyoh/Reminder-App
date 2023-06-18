import 'dart:convert';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reminder_app/screen/reminder.dart';
import 'package:reminder_app/screen/AddReminder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Reminder> rems = [Reminder("test1", "test1"), Reminder("test2", "test2")];

void _showTimePicker(){
  showTimePicker(context: context,
    initialTime: TimeOfDay.now(),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
        

      ),
      body: 
      


        
  

      ListView.builder(
          itemCount: rems.length,
          itemBuilder: (context, index) {
            fetchRems();
            final rem = rems[index];
            final judul = rem.judul;
            final isi = rem.isi;
            print(judul);
            
          Center(
              child: MaterialButton(
                    onPressed:_showTimePicker,
                        color: Colors.blue,
                    child: const  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: const Text('pick time',
                      style: TextStyle(color: Colors.white, fontSize: 30)),
                          ),
                        ),
                      );

            return ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text(judul),
              subtitle: Text(isi),
            );
            
          })
          
          ,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
      MaterialPageRoute(builder: (context) => Add())),
      ),
      
      
    );
  }

  void fetchRems() async {
    print('fetchUsers Called');
    rems.add(Reminder("test1", "test1"));
    rems.add(Reminder("test2", "test2"));
    print(rems.toString());
  }
}
