import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '/app/home/feedbacks/components/feedback_attachments.dart';
import '/app/home/feedbacks/components/summary.dart';
import '/app/home/member/posts/components/my_user_avatar.dart';
import '/app/home/messages/messages_page.dart';
import '/common_widgets/avatar.dart';
import '/common_widgets/helper.dart';
import '/constants/ui.dart';
import '/models/feedback.dart';
import '/models/my_user.dart';
import '/routing/app_router.dart';
import '/services/database_service.dart';

class FeedBacksPage extends StatefulWidget {
  const FeedBacksPage({required this.myUser, required this.myUserId2});

  final MyUser myUser;
  final String myUserId2;

  static Future<void> showPlz(BuildContext context, MyUser myUser, String myUserId2) async {
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.feedbacksPage,
      arguments: {
        'myUser': myUser,
        'myUserId2': myUserId2,
      },
    );
  }

  @override
  State<FeedBacksPage> createState() => _FeedBacksPageState();
}

class _FeedBacksPageState extends State<FeedBacksPage> {
  FeedBackQuery feedBacksQuery = FeedBackQuery.createdAtDesc;

  Future<void> _showMessagesPage(BuildContext context, MyUser myUser, String myUserId2) async {
    if(myUser.id! != myUserId2) {
      //TODO: chua test
      await MessagesPage.showMessagesPage(context, myUser, myUserId2);
    }else{
      print('ko the nhan tin cho chinh minh');
    }
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const BackButton(),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*.5),
              child: Text(AppLocalizations.of(context)!.rateAndFeedBacks,overflow: TextOverflow.ellipsis)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.local_phone),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.message_outlined),
          onPressed: () {
            _showMessagesPage(context, widget.myUser, widget.myUserId2);
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Column(children: [
          MyUserAvatar(myUserId: widget.myUserId2),
          const SizedBox(height: kDefaultPadding * 0.75),
          StreamBuilder(
            stream:
            DatabaseService().getStreamMyUserByDocumentId(widget.myUserId2),
            builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
              if (snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(snapshot.data!.name ?? ''),
                    Text(snapshot.data!.phoneNumber ?? ''),
                  ],
                );
              }
              return Container();
            },
          ),
        ]),
      ),
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Logout':
        print('logout');
        break;
      case 'Settings':
        print('settings');
        break;
    }
  }

  Widget _createdBy(String myUserId) {
    return StreamBuilder(
      stream: DatabaseService().getStreamMyUserByDocumentId(myUserId),
      builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
        if (snapshot.hasError) {
          return Container();
        }
        if (snapshot.hasData) {
          return Row(children: [
            Avatar(
              photoUrl: snapshot.data!.photoURL,
              radius: 15,
              borderColor: Colors.black54,
              borderWidth: 1.0,
            ),
            const SizedBox(width: 10),
            Text(snapshot.data!.name ?? ''),
          ]);
        }
        return Container();
      },
    );
  }

  Widget _rating(num star) {
    switch (star) {
      case 5:
        return Row(children: const [
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
        ]);
      case 4:
        return Row(children: const [
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
        ]);
      case 3:
        return Row(children: const [
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
        ]);
      case 2:
        return Row(children: const [
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
        ]);
      case 1:
        return Row(children: const [
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
        ]);
      default:
        return Row(children: const [
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
        ]);
    }
  }

  Widget _feedbackItem(FeedBack feedback) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration: const BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //TODO: avatar+name+rate+date
        Row(children: [
          _createdBy(feedback.createdBy),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _rating(feedback.rating),
            const SizedBox(height: 10),
            Text(Helper.timeToString(feedback.createdAt)),
          ]),
        ]),
        //TODO: text
        Text(feedback.text ?? ''),
        //TODO: attachments
        Column(children: [
          Row(children: const [
            Icon(Icons.attachment),
            SizedBox(width: 10),
            Text('Tệp đính kèm: '),
          ]),
          const SizedBox(width: 10),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .3),
            padding: const EdgeInsets.all(5.0),
            decoration: const BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: FeedBackAttachments(
                myUser: widget.myUser, attachments: feedback.attachments),
          ),
        ]),
        //TODO: reply
        if (feedback.reply != null)
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('Phản hồi:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(Helper.timeToString(feedback.reply!.createdAt)),
              ]),
              Text(feedback.reply!.text),
            ]),
          ),
      ]),
    );
  }

  Future<void> _showFilters() async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Sắp xếp theo'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  setState(() {
                    feedBacksQuery = FeedBackQuery.createdAtDesc;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Gần đây nhất'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  setState(() {
                    feedBacksQuery = FeedBackQuery.createdAtAsc;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Cũ nhất'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  setState(() {
                    feedBacksQuery = FeedBackQuery.ratingDesc;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Điểm đánh giá cao nhất'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  setState(() {
                    feedBacksQuery = FeedBackQuery.ratingAsc;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Điểm đánh giá thấp nhất'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Column(children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            reverse: false,
            child: Column(
              children: [
                //TODO: feedbacks
                StreamBuilder(
                  stream:
                      DatabaseService().getStreamListFeedback(widget.myUserId2, query: feedBacksQuery),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<FeedBack>> snapshot) {
                    if (snapshot.hasError) {
                      return Container();
                    }
                    if (snapshot.hasData) {
                      List<FeedBack> feedBacks = snapshot.data!;
                      return Column(children: [
                        Column(children: [
                          Row(children: const [
                            Text('Xếp hạng & nhận xét'),
                            Spacer(),
                          ]),
                          Summary(feedBacks: feedBacks),
                          Row(children: [
                            const Text('Chạm để xếp hạng'),
                            IconButton(
                                onPressed: () {
                                  print('1 star');
                                },
                                icon: const Icon(Icons.star)),
                            IconButton(
                                onPressed: () {
                                  print('2 star');
                                },
                                icon: const Icon(Icons.star)),
                            IconButton(
                                onPressed: () {
                                  print('3 star');
                                },
                                icon: const Icon(Icons.star)),
                            IconButton(
                                onPressed: () {
                                  print('4 star');
                                },
                                icon: const Icon(Icons.star)),
                            IconButton(
                                onPressed: () {
                                  print('5 star');
                                },
                                icon: const Icon(Icons.star)),
                          ]),
                          GestureDetector(
                            onTap: () {
                              print('tap add nhận xét');
                            },
                            child: Row(children: const [
                              Icon(Icons.note_add_outlined),
                              Text('Viết nhận xét',
                                  style: TextStyle(color: Colors.blue)),
                            ]),
                          ),
                          Row(children: [
                            const Spacer(),
                            TextButton(
                                onPressed: () {
                                  _showFilters();
                                },
                                child: const Text('Sắp xếp theo')),
                          ]),
                        ]),
                        Column(
                            children: feedBacks.map((feedBack) {
                              return Column(children:[
                                _feedbackItem(feedBack),
                                const SizedBox(height: 10),
                              ]);
                        }).toList()),
                      ]);
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
          ),
        )),
      ]),
    );
  }
}
