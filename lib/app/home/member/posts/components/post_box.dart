import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'rating_widget.dart';
import 'post_attachments.dart';
import 'post_shipment.dart';
import '/common_widgets/helper.dart';
import '/models/attachment.dart';
import '/models/comment.dart';
import '/models/emote.dart';
import '/models/my_user.dart';
import '/models/post.dart';
import '/models/shipment.dart';
import '/services/database_service.dart';
import 'comment_item.dart';
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
  bool _showComments = false;
  static const _defaultLimitIncrease = 5;
  static const _defaultLimit = 3;
  int _limit = _defaultLimit;
  final FocusNode _commentNode = FocusNode();
  final TextEditingController _commentController = TextEditingController();
  CommentQuery commentQuery = CommentQuery.createdAtDesc;

  @override
  void dispose() {
    _commentNode.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _increaseLimit() {
    setState(() {
      _limit += _defaultLimitIncrease;
    });
  }

  Future<void> _addCommentToPost() async {
    try {
      String text = _commentController.text.trim();
      print('comment text: $text');
      Attachment? attachment;
      if (text.isNotEmpty || attachment != null) {
        String postId = widget.post.id!;
        String myUserId = widget.myUser.id!;
        //TODO: new
        Comment comment = Comment(
          attachment: attachment,
          createdAt: DateTime.now(),
          deletedAt: null,
          editedAt: null,
          createdBy: myUserId,
          text: text,
        );
        //TODO: add
        await DatabaseService().addCommentToPost(postId, comment.toMap());
        Future.delayed(const Duration(), () {
          _commentController.clear();
        });
      }
    } catch (e) {
      print('posts_page, post_box, postId: ${widget.post.id!}, error: $e');
    }
  }

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
            }
            return Container();
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
        stream: DatabaseService().getStreamListEmoteInPost(widget.post.id!),
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
      //TODO: comment count
      StreamBuilder(
        stream: DatabaseService().getStreamListCommentInPost(widget.post.id!),
        builder: (BuildContext context, AsyncSnapshot<List<Comment>> snapshot) {
          if (snapshot.hasData) {
            if(snapshot.data!.isNotEmpty){
              return Text('${snapshot.data!.length} bình luận');
            }
          }
          return Container();
        },
      ),
      const SizedBox(width: 10.0),
      const Text('0 chia sẻ'),
      const SizedBox(width: 10.0),
    ]);
  }

  Widget _emoteIcon(String emoteCode) {
    switch (emoteCode) {
      case 'HEART':
        return const Icon(Icons.favorite_rounded, color: Colors.red);
      case 'HAHA':
        return const Icon(Icons.tag_faces_rounded, color: Colors.yellow);
      case 'ANGRY':
        return const Icon(Icons.tag_faces_rounded, color: Colors.red);
      default:
        return const Icon(Icons.thumb_up_alt, color: Colors.blue);
    }
  }

  Widget _emoteText(String emoteCode) {
    switch (emoteCode) {
      case 'HEART':
        return const Text('Thương thương', style: TextStyle(color: Colors.red));
      case 'HAHA':
        return const Text('Haha', style: TextStyle(color: Colors.yellow));
      case 'ANGRY':
        return const Text('Phẫn nội', style: TextStyle(color: Colors.red));
      default:
        return const Text('Thích', style: TextStyle(color: Colors.blue));
    }
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
                    _limit = _defaultLimit;
                    commentQuery = CommentQuery.createdAtDesc;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Gần đây nhất'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  setState(() {
                    _limit = _defaultLimit;
                    commentQuery = CommentQuery.createdAtAsc;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Tất cả bình luận'),
              ),
            ],
          );
        });
  }

  Widget _listCommentsWithFilter() {
    return StreamBuilder(
      stream: DatabaseService().getStreamListCommentInPost(widget.post.id!,
          query: commentQuery, limit: _limit),
      builder: (BuildContext context, AsyncSnapshot<List<Comment>> snapshot) {
        if (snapshot.hasError) {
          print('posts_page, post_box, list comments error: ${snapshot.error}');
          return Container();
        }
        if (snapshot.hasData) {
          List<Comment> comments = snapshot.data!;
          return Column(
              children: comments.map((comment) {
            return CommentItem(
              myUser: widget.myUser,
              comment: comment,
              onReplyTap: null,
            );
          }).toList());
        }
        return Container();
      },
    );
  }

  Widget _viewMoreCommentsWidget() {
    return StreamBuilder(
      stream: DatabaseService().getStreamListCommentInPost(widget.post.id!),
      builder: (BuildContext context, AsyncSnapshot<List<Comment>> snapshot) {
        if (snapshot.hasData) {
          num length = snapshot.data!.length;
          if (length > _limit) {
            //TODO: switch
            switch (commentQuery) {
              case CommentQuery.createdAtAsc:
                //TODO: Xem các bình luận trước/Xem thêm 3 bình luận
                if (length - _limit > _defaultLimitIncrease) {
                  return TextButton(
                      onPressed: _increaseLimit,
                      child: const Text('Xem các bình luận trước'));
                } else {
                  return TextButton(
                      onPressed: _increaseLimit,
                      child: Text('Xem thêm ${length - _limit} bình luận'));
                }
              case CommentQuery.createdAtDesc:
                //TODO: Xem thêm bình luận/Xem thêm 6 bình luận
                if (length - _limit > _defaultLimitIncrease) {
                  return Row(children: [
                    TextButton(
                        onPressed: _increaseLimit,
                        child: const Text('Xem thêm bình luận')),
                    const Spacer(),
                    Text('$_limit/$length'),
                  ]);
                } else {
                  return Row(children: [
                    TextButton(
                        onPressed: _increaseLimit,
                        child: Text('Xem thêm ${length - _limit} bình luận')),
                    const Spacer(),
                    Text('$_limit/$length'),
                  ]);
                }
            }
          }
        }
        return Container();
      },
    );
  }

  Widget _inputRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: [
          MyUserAvatar(myUser: widget.myUser, myUserId: null),
          const SizedBox(width: 10.0),
          Expanded(
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (event) async {
                if (event.runtimeType == RawKeyDownEvent &&
                    (event.logicalKey.keyId == 4294967309) &&
                    (!event.isShiftPressed)) {
                  await _addCommentToPost();
                }
              },
              child: TextField(
                focusNode: _commentNode,
                controller: _commentController,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                      left: 10.0, top: 15, right: 0, bottom: 15),
                  hintText: 'Viết bình luận công khai',
                  filled: true,
                  fillColor: Theme.of(context).bannerTheme.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      Icons.tag_faces_outlined,
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.color
                          ?.withOpacity(0.64),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Icon(
                      Icons.photo_camera_outlined,
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.color
                          ?.withOpacity(0.64),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Icon(
                      Icons.attach_file,
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.color
                          ?.withOpacity(0.64),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                  ]),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 5.0,
          ),
          IconButton(
            icon: const Icon(
              Icons.send,
              color: Colors.blue,
            ),
            onPressed: _addCommentToPost,
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  Widget _commentsContent() {
    switch (commentQuery) {
      case CommentQuery.createdAtAsc:
        return Column(
          children: [
            //TODO: Xem các bình luận trước/Xem thêm 3 bình luận - Tất cả bình luận ▼
            Row(children: [
              //TODO: Xem các bình luận trước/Xem thêm 3 bình luận
              _viewMoreCommentsWidget(),
              const Spacer(),
              //TODO: Tất cả bình luận ▼
              TextButton(
                onPressed: _showFilters,
                child: Row(mainAxisSize:MainAxisSize.min, children: const [
                  Text('Tất cả bình luận '),
                  Icon(Icons.arrow_drop_down_outlined),
                ]),
              ),
            ]),
            //TODO: list comments with filter
            _listCommentsWithFilter(),
            //TODO: input row
            _inputRow(),
          ],
        );
      case CommentQuery.createdAtDesc:
        return Column(
          children: [
            //TODO: Gần đây nhất ▼
            Row(children: [
              const Spacer(),
              TextButton(
                onPressed: _showFilters,
                child: Row(mainAxisSize:MainAxisSize.min, children: const [
                  Text('Gần đây nhất'),
                  Icon(Icons.arrow_drop_down_outlined),
                ]),
              ),
            ]),
            //TODO: input row
            _inputRow(),
            //TODO: list comments with filter
            _listCommentsWithFilter(),
            //TODO: Xem thêm bình luận/Xem thêm 6 bình luận - 3/28
            _viewMoreCommentsWidget(),
            //TODO: Ai đó đang nhập bình luận...
            Row(children: const [
              Text('··· Ai đó đang nhập bình luận...'),
              Spacer(),
            ]),
            //TODO: Viết bình luận...
            Row(children: [
              TextButton(
                  onPressed: () => _commentNode.requestFocus(),
                  child: const Text('Viết bình luận...')),
              const Spacer(),
            ]),
          ],
        );
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
                        RatingWidget(myUserId: widget.post.createdBy),
                      ]),
                      const SizedBox(height: 5.0),
                      //TODO: date
                      GestureDetector(
                          child: Text(
                            Helper.timeToString(widget.post.createdAt),
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
                                  onLongPress: () {
                                    setState(() {
                                      _showEmoteSelectionsBar = true;
                                    });
                                    Future.delayed(const Duration(seconds: 3),
                                        () {
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
                                    style: Theme.of(context).textTheme.button),
                              );
                            },
                          ),
                        ),
                        //TODO: comment button
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _showComments = true;
                              });
                              _commentNode.requestFocus();
                            },
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
            //TODO: _showComments + input row
            if (_showComments)
              Column(children: [
                const Divider(thickness: 1.5),
                _commentsContent(),
              ]),
          ],
        ),
      ),
    );
  }
}
