import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/app/home/member/posts/components/my_user_avatar.dart';
import '/app/home/member/posts/components/my_user_name.dart';
import '/constants/ui.dart';
import '/models/feedback.dart';
import '/models/my_user.dart';
import '/routing/app_router.dart';
import '/services/database_service.dart';

class MyUsersPage extends StatefulWidget {
  const MyUsersPage({required this.myUser, this.controller});

  final MyUser myUser;
  final ScrollController? controller;
  @override
  createState() => _MyUsersPageState();
}

class _MyUsersPageState extends State<MyUsersPage> {
  //Let's add the color code for our project
  Color bgBlack = const Color(0xFF1a1a1a);
  Color mainBlack = const Color(0xFF262626);
  Color fbBlue = const Color(0xFF2D88FF);
  Color mainGrey = const Color(0xFF505050);

  String field = 'name';
  String somePart = '';

  Widget _rating(BuildContext context, String myUserId) {
    return StreamBuilder(
      stream: DatabaseService().getStreamListFeedback(myUserId),
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
        }
        return Container();
      },
    );
  }

  Future<void> _showMyUserDetailsPage(BuildContext context, {required String myUserId2}) async {
    print('MyUsersPage, _showAccountPage, myUserId2: $myUserId2');
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.myUserDetailsPage,
      arguments: {
        'myUser': widget.myUser,
        'myUserId2': myUserId2,
      },
    );
  }

  Widget _myUserItem(BuildContext context ,MyUser myUser) {
    return GestureDetector(
      onTap: (){
        print('my_users_page, _contactItem, tap myUser.name: ${myUser.name}');
        //TODO: detail
        _showMyUserDetailsPage(context, myUserId2: myUser.id!);
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
              //TODO: photo+name+date
              Row(
                children: [
                  //TODO: img
                  MyUserAvatar(myUser: myUser,myUserId: null),
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
                          MyUserName(myUserId: myUser.id!),
                          const SizedBox(width: 15.0),
                          //TODO: rating
                          _rating(context, myUser.id!),
                        ]),
                        const SizedBox(height: 5.0),
                        //TODO: phone
                        if (myUser.phoneNumber != null)
                          Text(
                            myUser.phoneNumber.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
                  ),
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
      //TODO: list myUsers
      body: StreamBuilder(
          stream: DatabaseService().getStreamListMyUserBySomePart(field, somePart),
          builder:
              (BuildContext ctx, AsyncSnapshot<List<MyUser>> snapshot) {
            if (snapshot.hasError) {
              return Container();
            }
            if (snapshot.hasData) {
              List<MyUser> myUsers = snapshot.data!;
              print('myUsers has data');
              print(myUsers.length);
              //TODO: doi sang singlechildscrollview
              return ListView.builder(
                controller: widget.controller,
                itemCount: myUsers.length,
                itemBuilder: (BuildContext ctx, int index) {
                  if(myUsers[index].id! != widget.myUser.id!){
                    return _myUserItem(context, myUsers[index]);
                  }
                  return Container();
                },
              );
            } else {
              return Container();
            }
          }),
    );
  }
}
