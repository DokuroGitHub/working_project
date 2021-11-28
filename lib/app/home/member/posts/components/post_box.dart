import 'package:flutter/material.dart';

import '/app/home/member/posts/components/post_attachments.dart';
import '/app/home/member/posts/components/post_shipment.dart';
import '/models/emote.dart';
import '/models/feedback.dart';
import '/models/my_user.dart';
import '/models/post.dart';
import '/models/shipment.dart';
import '/services/database_service.dart';

import 'my_user_avatar.dart';
import 'my_user_name.dart';

class PostBox extends StatelessWidget {
  const PostBox({Key? key, required this.myUser, required this.post})
      : super(key: key);
  final MyUser myUser;
  final Post post;

  Future<void> postEmote(String emoteCode) async {
    //TODO: check exist
    Emote? emote =
        await DatabaseService().getEmoteInPost(postId: post.id!, myUserId: myUser.id!);
    if (emote == null) {
      //TODO: new
      Emote x = Emote(
        createdBy: myUser.id!,
        emoteCode: emoteCode,
      );
      //TODO: add
      DatabaseService().addEmoteToPost(postId: post.id!, myUserId: myUser.id!, emoteMap: x.toMap());
    } else {
      //TODO: delete
      DatabaseService().deleteEmoteInPost(postId: post.id!, emoteId: emote.id!);
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
        color: Theme.of(context).cardColor
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
                    style: const TextStyle(fontSize: 16.0))
              ]),
            const SizedBox(height: 10.0),
            //TODO: content
            _content(),

            const Divider(
              thickness: 1.5,
            ),
            //TODO: like+comment+share
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: (){
                      print('tap like btn');
                      postEmote('LIKE');
                    },
                    icon: Icon(Icons.thumb_up_outlined, color: Theme.of(context).textTheme.button?.color),
                    label: Text('Like', style: Theme.of(context).textTheme.button),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: (){},
                    icon: Icon(Icons.comment, color: Theme.of(context).textTheme.button?.color),
                    label: Text('Reply', style: Theme.of(context).textTheme.button),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: (){},
                    icon: Icon(Icons.share, color: Theme.of(context).textTheme.button?.color),
                    label: Text('Share', style: Theme.of(context).textTheme.button),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
