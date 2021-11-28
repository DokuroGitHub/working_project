import 'dart:async';

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

class PostBox extends StatefulWidget {
  const PostBox({Key? key, required this.myUser, required this.post})
      : super(key: key);
  final MyUser myUser;
  final Post post;

  @override
  State<PostBox> createState() => _PostBoxState();
}

class _PostBoxState extends State<PostBox> {

  Future<void> addEmoteToPost(String emoteCode) async {
    try {
      //TODO: new
      Emote x = Emote(
        createdBy: widget.myUser.id!,
        emoteCode: emoteCode,
      );
      //TODO: add
      DatabaseService().addEmoteToPost(
          postId: widget.post.id!,
          myUserId: widget.myUser.id!,
          emoteMap: x.toMap());
    } catch (e) {
      print('posts_page, post_box, addEmote error: $e');
    }
  }

  Future<void> deleteEmoteInPost() async {
    try {
      //TODO: delete
      DatabaseService().deleteEmoteInPost(
          postId: widget.post.id!, emoteId: widget.myUser.id!);
    } catch (e) {
      print('posts_page, post_box, addEmote error: $e');
    }
  }

  Widget _rating(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService().getStreamListFeedback(widget.post.createdBy),
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
    if (widget.post.shipmentId == null) {
      return _postContent();
    } else {
      return _shipmentContent();
    }
  }

  Widget _postContent() {
    return Column(children: [
      //TODO: text
      if (widget.post.text != null)
        Row(children: [
          Text(widget.post.text!, style: const TextStyle(fontSize: 16.0))
        ]),
      const SizedBox(height: 10.0),
      //TODO: attachments
      PostAttachments(
          myUser: widget.myUser, attachments: widget.post.attachments),
      const SizedBox(height: 10.0),
    ]);
  }

  Widget _shipmentContent() {
    return Column(children: [
      //TODO: PostShipment
      if (widget.post.shipmentId != null)
        StreamBuilder(
          stream: DatabaseService()
              .getStreamShipmentByDocumentId(widget.post.shipmentId!),
          builder: (BuildContext context, AsyncSnapshot<Shipment?> snapshot) {
            if (snapshot.hasError) {
              print('post, shipment hasError: ${snapshot.error}');
              return Container();
            }
            if (snapshot.hasData) {
              return PostShipment(
                  myUser: widget.myUser, shipment: snapshot.data!);
            } else {
              print('post, shipment hasData false');
              return Container();
            }
          },
        ),

      const SizedBox(height: 10.0),
    ]);
  }

  bool _showEmoteSelectionsBar = false;

  Widget _emoteCommentShareCounts() {
    return Row(children: [
      const SizedBox(width: 10.0),
      //TODO: emote count
      StreamBuilder(
        stream:
            DatabaseService().getStreamListEmoteInPost(postId: widget.post.id!),
        builder: (BuildContext context, AsyncSnapshot<List<Emote>> snapshot) {
          if (snapshot.hasData) {
            List<Emote> emotes = snapshot.data!;
            List<Emote> likes = [];
            List<Emote> hearts = [];
            List<Emote> hahas = [];
            List<Emote> angries = [];
            for (var element in emotes) {
              switch (element.emoteCode) {
                case 'LIKE':
                  likes.add(element);
                  break;
                case 'HEART':
                  hearts.add(element);
                  break;
                case 'HAHA':
                  hahas.add(element);
                  break;
                case 'ANGRY':
                  angries.add(element);
                  break;
                default:
                  break;
              }
            }
            List<Widget> rowItems = [];
            rowItems.add(const SizedBox(width: 5));
            if (likes.isNotEmpty) {
              rowItems.add(Icon(Icons.thumb_up_alt_rounded,
                  color: Colors.blue, semanticLabel: likes.length.toString()));
              rowItems.add(const SizedBox(width: 5));
            }
            if (hearts.isNotEmpty) {
              rowItems.add(Icon(Icons.favorite_rounded,
                  color: Colors.red, semanticLabel: hearts.length.toString()));
              rowItems.add(const SizedBox(width: 5));
            }
            if (hahas.isNotEmpty) {
              rowItems.add(Icon(Icons.tag_faces_rounded,
                  color: Colors.yellow,
                  semanticLabel: hahas.length.toString()));
              rowItems.add(const SizedBox(width: 5));
            }
            if (angries.isNotEmpty) {
              rowItems.add(Icon(Icons.tag_faces_rounded,
                  color: Colors.red, semanticLabel: angries.length.toString()));
              rowItems.add(const SizedBox(width: 5));
            }
            rowItems.add(const SizedBox(width: 10));

            if (emotes.isNotEmpty) {
              if (emotes
                  .where((element) => element.createdBy == widget.myUser.id!)
                  .isNotEmpty) {
                //TODO: has me in this list
                String s = 'Bạn';
                if (emotes.length > 1) {
                  s += ' và ${emotes.length - 1} người khác';
                }
                rowItems.add(Text(s));
              } else {
                //TODO: not having me in this list
                rowItems.add(Text(emotes.length.toString()));
              }
              return Row(children: rowItems);
            }
          }
          return Container();
        },
      ),
      const Spacer(),
      const Text('0 bình luận'),
      const SizedBox(width: 10.0),
      const Text('0 chia sẻ'),
      const SizedBox(width: 10.0),
    ]);
  }

  Widget _emoteIcon(String emoteCode){
    switch(emoteCode){
      case 'HEART':
        return const Icon(Icons.favorite_rounded,
            color: Colors.red);
      case 'HAHA':
        return const Icon(Icons.tag_faces_rounded,
            color: Colors.yellow);
      case 'ANGRY':
        return const Icon(Icons.tag_faces_rounded,
            color: Colors.red);
      default:
        return const Icon(Icons.thumb_up_alt,
            color: Colors.blue);
    }
  }

  Widget _emoteText(String emoteCode){
    switch(emoteCode){
      case 'HEART':
        return const Text('Thương thương',
            style: TextStyle(color: Colors.red));
      case 'HAHA':
        return const Text('Haha',
            style: TextStyle(color: Colors.yellow));
      case 'ANGRY':
        return const Text('Phẫn nội',
            style: TextStyle(color: Colors.red));
      default:
        return const Text('Thích',
            style: TextStyle(color: Colors.blue));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Theme.of(context).cardColor),
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
                  myUser: null,
                    myUserId: widget.post.createdBy,
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
                            myUserId: widget.post.createdBy,
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
                            widget.post.createdAt.toString(),
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
            _content(),
            //TODO: row 3 counts, row 3 buttons
            Stack(
              children: [
                Column(
                  children: [
                    //TODO: emote/comment/share counts
                    _emoteCommentShareCounts(),
                    const Divider(
                      thickness: 1.5,
                    ),
                    //TODO: like+comment+share
                    Row(
                      children: [
                        //TODO: like button
                        Expanded(
                          child: StreamBuilder(
                            stream: DatabaseService().getStreamEmoteInPost(
                                postId: widget.post.id!,
                                myUserId: widget.myUser.id!),
                            builder: (BuildContext context,
                                AsyncSnapshot<Emote?> snapshot) {
                              if (snapshot.hasData) {
                                //TODO: da tha emote
                                return TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _showEmoteSelectionsBar = false;
                                    });
                                    deleteEmoteInPost();
                                  },
                                  onLongPress: (){
                                    setState(() {
                                      _showEmoteSelectionsBar = true;
                                    });
                                    Future.delayed(const Duration(seconds: 3), () {
                                      setState(() {
                                        _showEmoteSelectionsBar = false;
                                      });
                                    });
                                  },
                                  icon: _emoteIcon(snapshot.data!.emoteCode),
                                  label: _emoteText(snapshot.data!.emoteCode),
                                );
                              }
                              //TODO: chua tha emote
                              return TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showEmoteSelectionsBar = false;
                                  });
                                  addEmoteToPost('LIKE');
                                },
                                icon: Icon(Icons.thumb_up_alt_outlined,
                                    color: Theme.of(context)
                                        .textTheme
                                        .button
                                        ?.color),
                                label: Text('Like',
                                    style:
                                        Theme.of(context).textTheme.button),
                              );
                            },
                          ),
                        ),
                        //TODO: comment button
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.comment,
                                color:
                                    Theme.of(context).textTheme.button?.color),
                            label: Text('Bình luận',
                                style: Theme.of(context).textTheme.button),
                          ),
                        ),
                        //TODO: share button
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.share,
                                color:
                                    Theme.of(context).textTheme.button?.color),
                            label: Text('Share',
                                style: Theme.of(context).textTheme.button),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                //TODO: emote selections bar
                if (_showEmoteSelectionsBar)
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showEmoteSelectionsBar = false;
                          });
                          addEmoteToPost('LIKE');
                        },
                        icon: const Icon(
                          Icons.thumb_up_alt_rounded,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showEmoteSelectionsBar = false;
                          });
                          addEmoteToPost('HEART');
                        },
                        icon: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showEmoteSelectionsBar = false;
                          });
                          addEmoteToPost('HAHA');
                        },
                        icon: const Icon(
                          Icons.tag_faces_rounded,
                          color: Colors.yellow,
                          size: 40,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showEmoteSelectionsBar = false;
                          });
                          addEmoteToPost('ANGRY');
                        },
                        icon: const Icon(
                          Icons.tag_faces_rounded,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const Divider(thickness: 1.5),
            Row(
              children: [
                MyUserAvatar(myUser: widget.myUser, myUserId: null),
                const SizedBox(width: 10.0),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        contentPadding:
                        const EdgeInsets.only(left: 25.0),
                        hintText: 'Viết bình luận công khai',
                        filled: true,
                        fillColor: Theme.of(context).bannerTheme.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        )),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5.0,
            ),
          ],
        ),
      ),
    );
  }
}
