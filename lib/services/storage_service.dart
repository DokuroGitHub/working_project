
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {

  UploadTask uploadFileInPost({required File file, required String fileName, required String postId,required String myUserId}) {
    Reference reference = FirebaseStorage.instance.ref().child('post/$postId/$myUserId/$fileName');
    UploadTask uploadTask = reference.putFile(file);
    return uploadTask;
  }
  UploadTask uploadDataInPost({required Uint8List data, required String fileName, required String postId, required String myUserId}) {
    Reference reference = FirebaseStorage.instance.ref().child('post/$postId/$myUserId/$fileName');
    UploadTask uploadTask = reference.putData(data);
    return uploadTask;
  }

  UploadTask uploadFileInConversation({required File file, required String fileName, required String conversationId, required String myUserId}) {
    Reference reference = FirebaseStorage.instance.ref().child('conversation/$conversationId/$myUserId/$fileName');
    UploadTask uploadTask = reference.putFile(file);
    return uploadTask;
  }
  UploadTask uploadDataInConversation({required Uint8List data, required String fileName, required String conversationId, required String myUserId}) {
    Reference reference = FirebaseStorage.instance.ref().child('conversation/$conversationId/$myUserId/$fileName');
    UploadTask uploadTask = reference.putData(data);
    return uploadTask;
  }

  UploadTask uploadFileInFeedBack({required File file, required String fileName, required String myUserId2, required String myUserId}) {
    Reference reference = FirebaseStorage.instance.ref().child('my_user/$myUserId2/feedbacks/$myUserId/$fileName');
    UploadTask uploadTask = reference.putFile(file);
    return uploadTask;
  }
  UploadTask uploadDataInFeedBack({required Uint8List data, required String fileName, required String myUserId2, required String myUserId}) {
    Reference reference = FirebaseStorage.instance.ref().child('my_user/$myUserId2/feedbacks/$myUserId/$fileName');
    UploadTask uploadTask = reference.putData(data);
    return uploadTask;
  }

}
