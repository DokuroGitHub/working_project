import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

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
  final Function? onReplyTap;

  @override
  createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> with TickerProviderStateMixin{
  bool _showReplies = false;
  static const _defaultLimitIncrease = 10;
  static const _defaultLimit = 3;
  int _limit = _defaultLimit;
  final FocusNode _replyNode = FocusNode();
  final TextEditingController _replyController = TextEditingController();

  //TODO: emotes components //start
  late AudioPlayer audioPlayer;

  int durationAnimationBox = 500;
  int durationAnimationBtnLongPress = 150;
  int durationAnimationBtnShortPress = 500;
  int durationAnimationIconWhenDrag = 150;
  int durationAnimationIconWhenRelease = 1000;

  // For long press btn
  late AnimationController animControlBtnLongPress, animControlBox;
  late Animation zoomIconLikeInBtn, tiltIconLikeInBtn, zoomTextLikeInBtn;
  late Animation fadeInBox;
  late Animation moveRightGroupIcon;
  late Animation pushIconLikeUp,
      pushIconLoveUp,
      pushIconHahaUp,
      pushIconWowUp,
      pushIconSadUp,
      pushIconAngryUp;
  late Animation zoomIconLike,
      zoomIconLove,
      zoomIconHaha,
      zoomIconWow,
      zoomIconSad,
      zoomIconAngry;

  // For short press btn
  late AnimationController animControlBtnShortPress;
  late Animation zoomIconLikeInBtn2, tiltIconLikeInBtn2;

  // For zoom icon when drag
  late AnimationController animControlIconWhenDrag;
  late AnimationController animControlIconWhenDragInside;
  late AnimationController animControlIconWhenDragOutside;
  late AnimationController animControlBoxWhenDragOutside;
  late Animation zoomIconChosen, zoomIconNotChosen;
  late Animation zoomIconWhenDragOutside;
  late Animation zoomIconWhenDragInside;
  late Animation zoomBoxWhenDragOutside;
  late Animation zoomBoxIcon;

  // For jump icon when release
  late AnimationController animControlIconWhenRelease;
  late Animation zoomIconWhenRelease, moveUpIconWhenRelease;
  late Animation moveLeftIconLikeWhenRelease,
      moveLeftIconLoveWhenRelease,
      moveLeftIconHahaWhenRelease,
      moveLeftIconWowWhenRelease,
      moveLeftIconSadWhenRelease,
      moveLeftIconAngryWhenRelease;

  Duration durationLongPress = const Duration(milliseconds: 250);
  late Timer holdTimer;
  bool isLongPress = false;
  //bool isLiked = false;

  // 0 = nothing, 1 = like, 2 = love, 3 = haha, 4 = wow, 5 = sad, 6 = angry
  int whichIconUserChoose = 0;

  // 0 = nothing, 1 = like, 2 = love, 3 = haha, 4 = wow, 5 = sad, 6 = angry
  int currentIconFocus = 0;
  int previousIconFocus = 0;
  bool isDragging = false;
  bool isDraggingOutside = false;
  bool isJustDragInside = true;
//TODO: emotes components //end

  @override
  void initState() {
    super.initState();

    //TODO: emote components
    audioPlayer = AudioPlayer();

    // Button Like
    initAnimationBtnLike();

    // Box and Icons
    initAnimationBoxAndIcons();

    // Icon when drag
    initAnimationIconWhenDrag();

    // Icon when drag outside
    initAnimationIconWhenDragOutside();

    // Box when drag outside
    initAnimationBoxWhenDragOutside();

    // Icon when first drag
    initAnimationIconWhenDragInside();

    // Icon when release
    initAnimationIconWhenRelease();
  }

  //TODO: emotes components init//start
  void initAnimationBtnLike() {
    // long press
    animControlBtnLongPress = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationAnimationBtnLongPress));
    zoomIconLikeInBtn =
        Tween(begin: 1.0, end: 0.85).animate(animControlBtnLongPress);
    tiltIconLikeInBtn =
        Tween(begin: 0.0, end: 0.2).animate(animControlBtnLongPress);
    zoomTextLikeInBtn =
        Tween(begin: 1.0, end: 0.85).animate(animControlBtnLongPress);

    zoomIconLikeInBtn.addListener(() {
      setState(() {});
    });
    tiltIconLikeInBtn.addListener(() {
      setState(() {});
    });
    zoomTextLikeInBtn.addListener(() {
      setState(() {});
    });

    // short press
    animControlBtnShortPress = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationAnimationBtnShortPress));
    zoomIconLikeInBtn2 =
        Tween(begin: 1.0, end: 0.2).animate(animControlBtnShortPress);
    tiltIconLikeInBtn2 =
        Tween(begin: 0.0, end: 0.8).animate(animControlBtnShortPress);

    zoomIconLikeInBtn2.addListener(() {
      setState(() {});
    });
    tiltIconLikeInBtn2.addListener(() {
      setState(() {});
    });
  }

  void initAnimationBoxAndIcons() {
    animControlBox = AnimationController(
        vsync: this, duration: Duration(milliseconds: durationAnimationBox));

    // General
    moveRightGroupIcon = Tween(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.0, 1.0)),
    );
    moveRightGroupIcon.addListener(() {
      setState(() {});
    });

    // Box
    fadeInBox = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.7, 1.0)),
    );
    fadeInBox.addListener(() {
      setState(() {});
    });

    // Icons
    pushIconLikeUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.0, 0.5)),
    );
    zoomIconLike = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.0, 0.5)),
    );

    pushIconLoveUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.1, 0.6)),
    );
    zoomIconLove = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.1, 0.6)),
    );

    pushIconHahaUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.2, 0.7)),
    );
    zoomIconHaha = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.2, 0.7)),
    );

    pushIconWowUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.3, 0.8)),
    );
    zoomIconWow = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.3, 0.8)),
    );

    pushIconSadUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.4, 0.9)),
    );
    zoomIconSad = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.4, 0.9)),
    );

    pushIconAngryUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.5, 1.0)),
    );
    zoomIconAngry = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.5, 1.0)),
    );

    pushIconLikeUp.addListener(() {
      setState(() {});
    });
    zoomIconLike.addListener(() {
      setState(() {});
    });
    pushIconLoveUp.addListener(() {
      setState(() {});
    });
    zoomIconLove.addListener(() {
      setState(() {});
    });
    pushIconHahaUp.addListener(() {
      setState(() {});
    });
    zoomIconHaha.addListener(() {
      setState(() {});
    });
    pushIconWowUp.addListener(() {
      setState(() {});
    });
    zoomIconWow.addListener(() {
      setState(() {});
    });
    pushIconSadUp.addListener(() {
      setState(() {});
    });
    zoomIconSad.addListener(() {
      setState(() {});
    });
    pushIconAngryUp.addListener(() {
      setState(() {});
    });
    zoomIconAngry.addListener(() {
      setState(() {});
    });
  }

  void initAnimationIconWhenDrag() {
    animControlIconWhenDrag = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationAnimationIconWhenDrag));

    zoomIconChosen =
        Tween(begin: 1.0, end: 1.8).animate(animControlIconWhenDrag);
    zoomIconNotChosen =
        Tween(begin: 1.0, end: 0.8).animate(animControlIconWhenDrag);
    zoomBoxIcon =
        Tween(begin: 50.0, end: 40.0).animate(animControlIconWhenDrag);

    zoomIconChosen.addListener(() {
      setState(() {});
    });
    zoomIconNotChosen.addListener(() {
      setState(() {});
    });
    zoomBoxIcon.addListener(() {
      setState(() {});
    });
  }

  void initAnimationIconWhenDragOutside() {
    animControlIconWhenDragOutside = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationAnimationIconWhenDrag));
    zoomIconWhenDragOutside =
        Tween(begin: 0.8, end: 1.0).animate(animControlIconWhenDragOutside);
    zoomIconWhenDragOutside.addListener(() {
      setState(() {});
    });
  }

  void initAnimationBoxWhenDragOutside() {
    animControlBoxWhenDragOutside = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationAnimationIconWhenDrag));
    zoomBoxWhenDragOutside =
        Tween(begin: 40.0, end: 50.0).animate(animControlBoxWhenDragOutside);
    zoomBoxWhenDragOutside.addListener(() {
      setState(() {});
    });
  }

  void initAnimationIconWhenDragInside() {
    animControlIconWhenDragInside = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationAnimationIconWhenDrag));
    zoomIconWhenDragInside =
        Tween(begin: 1.0, end: 0.8).animate(animControlIconWhenDragInside);
    zoomIconWhenDragInside.addListener(() {
      setState(() {});
    });
    animControlIconWhenDragInside.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isJustDragInside = false;
      }
    });
  }

  void initAnimationIconWhenRelease() {
    animControlIconWhenRelease = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationAnimationIconWhenRelease));

    zoomIconWhenRelease = Tween(begin: 1.8, end: 0.0).animate(CurvedAnimation(
        parent: animControlIconWhenRelease, curve: Curves.decelerate));

    moveUpIconWhenRelease = Tween(begin: 180.0, end: 50.0).animate(
        CurvedAnimation(
            parent: animControlIconWhenRelease, curve: Curves.decelerate));

    moveLeftIconLikeWhenRelease = Tween(begin: 20.0, end: 10.0).animate(
        CurvedAnimation(
            parent: animControlIconWhenRelease, curve: Curves.decelerate));
    moveLeftIconLoveWhenRelease = Tween(begin: 68.0, end: 10.0).animate(
        CurvedAnimation(
            parent: animControlIconWhenRelease, curve: Curves.decelerate));
    moveLeftIconHahaWhenRelease = Tween(begin: 116.0, end: 10.0).animate(
        CurvedAnimation(
            parent: animControlIconWhenRelease, curve: Curves.decelerate));
    moveLeftIconWowWhenRelease = Tween(begin: 164.0, end: 10.0).animate(
        CurvedAnimation(
            parent: animControlIconWhenRelease, curve: Curves.decelerate));
    moveLeftIconSadWhenRelease = Tween(begin: 212.0, end: 10.0).animate(
        CurvedAnimation(
            parent: animControlIconWhenRelease, curve: Curves.decelerate));
    moveLeftIconAngryWhenRelease = Tween(begin: 260.0, end: 10.0).animate(
        CurvedAnimation(
            parent: animControlIconWhenRelease, curve: Curves.decelerate));

    zoomIconWhenRelease.addListener(() {
      setState(() {});
    });
    moveUpIconWhenRelease.addListener(() {
      setState(() {});
    });

    moveLeftIconLikeWhenRelease.addListener(() {
      setState(() {});
    });
    moveLeftIconLoveWhenRelease.addListener(() {
      setState(() {});
    });
    moveLeftIconHahaWhenRelease.addListener(() {
      setState(() {});
    });
    moveLeftIconWowWhenRelease.addListener(() {
      setState(() {});
    });
    moveLeftIconSadWhenRelease.addListener(() {
      setState(() {});
    });
    moveLeftIconAngryWhenRelease.addListener(() {
      setState(() {});
    });
  }
  //TODO: emotes components init//end

  @override
  void dispose() {
    _replyNode.dispose();
    _replyController.dispose();

    //TODO: emote components
    animControlBtnLongPress.dispose();
    animControlBox.dispose();
    animControlIconWhenDrag.dispose();
    animControlIconWhenDragInside.dispose();
    animControlIconWhenDragOutside.dispose();
    animControlBoxWhenDragOutside.dispose();
    animControlIconWhenRelease.dispose();

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
          replyForCommentDocumentPath: widget.comment.documentPath!,
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

  Future<void> addEmoteToComment(int emoteInt) async {
    String emoteCode = _emoteIntToCode(emoteInt);
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

  Future<void> _deleteComment() async {
    try {
      await DatabaseService().deleteComment(widget.comment.documentPath!);
      final snackBar = SnackBar(
        content: const Text('Deleted comment successfully!'),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }catch(e){
      print('comment_item, _deleteComment, error: $e');
      final snackBar = SnackBar(
        content: const Text('Deleted failed!'),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _confirmDelete() async {
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(children: [
              const Text('Xóa bình luận?'),
              const Spacer(),
              IconButton(onPressed: (){
                Navigator.pop(context);
              }, icon: const Icon(Icons.cancel)),
            ],),
            content: const Text('Bạn có chắc chắn muốn xóa bình luận này không?'),
            actions: [
              TextButton(
                onPressed: () {
                  //TODO: Cancel
                  Navigator.pop(context);
                },
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  //TODO: delete
                  _deleteComment();
                },
                child: const Text('Xóa'),
              ),
            ],
          );
        });
  }

  Future<void> _on3dotsClick() async {
    //TODO: check if i created this comment
    if(widget.comment.createdBy==widget.myUser.id!){
      //TODO: this is my comment, edit/delete
      await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text('Chọn thao tác'),
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    //TODO: edit

                  },
                  child: const Text('Chỉnh sửa'),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    //TODO: delete, confirm
                    _confirmDelete();
                  },
                  child: const Text('Xóa'),
                ),
              ],
            );
          });
    }else{
      //TODO: not my comment, report/hide
      await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text('Chọn thao tác'),
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () {
                    //TODO: report

                    Navigator.pop(context);
                  },
                  child: const Text('Report'),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    //TODO: hide

                    Navigator.pop(context);
                  },
                  child: const Text('Hide'),
                ),
              ],
            );
          });
    }
  }

  Future<void> _setNameTag(String replyToMyUserid) async {
    String text = _replyController.text;
    text = text.replaceAll(RegExp(r'(?=@).*? (?<=, )'), '');
    if(text.trim().isEmpty) {
      MyUser? myUser = await DatabaseService().getMyUserByDocumentId(replyToMyUserid);
      String? name = myUser?.name;
      setState(() {
        _replyController.text = '@$name, ';
      });
    }
  }

  //bool _showEmoteSelectionsBar = false;

  //TODO: emote components-------------------------------
  Widget renderBtnLike(Emote? emote) {
    int emoteInt = _emoteCodeToInt(emote?.emoteCode??'');
    return GestureDetector(
      onTapDown: onTapDownBtn,
      onTapUp: (TapUpDetails tapUpDetails)=>onTapUpBtn(tapUpDetails, emoteInt:emoteInt),
      //onTap: ()=>onTapBtn(emoteInt),
      child: TextButton(
        onPressed: () => onTapBtn(emoteInt),
        child: _emoteText(emoteInt),
      ),
    );
  }

  String _emoteIntToImageLink(int emoteInt) {
    switch (emoteInt) {
      case 1:
        return 'assets/images/emotes/ic_like_fill2.png';
      case 2:
        return 'assets/images/emotes/love2.png';
      case 3:
        return 'assets/images/emotes/haha2.png';
      case 4:
        return 'assets/images/emotes/wow2.png';
      case 5:
        return 'assets/images/emotes/sad2.png';
      case 6:
        return 'assets/images/emotes/angry2.png';
      default:
        return 'assets/images/emotes/ic_like2.png';
    }
  }

  //TODO: chua chac co nen truyen onPress hay ko
  Widget _emoteText(int emoteInt) {
    switch (emoteInt) {
      case 1:
        return const Text('Like', style: TextStyle(color: Colors.blue));
      case 2:
        return const Text('Love', style: TextStyle(color: Color(0xffED5167)));
      case 3:
        return const Text('Haha', style: TextStyle(color: Color(0xffFFD96A)));
      case 4:
        return const Text('Wow', style: TextStyle(color: Color(0xffFFD96A)));
      case 5:
        return const Text('Sad', style: TextStyle(color: Color(0xffFFD96A)));
      case 6:
        return const Text('Angry', style: TextStyle(color: Color(0xffF6876B)));
      default:
        return Text('Like', style: TextStyle(color: Theme.of(context).textTheme.button?.color));
    }
  }

  Widget renderBox() {
    return Opacity(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(color: Colors.grey.shade300, width: 0.3),
          boxShadow: [
            BoxShadow(
                color: Colors.grey,
                blurRadius: 5.0,
                // LTRB
                offset: Offset.lerp(
                    const Offset(0.0, 0.0), const Offset(0.0, 0.5), 10.0)!),
          ],
        ),
        width: 300.0,
        height: isDragging
            ? (previousIconFocus == 0 ? zoomBoxIcon.value as double : 40.0)
            : isDraggingOutside
            ? zoomBoxWhenDragOutside.value as double
            : 50.0,
        margin: const EdgeInsets.only(bottom: 67.0, left: 10.0),
      ),
      opacity: fadeInBox.value as double,
    );
  }

  Widget renderIcons() {
    return Container(
      child: Row(
        children: <Widget>[
          // icon like
          Transform.scale(
            child: Container(
              child: Column(
                children: <Widget>[
                  currentIconFocus == 1
                      ? Container(
                    child: const Text(
                      'Like',
                      style:
                      TextStyle(fontSize: 8.0, color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.black.withOpacity(0.3),
                    ),
                    padding: const EdgeInsets.only(
                        left: 7.0, right: 7.0, top: 2.0, bottom: 2.0),
                    margin: const EdgeInsets.only(bottom: 8.0),
                  )
                      : Container(),
                  Image.asset(
                    'assets/images/emotes/like.gif',
                    width: 40.0,
                    height: 40.0,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: pushIconLikeUp.value as double),
              width: 40.0,
              height: currentIconFocus == 1 ? 70.0 : 40.0,
            ),
            scale: isDragging
                ? (currentIconFocus == 1
                ? zoomIconChosen.value as double
                : (previousIconFocus == 1
                ? zoomIconNotChosen.value as double
                : isJustDragInside
                ? zoomIconWhenDragInside.value as double
                : 0.8))
                : isDraggingOutside
                ? zoomIconWhenDragOutside.value as double
                : zoomIconLike.value as double,
          ),

          // icon love
          Transform.scale(
            child: Container(
              child: Column(
                children: <Widget>[
                  currentIconFocus == 2
                      ? Container(
                    child: const Text(
                      'Love',
                      style:
                      TextStyle(fontSize: 8.0, color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.black.withOpacity(0.3)),
                    padding: const EdgeInsets.only(
                        left: 7.0, right: 7.0, top: 2.0, bottom: 2.0),
                    margin: const EdgeInsets.only(bottom: 8.0),
                  )
                      : Container(),
                  Image.asset(
                    'assets/images/emotes/love.gif',
                    width: 40.0,
                    height: 40.0,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: pushIconLoveUp.value as double),
              width: 40.0,
              height: currentIconFocus == 2 ? 70.0 : 40.0,
            ),
            scale: isDragging
                ? (currentIconFocus == 2
                ? zoomIconChosen.value as double
                : (previousIconFocus == 2
                ? zoomIconNotChosen.value as double
                : isJustDragInside
                ? zoomIconWhenDragInside.value as double
                : 0.8))
                : isDraggingOutside
                ? zoomIconWhenDragOutside.value as double
                : zoomIconLove.value as double,
          ),

          // icon haha
          Transform.scale(
            child: Container(
              child: Column(
                children: <Widget>[
                  currentIconFocus == 3
                      ? Container(
                    child: const Text(
                      'Haha',
                      style:
                      TextStyle(fontSize: 8.0, color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.black.withOpacity(0.3)),
                    padding: const EdgeInsets.only(
                        left: 7.0, right: 7.0, top: 2.0, bottom: 2.0),
                    margin: const EdgeInsets.only(bottom: 8.0),
                  )
                      : Container(),
                  Image.asset(
                    'assets/images/emotes/haha.gif',
                    width: 40.0,
                    height: 40.0,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: pushIconHahaUp.value as double),
              width: 40.0,
              height: currentIconFocus == 3 ? 70.0 : 40.0,
            ),
            scale: isDragging
                ? (currentIconFocus == 3
                ? zoomIconChosen.value as double
                : (previousIconFocus == 3
                ? zoomIconNotChosen.value as double
                : isJustDragInside
                ? zoomIconWhenDragInside.value as double
                : 0.8))
                : isDraggingOutside
                ? zoomIconWhenDragOutside.value as double
                : zoomIconHaha.value as double,
          ),

          // icon wow
          Transform.scale(
            child: Container(
              child: Column(
                children: <Widget>[
                  currentIconFocus == 4
                      ? Container(
                    child: const Text(
                      'Wow',
                      style:
                      TextStyle(fontSize: 8.0, color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.black.withOpacity(0.3)),
                    padding: const EdgeInsets.only(
                        left: 7.0, right: 7.0, top: 2.0, bottom: 2.0),
                    margin: const EdgeInsets.only(bottom: 8.0),
                  )
                      : Container(),
                  Image.asset(
                    'assets/images/emotes/wow.gif',
                    width: 40.0,
                    height: 40.0,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: pushIconWowUp.value as double),
              width: 40.0,
              height: currentIconFocus == 4 ? 70.0 : 40.0,
            ),
            scale: isDragging
                ? (currentIconFocus == 4
                ? zoomIconChosen.value as double
                : (previousIconFocus == 4
                ? zoomIconNotChosen.value as double
                : isJustDragInside
                ? zoomIconWhenDragInside.value as double
                : 0.8))
                : isDraggingOutside
                ? zoomIconWhenDragOutside.value as double
                : zoomIconWow.value as double,
          ),

          // icon sad
          Transform.scale(
            child: Container(
              child: Column(
                children: <Widget>[
                  currentIconFocus == 5
                      ? Container(
                    child: const Text(
                      'Sad',
                      style:
                      TextStyle(fontSize: 8.0, color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.black.withOpacity(0.3),
                    ),
                    padding: const EdgeInsets.only(
                        left: 7.0, right: 7.0, top: 2.0, bottom: 2.0),
                    margin: const EdgeInsets.only(bottom: 8.0),
                  )
                      : Container(),
                  Image.asset(
                    'assets/images/emotes/sad.gif',
                    width: 40.0,
                    height: 40.0,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: pushIconSadUp.value as double),
              width: 40.0,
              height: currentIconFocus == 5 ? 70.0 : 40.0,
            ),
            scale: isDragging
                ? (currentIconFocus == 5
                ? zoomIconChosen.value as double
                : (previousIconFocus == 5
                ? zoomIconNotChosen.value as double
                : isJustDragInside
                ? zoomIconWhenDragInside.value as double
                : 0.8))
                : isDraggingOutside
                ? zoomIconWhenDragOutside.value as double
                : zoomIconSad.value as double,
          ),

          // icon angry
          Transform.scale(
            child: Container(
              child: Column(
                children: <Widget>[
                  currentIconFocus == 6
                      ? Container(
                    child: const Text(
                      'Angry',
                      style:
                      TextStyle(fontSize: 8.0, color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.black.withOpacity(0.3),
                    ),
                    padding: const EdgeInsets.only(
                        left: 7.0, right: 7.0, top: 2.0, bottom: 2.0),
                    margin: const EdgeInsets.only(bottom: 8.0),
                  )
                      : Container(),
                  Image.asset(
                    'assets/images/emotes/angry.gif',
                    width: 40.0,
                    height: 40.0,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: pushIconAngryUp.value as double),
              width: 40.0,
              height: currentIconFocus == 6 ? 70.0 : 40.0,
            ),
            scale: isDragging
                ? (currentIconFocus == 6
                ? zoomIconChosen.value as double
                : (previousIconFocus == 6
                ? zoomIconNotChosen.value as double
                : isJustDragInside
                ? zoomIconWhenDragInside.value as double
                : 0.8))
                : isDraggingOutside
                ? zoomIconWhenDragOutside.value as double
                : zoomIconAngry.value as double,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      width: 300.0,
      height: 123.0,
      margin:
      EdgeInsets.only(left: moveRightGroupIcon.value as double, top: 50.0),
      // uncomment here to see area of draggable
      //color: Colors.amber.withOpacity(0.5),
    );
  }

  int _emoteCodeToInt(String emoteCode){
    switch (emoteCode) {
      case 'LIKE':
        return 1;
      case 'LOVE':
        return 2;
      case 'HAHA':
        return 3;
      case 'WOW':
        return 4;
      case 'SAD':
        return 5;
      case 'ANGRY':
        return 6;
      default:
        return 0;
    }
  }

  String _emoteIntToCode(int emoteInt){
    switch (emoteInt) {
      case 1:
        return 'LIKE';
      case 2:
        return 'LOVE';
      case 3:
        return 'HAHA';
      case 4:
        return 'WOW';
      case 5:
        return 'SAD';
      case 6:
        return 'ANGRY';
      default:
        return '';
    }
  }

  double processTopPosition(double value) {
    // margin top 100 -> 40 -> 160 (value from 180 -> 0)
    if (value >= 120.0) {
      return value - 80.0;
    } else {
      return 160.0 - value;
    }
  }

  void onHorizontalDragEndBoxIcon(DragEndDetails dragEndDetail) {
    isDragging = false;
    isDraggingOutside = false;
    isJustDragInside = true;
    previousIconFocus = 0;
    currentIconFocus = 0;

    onTapUpBtn(null);
  }

  void onHorizontalDragUpdateBoxIcon(DragUpdateDetails dragUpdateDetail) {
    // return if the drag is drag without press button
    if (!isLongPress) return;

    // the margin top the box is 150
    // and plus the height of toolbar and the status bar
    // so the range we check is about 200 -> 500

    if (dragUpdateDetail.localPosition.dy >= 0 &&
        dragUpdateDetail.localPosition.dy <= 250) {
      isDragging = true;
      isDraggingOutside = false;

      if (isJustDragInside && !animControlIconWhenDragInside.isAnimating) {
        animControlIconWhenDragInside.reset();
        animControlIconWhenDragInside.forward();
      }

      if (dragUpdateDetail.globalPosition.dx >= 20 &&
          dragUpdateDetail.globalPosition.dx < 83) {
        if (currentIconFocus != 1) {
          handleWhenDragBetweenIcon(1);
        }
      } else if (dragUpdateDetail.globalPosition.dx >= 83 &&
          dragUpdateDetail.globalPosition.dx < 126) {
        if (currentIconFocus != 2) {
          handleWhenDragBetweenIcon(2);
        }
      } else if (dragUpdateDetail.globalPosition.dx >= 126 &&
          dragUpdateDetail.globalPosition.dx < 180) {
        if (currentIconFocus != 3) {
          handleWhenDragBetweenIcon(3);
        }
      } else if (dragUpdateDetail.globalPosition.dx >= 180 &&
          dragUpdateDetail.globalPosition.dx < 233) {
        if (currentIconFocus != 4) {
          handleWhenDragBetweenIcon(4);
        }
      } else if (dragUpdateDetail.globalPosition.dx >= 233 &&
          dragUpdateDetail.globalPosition.dx < 286) {
        if (currentIconFocus != 5) {
          handleWhenDragBetweenIcon(5);
        }
      } else if (dragUpdateDetail.globalPosition.dx >= 286 &&
          dragUpdateDetail.globalPosition.dx < 340) {
        if (currentIconFocus != 6) {
          handleWhenDragBetweenIcon(6);
        }
      }
    } else {
      whichIconUserChoose = 0;
      previousIconFocus = 0;
      currentIconFocus = 0;
      isJustDragInside = true;

      if (isDragging && !isDraggingOutside) {
        isDragging = false;
        isDraggingOutside = true;
        animControlIconWhenDragOutside.reset();
        animControlIconWhenDragOutside.forward();
        animControlBoxWhenDragOutside.reset();
        animControlBoxWhenDragOutside.forward();
      }
    }
  }

  void handleWhenDragBetweenIcon(int currentIcon) {
    playSound('icon_focus.mp3');
    whichIconUserChoose = currentIcon;
    previousIconFocus = currentIconFocus;
    currentIconFocus = currentIcon;
    animControlIconWhenDrag.reset();
    animControlIconWhenDrag.forward();
  }

  void onTapDownBtn(TapDownDetails tapDownDetail) {
    holdTimer = Timer(durationLongPress, showBox);
  }

  void onTapUpBtn(TapUpDetails? tapUpDetail, {int emoteInt=0}) {
    if(whichIconUserChoose!=0){
      addEmoteToComment(whichIconUserChoose);
    }

    if (isLongPress) {
      if (emoteInt == 0) {
        playSound('box_down.mp3');
      } else {
        playSound('icon_choose.mp3');
      }
    }

    Timer(Duration(milliseconds: durationAnimationBox), () {
      isLongPress = false;
    });

    holdTimer.cancel();

    animControlBtnLongPress.reverse();

    setReverseValue();
    animControlBox.reverse();

    animControlIconWhenRelease.reset();
    animControlIconWhenRelease.forward();
  }

  // when user short press the button
  void onTapBtn(int emoteInt) {
    if (!isLongPress) {
      //TODO: chi khi pure onTap
      whichIconUserChoose = 0;
      if (emoteInt==0) {
        //TODO: chua co emote nao nen add
        addEmoteToComment(1);
        playSound('short_press_like.mp3');
        animControlBtnShortPress.forward();
      } else {
        //TODO: da co emote nen delete
        deleteEmoteInComment();
        animControlBtnShortPress.reverse();
      }
    }
  }

  double handleOutputRangeZoomInIconLike(double value) {
    if (value >= 0.8) {
      return value;
    } else if (value >= 0.4) {
      return 1.6 - value;
    } else {
      return 0.8 + value;
    }
  }

  double handleOutputRangeTiltIconLike(double value) {
    if (value <= 0.2) {
      return value;
    } else if (value <= 0.6) {
      return 0.4 - value;
    } else {
      return -(0.8 - value);
    }
  }

  void showBox() {
    playSound('box_up.mp3');
    isLongPress = true;

    animControlBtnLongPress.forward();

    setForwardValue();
    animControlBox.forward();
  }

  // We need to set the value for reverse because if not
  // the angry-icon will be pulled down first, not the like-icon
  void setReverseValue() {
    // Icons
    pushIconLikeUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.5, 1.0)),
    );
    zoomIconLike = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.5, 1.0)),
    );

    pushIconLoveUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.4, 0.9)),
    );
    zoomIconLove = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.4, 0.9)),
    );

    pushIconHahaUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.3, 0.8)),
    );
    zoomIconHaha = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.3, 0.8)),
    );

    pushIconWowUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.2, 0.7)),
    );
    zoomIconWow = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.2, 0.7)),
    );

    pushIconSadUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.1, 0.6)),
    );
    zoomIconSad = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.1, 0.6)),
    );

    pushIconAngryUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.0, 0.5)),
    );
    zoomIconAngry = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.0, 0.5)),
    );
  }

  // When set the reverse value, we need set value to normal for the forward
  void setForwardValue() {
    // Icons
    pushIconLikeUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.0, 0.5)),
    );
    zoomIconLike = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.0, 0.5)),
    );

    pushIconLoveUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.1, 0.6)),
    );
    zoomIconLove = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.1, 0.6)),
    );

    pushIconHahaUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.2, 0.7)),
    );
    zoomIconHaha = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.2, 0.7)),
    );

    pushIconWowUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.3, 0.8)),
    );
    zoomIconWow = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.3, 0.8)),
    );

    pushIconSadUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.4, 0.9)),
    );
    zoomIconSad = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.4, 0.9)),
    );

    pushIconAngryUp = Tween(begin: 30.0, end: 60.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.5, 1.0)),
    );
    zoomIconAngry = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: const Interval(0.5, 1.0)),
    );
  }

  Future playSound(String nameSound) async {
    // Sometimes multiple sound will play the same time, so we'll stop all before play the newest
    await audioPlayer.stop();
    final file = File('${(await getTemporaryDirectory()).path}/$nameSound');
    await file.writeAsBytes((await loadAsset(nameSound)).buffer.asUint8List());
    await audioPlayer.play(file.path, isLocal: true);
  }

  Future<ByteData> loadAsset(String nameSound) async {
    return await rootBundle.load('assets/sounds/emotes/$nameSound');
  }

  Widget _emoteCounts2(){
    return StreamBuilder(
      stream: DatabaseService().getStreamListEmoteInComment(
          commentDocumentPath: widget.comment.documentPath!),
      builder: (BuildContext context, AsyncSnapshot<List<Emote>> snapshot) {
        if (snapshot.hasData) {
          //TODO: 0 = nothing, 1 = like, 2 = love, 3 = haha, 4 = wow, 5 = sad, 6 = angry
          List<Emote> emotes = snapshot.data!;
          List<Emote> like1s = [];
          List<Emote> love2s = [];
          List<Emote> haha3s = [];
          List<Emote> wow4s = [];
          List<Emote> sad5s = [];
          List<Emote> angry6s = [];
          for (var element in emotes) {
            switch (_emoteCodeToInt(element.emoteCode)) {
              case 1:
                like1s.add(element);
                break;
              case 2:
                love2s.add(element);
                break;
              case 3:
                haha3s.add(element);
                break;
              case 4:
                wow4s.add(element);
                break;
              case 5:
                sad5s.add(element);
                break;
              case 6:
                angry6s.add(element);
                break;
              default:
                break;
            }
          }
          List<Widget> rowItems = [];
          rowItems.add(const SizedBox(width: 5));
          if (like1s.isNotEmpty) {
            rowItems.add(Image.asset(_emoteIntToImageLink(1),
              semanticLabel: like1s.length.toString(),
              width: 20.0,
              height: 20.0,
              fit: BoxFit.contain,
            ));
            //rowItems.add(Icon(Icons.thumb_up_alt_rounded, color: Colors.blue, semanticLabel: likes.length.toString()));
            rowItems.add(const SizedBox(width: 5));
          }
          if (love2s.isNotEmpty) {
            rowItems.add(Image.asset(_emoteIntToImageLink(2),
              semanticLabel: love2s.length.toString(),
              width: 20.0,
              height: 20.0,
              fit: BoxFit.contain,
            ));
            //rowItems.add(Icon(Icons.favorite_rounded, color: Colors.red, semanticLabel: loves.length.toString()));
            rowItems.add(const SizedBox(width: 5));
          }
          if (haha3s.isNotEmpty) {
            rowItems.add(Image.asset(_emoteIntToImageLink(3),
              semanticLabel: haha3s.length.toString(),
              width: 20.0,
              height: 20.0,
              fit: BoxFit.contain,
            ));
            //rowItems.add(Icon(Icons.tag_faces_rounded, color: Colors.yellow, semanticLabel: hahas.length.toString()));
            rowItems.add(const SizedBox(width: 5));
          }
          if (wow4s.isNotEmpty) {
            rowItems.add(Image.asset(_emoteIntToImageLink(4),
              semanticLabel: wow4s.length.toString(),
              width: 20.0,
              height: 20.0,
              fit: BoxFit.contain,
            ));
            //rowItems.add(Icon(Icons.tag_faces_rounded,color: Colors.yellow, semanticLabel: wows.length.toString()));
            rowItems.add(const SizedBox(width: 5));
          }
          if (sad5s.isNotEmpty) {
            rowItems.add(Image.asset(_emoteIntToImageLink(5),
              semanticLabel: sad5s.length.toString(),
              width: 20.0,
              height: 20.0,
              fit: BoxFit.contain,
            ));
            //rowItems.add(Icon(Icons.tag_faces_rounded,color: Colors.yellow,semanticLabel: sads.length.toString()));
            rowItems.add(const SizedBox(width: 5));
          }
          if (angry6s.isNotEmpty) {
            rowItems.add(Image.asset(_emoteIntToImageLink(6),
              semanticLabel: angry6s.length.toString(),
              width: 20.0,
              height: 20.0,
              fit: BoxFit.contain,
            ));
            //rowItems.add(Icon(Icons.tag_faces_rounded,color: Colors.red, semanticLabel: angries.length.toString()));
            rowItems.add(const SizedBox(width: 5));
          }
          rowItems.add(const SizedBox(width: 10));

          if (emotes.isNotEmpty) {
            rowItems.add(Text(emotes.length.toString()));
            return Row(mainAxisSize:MainAxisSize.min,children: rowItems);
          }
        }
        return Container();
      },
    );
  }

  // Widget _emoteCounts() {
  //   return StreamBuilder(
  //     stream: DatabaseService().getStreamListEmoteInComment(
  //         commentDocumentPath: widget.comment.documentPath!),
  //     builder: (BuildContext context, AsyncSnapshot<List<Emote>> snapshot) {
  //       if (snapshot.hasData) {
  //         List<Emote> emotes = snapshot.data!;
  //         if (emotes.isNotEmpty) {
  //           List<Emote> likes = [];
  //           List<Emote> hearts = [];
  //           List<Emote> hahas = [];
  //           List<Emote> angries = [];
  //           for (var element in emotes) {
  //             switch (element.emoteCode) {
  //               case 'LIKE':
  //                 likes.add(element);
  //                 break;
  //               case 'HEART':
  //                 hearts.add(element);
  //                 break;
  //               case 'HAHA':
  //                 hahas.add(element);
  //                 break;
  //               case 'ANGRY':
  //                 angries.add(element);
  //                 break;
  //               default:
  //                 break;
  //             }
  //           }
  //           List<Widget> rowItems = [];
  //           if (likes.isNotEmpty) {
  //             rowItems.add(Icon(Icons.thumb_up_alt_rounded,
  //                 color: Colors.blue, semanticLabel: likes.length.toString()));
  //           }
  //           if (hearts.isNotEmpty) {
  //             rowItems.add(Icon(Icons.favorite_rounded,
  //                 color: Colors.red, semanticLabel: hearts.length.toString()));
  //           }
  //           if (hahas.isNotEmpty) {
  //             rowItems.add(Icon(Icons.tag_faces_rounded,
  //                 color: Colors.yellow,
  //                 semanticLabel: hahas.length.toString()));
  //           }
  //           if (angries.isNotEmpty) {
  //             rowItems.add(Icon(Icons.tag_faces_rounded,
  //                 color: Colors.red, semanticLabel: angries.length.toString()));
  //           }
  //           rowItems.add(const SizedBox(width: 2));
  //
  //           rowItems.add(Text(emotes.length.toString()));
  //           return Row(mainAxisSize: MainAxisSize.min, children: rowItems);
  //         }
  //       }
  //       return Container();
  //     },
  //   );
  // }

  //TODO: working-------------------------------

  Widget _listRepliesWithFilter() {
    return StreamBuilder(
      stream: DatabaseService().getStreamListCommentInComment(
          widget.comment.documentPath!,
          limit: _limit),
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
                  onReplyTap: (String myUserId) async {
                    //TODO: focus to this reply node
                    print('onReplyTap, comment này ko thể reply thêm nhánh');
                    await _setNameTag(myUserId);
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
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 90),
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

  // Widget _emoteSelectionsBar() {
  //   return Row(
  //     children: [
  //       IconButton(
  //         onPressed: () {
  //           setState(() {
  //             _showEmoteSelectionsBar = false;
  //           });
  //           addEmoteToComment('LIKE');
  //         },
  //         icon: const Icon(
  //           Icons.thumb_up_alt_rounded,
  //           color: Colors.blue,
  //           size: 40,
  //         ),
  //       ),
  //       IconButton(
  //         onPressed: () {
  //           setState(() {
  //             _showEmoteSelectionsBar = false;
  //           });
  //           addEmoteToComment('HEART');
  //         },
  //         icon: const Icon(
  //           Icons.favorite_rounded,
  //           color: Colors.red,
  //           size: 40,
  //         ),
  //       ),
  //       IconButton(
  //         onPressed: () {
  //           setState(() {
  //             _showEmoteSelectionsBar = false;
  //           });
  //           addEmoteToComment('HAHA');
  //         },
  //         icon: const Icon(
  //           Icons.tag_faces_rounded,
  //           color: Colors.yellow,
  //           size: 40,
  //         ),
  //       ),
  //       IconButton(
  //         onPressed: () {
  //           setState(() {
  //             _showEmoteSelectionsBar = false;
  //           });
  //           addEmoteToComment('ANGRY');
  //         },
  //         icon: const Icon(
  //           Icons.tag_faces_rounded,
  //           color: Colors.red,
  //           size: 40,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _repliesCountWidget() {
    return StreamBuilder(
      stream: DatabaseService()
          .getStreamListCommentInComment(widget.comment.documentPath!),
      builder: (BuildContext context, AsyncSnapshot<List<Comment>> snapshot) {
        if (snapshot.hasData) {
          num length = snapshot.data!.length;
          if(length>0) {
            return TextButton.icon(
              onPressed: () {
                  setState(() {
                    _showReplies = true;
                  });
                  },
              icon: const Icon(Icons.subdirectory_arrow_right),
              label: Text('$length phản hồi'),
            );
          }
        }
        return Container();
      },
    );
  }

  Widget _viewMoreRepliesWidget() {
    return StreamBuilder(
      stream: DatabaseService()
          .getStreamListCommentInComment(widget.comment.documentPath!),
      builder: (BuildContext context, AsyncSnapshot<List<Comment>> snapshot) {
        if (snapshot.hasData) {
          num length = snapshot.data!.length;
          num gap = length - _limit;
          if (gap > 0) {
            //TODO: Xem thêm 3 phản hồi
            return TextButton(
                onPressed: () {
                  setState(() {
                    _limit += _defaultLimitIncrease;
                  });
                },
                child: Text('Xem thêm $gap phản hồi'));
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
                            onPressed: _on3dotsClick,
                            icon: const Icon(Icons.more_horiz)),
                        //const Spacer(),
                      ],
                    ),

                    //TODO: attachments + emote counts
                    SizedBox(
                      width: MediaQuery.of(context).size.width-142,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                          children:[
                            //TODO: attachments
                            // SizedBox(width: 200),
                            const Spacer(),
                            _emoteCounts2(),
                       ]),
                    ),
                    // //TODO: like+comment+share+date+emoteCounts
                    // Row(
                    //   mainAxisSize: MainAxisSize.min,
                    //   children: [
                    //     //TODO: like button
                    //     //TODO:------can thay = emote button moi--------
                    //     StreamBuilder(
                    //       stream: DatabaseService().getStreamEmoteInComment(
                    //           commentDocumentPath: widget.comment.documentPath!,
                    //           myUserId: widget.myUser.id!),
                    //       builder: (BuildContext context,
                    //           AsyncSnapshot<Emote?> snapshot) {
                    //         // if (snapshot.hasData) {
                    //         //   //TODO: da tha emote
                    //         //   return renderBtnLike(snapshot.data!);
                    //         //   // return TextButton(
                    //         //   //   child: _emoteText(snapshot.data!.emoteCode),
                    //         //   //   onPressed: () {
                    //         //   //     setState(() {
                    //         //   //       _showEmoteSelectionsBar = false;
                    //         //   //     });
                    //         //   //     deleteEmoteInComment();
                    //         //   //   },
                    //         //   //   onLongPress: () {
                    //         //   //     setState(() {
                    //         //   //       _showEmoteSelectionsBar = true;
                    //         //   //     });
                    //         //   //     Future.delayed(const Duration(seconds: 3),
                    //         //   //         () {
                    //         //   //       setState(() {
                    //         //   //         _showEmoteSelectionsBar = false;
                    //         //   //       });
                    //         //   //     });
                    //         //   //   },
                    //         //   // );
                    //         // }
                    //         //TODO: chua tha emote
                    //         return renderBtnLike(snapshot.data);
                    //         // return TextButton(
                    //         //   child: Text('Like',
                    //         //       style: Theme.of(context).textTheme.button),
                    //         //   onPressed: () {
                    //         //     setState(() {
                    //         //       _showEmoteSelectionsBar = false;
                    //         //     });
                    //         //     addEmoteToComment('LIKE');
                    //         //   },
                    //         // );
                    //       },
                    //     ),
                    //     const Text('·'),
                    //     //TODO: reply button
                    //     TextButton(
                    //       onPressed: () async {
                    //         if (widget.onReplyTap == null) {
                    //           //TODO: comment này có thể phản hồi
                    //           setState(() {
                    //             _showReplies = true;
                    //           });
                    //           await _setNameTag(widget.comment.createdBy);
                    //           _replyNode.requestFocus();
                    //         } else {
                    //           //TODO: setNameTag bằng createdBy của comment này
                    //           //TODO: focus vào _replyNode của comment mà comment này đang reply
                    //           widget.onReplyTap!(widget.comment.createdBy);
                    //         }
                    //       },
                    //       child: Text('Phản hồi',
                    //           style: Theme.of(context).textTheme.button),
                    //     ),
                    //     const Text('·'),
                    //     //TODO: share button
                    //     TextButton(
                    //       onPressed: () {},
                    //       child: Text('Chia sẻ',
                    //           style: Theme.of(context).textTheme.button),
                    //     ),
                    //     const Text('·'),
                    //     //TODO: date
                    //     TextButton(
                    //       onPressed: () {
                    //         print('tap date');
                    //       },
                    //       child: Text(
                    //           Helper.timeToString(widget.comment.createdAt),
                    //           style: Theme.of(context).textTheme.button),
                    //     ),
                    //     //const SizedBox(width: 10),
                    //     //_emoteCounts(),
                    //     //const SizedBox(width: 10),
                    //   ],
                    // ),

                    const SizedBox(height: 50.0),
                  ],
                ),

                //TODO: Box background + emotes
                Positioned(
                  bottom: 0,
                  child: Stack(
                    children: <Widget>[
                      // Box
                      renderBox(),

                      // Icons
                      renderIcons(),
                    ],
                    alignment: Alignment.bottomCenter,
                  ),
                ),

                //TODO: like+comment+share+date+emoteCounts
                Positioned(left:0, bottom: 0, child: Stack(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width-123,
                      height: 160,
                      child: GestureDetector(
                    child: Column(
                        children:[
                          const Spacer(),
                          //TODO: like+comment+share+date+emoteCounts
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              //TODO: like button
                              StreamBuilder(
                                stream: DatabaseService().getStreamEmoteInComment(
                                    commentDocumentPath: widget.comment.documentPath!,
                                    myUserId: widget.myUser.id!),
                                builder: (BuildContext context,
                                    AsyncSnapshot<Emote?> snapshot) {
                                  return renderBtnLike(snapshot.data);
                                },
                              ),
                              const Text('·'),
                              //TODO: reply button
                              TextButton(
                                onPressed: () async {
                                  if (widget.onReplyTap == null) {
                                    //TODO: comment này có thể phản hồi
                                    setState(() {
                                      _showReplies = true;
                                    });
                                    await _setNameTag(widget.comment.createdBy);
                                    _replyNode.requestFocus();
                                  } else {
                                    //TODO: setNameTag bằng createdBy của comment này
                                    //TODO: focus vào _replyNode của comment mà comment này đang reply
                                    widget.onReplyTap!(widget.comment.createdBy);
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
                            ],
                          ),
                        ]
                    ),
                    onHorizontalDragEnd: onHorizontalDragEndBoxIcon,
                    onHorizontalDragUpdate: onHorizontalDragUpdateBoxIcon,
                      ),
                    ),

                  //TODO: Icons when jump
                  // Icon like
                  whichIconUserChoose == 1 && !isDragging
                      ? Container(
                    child: Transform.scale(
                      child: Image.asset(
                        'assets/images/emotes/like.gif',
                        width: 40.0,
                        height: 40.0,
                      ),
                      scale: zoomIconWhenRelease.value as double,
                    ),
                    margin: EdgeInsets.only(
                      top: processTopPosition(moveUpIconWhenRelease.value as double),
                      left: moveLeftIconLikeWhenRelease.value as double,
                    ),
                  )
                      : Container(),

                  // Icon love
                  whichIconUserChoose == 2 && !isDragging
                      ? Container(
                    child: Transform.scale(
                      child: Image.asset(
                        'assets/images/emotes/love.gif',
                        width: 40.0,
                        height: 40.0,
                      ),
                      scale: zoomIconWhenRelease.value as double,
                    ),
                    margin: EdgeInsets.only(
                      top: processTopPosition(moveUpIconWhenRelease.value as double),
                      left: moveLeftIconLoveWhenRelease.value as double,
                    ),
                  )
                      : Container(),

                  // Icon haha
                  whichIconUserChoose == 3 && !isDragging
                      ? Container(
                    child: Transform.scale(
                      child: Image.asset(
                        'assets/images/emotes/haha.gif',
                        width: 40.0,
                        height: 40.0,
                      ),
                      scale: zoomIconWhenRelease.value as double,
                    ),
                    margin: EdgeInsets.only(
                      top: processTopPosition(moveUpIconWhenRelease.value as double),
                      left: moveLeftIconHahaWhenRelease.value as double,
                    ),
                  )
                      : Container(),

                  // Icon Wow
                  whichIconUserChoose == 4 && !isDragging
                      ? Container(
                    child: Transform.scale(
                      child: Image.asset(
                        'assets/images/emotes/wow.gif',
                        width: 40.0,
                        height: 40.0,
                      ),
                      scale: zoomIconWhenRelease.value as double,
                    ),
                    margin: EdgeInsets.only(
                      top: processTopPosition(moveUpIconWhenRelease.value as double),
                      left: moveLeftIconWowWhenRelease.value as double,
                    ),
                  )
                      : Container(),

                  // Icon sad
                  whichIconUserChoose == 5 && !isDragging
                      ? Container(
                    child: Transform.scale(
                      child: Image.asset(
                        'assets/images/emotes/sad.gif',
                        width: 40.0,
                        height: 40.0,
                      ),
                      scale: zoomIconWhenRelease.value as double,
                    ),
                    margin: EdgeInsets.only(
                      top: processTopPosition(moveUpIconWhenRelease.value as double),
                      left: moveLeftIconSadWhenRelease.value as double,
                    ),
                  )
                      : Container(),

                  // Icon angry
                  whichIconUserChoose == 6 && !isDragging
                      ? Container(
                    child: Transform.scale(
                      child: Image.asset(
                        'assets/images/emotes/angry.gif',
                        width: 40.0,
                        height: 40.0,
                      ),
                      scale: zoomIconWhenRelease.value as double,
                    ),
                    margin: EdgeInsets.only(
                      top: processTopPosition(moveUpIconWhenRelease.value as double),
                      left: moveLeftIconAngryWhenRelease.value as double,
                    ),
                  )
                      : Container(),

                ],)),

                //TODO: emote selections bar
                //if (_showEmoteSelectionsBar) _emoteSelectionsBar(),
              ],
            ),

            //TODO: replies / -> [Avatar] Thanh Do Vo da tra loi . 4 phan hoi 16 phut
            if(!_showReplies)
              _repliesCountWidget(),
            //TODO: _showReplies + input row
            if (_showReplies)
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                //TODO: Xem thêm 3 phản hồi
                _viewMoreRepliesWidget(),
                //TODO: list phản hồi
                _listRepliesWithFilter(),
                //TODO: input row
                _inputRow(),
              ]),
          ],
        ),
      ],
    );
  }
}
