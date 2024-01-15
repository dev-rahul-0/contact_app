import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController1 = TextEditingController();
  final TextEditingController _phoneController1 = TextEditingController();

  Future<void> _create() async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Add Contact',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 20,
                ),
                  TextField(
                    controller: _nameController1,
                  decoration: const InputDecoration(labelText: "Name"),keyboardType: TextInputType.text
                ),
                  TextField(
                    controller: _phoneController1,
                  decoration: const InputDecoration(labelText: "Phone"),keyboardType: TextInputType.number,maxLength: 10,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async{
                      final String name = _nameController1.text;
                      final String phone = _phoneController1.text;
                      if (phone !=null) {
                        await contact.add({"name": name, "phone": phone});
                        _nameController1.text="";
                        _phoneController1.text="";
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                    child: const Text('Create'))
              ],
            ),
          );
        });
  }


  Future<void> _update([DocumentSnapshot? documentSnapshot]) async{
    if (documentSnapshot !=null)
      {
        _nameController.text = documentSnapshot['name'];
        _phoneController.text = documentSnapshot['phone'];
      }
    await showModalBottomSheet(context: context,
        builder: (BuildContext context){
      return Padding(padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text('Update Contact',
          textAlign: TextAlign.center,style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 19
            ),),
          const SizedBox(height: 20,),
            TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Name"),keyboardType: TextInputType.text
          ),
            TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: "Phone"),keyboardType: TextInputType.number,maxLength: 10,
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () async{
                final String name = _nameController.text;
                final String phone = _phoneController.text;
                if (phone !=null) {
                  await contact.doc(documentSnapshot!.id).update({"name": name, "phone": phone});
                  _nameController.text="";
                  _phoneController.text="";
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent),
              child: const Text('Update'))
        ],
      ),
      );
        });
  }
  Future<void> _delete(String contactId) async{
    await contact.doc(contactId).delete();
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('You have successfully deleted a contact'),
    ),);
  }

  final CollectionReference contact =
      FirebaseFirestore.instance.collection('contact');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text('Contact List'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: contact.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  return Card(
                    color: Colors.pink[50],
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(
                        documentSnapshot['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 17),
                      ),
                      subtitle: Text(
                        documentSnapshot['phone'],
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                _update(documentSnapshot);
                              },
                              icon: const Icon(Icons.edit),
                              color: Colors.yellow,
                            ),
                            IconButton(
                              onPressed: () {
                                _delete(documentSnapshot.id);
                              },
                              icon: const Icon(Icons.delete),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () {
          _create();
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
