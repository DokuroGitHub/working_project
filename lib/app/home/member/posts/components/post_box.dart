import 'package:flutter/material.dart';

import '/app/home/member/posts/components/post_attachments.dart';
import '/app/home/member/posts/components/post_shipment.dart';
import '/models/emote.dart';
import '/models/feedback.dart';
import '/models/my_user.dart';
import '/models/post.dart';
import '/models/shipment.dart';
import '/services/database_service.dart';

import 'actionbtn.dart';
import 'my_user_avatar.dart';
import 'my_user_name.dart';

class PostBox extends StatelessWidget {
  const PostBox({Key? key, required this.myUser, required this.post})
      : super(key: key);
  final MyUser myUser;
  final Post post;

  Future<void> postEmote(String emoteCode) async {
    //TODO: can dua vao DatabaseService luon
    String documentPath = 'post/${post.id!}';
    //TODO: check exist
    Emote? emote =
        await DatabaseService().getEmoteByCreatedBy(documentPath, myUser.id!);
    if (emote == null) {
      //TODO: new
      Emote x = Emote(
        createdBy: myUser.id!,
        emoteCode: emoteCode,
      );
      //TODO: add
      DatabaseService().addEmoteWithId(myUser.id!, documentPath, x.toMap());
    } else {
      //TODO: delete
      DatabaseService().deleteEmote(documentPath, emote.id!);
    }
  }

  Widget _rating(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService().getStreamListFeedback(post.createdBy),
      builder: (BuildContext context, AsyncSnapshot<List<FeedBack>> snapshot) {
        if (snapshot.hasError) {
          print(
              'PostBox, _rating, snapshot feedback hasError: ${snapshot.error}');
          return Container();
        }
        if (snapshot.hasData) {
          List<num> _listRating = snapshot.data!.map((e) => e.rating).toList();
          double _rating = 0;
          double _sum = 0;
          int _length = _listRating.length;
          for (var item in _listRating) {
            _sum += item;
          }
          if (_length > 0) {
            _rating = _sum / _length;
          }
          return InkWell(
              onTap: () {
                print('tap rating, len:$_length sum:$_sum rating:$_rating');
              },
              child: Tooltip(
                  message: '$_length lượt đánh giá',
                  child: Row(children: [
                    Text(_rating.toString(),
                        style: const TextStyle(color: Colors.amber)),
                    const Icon(Icons.star, color: Colors.amber)
                  ])));
        } else {
          print('PostBox, _rating, snapshot feedback hasData false');
          return Container();
        }
      },
    );
  }

  Widget _content() {
    if (post.shipmentId == null) {
      return _postContent();
    } else {
      return _shipmentContent();
    }
  }

  Widget _postContent() {
    return Column(children: [
      //TODO: attachments
      PostAttachments(myUser: myUser, attachments: post.attachments),
      const SizedBox(height: 10.0),
    ]);
  }

  Widget _shipmentContent() {
    return Column(children: [
      //TODO: PostShipment
      if (post.shipmentId != null)
        StreamBuilder(
          stream:
              DatabaseService().getStreamShipmentByDocumentId(post.shipmentId!),
          builder: (BuildContext context, AsyncSnapshot<Shipment?> snapshot) {
            if (snapshot.hasError) {
              print('post, shipment hasError: ${snapshot.error}');
              return Container();
            }
            if (snapshot.hasData) {
              return PostShipment(myUser: myUser, shipment: snapshot.data!);
            } else {
              print('post, shipment hasData false');
              return Container();
            }
          },
        ),

      const SizedBox(height: 10.0),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
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
                MyUserAvatar(
                    myUserId: post.createdBy,
                    onTap: () {
                      print('tap avatar');
                    }),

                const SizedBox(
                  width: 10.0,
                ),

                //TODO: name+rating+date
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        //TODO: name
                        MyUserName(
                            myUserId: post.createdBy,
                            onTap: () {
                              print('tap name');
                            }),
                        const SizedBox(width: 15.0),
                        //TODO: rating
                        _rating(context),
                      ]),
                      const SizedBox(height: 5.0),
                      //TODO: date
                      GestureDetector(
                          child: Text(
                            post.createdAt.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onTap: () {
                            print('tap date');
                          }),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            //TODO: content
            if (post.text != null)
              Row(children: [
                Text(post.text!,
                    style: const TextStyle(color: Colors.white, fontSize: 16.0))
              ]),
            const SizedBox(height: 10.0),
            //TODO: content
            _content(),

            const Divider(
              thickness: 1.5,
              color: Color(0xFF505050),
            ),
            //TODO: like+comment+share
            Row(
              children: [
                actionButton(Icons.thumb_up, "Like", const Color(0xFF505050),
                    onTap: () {
                  print('tap like btn');
                  postEmote('LIKE');
                }),
                actionButton(Icons.comment, "Reply", const Color(0xFF505050),
                    onTap: () {
                  print('tap comment btn');
                }),
                actionButton(Icons.share, "Share", const Color(0xFF505050),
                    onTap: () {
                  print('tap share btn');
                }),
              ],
            )
          ],
        ),
      ),
    );
  }
}
