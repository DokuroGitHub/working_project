import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/app/home/member/posts/components/post_box.dart';
import '/app/home/member/posts/components/storytile.dart';
import '/models/my_user.dart';
import '/models/post.dart';
import '/services/database_service.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({required this.myUser});

  final MyUser myUser;

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  //Let's add the color code for our project
  Color bgBlack = const Color(0xFF1a1a1a);
  Color mainBlack = const Color(0xFF262626);
  Color fbBlue = const Color(0xFF2D88FF);
  Color mainGrey = const Color(0xFF505050);

  //Here I'm going to import a list of images that we will use for the profile picture and the storys
  List<String> avatarUrl = [
    "https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=700&q=80",
    "https://images.unsplash.com/photo-1457449940276-e8deed18bfff?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1525879000488-bff3b1c387cf?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80",
  ];
  List<String> storyUrl = [
    "https://images.unsplash.com/photo-1600055882386-5d18b02a0d51?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=621&q=80",
    "https://images.unsplash.com/photo-1600174297956-c6d4d9998f14?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80",
    "https://images.unsplash.com/photo-1600008646149-eb8835bd979d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=666&q=80",
    "https://images.unsplash.com/photo-1502920313556-c0bbbcd00403?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=967&q=80",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      //let's add the app bar
      appBar: AppBar(
        elevation: 0.0,
        //backgroundColor: mainBlack,
        title: Text('Facebook', style: Theme.of(context).appBarTheme.titleTextStyle),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu),
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ],
      ),

      //Now let's work on the body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //TODO: post editor
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 10.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25.0,
                            backgroundImage: NetworkImage(avatarUrl[0]),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.only(left: 25.0),
                                  hintText: "Post something...",
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
                      const Divider(thickness: 1.5),
                      //Now we will create a Row of three button
                      Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              onPressed: (){},
                              icon: const Icon(
                                Icons.live_tv,
                                color: Color(0xFFF23E5C),
                              ),
                              label: Text('Live',  style: Theme.of(context).textTheme.button),
                            ),
                          ),
                          Expanded(
                            child: TextButton.icon(
                              onPressed: (){},
                              icon: const Icon(
                                Icons.image,
                                color: Color(0xFF58C472),
                              ),
                              label: Text('Picture', style: Theme.of(context).textTheme.button),
                            ),
                          ),
                          Expanded(
                            child: TextButton.icon(
                              onPressed: (){},
                              icon: const Icon(
                                Icons.insert_emoticon,
                                color: Color(0xFFF8C03E),
                              ),
                              label: Text('Activity', style: Theme.of(context).textTheme.button),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              //TODO: story
              SizedBox(
                height: 160.0,
                width: double.infinity,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    storyTile(avatarUrl[0], storyUrl[0], "Ling chang"),
                    storyTile(avatarUrl[1], storyUrl[1], "Ling chang"),
                    storyTile(avatarUrl[2], storyUrl[2], "Ling chang"),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              //TODO: posts stream
              StreamBuilder(
                  stream: DatabaseService().getStreamListPost(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Post>> snapshot) {
                    if (snapshot.hasError) {
                      return Container();
                    }
                    if (snapshot.hasData) {
                      List<Post> posts = snapshot.data!;
                      return Column(children: posts.map((post) {
                        return PostBox(myUser: widget.myUser, post: post);
                      }).toList());
                    } else {
                      return Container();
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
