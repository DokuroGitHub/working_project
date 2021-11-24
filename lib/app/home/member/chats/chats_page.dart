import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/app/home/member/posts/components/my_user_avatar.dart';
import '/common_widgets/helper.dart';
import '/models/conversation.dart';
import '/models/my_user.dart';
import '/models/participant.dart';
import '/routing/app_router.dart';
import '/services/database_service.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({required this.myUser});

  final MyUser myUser;

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  //Let's add the color code for our project
  Color bgBlack = const Color(0xFF1a1a1a);
  Color mainBlack = const Color(0xFF262626);
  Color fbBlue = const Color(0xFF2D88FF);
  Color mainGrey = const Color(0xFF505050);

  final String defaultPhotoURL =
      'https://scontent.fdad1-2.fna.fbcdn.net/v/t1.30497-1/p100x100/143086968_2856368904622192_1959732218791162458_n.png?_nc_cat=1&ccb=1-5&_nc_sid=7206a8&_nc_ohc=xxuCSnWhe_UAX9Uml8x&tn=ydMBgSqsmF5ZJOjR&_nc_ht=scontent.fdad1-2.fna&oh=00f1644507795114064f220c2267cfb1&oe=61AD6051';

  Widget _circleAvatar({String? photoURL}) {
    return CircleAvatar(
      backgroundImage: NetworkImage(photoURL ?? defaultPhotoURL),
      radius: 25.0,
    );
  }

  Widget _avatarInGroup(String myUserId) {
    return StreamBuilder(
        stream: DatabaseService().getStreamMyUserByDocumentId(myUserId),
        builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
          if (snapshot.hasError) {
            print('MyUserAvatar, myUser hasError');
            return _circleAvatar();
          }
          if (snapshot.hasData) {
            //TODO: avatar
            return _circleAvatar(photoURL: snapshot.data?.photoURL);
          } else {
            print('MyUserAvatar, myUser hasData false');
            return _circleAvatar();
          }
        });
  }

  Widget _circleAvatarForGroup(String myUser1, String myUser2) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      radius: 25.0,
      child: Stack(children: [
        Positioned(
          right: 3,
          top: 3,
          child: SizedBox(
            height: 25,
            width: 25,
            child: _avatarInGroup(myUser1),
          ),
        ),
        Positioned(
          left: 3,
          bottom: 3,
          child: SizedBox(
            height: 25,
            width: 25,
            child: _avatarInGroup(myUser2),
          ),
        ),
      ]),
    );
  }

  Widget _photo(Conversation conversation) {
    if (conversation.photoURL != null) {
      return _circleAvatar(photoURL: conversation.photoURL);
    }
    print('body, conversation.photoURL null, finding member(s) photo(s)');
    List<String> members = conversation.members;
    members.remove(widget.myUser.id!);
    if (members.length == 1) {
      print('group tru minh ra, con 1 nguoi');
      return MyUserAvatar(
          myUserId: members[0],
          onTap: () {
            print('tap photo');
          });
    }
    if (members.length > 1) {
      //TODO: stack 2 photo
      print(
          'group tru minh ra, con 2 nguoi tro len, lay 2 nguoi lam group photo');
      return _circleAvatarForGroup(members[0], members[1]);
    }
    //TODO: default
    print('body, conversation default photo');
    return _circleAvatar();
  }

  Widget _name({String? name}) {
    return Text(
      name ?? '',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _whiteText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15.0,
        fontWeight: FontWeight.w400,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _lassMessageSender(
      {required String conversationId,
      required String? senderId,
      required String text}) {
    if (senderId != null) {
      if (senderId == widget.myUser.id) {
        //TODO: sent by me
        return _whiteText('Bạn: $text');
      } else {
        //TODO: nickname??name
        return StreamBuilder(
          stream: DatabaseService()
              .getStreamParticipantByDocumentId(conversationId, senderId),
          builder:
              (BuildContext context, AsyncSnapshot<Participant?> snapshot) {
            if (snapshot.hasError) {
              return _whiteText('Someone: $text');
            }
            if (snapshot.hasData) {
              if (snapshot.data!.nickname != null) {
                return _whiteText(snapshot.data!.nickname! + ': ' + text);
              } else {
                //TODO: not sent by me, no nickname
                return StreamBuilder(
                  stream:
                      DatabaseService().getStreamMyUserByDocumentId(senderId),
                  builder:
                      (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
                    if (snapshot.hasError) {
                      return _whiteText('Someone: $text');
                    }
                    if (snapshot.hasData) {
                      return _whiteText(snapshot.data!.name ?? 'Someone' + text);
                    } else {
                      return _whiteText('Someone: $text');
                    }
                  },
                );
              }
            } else {
              return _whiteText('Someone: $text');
            }
          },
        );
      }
    } else {
      //TODO: message từ hệ thống
      return _whiteText(text);
    }
  }

  Widget _messageLast(Conversation conversation) {
    if (conversation.messageLast == null) {
      return Container();
    } else {
      String text = conversation.messageLast!.text;
      String time = Helper.timeToString(conversation.messageLast!.updatedAt);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: _lassMessageSender(
                conversationId: conversation.id!,
                senderId: conversation.messageLast!.updatedBy,
                text: text),
          ),
          _whiteText(' • ' + time.toString()),
        ],
      );
    }
  }

  Widget _chatName(Conversation conversation) {
    if (conversation.title != null) {
      return _name(name: conversation.title);
    }
    List<String> members = conversation.members;
    members.remove(widget.myUser.id!);
    //TODO: group 3+
    if (members.length > 1) {
      return StreamBuilder(
        stream: DatabaseService().getStreamMyUserByDocumentId(members[0]),
        builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
          if (snapshot.hasError) {
            return Container();
          }
          if (snapshot.hasData) {
            String? name1 = snapshot.data!.name;
            return StreamBuilder(
              stream: DatabaseService().getStreamMyUserByDocumentId(members[1]),
              builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
                if (snapshot.hasError) {
                  return Container();
                }
                if (snapshot.hasData) {
                  String? name2 = snapshot.data!.name;
                  String name = '';
                  if (name1 != null) {
                    if (name2 != null) {
                      if (members.length - 2 + 1 > 0) {
                        name = name1 +
                            ', ' +
                            name2 +
                            ' và ${members.length - 2 + 1} người khác';
                      } else {
                        name = name1 + ', ' + name2;
                      }
                    } else {
                      name = name1 + ' và ${members.length - 2 + 2} người khác';
                    }
                  } else {
                    if (name2 != null) {
                      name = name2 + ' và ${members.length - 2 + 2} người khác';
                    } else {
                      name = ' Bạn và ${members.length - 2 + 3} người khác';
                    }
                  }
                  return _name(name: name);
                } else {
                  return Container();
                }
              },
            );
          } else {
            return Container();
          }
        },
      );
    }
    //TODO: group 2
    if (members.length == 1) {
      return StreamBuilder(
        stream: DatabaseService().getStreamMyUserByDocumentId(members[0]),
        builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
          if (snapshot.hasError) {
            return Container();
          }
          if (snapshot.hasData) {
            String? name1 = snapshot.data!.name;
            String name = '';
            if (name1 != null) {
              name = name1;
            } else {
              name = 'Bạn và 1 người khác';
            }
            return _name(name: name);
          } else {
            return Container();
          }
        },
      );
    }
    //TODO: default, group 1 mình
    return _name(name: 'Bạn và chỉ mỗi mình bạn');
  }

  Future<void> _showMessagesPage(BuildContext context, String? conversationId) async {
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.messagesPage,
      arguments: {
        'myUser': widget.myUser,
        'conversationId': conversationId,
      },
    );
  }

  Widget _item(BuildContext context, Conversation conversation) {
    return GestureDetector(
      onTap: () =>_showMessagesPage(context, conversation.id!),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: const Color(0xFF262626),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //TODO: photo+name+date
              Row(
                children: [
                  //TODO: img
                  _photo(conversation),
                  const SizedBox(
                    width: 10.0,
                  ),

                  //TODO: name+last message
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //TODO: name
                        _chatName(conversation),
                        const SizedBox(height: 5.0),
                        //TODO: last message
                        _messageLast(conversation),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('chats_page');
    return Scaffold(
      backgroundColor: bgBlack,
      //TODO: appBar
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: mainBlack,
        actions: [
          Expanded(
              child: TextField(
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 25.0),
                hintText: "Search something...",
                focusColor: Colors.grey,
                hoverColor: Colors.white70,
                filled: true,
                fillColor: mainGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                )),
          )),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      //TODO: list conversations
      body: StreamBuilder(
          stream: DatabaseService().getStreamListConversation(),
          builder: (BuildContext context,
              AsyncSnapshot<List<Conversation>> snapshot) {
            if (snapshot.hasError) {
              return Container();
            }
            if (snapshot.hasData) {
              List<Conversation> conversations = snapshot.data!;
              print('chats_page, conversations: ${conversations.length}');
              return ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (BuildContext context, int index) {
                  return _item(context, conversations[index]);
                },
              );
            } else {
              return Container();
            }
          }),
    );
  }
}
