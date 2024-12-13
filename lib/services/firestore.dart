import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // need CRUD to edit the database
  // get a collectionof notes
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  // CREATE - add a new note
  Future<void> addNote(String note) {
    return notes.add({
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

  // READ - get notes from the database
  Stream<QuerySnapshot> getNotesStream() {
    final notesSteam = notes
        .orderBy('timestamp', descending: true)
        .snapshots(); // this isordering it by when it was inputted
    return notesSteam;
  }

  // UPDATE - update notes given a doc id
  Future<void> updateNote(String docId, String newNote) {
    return notes.doc(docId).update({
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  // DELETE - delete notes given a doc id
  Future<void> deleteNote(String docId) {
    return notes.doc(docId).delete();
  }
}
