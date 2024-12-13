import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_tester/services/firestore.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController _controller = TextEditingController();

  void openNoteBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: _controller,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    firestoreService.addNote(_controller.text);

                    // clear text fields text
                    _controller.clear();

                    // pops the alert box
                    Navigator.pop(context);
                  },
                  child: const Text('Submit'),
                )
              ],
            ));
  }

  void openDeleteBox(String docId) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: const Text('are you sure you want to delete this item?'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    firestoreService.deleteNote(docId);

                    // pops the alert box
                    Navigator.pop(context);
                  },
                  child: const Text('YES'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // pops the alert box
                    Navigator.pop(context);
                  },
                  child: const Text('NO'),
                )
              ],
            ));
  }

  void openEditBox(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: _controller,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              firestoreService.updateNote(docId, _controller.text);

              // clear text fields text
              _controller.clear();

              // pops the alert box
              Navigator.pop(context);
            },
            child: const Text('YES'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FIREBASE TO-DO LIST',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(
          Icons.add,
        ),
      ),
      body: StreamBuilder(
          stream: firestoreService.getNotesStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;

              return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  // get the individual doc
                  DocumentSnapshot document = notesList[index];
                  String docId = document.id;

                  // get note from each doc
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String noteText = data['note'];

                  // display as a list tile
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            // this displays the text for the item held
                            child: ListTile(
                              title: Text(
                                noteText,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                              // the edit button
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onPressed: () {
                                openEditBox(docId);
                              },
                              child: const Icon(
                                Icons.settings,
                                color: Colors.grey,
                              )),
                          SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                              // the bin button
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onPressed: () {
                                openDeleteBox(docId);
                              },
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              )),
                          SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else {
              return const Text('no notes');
            }
          }),
    );
  }
}
