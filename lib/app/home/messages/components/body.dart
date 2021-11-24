import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '/app/home/member/posts/components/my_user_avatar.dart';
import '/common_widgets/avatar.dart';
import '/common_widgets/helper.dart';
import '/constants/ui.dart';
import '/models/attachment.dart';
import '/models/conversation.dart';
import '/models/message.dart';
import '/models/message_last.dart';
import '/models/my_user.dart';
import '/models/participant.dart';
import '/services/database_service.dart';

import 'message_attachments.dart';

class Body extends StatefulWidget {
  const Body({required this.myUser, required this.conversation});

  final MyUser myUser;
  final Conversation conversation;

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool _showBottom = false;
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

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
            return _circleAvatar();
          }
          if (snapshot.hasData) {
            //TODO: avatar
            return _circleAvatar(photoURL: snapshot.data?.photoURL);
          } else {
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
      return _circleAvatarForGroup(members[0], members[1]);
    }
    //TODO: default
    print('body, conversation default photo');
    return _circleAvatar();
  }

  Widget _chatNameText({String? name}) {
    return Text(
      name ?? '',
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _chatName(Conversation conversation) {
    if (conversation.title != null) {
      return _chatNameText(name: conversation.title);
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
                  return _chatNameText(name: name);
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
            return _chatNameText(name: name);
          } else {
            return Container();
          }
        },
      );
    }
    //TODO: default, group 1 mình
    return _chatNameText(name: 'Bạn và chỉ mỗi mình bạn');
  }

  Widget _chatStatusText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12),
    );
  }

  Widget _chatStatus(List<String> members) {
    print('body, _chatStatus, chua remove, members.length: ${members.length}');
    members.remove(widget.myUser.id!);
    if(members.length==1){
      return StreamBuilder(stream: DatabaseService().getStreamMyUserByDocumentId(members.first),
        builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
        if(snapshot.hasError){
          return Container();
        }
        if(snapshot.hasData){
          MyUser myUser = snapshot.data!;
          if(myUser.isActive){
            //TODO: isActive, green dot + Dang hoat dong
            return Row(children: [
              //TODO: green dot, có vẻ ko cần
              Container(
                height: 16,
                width: 16,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                ),
              ),
              const SizedBox(width: 10),
              _chatStatusText('Đang hoạt động'),
            ]);
          }
          //TODO: is not active, last sign in time
          String time = Helper.timeToString(myUser.lastSignInAt);
          return _chatStatusText('Hoạt động $time');
        }
        return Container();
      });
    }
    //TODO: default
    return Container();
  }

  Widget _senderNameText(String name) {
    return Text(
      name,
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget _nickNameOrName(String myUserId) {
    //TODO: check nickname
    return StreamBuilder(
      stream: DatabaseService()
          .getStreamParticipantByDocumentId(widget.conversation.id!, myUserId),
      builder: (BuildContext context, AsyncSnapshot<Participant?> snapshot) {
        if (snapshot.hasData && snapshot.data!.nickname != null) {
          //TODO: co nickname
          return _senderNameText(snapshot.data!.nickname!);
        }
        //TODO: ko tim dc nickname, tim name
        return StreamBuilder(
          stream: DatabaseService().getStreamMyUserByDocumentId(myUserId),
          builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
            if (snapshot.hasError) {
              return _senderNameText('Someone');
            }
            if (snapshot.hasData) {
              return _senderNameText(snapshot.data!.name ?? 'Someone');
            } else {
              return _senderNameText('Someone');
            }
          },
        );
      },
    );
  }

  Widget _receivedMessageWidget(Message message) {
    return GestureDetector(
      onTap: () {
        print('body, attachments.length: ${message.attachments.length}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.0),
        child: Column(
          children: [
            const SizedBox(width: 15),
            //TODO: createdAt
            Text(message.createdAt.toString(),overflow: TextOverflow.ellipsis),
            Row(
              //TODO: CrossAxisAlignment.end dua avatar vs createdAt xuong bottom
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                //TODO: sender avatar
                MyUserAvatar(
                    myUserId: message.createdBy,
                    onTap: () {
                      print('tap photo, myUserId: ${message.createdBy}');
                    }),
                //TODO: message content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    //TODO: nickname??name
                    _nickNameOrName(message.createdBy),
                    //TODO: text
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * .6),
                      padding: const EdgeInsets.all(15.0),
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                      child: Text(message.text != null
                          ? message.text!.replaceAll('\n', '\n')
                          : ''),
                    ),
                    //TODO: attachments
                    Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .6),
                      child:MessageAttachments(
                      myUser: widget.myUser,
                      attachments: message.attachments,
                    )),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sentMessageWidget(Message message) {
    return GestureDetector(
      onTap: () {
        print('body, attachments.length: ${message.attachments.length}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.0),
        child: Column(
          children: [
            //TODO: createdAt
            Text(message.createdAt.toString(),overflow: TextOverflow.ellipsis),
            Row(
              //TODO: day ve ben phai
              mainAxisAlignment: MainAxisAlignment.end,
              //TODO: dua createdAt ve bottom
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                const SizedBox(width: 15),
                //TODO: message content
                Column(
                    mainAxisSize: MainAxisSize.min,
                    //TODO: dua text vs attachments ve phai
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                  //TODO: text
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * .6),
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: myGreen,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                    ),
                    child: Text(message.text != null
                        ? message.text!.replaceAll('\\n', '\n')
                        : ''),
                  ),
                      //TODO: attachments
                      Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .6),
                          child:MessageAttachments(
                            myUser: widget.myUser,
                            attachments: message.attachments,
                          )),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _seen(Conversation conversation) {
    if (conversation.id == null || conversation.messageLast == null) {
      return Container();
    }
    return StreamBuilder(
      stream: DatabaseService().getStreamListParticipantByUpdatedAt(
          conversation.id!, conversation.messageLast!.updatedAt),
      builder:
          (BuildContext context, AsyncSnapshot<List<Participant>> snapshot) {
        if (snapshot.hasError) {
          print('body, _seen, snapshot.hasError: ${snapshot.error}');
          return Container();
        }
        if (snapshot.hasData) {
          List<Widget> avatars = [];
          List<Participant> participants = snapshot.data!;
          //TODO: loai minh ra
          participants
              .removeWhere((element) => element.id! == widget.myUser.id!);
          int len = participants.length;
          print('body, _seen, len: $len');
          if (len == 0) {
            return Container();
          }
          const maxAvatar = 4;
          int nAvatar = len > maxAvatar ? maxAvatar : len;
          for (int i = 0; i < nAvatar; i++) {
            //TODO: add avatar
            avatars.add(Tooltip(
                message: 'Xem lúc ${participants[i].updatedAt}',
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: _avatarInGroup(participants[i].id!))));
            avatars.add(const SizedBox(width: 2));
          }
          if (len > nAvatar) {
            avatars.add(IconButton(
              icon: const Icon(Icons.add_circle, size: 20),
              onPressed: () {},
              tooltip: 'và ${len - nAvatar} người khác',
            ));
          }
          print('body, _seen, participants.length: ${participants.length}');
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: avatars,
            ),
          );
        }
        return Container();
      },
    );
  }

  Future _sendMessage() async {
    String text = _messageController.text.trim();
    print('message: $text');
    List<Attachment> attachments = [];
    if (text.isNotEmpty || attachments.isNotEmpty) {
      String conversationId = widget.conversation.id!;
      String myUserId = widget.myUser.id!;
      //TODO: new
      Message message = Message(
        attachments: attachments,
        createdAt: DateTime.now(),
        createdBy: myUserId,
        replyToMessageId: null,
        text: text,
      );
      //TODO: add
      await DatabaseService().addMessage(conversationId, message.toMap());
      //TODO: new
      MessageLast messageLast = MessageLast(
        text: message.text??'${widget.myUser.name} đã gửi 1 tin nhắn mới',
        updatedAt: DateTime.now(),
        updatedBy: widget.myUser.id!,
      );
      //TODO: updated
      await DatabaseService().updateConversation(conversationId,
          {
            'messageLast': messageLast.toMap()
          },
      );
      _messageController.clear();
    }
  }

  Widget _chatInputFieldWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 32,
            color: const Color(0xFF087949).withOpacity(0.08),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            InkWell(
              child: const Icon(
                Icons.add_circle,
                color: kPrimaryColor,
              ),
              onTap: () {
                setState(() {
                  _showBottom = true;
                });
              },
            ),
            const SizedBox(width: kDefaultPadding),
            const Icon(Icons.mic, color: kPrimaryColor),
            const SizedBox(width: kDefaultPadding / 2),
            Expanded(
                child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding * 0.75,
              ),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sentiment_satisfied_alt_outlined,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.color
                        ?.withOpacity(0.64),
                  ),
                  const SizedBox(width: kDefaultPadding / 4),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Type message",
                        border: InputBorder.none,
                      ),
                      autocorrect: false,
                      //onEditingComplete: _node.nextFocus,
                    ),
                  ),
                  Icon(
                    Icons.attach_file,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.color
                        ?.withOpacity(0.64),
                  ),
                  const SizedBox(width: kDefaultPadding / 4),
                  Icon(
                    Icons.camera_alt_outlined,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.color
                        ?.withOpacity(0.64),
                  ),
                ],
              ),
            )),
            const SizedBox(width: kDefaultPadding),
            IconButton(
                icon: const Icon(Icons.send, color: kPrimaryColor),
                onPressed: () {
                  //TODO: send message
                  _sendMessage();
                }),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const BackButton(),
          _photo(widget.conversation),
          const SizedBox(width: kDefaultPadding * 0.75),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width*.4),
                  child:_chatName(widget.conversation)),
              ConstrainedBox(constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width*.4),
                  child:_chatStatus(widget.conversation.members)),
            ],
          )
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.local_phone),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {},
        ),
        const SizedBox(width: kDefaultPadding / 2),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Stack(
        children: [
          //TODO: content
          Column(children: [
            //TODO: messages+seen
            Expanded(child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  children: [
                    //TODO: messages
                    StreamBuilder(
                      stream: DatabaseService()
                          .getStreamListMessage(widget.conversation.id!),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Message>> snapshot) {
                        if (snapshot.hasError) {
                          return Container();
                        }
                        if (snapshot.hasData) {
                          List<Message> messages = snapshot.data!;
                          return Column(children: messages.map((message) {
                            if (message.createdBy != widget.myUser.id!) {
                              return _receivedMessageWidget(message);
                            } else {
                              return _sentMessageWidget(message);
                            }
                          }).toList());
                        } else {
                          return Container();
                        }
                      },
                    ),
                    //TODO: seen
                    _seen(widget.conversation),
                  ],
                ),
              ),
            )),
            //TODO: input
            _chatInputFieldWidget(),
          ]),
          //TODO: add files
          _showBottom
              ? Stack(children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        print('tap, _showBottom = false');
                        setState(() {
                          _showBottom = false;
                        });
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 90,
                    left: 25,
                    right: 25,
                    child: Container(
                      padding: const EdgeInsets.all(25.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 5),
                              blurRadius: 15.0,
                              color: Colors.grey)
                        ],
                      ),
                      child: GridView.count(
                        mainAxisSpacing: 21.0,
                        crossAxisSpacing: 21.0,
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        children: List.generate(
                          icons.length,
                          (i) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: Colors.grey[200],
                                border: Border.all(color: myGreen, width: 2),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  icons[i],
                                  color: myGreen,
                                ),
                                onPressed: () {},
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ])
              : Container(),
        ],
      ),
    );
  }
}

List<IconData> icons = [
  Icons.image,
  Icons.camera,
  Icons.file_upload,
  Icons.folder,
  Icons.gif
];

Color myGreen = const Color(0xff4bb17b);
