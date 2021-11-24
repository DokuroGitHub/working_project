import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:working_project/models/my_user.dart';


class DataRepository {
  final CollectionReference collection = FirebaseFirestore.instance.collection('product');

  //TODO: getStreamListMyUse
  Stream<List<MyUser>> getStreamListMyUser() {
    return FirebaseFirestore.instance
        .collection('my_user')
        .snapshots()
        .map(
            (snapshot) => snapshot.docs
            .map((doc) => MyUser.fromMap(doc.data(), doc.id))
            .toList());
  }

  //TODO: getStream
  Stream<QuerySnapshot> getStream() {
    return FirebaseFirestore.instance
        .collection('my_user')
        .snapshots();
  }

}