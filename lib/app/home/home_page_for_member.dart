import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/app/home/member/posts/posts_page.dart';
import '/app/home/member/shipments/shipments_page.dart';
import '/models/my_user.dart';
import 'account/account_page.dart';
import 'member/chats/chats_page.dart';
import 'member/contacts/contacts_page.dart';

class HomePageForMember extends StatefulWidget {
  const HomePageForMember({
    Key? key,
    required this.myUser,
  }) : super(key: key);
  final MyUser myUser;

  @override
  _HomePageForMemberState createState() => _HomePageForMemberState();
}

class _HomePageForMemberState extends State<HomePageForMember> {
  //TODO: nav screen
  int _selectedIndex = 0;
  //TODO: hide nav
  late final ScrollListener _model;
  late final ScrollController _controller;
  final double _bottomNavBarHeight = 60;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _model = ScrollListener.initialise(_controller);
  }

  Widget get _bottomNavBar {
    return SizedBox(
      height: _bottomNavBarHeight,
      child: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: const Icon(Icons.post_add),
              tooltip: 'Posts here',
              label: AppLocalizations.of(context)!.posts,
              backgroundColor: Colors.green),
          BottomNavigationBarItem(
              icon: const Icon(Icons.delivery_dining),
              tooltip: 'Shipments here',
              label: AppLocalizations.of(context)!.shipments,
              backgroundColor: Colors.yellow),
          BottomNavigationBarItem(
            icon: const Icon(Icons.contacts),
            tooltip: 'Contacts here',
            label: AppLocalizations.of(context)!.contacts,
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            tooltip: 'Chats here',
            label: AppLocalizations.of(context)!.chats,
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            tooltip: 'Profile here',
            label: AppLocalizations.of(context)!.account,
            backgroundColor: Colors.blue,
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        //backgroundColor: Colors.blue,
        iconSize: 30,
        onTap: (index){
          setState(() {
            _selectedIndex = index;
          });
        },
        elevation: 5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> _widgetOptions = [
      //TODO: page 0
      PostsPage(myUser: widget.myUser, controller: _controller),
      //TODO: page 1
      ShipmentsPage(myUser: widget.myUser, controller: _controller),
      //TODO: page 2
      ContactsPage(myUser: widget.myUser, controller: _controller),
      //TODO: page 3
      ChatsPage(myUser: widget.myUser, controller: _controller),
      //TODO: page 4
      AccountPage(myUser: widget.myUser, myUserId2: widget.myUser.id!, controller: _controller,),
    ];

    return Scaffold(
      body: AnimatedBuilder(
        animation: _model,
        builder: (context, child) {
          return Stack(
            children: [
              _widgetOptions[_selectedIndex],
              Positioned(
                left: 0,
                right: 0,
                bottom: _model.bottom,
                child: _bottomNavBar,
              ),
            ],
          );
        },
      ),
    );
  }
}

//TODO: hide nav bar
class ScrollListener extends ChangeNotifier {
  double bottom = 0;
  double _last = 0;

  ScrollListener.initialise(ScrollController controller, [double height = 56]) {
    controller.addListener(() {
      final current = controller.offset;
      bottom += _last - current;
      if (bottom <= -height) bottom = -height;
      if (bottom >= 0) bottom = 0;
      _last = current;
      if (bottom <= 0 && bottom >= -height) notifyListeners();
    });
  }
}