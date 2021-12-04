import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/common_widgets/helper.dart';
import '/models/attachment.dart';
import '/models/comment.dart';
import '/models/emote.dart';
import '/models/my_user.dart';
import '/services/database_service.dart';
import 'my_user_avatar.dart';
import 'my_user_name.dart';
import 'rating_widget.dart';

class CommentItem extends StatefulWidget {
  const CommentItem(
      {Key? key,
      required this.myUser,
      required this.comment,
      required this.onReplyTap})
      : super(key: key);

  final MyUser myUser;
  final Comment comment;
  final VoidCallback? onReplyTap;

  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _showReplies = false;
  static const _defaultLimitIncrease = 10;
  static const _defaultLimit = 3;
  int _limit = _defaultLimit;
  final FocusNode _replyNode = FocusNode();
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyNode.dispose();
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _addReplyToComment() async {
    try {
      String text = _replyController.text.trim();
      print('comment text: $text');
      Attachment? attachment;
      if (text.isNotEmpty || attachment != null) {
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
        await DatabaseService().addCommentToComment(
          replyForCommentDocumentPath: comment.documentPath!,
          commentMap: comment.toMap(),
        );
        Future.delayed(const Duration(), () {
          _replyController.clear();
        });
      }
    } catch (e) {
      print(
          'posts_page, post_box, comment_item: ${widget.comment.documentPath!}, error: $e');
    }
  }

  Future<void> addEmoteToComment(String emoteCode) async {
    try {
      //TODO: new
      Emote x = Emote(
        createdBy: widget.myUser.id!,
        emoteCode: emoteCode,
      );
      //TODO: add
      DatabaseService().addEmoteToComment(
          commentPath: widget.comment.documentPath!,
          myUserId: widget.myUser.id!,
          emoteMap: x.toMap());
    } catch (e) {
      print('posts_page, post_box, comment_item, addEmoteToComment error: $e');
    }
  }

  Future<void> deleteEmoteInComment() async {
    try {
      //TODO: delete
      DatabaseService().deleteEmoteInComment(
          commentPath: widget.comment.documentPath!,
          emoteId: widget.myUser.id!);
    } catch (e) {
      print(
          'posts_page, post_box, comment_item, deleteEmoteInComment error: $e');
    }
  }

  bool _showEmoteSelectionsBar = false;

  Widget _emoteCounts() {
    return StreamBuilder(
      stream: DatabaseService().getStreamListEmoteInComment(
          commentDocumentPath: widget.comment.documentPath!),
      builder: (BuildContext context, AsyncSnapshot<List<Emote>> snapshot) {
        if (snapshot.hasData) {
          List<Emote> emotes = snapshot.data!;
          if (emotes.isNotEmpty) {
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
            if (likes.isNotEmpty) {
              rowItems.add(Icon(Icons.thumb_up_alt_rounded,
                  color: Colors.blue, semanticLabel: likes.length.toString()));
            }
            if (hearts.isNotEmpty) {
              rowItems.add(Icon(Icons.favorite_rounded,
                  color: Colors.red, semanticLabel: hearts.length.toString()));
            }
            if (hahas.isNotEmpty) {
              rowItems.add(Icon(Icons.tag_faces_rounded,
                  color: Colors.yellow,
                  semanticLabel: hahas.length.toString()));
            }
            if (angries.isNotEmpty) {
              rowItems.add(Icon(Icons.tag_faces_rounded,
                  color: Colors.red, semanticLabel: angries.length.toString()));
            }
            rowItems.add(const SizedBox(width: 2));

            rowItems.add(Text(emotes.length.toString()));
            return Row(mainAxisSize: MainAxisSize.min, children: rowItems);
          }
        }
        return Container();
      },
    );
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

  Widget _listRepliesWithFilter() {
    return StreamBuilder(
      stream: DatabaseService()
          .getStreamListCommentInComment(widget.comment.documentPath!, limit: _limit),
      builder: (BuildContext context, AsyncSnapshot<List<Comment>> snapshot) {
        if (snapshot.hasError) {
          print(
              'posts_page, post_box, comment_item, _listCommentsWithFilter error: ${snapshot.error}');
          return Container();
        }
        if (snapshot.hasData) {
          List<Comment> comments = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: comments.map((comment) {
            //TODO: cần xác định bài viết có tối đa bao nhiêu bậc comment
            //TODO: và comment này đang ở bậc bao nhiêu
            //TODO: tạm thời default post.maxRep=2, comment.rep=1
            //TODO: comment này chỉ được tối đa thêm 1 rep -> onRepTap!=null
            return CommentItem(
              myUser: widget.myUser,
              comment: comment,
              onReplyTap: (){
                //TODO: focus to this reply node
                print('onReplyTap, comment này ko thể reply thêm nhánh');
                _replyNode.requestFocus();
              },
            );
          }).toList());
        }
        return Container();
      },
    );
  }

  Widget _inputRow() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width-90),
      child: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          mainAxisSize: MainAxisSize.max,
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
                    await _addReplyToComment();
                  }
                },
                child: TextField(
                  focusNode: _replyNode,
                  controller: _replyController,
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
              onPressed: _addReplyToComment,
            ),
            const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }

  Widget _emoteSelectionsBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _showEmoteSelectionsBar = false;
            });
            addEmoteToComment('LIKE');
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
            addEmoteToComment('HEART');
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
            addEmoteToComment('HAHA');
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
            addEmoteToComment('ANGRY');
          },
          icon: const Icon(
            Icons.tag_faces_rounded,
            color: Colors.red,
            size: 40,
          ),
        ),
      ],
    );
  }

  Widget _viewMoreRepliesWidget() {
    return StreamBuilder(
      stream: DatabaseService().getStreamListCommentInComment(widget.comment.documentPath!),
      builder: (BuildContext context, AsyncSnapshot<List<Comment>> snapshot) {
        if (snapshot.hasData) {
          num length = snapshot.data!.length;
          num gap = length - _limit;
          if (gap>0) {
            //TODO: Xem thêm 3 bình luận
            TextButton(
                onPressed: (){
                  setState(() {
                    _limit+=_defaultLimitIncrease;
                  });
                },
                child: Text('Xem thêm $gap bình luận'));
          }
        }
        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //TODO: img
        MyUserAvatar(
            myUser: null,
            myUserId: widget.comment.createdBy,
            onTap: () {
              print('tap avatar');
            }),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //TODO: name text thich phan hoi share? datetime emoteCounts 3 dots
                    Row(
                      //mainAxisSize: MainAxisSize.min,
                      children: [
                        //TODO: name text thich phan hoi share? datetime emoteCounts
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //TODO: name + rating
                              Row(children: [
                                MyUserName(
                                  myUserId: widget.comment.createdBy,
                                  onTap: () {
                                    print('tap name');
                                  },
                                ),
                                const SizedBox(width: 15.0),
                                //TODO: rating
                                RatingWidget(
                                    myUserId: widget.comment.createdBy),
                              ]),
                              //TODO: text
                              if (widget.comment.text != null)
                                Text(widget.comment.text!),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        //TODO: 3 dots: edit, delete / hide, report
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_horiz)),
                        //const Spacer(),
                      ],
                    ),

                    //TODO: attachments

                    //TODO: like+comment+share+date+emoteCounts
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //TODO: like button
                        StreamBuilder(
                          stream: DatabaseService().getStreamEmoteInComment(
                              commentDocumentPath: widget.comment.documentPath!,
                              myUserId: widget.myUser.id!),
                          builder: (BuildContext context,
                              AsyncSnapshot<Emote?> snapshot) {
                            if (snapshot.hasData) {
                              //TODO: da tha emote
                              return TextButton(
                                child: _emoteText(snapshot.data!.emoteCode),
                                onPressed: () {
                                  setState(() {
                                    _showEmoteSelectionsBar = false;
                                  });
                                  deleteEmoteInComment();
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
                              );
                            }
                            //TODO: chua tha emote
                            return TextButton(
                              child: Text('Like',
                                  style: Theme.of(context).textTheme.button),
                              onPressed: () {
                                setState(() {
                                  _showEmoteSelectionsBar = false;
                                });
                                addEmoteToComment('LIKE');
                              },
                            );
                          },
                        ),
                        const Text('·'),
                        //TODO: reply button
                        TextButton(
                          onPressed: () {
                            if (widget.onReplyTap==null) {
                              //TODO: comment này có thể phản hồi
                              setState(() {
                                _showReplies = true;
                              });
                              _replyNode.requestFocus();
                            }else{
                              //TODO: focus vào _replyNode của comment mà comment này đang reply
                              widget.onReplyTap!();
                            }
                          },
                          child: Text('Phản hồi',
                              style: Theme.of(context).textTheme.button),
                        ),
                        const Text('·'),
                        //TODO: share button
                        TextButton(
                          onPressed: () {},
                          child: Text('Chia sẻ',
                              style: Theme.of(context).textTheme.button),
                        ),
                        const Text('·'),
                        //TODO: date
                        TextButton(
                          onPressed: () {
                            print('tap date');
                          },
                          child: Text(
                              Helper.timeToString(widget.comment.createdAt),
                              style: Theme.of(context).textTheme.button),
                        ),
                        const SizedBox(width: 10),
                        _emoteCounts(),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
                //TODO: emote selections bar
                if (_showEmoteSelectionsBar) _emoteSelectionsBar(),
              ],
            ),

            //TODO: replies / -> [Avatar] Thanh Do Vo da tra loi . 4 phan hoi 16 phut
            //TODO: _showReplies + input row
            if (_showReplies)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                //TODO: list phản hồi
                _listRepliesWithFilter(),
                //TODO: Xem thêm 3 phản hồi
                _viewMoreRepliesWidget(),
                //TODO: input row
                _inputRow(),
              ]),
          ],
        ),
      ],
    );
  }
}
