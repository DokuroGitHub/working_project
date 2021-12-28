import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:working_project/models/address.dart';
import 'package:working_project/models/attachment.dart';
import 'package:working_project/models/comment.dart';
import 'package:working_project/models/conversation.dart';
import 'package:working_project/models/deleted_message.dart';
import 'package:working_project/models/emote.dart';
import 'package:working_project/models/feedback.dart';
import 'package:working_project/models/message.dart';
import 'package:working_project/models/message_last.dart';
import 'package:working_project/models/my_user.dart';
import 'package:working_project/models/offer.dart';
import 'package:working_project/models/parcel.dart';
import 'package:working_project/models/participant.dart';
import 'package:working_project/models/post.dart';
import 'package:working_project/models/post_reported.dart';
import 'package:working_project/models/reply.dart';
import 'package:working_project/models/shipment.dart';

class DatabaseService {
  //TODO: ------------------- MyUser -----------------------------
  //TODO: addMyUserToDBWithGenId           ----- ko nen xai -----
  Future<void> addMyUserToDBWithGenId(Map<String, dynamic> myUserMap) async {
    FirebaseFirestore.instance.collection("my_user").add(myUserMap).then((ref) {
      print('added ${ref.path}');
    });
  }

  //TODO: addMyUserToDBWithId, new/ko merge   --- nen xai--
  Future<void> addMyUserToDBWithId(
      String myUserId, Map<String, dynamic> myUserMap) async {
    var ref = FirebaseFirestore.instance.collection("my_user").doc(myUserId);
    ref.set(myUserMap).whenComplete(() {
      print('added ${ref.path}');
    });
  }

  //TODO: updateMyUserOnDB, merge
  Future<void> updateMyUserOnDB(
      String myUserId, Map<String, dynamic> myUserMap) async {
    var ref = FirebaseFirestore.instance.collection("my_user").doc(myUserId);
    ref.set(myUserMap, SetOptions(merge: true)).whenComplete(() {
      print('updated ${ref.path}');
    });
  }

  //TODO: deleteMyUserOnDB
  Future<void> deleteMyUserOnDB(String myUserId) async {
    var ref = FirebaseFirestore.instance.collection('my_user').doc(myUserId);
    ref.delete().whenComplete(() {
      print('deleted ${ref.path}');
    });
  }

  //TODO: getStreamMyUserByDocumentId
  Stream<MyUser?> getStreamMyUserByDocumentId(String documentId) {
    return FirebaseFirestore.instance
        .doc('my_user/$documentId')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        print('my_user/$documentId not exists');
        return null;
      }
      return MyUser.fromMap(snapshot.data(), snapshot.id);
    });
  }

  //TODO: getStreamListMyUse
  Stream<List<MyUser>> getStreamListMyUser() {
    return FirebaseFirestore.instance.collection('my_user').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => MyUser.fromMap(doc.data(), doc.id))
            .toList());
  }

  //TODO: getStreamListMyUserByPhoneNumberPart
  Stream<List<MyUser>> getStreamListMyUserBySomePart(
      String field, String searchKey) {
    return FirebaseFirestore.instance
        .collection('my_user')
        .where(field, isGreaterThanOrEqualTo: searchKey)
        .where(field, isLessThan: searchKey + 'z')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MyUser.fromMap(doc.data(), doc.id))
            .toList());
  }

  //TODO: getStreamMyUserByPhoneNumber
  Stream<MyUser?> getStreamMyUserByPhoneNumber(String phoneNumber) {
    return FirebaseFirestore.instance
        .collection("my_user")
        .where("phoneNumber", isEqualTo: phoneNumber)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      return MyUser.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
    });
  }

  //TODO: getMyUserByPhoneNumber
  Future<MyUser?> getMyUserByPhoneNumber(String phoneNumber) {
    return FirebaseFirestore.instance
        .collection("my_user")
        .where("phoneNumber", isEqualTo: phoneNumber)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      return MyUser.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
    });
  }

  //TODO: getMyUserByDocumentId
  Future<MyUser?> getMyUserByDocumentId(String documentId) {
    return FirebaseFirestore.instance
        .collection('my_user')
        .doc(documentId)
        .get()
        .then((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return MyUser.fromMap(snapshot.data(), snapshot.id);
    });
  }

  //TODO: ------------------- FeedBack -----------------------------
  //TODO: addFeedbacksToMyUser
  Future<void> addFeedbackToMyUser(
      String myUserId, Map<String, dynamic> feedBackMap) async {
    FirebaseFirestore.instance
        .collection("my_user")
        .doc(myUserId)
        .collection('feedbacks')
        .add(feedBackMap)
        .then((ref) {
      print('added ${ref.path}');
    });
  }

  //TODO: getStreamListFeedback
  Stream<List<FeedBack>> getStreamListFeedback(String myUserId,
      {FeedBackQuery? query}) {
    var ref =
        FirebaseFirestore.instance.collection('my_user/$myUserId/feedbacks');
    Query<Map<String, dynamic>> newQuery;
    switch (query) {
      case FeedBackQuery.createdAtAsc:
      case FeedBackQuery.createdAtDesc:
        newQuery = ref.orderBy('createdAt',
            descending: query == FeedBackQuery.createdAtDesc);
        break;
      case FeedBackQuery.ratingAsc:
      case FeedBackQuery.ratingDesc:
        newQuery = ref.orderBy('rating',
            descending: query == FeedBackQuery.ratingDesc);
        break;
      default:
        newQuery = ref;
        break;
    }
    return newQuery.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => FeedBack.fromMap(doc.data(), doc.id))
        .toList());
  }

  //TODO: getMyUserByDocumentId
  Future<FeedBack?> getFeedBackByDocumentId({required String myUserId, required String feedBackId}) {
    return FirebaseFirestore.instance
        .doc('my_user/$myUserId/feedbacks/$feedBackId')
        .get()
        .then((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return FeedBack.fromMap(snapshot.data(), snapshot.id);
    });
  }

  //TODO: updateFeedBackOnDB, merge
  Future<void> updateFeedBackOnDB({required String myUserId, required String feedBackId, required Map<String, dynamic> map}) async {
    var ref = FirebaseFirestore.instance.doc('my_user/$myUserId/feedbacks/$feedBackId');
    ref.set(map, SetOptions(merge: true)).whenComplete(() {
      print('updated ${ref.path}');
    });
  }

  //TODO: ------------------- Post -----------------------------
  //TODO: addPost
  Future<String?> addPost(Map<String, dynamic> postMap) async {
    return FirebaseFirestore.instance.collection('post').add(postMap).then(
        (ref) {
      print('added ${ref.path}');
      return ref.id;
    }, onError: (dynamic error) {
      print('added post failed, error: $error');
      return null;
    });
  }

  //TODO: updatePost, merge
  Future<void> updatePost(String postId, Map<String, dynamic> postMap) async {
    var ref = FirebaseFirestore.instance.collection('post').doc(postId);
    ref.set(postMap, SetOptions(merge: true)).whenComplete(() {
      print('updated ${ref.path}');
    });
  }

  //TODO: deletePost
  Future<void> deletePost(String postId) async {
    var ref = FirebaseFirestore.instance.collection('post').doc(postId);
    ref.delete().whenComplete(() {
      print('deleted ${ref.path}');
    });
  }

  //TODO: getStreamListPost
  Stream<List<Post>> getStreamListPost() {
    return FirebaseFirestore.instance.collection('post').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Post.fromMap(doc.data(), doc.id))
            .toList());
  }

  //TODO: getStreamListMyUserByPhoneNumberPart
  Stream<List<Post>> getStreamListPostBySomePart({String? field, String? searchKey, PostQuery? query, int limit=0}) {
    Query<Map<String, dynamic>> ref = FirebaseFirestore.instance
        .collection('post');
    if(field!=null && searchKey!=null) {
      ref = ref
          //.where(field, isGreaterThanOrEqualTo: searchKey)
          //.where(field, isLessThan: searchKey + 'z')
          //.orderBy(field, descending: true)
      ;
    }
    Query<Map<String, dynamic>> newQuery;
    switch (query) {
      case PostQuery.createdAtAsc:
        newQuery =
            ref.orderBy('createdAt', descending: false).limitToLast(limit);
        break;
      case PostQuery.createdAtDesc:
        newQuery = ref.orderBy('createdAt', descending: true).limit(limit);
        break;
      default:
        if(limit!=0){
          newQuery = ref.limit(limit);
        }else{
          newQuery = ref;
        }
        break;
    }
    return newQuery.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Post.fromMap(doc.data(), doc.id))
        .toList());
  }

  //TODO: getStreamPostByDocumentId
  Stream<Post?> getStreamPostByDocumentId(String documentId) {
    return FirebaseFirestore.instance
        .doc('post/$documentId')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        print('post/$documentId not exists');
        return null;
      }
      return Post.fromMap(snapshot.data(), snapshot.id);
    });
  }

  //TODO: getPostByDocumentId
  Future<Post?> getPostByDocumentId(String documentId) {
    return FirebaseFirestore.instance
        .collection('post')
        .doc(documentId)
        .get()
        .then((snapshot) {
      if (!snapshot.exists) {
        print('post/$documentId not exists');
        return null;
      }
      return Post.fromMap(snapshot.data(), snapshot.id);
    });
  }

  //TODO: ------------------- Emote -----------------------------
  //TODO: ------------------- Emote in Post -----------------------------
  //TODO: addEmoteToPost, new/ko merge   --- nen xai--
  Future<void> addEmoteToPost(
      {required String postId,
      required String myUserId,
      required Map<String, dynamic> emoteMap}) async {
    var ref = FirebaseFirestore.instance
        .collection('post/$postId/emotes')
        .doc(myUserId);
    ref.set(emoteMap).whenComplete(() {
      print('added ${ref.path}');
    });
  }

  //TODO: getEmoteInPost
  Future<Emote?> getEmoteInPost(
      {required String postId, required String myUserId}) {
    return FirebaseFirestore.instance
        .doc('post/$postId/emotes/$myUserId')
        .get()
        .then((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return Emote.fromMap(snapshot.data(), snapshot.id);
    });
  }

  //TODO: deleteEmoteInPost
  Future<void> deleteEmoteInPost(
      {required String postId, required String emoteId}) async {
    var ref = FirebaseFirestore.instance.doc('post/$postId/emotes/$emoteId');
    ref.delete().whenComplete(() {
      print('deleted ${ref.path}');
    });
  }

  //TODO: getStreamEmoteInPost
  Stream<Emote?> getStreamEmoteInPost(
      {required String postId, required String myUserId}) {
    return FirebaseFirestore.instance
        .doc('post/$postId/emotes/$myUserId')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return Emote.fromMap(snapshot.data(), snapshot.id);
    });
  }

  //TODO: getStreamListEmoteInPost
  Stream<List<Emote>> getStreamListEmoteInPost(String postId) {
    return FirebaseFirestore.instance
        .collection('post/$postId/emotes')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Emote.fromMap(doc.data(), doc.id))
            .toList());
  }

  //TODO: ------------------- Emote in Comment -----------------------------
  //TODO: addEmoteToComment, new/ko merge   --- nen xai--
  Future<void> addEmoteToComment(
      {required String myUserId,
      required String commentPath,
      required Map<String, dynamic> emoteMap}) async {
    var ref = FirebaseFirestore.instance
        .doc(commentPath)
        .collection('emotes')
        .doc(myUserId);
    ref.set(emoteMap).whenComplete(() {
      print('added ${ref.path}');
    });
  }

  //TODO: getEmoteInComment
  Future<Emote?> getEmoteInComment(
      {required String commentPath, required String myUserId}) {
    return FirebaseFirestore.instance
        .doc('$commentPath/emotes/$myUserId')
        .get()
        .then((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return Emote.fromMap(snapshot.data(), snapshot.id);
    });
  }

  //TODO: deleteEmoteInComment
  Future<void> deleteEmoteInComment(
      {required String commentPath, required String emoteId}) async {
    var ref = FirebaseFirestore.instance.doc('$commentPath/emotes/$emoteId');
    ref.delete().whenComplete(() {
      print('deleted ${ref.path}');
    });
  }

  //TODO: getStreamEmoteInComment
  Stream<Emote?> getStreamEmoteInComment(
      {required String commentDocumentPath, required String myUserId}) {
    return FirebaseFirestore.instance
        .doc('$commentDocumentPath/emotes/$myUserId')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return Emote.fromMap(snapshot.data(), snapshot.id);
    });
  }

  //TODO: getStreamListEmoteInComment
  Stream<List<Emote>> getStreamListEmoteInComment(
      {required String commentDocumentPath}) {
    return FirebaseFirestore.instance
        .collection('$commentDocumentPath/emotes')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Emote.fromMap(doc.data(), doc.id))
            .toList());
  }

  //TODO: ------------------- Emote in Message -----------------------------
  //TODO: addEmoteWithId, new/ko merge   --- nen xai--
  Future<void> addEmoteToMessage(
      {required String messageId,
      required String myUserId,
      required Map<String, dynamic> emoteMap}) async {
    var ref = FirebaseFirestore.instance
        .doc(messageId)
        .collection('emotes')
        .doc(myUserId);
    ref.set(emoteMap).whenComplete(() {
      print('added ${ref.path}');
    });
  }

  //TODO: updateEmote, merge
  Future<void> updateEmote(String myUserId, String documentPath,
      Map<String, dynamic> emoteMap) async {
    var ref = FirebaseFirestore.instance
        .doc(documentPath)
        .collection('emotes')
        .doc(myUserId);
    ref.set(emoteMap, SetOptions(merge: true)).whenComplete(() {
      print('updated ${ref.path}');
    });
  }

  //TODO: ------------------- Comment -----------------------------
  //TODO: addCommentToPost
  Future<void> addCommentToPost(
      String postId, Map<String, dynamic> commentMap) async {
    FirebaseFirestore.instance
        .collection('post/$postId/comments')
        .add(commentMap)
        .then((ref) {
      print('added ${ref.path}');
    });
  }

  //TODO: addCommentToComment
  Future<void> addCommentToComment(
      {required String replyForCommentDocumentPath,
      required Map<String, dynamic> commentMap}) async {
    FirebaseFirestore.instance
        .collection('$replyForCommentDocumentPath/replies')
        .add(commentMap)
        .then((ref) {
      print('added ${ref.path}');
    });
  }

  //TODO: deleteComment
  Future<void> deleteComment(String documentPath) async {
    var ref = FirebaseFirestore.instance.doc(documentPath);
    ref.delete().whenComplete(() {
      print('deleted ${ref.path}');
    });
  }

  //TODO: getStreamListCommentInPost
  Stream<List<Comment>> getStreamListCommentInPost(String postId,
      {CommentQuery? query, int limit=0}) {
    var ref = FirebaseFirestore.instance.collection('post/$postId/comments');
    Query<Map<String, dynamic>> newQuery;
    switch (query) {
      case CommentQuery.createdAtAsc:
        newQuery =
            ref.orderBy('createdAt', descending: false).limitToLast(limit);
        break;
      case CommentQuery.createdAtDesc:
        newQuery = ref.orderBy('createdAt', descending: true).limit(limit);
        break;
      default:
        if(limit!=0){
          newQuery = ref.limit(limit);
        }else{
          newQuery = ref;
        }
        break;
    }
    return newQuery.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Comment.fromMap(doc.data(), doc.id, doc.reference.path))
        .toList());
  }

  //TODO: getStreamListCommentInComment // lấy limit số replies mới nhất
  Stream<List<Comment>> getStreamListCommentInComment(
      String replyForCommentDocumentPath,
      {int limit = 0}) {
    var ref = FirebaseFirestore.instance
        .collection('$replyForCommentDocumentPath/replies')
        .orderBy('createdAt', descending: false);
    Query<Map<String, dynamic>> newQuery;
    if(limit!=0){
      newQuery = ref.limitToLast(limit);
    }else{
      newQuery = ref;
    }
    return newQuery.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Comment.fromMap(doc.data(), doc.id, doc.reference.path))
        .toList());
  }

  //TODO: ------------------- PostReported -----------------------------
  //TODO: addPostReported
  Future<void> addPostReported(Map<String, dynamic> postReportedMap) async {
    FirebaseFirestore.instance
        .collection('post_reported')
        .add(postReportedMap)
        .then((ref) {
      print('added ${ref.path}');
    });
  }

  //TODO: updatePostReported, merge
  Future<void> updatePostReported(String documentId, Map<String, dynamic> map) async {
    var ref = FirebaseFirestore.instance.collection('post_reported').doc(documentId);
    ref.set(map, SetOptions(merge: true)).whenComplete(() {
      print('updated ${ref.path}');
    });
  }

  //TODO: getStreamListPostReportedBySomePart
  Stream<List<PostReported>> getStreamListPostReportedBySomePart(
      String field, String searchKey) {
    return FirebaseFirestore.instance
        .collection('post_reported')
        .where(field, isGreaterThanOrEqualTo: searchKey)
        .where(field, isLessThan: searchKey + 'z')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PostReported.fromMap(doc.data(), doc.id))
        .toList());
  }

  //TODO: getStreamPostReportedByDocumentId
  Stream<PostReported?> getStreamPostReportedByDocumentId(String documentId) {
    return FirebaseFirestore.instance
        .doc('post_reported/$documentId')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        print('post_reported/$documentId not exists');
        return null;
      }
      return PostReported.fromMap(snapshot.data(), snapshot.id);
    });
  }

  //TODO: ------------------- Shipment -----------------------------
  //TODO: addShipment
  Future<String?> addShipment(Map<String, dynamic> shipmentMap) async {
    return FirebaseFirestore.instance
        .collection('shipment')
        .add(shipmentMap)
        .then((ref) {
      print('added ${ref.path}');
      return ref.id;
    }, onError: (dynamic error) {
      print('added failed, error: $error}');
      return null;
    });
  }

  //TODO: getStreamShipmentByDocumentId
  Stream<Shipment?> getStreamShipmentByDocumentId(String documentId) {
    return FirebaseFirestore.instance
        .doc('shipment/$documentId')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        print('shipment/$documentId not exists');
        return null;
      }
      return Shipment.fromMap(snapshot.data(), snapshot.id);
    });
  }

  //TODO: updateShipment, merge
  Future<void> updateShipment(
      String shipmentId, Map<String, dynamic> shipmentMap) async {
    var ref = FirebaseFirestore.instance.collection('shipment').doc(shipmentId);
    ref.set(shipmentMap, SetOptions(merge: true)).whenComplete(() {
      print('updated ${ref.path}');
    });
  }

  //TODO: getStreamListShipment
  Stream<List<Shipment>> getStreamListShipment() {
    return FirebaseFirestore.instance.collection('shipment').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Shipment.fromMap(doc.data(), doc.id))
            .toList());
  }

  //TODO: getShipmentByDocumentId
  Future<Shipment?> getShipmentByDocumentId(String documentId) {
    return FirebaseFirestore.instance
        .collection('shipment')
        .doc(documentId)
        .get()
        .then((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return Shipment.fromMap(snapshot.data(), snapshot.id);
    });
  }

  //TODO: ------------------- Offer -----------------------------
  //TODO: addOfferToShipmentWithId, set ko merge   --- nen xai--
  Future<void> addOfferToShipmentWithId(
      {required String shipmentId,
      required String myUserId,
      required Map<String, dynamic> offerMap}) async {
    var ref =
        FirebaseFirestore.instance.doc('shipment/$shipmentId/offers/$myUserId');
    ref.set(offerMap).whenComplete(() {
      print('added ${ref.path}');
    });
  }

  //TODO: getStreamMyUserByDocumentId
  Stream<Offer?> getStreamOfferByDocumentId(
      String shipmentId, String documentId) {
    return FirebaseFirestore.instance
        .doc('shipment/$shipmentId/offers/$documentId')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        print('shipment/$shipmentId/offers/$documentId not exists');
        return null;
      }
      return Offer.fromMap(snapshot.data(), snapshot.id);
    });
  }

  //TODO: getStreamListOffer
  Stream<List<Offer>> getStreamListOffer(String shipmentId) {
    return FirebaseFirestore.instance
        .collection('shipment/$shipmentId/offers')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Offer.fromMap(doc.data(), doc.id))
            .toList());
  }

  //TODO: getOffer
  Future<Offer?> getOffer(
      {required String shipmentId, required String myUserId}) {
    return FirebaseFirestore.instance
        .doc('shipment/$shipmentId/offers/$myUserId')
        .get()
        .then((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return Offer.fromMap(snapshot.data(), snapshot.id);
    });
  }

  //TODO: deleteOffer
  Future<void> deleteOffer(
      {required String shipmentId, required String myUserId}) async {
    var ref =
        FirebaseFirestore.instance.doc('shipment/$shipmentId/offers/$myUserId');
    ref.delete().whenComplete(() {
      print('deleted ${ref.path}');
    });
  }

  //TODO: ------------------- Conversation -----------------------------
  //TODO: addConversation
  Future<String> addConversation(Map<String, dynamic> conversationMap) async {
    return FirebaseFirestore.instance
        .collection('conversation')
        .add(conversationMap)
        .then((ref) {
      print('added ${ref.path}');
      return ref.id;
    });
  }

  //TODO: updateConversation
  Future<void> updateConversation(
      String conversationId, Map<String, dynamic> conversationMap) async {
    var ref = FirebaseFirestore.instance
        .collection("conversation")
        .doc(conversationId);
    ref.set(conversationMap, SetOptions(merge: true)).whenComplete(() {
      print('updated ${ref.path}');
    });
  }

  //TODO: getListMembersOfConversation
  Future<List<String>> getListMembersOfConversation(String conversationId) {
    return FirebaseFirestore.instance
        .collection('conversation')
        .doc(conversationId)
        .get()
        .then((snapshot) {
      if (!snapshot.exists) {
        return [];
      }
      return Conversation.fromMap(snapshot.data(), snapshot.id).members;
    });
  }

  //TODO: getStreamListConversation
  Stream<List<Conversation>> getStreamListConversation() {
    return FirebaseFirestore.instance
        .collection('conversation')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Conversation.fromMap(doc.data(), doc.id))
            .toList());
  }

  //TODO: getMyUserByPhoneNumber
  Future<Conversation?> getConversationByMeAndSomeone(
      String myUserId1, String myUserId2) {
    return FirebaseFirestore.instance
        .collection('conversation')
        .where('members', arrayContains: myUserId1)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      var x = snapshot.docs.where((element) {
        List<String> members = [];
        var json = element['members'] as List<dynamic>?;
        print('json: $json');
        if (json == null) {
          members = [];
        }
        for (var value in json!) {
          if (value != null) {
            members.add(value as String);
          }
        }
        if (members.length == 2 && members.contains(myUserId2)) {
          return true;
        }
        return false;
      });
      if (x.isNotEmpty) {
        return Conversation.fromMap(x.first.data(), x.first.id);
      } else {
        return null;
      }
    });
  }

  //TODO: chuan bi xoa
  Stream<Conversation?> getStreamConversationByMeAndSomeone(
      String myUserId1, String myUserId2) {
    return FirebaseFirestore.instance
        .collection('conversation')
        .where('members', arrayContains: myUserId1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      var x = snapshot.docs.where((element) {
        List<String> members = [];
        var json = element.data()['members'] as List<dynamic>?;
        if (json == null) {
          members = [];
        }
        for (var value in json!) {
          if (value != null) {
            members.add(value as String);
          }
        }
        if (members.length == 2 && members.contains(myUserId2)) {
          return true;
        }
        return false;
      }).first;
      return Conversation.fromMap(x.data(), x.id);
    });
  }

  //TODO: getStreamMyUserByDocumentId
  Stream<Conversation?> getStreamConversationByDocumentId(String documentId) {
    return FirebaseFirestore.instance
        .doc('conversation/$documentId')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        print('conversation/$documentId not exists');
        return null;
      }
      return Conversation.fromMap(snapshot.data(), snapshot.id);
    });
  }

  //TODO: ------------------- Message -----------------------------
  //TODO: addMessage
  Future<void> addMessage(
      String conversationId, Map<String, dynamic> messageMap) async {
    FirebaseFirestore.instance
        .collection('conversation/$conversationId/messages')
        .add(messageMap)
        .then((ref) {
      print('added ${ref.path}');
    });
  }

  //TODO: getStreamListMessage
  Stream<List<Message>> getStreamListMessage(String conversationId) {
    return FirebaseFirestore.instance
        .collection('conversation/$conversationId/messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromMap(doc.data(), doc.id))
            .toList());
  }

  //TODO: ------------------- DeletedMessage -----------------------------
  //TODO: addDeletedMessage
  Future<void> addDeletedMessage(
      String conversationId, Map<String, dynamic> deletedMessageMap) async {
    FirebaseFirestore.instance
        .collection('conversation/$conversationId/deleted_messages')
        .add(deletedMessageMap)
        .then((ref) {
      print('added ${ref.path}');
    });
  }

  //TODO: getDeletedMessage
  Future<DeletedMessage?> getDeletedMessage(
      String conversationId, String messageId, String myUserId) {
    return FirebaseFirestore.instance
        .collection('conversation/$conversationId/deleted_messages')
        .where('messageId', isEqualTo: messageId)
        .where('createdBy', isEqualTo: myUserId)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      return DeletedMessage.fromMap(
          snapshot.docs.first.data(), snapshot.docs.first.id);
    });
  }

  //TODO: ------------------- Participant -----------------------------
  //TODO: addParticipantToDBWithId, new/ko merge   --- nen xai--
  Future<void> addParticipantToDBWithId(String conversationId,
      String participantId, Map<String, dynamic> participantMap) async {
    var ref = FirebaseFirestore.instance
        .collection('conversation/$conversationId/participants')
        .doc(participantId);
    ref.set(participantMap).whenComplete(() {
      print('added ${ref.path}');
    });
  }

  //TODO: getParticipantByDocumentId
  Future<Participant?> getParticipantByDocumentId(
      String conversationId, String documentId) {
    return FirebaseFirestore.instance
        .collection('conversation/$conversationId/participants')
        .doc(documentId)
        .get()
        .then((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return Participant.fromMap(snapshot.data(), snapshot.id);
    });
  }

  //TODO: getStreamParticipantByDocumentId
  Stream<Participant?> getStreamParticipantByDocumentId(
      String conversationId, String documentId) {
    return FirebaseFirestore.instance
        .doc('conversation/$conversationId/participants/$documentId')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        print(
            'conversation/$conversationId/participants/$documentId not exists');
        return null;
      }
      return Participant.fromMap(snapshot.data(), snapshot.id);
    });
  }

  //TODO: getStreamListParticipantByUpdatedAt
  Stream<List<Participant>> getStreamListParticipantByUpdatedAt(
      String conversationId, DateTime updatedAt) {
    return FirebaseFirestore.instance
        .collection('conversation/$conversationId/participants')
        .where('updatedAt', isGreaterThanOrEqualTo: updatedAt)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Participant.fromMap(doc.data(), doc.id))
            .toList());
  }

  //TODO:-------------------test-----------------------------------------
  //TODO: done
  Future<void> tesAddFeedbackToMyUser() async {
    print('*****');
    String myUserId = 'peXkGVl6GvcllR7D9g5oPOm0zV62';
    //TODO: add new
    var feedback = FeedBack(
        attachments: [Attachment(fileURL: 'fileURL', type: 'IMAGE')],
        createdAt: DateTime.now(),
        createdBy: myUserId,
        rating: 5,
        text: 'thao tac nhanh le, 10 diem',
        reply: Reply(createdAt: DateTime.now(), text: 'thanks'));
    MyUser? myUser = await getMyUserByDocumentId(myUserId);
    if (myUser != null) {
      //TODO: add vao collect
      addFeedbackToMyUser(myUserId, feedback.toMap());
    } else {
      print('MyUser docId: $myUserId, not found');
    }
  }

  //TODO: done
  Future<void> addOrUpdateMyUser() async {
    //TODO: kiem tra ton tai chua r add/update
    print('*****');
    //TODO: add new
    var xx = MyUser(
        birthDate: DateTime.utc(2000, 8, 5),
        createdAt: DateTime.now(),
        isActive: false,
        isBlocked: false,
        lastSignInAt: DateTime.now(),
        role: 'user');
    String phoneNumber = '0123123121';

    MyUser? x2 = await getMyUserByDocumentId('peXkGVl6GvcllR7D9g5oPOm0zV62');
    print('dung getMyUserByDocumentId:');
    print(x2.toString());

    MyUser? x = await getMyUserByPhoneNumber(phoneNumber);
    print('dung getMyUserByPhoneNumber:');
    print(x.toString());
    if (x == null) {
      addMyUserToDBWithGenId(xx.toMap());
    } else {
      print('user da ton tai, update selfIntroduction');
      var xxx = x;
      xxx.selfIntroduction = 'test update selfIntroduction';
      updateMyUserOnDB(xxx.id!, xxx.toMap());
    }
  }

  //TODO: done
  Future<void> testAddPost() async {
    print('*****');
    //TODO: new
    var x = Post(
        attachments: [],
        text: 'new post desu',
        createdAt: DateTime.now(),
        createdBy: 'tamthoidetrong');

    addPost(x.toMap());
  }

  //TODO: done
  Future<void> testAddEmoteToPost() async {
    print('*****');
    String myUserId = 'peXkGVl6GvcllR7D9g5oPOm0zV62';
    String postId = 'LMJdoO9wmfql27SYkeNZ';
    //TODO: new
    var x = Emote(createdBy: myUserId, emoteCode: 'HEART');

    addEmoteToPost(postId: postId, myUserId: myUserId, emoteMap: x.toMap());
  }

  //TODO: done
  Future<void> testAddEmoteToComment() async {
    print('*****');
    String myUserId = 'peXkGVl6GvcllR7D9g5oPOm0zV62';
    String commentPath =
        'post/LMJdoO9wmfql27SYkeNZ/comments/HTdUtjPgxBwgeRAUxfzk';
    //TODO: new
    var x = Emote(createdBy: myUserId, emoteCode: 'HEART');

    addEmoteToComment(
        commentPath: commentPath, myUserId: myUserId, emoteMap: x.toMap());
  }

  //TODO: done
  Future<void> testAddComment() async {
    print('*****');
    String myUserId = 'peXkGVl6GvcllR7D9g5oPOm0zV62';
    String postId = 'LMJdoO9wmfql27SYkeNZ';
    //TODO: new
    var x = Comment(
        attachment: null,
        createdAt: DateTime.now(),
        createdBy: myUserId,
        deletedAt: null,
        editedAt: null,
        text: 'new comment desu yoooo');

    addCommentToPost(postId, x.toMap());
  }

  //TODO: done
  Future<void> testAddPostReported() async {
    print('*****');
    String myUserId = 'peXkGVl6GvcllR7D9g5oPOm0zV62';
    String postId = 'LMJdoO9wmfql27SYkeNZ';
    //TODO: new
    var x = PostReported(
      createdAt: DateTime.now(),
      createdBy: myUserId,
      postId: postId,
      status: 'CHUAXULY',
      text: 'bài viết không phù hợp',
      type: 'SPAM',
    );

    addPostReported(x.toMap());
  }

  //TODO: done
  Future<void> testAddShipment() async {
    print('*****');
    String myUserId = 'peXkGVl6GvcllR7D9g5oPOm0zV62';
    //TODO: new
    var x = Shipment(
      addressFrom: const Address(
          details: '15, kp Phú Thứ, tt Phú Thứ, Tây Hòa Phú Yên',
          street: 'Phú Thứ',
          district: 'Tây Hòa',
          city: 'Phú Yên',
          location: GeoPoint(1.24, -43.53)),
      addressTo: const Address(
          details: '12, kp Phú Thứ, tt Phú Thứ, Tây Hòa Phú Yên',
          street: 'Phú Thứ',
          district: 'Tây Hòa',
          city: 'Phú Yên',
          location: GeoPoint(1.54, -33.53)),
      attachments: [],
      cod: 50000,
      createdAt: DateTime.now(),
      createdBy: myUserId,
      notes: 'hàng dễ vỡ xin nhẹ tay',
      parcel: const Parcel(
          code: 'HANG123A',
          description: '1x máy rung, 1x ding dong toy',
          height: 20,
          length: 20,
          nameFrom: 'Nguyễn Văn A',
          nameTo: 'Trần Như B',
          phoneFrom: '0123123123',
          phoneTo: '0123123124',
          weight: 500,
          width: 20),
      postId: null,
      service: 'NHANH',
      shipperId: null,
      shippersEnrolled: [],
      status: 'DANGTIMSHIPPER',
      type: 'SHIPHANG',
    );

    addShipment(x.toMap());
  }

  //TODO: done
  Future<void> testAddConversation() async {
    print('*****');
    String myUserId = 'peXkGVl6GvcllR7D9g5oPOm0zV62';
    String myUserId2 = 'tamthoidetrong';
    //TODO: new
    var x = Conversation(
      createdAt: DateTime.now(),
      createdBy: null,
      description: null,
      messageLast:
          MessageLast(text: 'test last message', updatedAt: DateTime.now()),
      members: [myUserId, myUserId2],
      title: null,
    );

    addConversation(x.toMap());
  }

  //TODO: done
  Future<void> testAddMessage() async {
    print('*****');
    String myUserId = 'peXkGVl6GvcllR7D9g5oPOm0zV62';
    String conversationId = '1HBfVQwh2U93b0WO0pgU';
    //String replyToMessageId = '2j1KbAB1rLBwerGU4gfJ';

    //TODO: new
    var x = Message(
        attachments: [],
        createdAt: DateTime.now(),
        createdBy: myUserId,
        replyToMessageId: null,
        text: 'chào nèeeeeeeee');

    //TODO: add message
    addMessage(conversationId, x.toMap());
    var messageLast = MessageLast(text: x.text!, updatedAt: x.createdAt);
    var xx = {
      'messageLast': messageLast.toMap(),
    };
    //TODO: update messageLast
    updateConversation(conversationId, xx);
  }

  //TODO: done
  Future<void> testAddParticipant() async {
    print('*****');
    //TODO: myUserId add myUserId2 vào conversation
    String myUserId = 'peXkGVl6GvcllR7D9g5oPOm0zV62';
    String myUserId2 = 'tamthoidetrong2';
    String conversationId = '1HBfVQwh2U93b0WO0pgU';
    var xxx = await getListMembersOfConversation(conversationId);
    if (xxx.contains(myUserId2)) {
      //TODO: group members có myUserId2 này rồi
      print('conversation/$conversationId members đã có $myUserId2 này rồi');
      return;
    }

    //TODO: new
    var x = Participant(
      createdAt: DateTime.now(),
      createdBy: myUserId,
      myUserId: myUserId2,
      nickname: null,
      role: 'MEMBER',
      updatedAt: DateTime.now(),
    );

    //TODO: addParticipant
    addParticipantToDBWithId(conversationId, x.myUserId, x.toMap());
    var messageLast = MessageLast(
        text: 'myUserId đã thêm myUserId2 vào nhóm', updatedAt: x.createdAt);

    xxx.add(myUserId2);
    var xx = {
      'messageLast': messageLast.toMap(),
      'members': xxx,
    };
    //TODO: update members, messageLast
    updateConversation(conversationId, xx);
  }

  //TODO: done
  Future<void> testGetParticipant() async {
    print('*****');
    //TODO: get participant by conversationId and myUserId
    String myUserId = 'peXkGVl6GvcllR7D9g5oPOm0zV62';
    String conversationId = '1HBfVQwh2U93b0WO0pgU';
    Participant? participant =
        await getParticipantByDocumentId(conversationId, myUserId);
    if (participant == null) {
      print(
          'participant with conversationId=$conversationId, myUserId=$myUserId not found');
    } else {
      print(participant);
    }
  }

  //TODO: done
  Future<void> testGetParticipant2() async {
    print('*****');
    //TODO: get participant by conversationId and participantId
    String conversationId = '1HBfVQwh2U93b0WO0pgU';
    String participantId = 'nS8jSY5fZfmTuurFy0Ha';
    Participant? participant =
        await getParticipantByDocumentId(conversationId, participantId);
    if (participant == null) {
      print(
          'participant with conversationId=$conversationId, participantId=$participantId not found');
    } else {
      print(participant);
    }
  }

  //TODO: done
  Future<void> testAddDeletedMessage() async {
    print('*****');
    String myUserId = 'peXkGVl6GvcllR7D9g5oPOm0zV62';
    String conversationId = '1HBfVQwh2U93b0WO0pgU';
    String messageId = 'mcUo9M2u1spYiotlQ8m4';

    //TODO: new
    var x = DeletedMessage(
      createdAt: DateTime.now(),
      createdBy: myUserId,
      messageId: messageId,
    );

    //TODO: add
    addDeletedMessage(conversationId, x.toMap());
  }

  //TODO: done
  Future<void> testGetDeletedMessage() async {
    print('*****');
    //TODO: get participant by conversationId and participantId
    String conversationId = '1HBfVQwh2U93b0WO0pgU';
    String messageId = 'mcUo9M2u1spYiotlQ8m4';
    String myUserId = 'peXkGVl6GvcllR7D9g5oPOm0zV62';
    DeletedMessage? deletedMessage =
        await getDeletedMessage(conversationId, messageId, myUserId);
    if (deletedMessage == null) {
      print(
          'deletedMessage with conversationId=$conversationId, messageId=$messageId, myUserId=$myUserId not found');
    } else {
      print(deletedMessage);
    }
  }

  //TODO: done
  Future<void> testStreamListMyUserByPhoneNumberPart() async {
    print('****');
    getStreamListMyUserBySomePart('phoneNumber', '0123').listen((event) {
      if (event.isEmpty) {
        print('empty');
        return;
      }
      print('not empty');
      print(event.toString());
    });
  }

  Future<void> runTest() async {
    //AuthService().signInWithGoogle();
  }
}
