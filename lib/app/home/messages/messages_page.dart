import 'package:flutter/material.dart';
import '/models/conversation.dart';
import '/models/my_user.dart';
import '/models/participant.dart';
import '/routing/app_router.dart';
import '/services/database_service.dart';

import 'components/body.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({required this.myUser, required this.conversationId});

  final MyUser myUser;
  final String conversationId;

  static Future<void> showMessagesPage(BuildContext context, MyUser myUser, String myUserId2) async {
    Conversation? conversation = await DatabaseService().getConversationByMeAndSomeone(myUser.id!, myUserId2);
    String conversationId;
    if(conversation!=null){
      //TODO: da ton tai conversation giua 2 nguoi
      conversationId = conversation.id!;
    }else {
      //TODO: new
      Conversation x = Conversation(
        createdAt: DateTime.now(),
        createdBy: null,
        description: null,
        messageLast: null,
        members: [myUser.id!, myUserId2],
        photoURL: null,
        title: null,
      );
      //TODO: add
      conversationId = await DatabaseService().addConversation(x.toMap());
      //TODO: new
      Participant y = Participant(
        createdAt:DateTime.now(),
        createdBy: myUser.id!,
        myUserId: myUser.id!,
        nickname:null,
        role: 'MEMBER',
        updatedAt: DateTime.now(),
      );
      //TODO: add
      await DatabaseService().addParticipantToDBWithId(conversationId, myUser.id!, y.toMap());
      //TODO: new
      Participant z = Participant(
        createdAt:DateTime.now(),
        createdBy: myUser.id!,
        myUserId: myUserId2,
        nickname:null,
        role: 'MEMBER',
        updatedAt: DateTime.now(),
      );
      //TODO: add
      await DatabaseService().addParticipantToDBWithId(conversationId, myUserId2, z.toMap());
    }
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.messagesPage,
      arguments: {
        'myUser': myUser,
        'conversationId': conversationId,
      },
    );
  }

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {

  @override
  Widget build(BuildContext context) {
    print('messages_pages');
    return StreamBuilder(
      stream: DatabaseService().getStreamConversationByDocumentId(widget.conversationId),
      builder: (BuildContext context,
          AsyncSnapshot<Conversation?> snapshot) {
        if (snapshot.hasError) {
          print('messages_page error');
          return Container();
        }
        if (snapshot.hasData) {
          return Body(
              myUser: widget.myUser, conversation: snapshot.data!);
        } else {
          return Container();
        }
      },
    );
  }
}
