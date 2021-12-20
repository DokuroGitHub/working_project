import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:working_project/models/post_reported.dart';

import '/app/home/member/posts/components/my_user_avatar.dart';
import '/app/home/member/posts/components/my_user_name.dart';
import '/constants/ui.dart';
import '/models/feedback.dart';
import '/models/my_user.dart';
import '/routing/app_router.dart';
import '/services/database_service.dart';

class PostReportsPage extends StatefulWidget {
  const PostReportsPage({required this.myUser, this.controller});

  final MyUser myUser;
  final ScrollController? controller;
  @override
  createState() => _PostReportsPageState();
}

class _PostReportsPageState extends State<PostReportsPage> {
  //Let's add the color code for our project
  Color bgBlack = const Color(0xFF1a1a1a);
  Color mainBlack = const Color(0xFF262626);
  Color fbBlue = const Color(0xFF2D88FF);
  Color mainGrey = const Color(0xFF505050);

  String field = 'status';
  String somePart = '';

  Future<void> _showPostReportedDetailsPage(BuildContext context, {required PostReported postReported}) async {
    print('PostReportsPage, _showPostReportedDetailsPage, postReported: ${postReported.id}');
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.postReportDetailsPage,
      arguments: {
        'myUser': widget.myUser,
        'postReported': postReported,
      },
    );
  }

  Widget _postReportedItem(BuildContext context, PostReported postReported) {
    return GestureDetector(
      onTap: (){
        print('_postReportedItem, tap postReported.id: ${postReported.id}');
        //TODO: detail
        _showPostReportedDetailsPage(context, postReported: postReported);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
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
              Row(
                children: [
                  //TODO: type
                  Text(postReported.type),
                  const SizedBox(
                    width: 10.0,
                  ),

                  //TODO: id+date
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //TODO: id
                        Text('Id: ${postReported.id}'),
                        const SizedBox(height: 5.0),
                        //TODO: date
                        Text('Created At: ${postReported.createdAt}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),

                  //TODO: status
                  Text(postReported.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBlack,
      //TODO: appBar
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: mainBlack,
        actions: [
          Expanded(
              child: TextField(
                onChanged: (String? value){
                  setState(() {
                    somePart = value??'';
                  });
                },
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 25.0),
                hintText: "Search something...",
                filled: true,
                fillColor: mainGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                )),
          )),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu),
          ),
          PopupMenuButton<String>(
            onSelected: (String value){
              setState(() {
                field = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'name',
                  child: Text('Tìm theo tên'),
                ),
                const PopupMenuItem<String>(
                  value: 'phoneNumber',
                  child: Text('Tìm theo sđt'),
                ),
                const PopupMenuItem<String>(
                  value: 'email',
                  child: Text('Tìm theo email'),
                ),
              ];
            },
          ),
          const SizedBox(width: kDefaultPadding / 2),
        ],
      ),
      //TODO: list post reports
      body: StreamBuilder(
          stream: DatabaseService().getStreamListPostReportedBySomePart(field, somePart),
          builder:
              (BuildContext ctx, AsyncSnapshot<List<PostReported>> snapshot) {
            if (snapshot.hasError) {
              return Container();
            }
            if (snapshot.hasData) {
              List<PostReported> listPostReported = snapshot.data!;
              print('listPostReported has data');
              print(listPostReported.length);
              //TODO: doi sang singlechildscrollview
              return ListView.builder(
                controller: widget.controller,
                itemCount: listPostReported.length,
                itemBuilder: (BuildContext ctx, int index) {
                  return _postReportedItem(context, listPostReported[index]);
                },
              );
            } else {
              return Container();
            }
          }),
    );
  }
}
