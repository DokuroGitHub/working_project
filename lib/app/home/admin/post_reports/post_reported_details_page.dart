import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:working_project/app/home/admin/posts/components/post_box.dart';
import 'package:working_project/common_widgets/avatar.dart';
import 'package:working_project/models/my_user.dart';
import 'package:working_project/models/post.dart';
import 'package:working_project/models/post_reported.dart';
import 'package:working_project/services/database_service.dart';

class PostReportedDetailsPage extends StatefulWidget {
  const PostReportedDetailsPage(
      {required this.myUser, required this.postReported});

  final MyUser myUser;
  final PostReported postReported;

  @override
  createState() => _PostReportedDetailsPageState();
}

class _PostReportedDetailsPageState extends State<PostReportedDetailsPage> {
  bool _showPostDetails = true;
  String selection = '';

  Widget _postId(String postId) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('_postId:'),
      const SizedBox(height: 10),
      Row(children: [
        const SizedBox(width: 20),
        const Icon(Icons.location_pin),
        const SizedBox(width: 10),
        Text(postId),
      ]),
    ]);
  }

  Widget _createdAt(String createdAt) {
    return Row(children: [
      const Icon(Icons.date_range_outlined),
      const SizedBox(width: 10),
      Text('_createdAt lúc: $createdAt'),
    ]);
  }

  Widget _status(String status) {
    return Row(children: [
      const Icon(Icons.people_alt_outlined),
      const SizedBox(width: 10),
      const Text('_status: '),
      Container(
        child: Text(status),
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: (status=='DAXULY')?Colors.green:Colors.blue,
          borderRadius: const BorderRadius.all(Radius.circular(25)),
        ),
      ),
    ]);
  }

  Widget _type(String type) {
    return Row(children: [
      const Icon(Icons.people_alt_outlined),
      const SizedBox(width: 10),
      const Text('_type: '),
      Container(
        child: Text(type),
        padding: const EdgeInsets.all(5.0),
        decoration: const BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
      ),
    ]);
  }

  Widget _text(String text) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.event_note_outlined),
      const SizedBox(width: 10),
      const Text('_text: '),
      const SizedBox(width: 10),
      Container(
        child: Text(text),
        padding: const EdgeInsets.all(15.0),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .6),
        decoration: const BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
      ),
    ]);
  }

  Widget _createdBy(String createdBy) {
    return StreamBuilder(
      stream: DatabaseService()
          .getStreamMyUserByDocumentId(createdBy),
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

  Widget _postDetails() {
    return StreamBuilder(
      stream: DatabaseService()
          .getStreamPostByDocumentId(widget.postReported.postId),
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

  Future<void> _deletePost() async {
    Post? post = await DatabaseService().getPostByDocumentId(widget.postReported.postId);
    if(post!=null){
      DatabaseService().deletePost(post.id!);
    }
  }

  Future<void> _blockPostCreatedBy() async {
    Post? post = await DatabaseService().getPostByDocumentId(widget.postReported.postId);
    if(post!=null){
      MyUser? myUser = await DatabaseService().getMyUserByDocumentId(post.createdBy);
      if(myUser!=null){
        myUser.isBlocked = true;
        await DatabaseService().updateMyUserOnDB(myUser.id!, myUser.toMap());
      }
    }
  }

  Future<void> _changePostReportedStatus() async {
    PostReported postReported = widget.postReported;
    if(postReported.status == 'CHUAXULY'){
      postReported.status = 'DAXULY';
    }else{
      postReported.status = 'CHUAXULY';
    }
    await DatabaseService().updatePostReported(postReported.id!, postReported.toMap());
  }

  //TODO: _showActions
  Future<void> _showActions(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context2) => AlertDialog(
        title: const Text('Chọn thao tác'),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(children: [
                    const Spacer(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .5,
                      child: TextButton(
                          onPressed: () {
                            Navigator.of(context2).pop();
                            _deletePost();
                          },
                          child: const Text('Xóa bài viết')),
                    ),
                    const Spacer(),
                  ]),
                  Row(children: [
                    const Spacer(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .5,
                      child: TextButton(
                          onPressed: () {
                            Navigator.of(context2).pop();
                            _blockPostCreatedBy();
                          },
                          child: const Text('Khóa chủ bài viết')),
                    ),
                    const Spacer(),
                  ]),
                  Row(children: [
                    const Spacer(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .5,
                      child: TextButton(
                          onPressed: () {
                            Navigator.of(context2).pop();
                            _changePostReportedStatus();
                          },
                          child: const Text('Đã xử lý xong report')),
                    ),
                    const Spacer(),
                  ]),
                ]),
          ),
        ),
      ),
    );
  }

  Widget _buildPostReport(){
    return StreamBuilder(stream: DatabaseService().getStreamPostReportedByDocumentId(widget.postReported.id!),
      builder: (BuildContext context, AsyncSnapshot<PostReported?> snapshot) {
      if(snapshot.data!=null) {
        PostReported postReported = snapshot.data!;
        return Column(children: [
          //TODO: fields
          Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  reverse: false,
                  child: Column(
                    children: [
                      //TODO: _postId
                      _postId(postReported.postId),
                      const SizedBox(height: 10),
                      //TODO: _createdBy
                      _createdBy(postReported.createdBy),
                      const SizedBox(height: 10),
                      //TODO: _createdAt
                      _createdAt(postReported.createdAt.toString()),
                      const SizedBox(height: 10),
                      //TODO: _type
                      _type(postReported.type),
                      const SizedBox(height: 10),
                      //TODO: _status
                      _status(postReported.status),
                      const SizedBox(height: 10),
                      //TODO: _text
                      _text(postReported.text??''),
                      const SizedBox(height: 10),
                      const Divider(
                        thickness: 3.0,
                      ),
                      //TODO: post details
                      TextButton(
                        child: Text(_showPostDetails ? 'Đóng' : 'Mở'),
                        onPressed: () {
                          setState(() {
                            _showPostDetails = !_showPostDetails;
                          });
                        },
                      ),
                      if (_showPostDetails) _postDetails(),
                    ],
                  ),
                ),
              )),
        ]);
      }
      return const Text('post reported waittttt');
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
        title: const Text('Chi tiết Post Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb),
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
            onPressed: () {
              //TODO: xu ly report
              _showActions(context);
            },
          ),
        ],
      ),
      body: _buildPostReport(),
    );
  }
}
