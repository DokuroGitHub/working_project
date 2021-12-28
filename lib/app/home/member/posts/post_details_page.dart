import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:working_project/app/home/member/posts/components/post_box.dart';
import 'package:working_project/models/my_user.dart';
import 'package:working_project/models/post.dart';
import 'package:working_project/routing/app_router.dart';
import 'package:working_project/services/database_service.dart';

class PostDetailsPage extends StatefulWidget {
  const PostDetailsPage(
      {required this.myUser, required this.postId});

  final MyUser myUser;
  final String postId;

  static Future<void> showPlz(BuildContext context, MyUser myUser, String postId) async {
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.postDetailsPage,
      arguments: {
        'myUser': myUser,
        'postId': postId,
      },
    );
  }

  @override
  createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {

  Widget _postDetails() {
    return StreamBuilder(
      stream: DatabaseService()
          .getStreamPostByDocumentId(widget.postId),
      builder: (BuildContext context, AsyncSnapshot<Post?> snapshot) {
        if (snapshot.hasError) {
          return const Text('errorrrrrrrrrrrrrrrrrr');
        }
        if (snapshot.hasData) {
          Post? post = snapshot.data;
          print(post);
          if (post != null) {
            return PostBox(post: post, myUser: widget.myUser);
          }
        }
        return const Text('waittttttttttttttttttttt');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.grey,
        ),
        title: const Text('Chi tiết bài viết'),
      ),
      body: Column(children: [
        Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                reverse: false,
                child: _postDetails(),
              ),
            )),
      ]),
    );
  }
}
