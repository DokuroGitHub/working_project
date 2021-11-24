import 'package:flutter/material.dart';

import '../../locale_service.dart';
import '../../theme_service.dart';
import '/models/my_user.dart';
import 'account/account_page.dart';
import 'member/chats/chats_page.dart';
import 'member/contacts/contacts_page.dart';
import 'member/posts/posts_page.dart';
import 'member/shipments/shipments_page.dart';

class HomePageForAdmin extends StatefulWidget {
  const HomePageForAdmin({
    Key? key,
    required this.myUser,
  }) : super(key: key);
  final MyUser myUser;

  @override
  _HomePageForAdminState createState() => _HomePageForAdminState();
}

class _HomePageForAdminState extends State<HomePageForAdmin> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = [
      //TODO: page 0
      PostsPage(myUser: widget.myUser),
      //TODO: page 1
      ShipmentsPage(myUser: widget.myUser),
      //TODO: page 2
      ContactsPage(myUser: widget.myUser),
      //TODO: page 3
      ChatsPage(myUser: widget.myUser),
      //TODO: page 4
      AccountPage(myUser: widget.myUser, myUserId2: widget.myUser.id!),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Home page for member'),
        actions: [
          IconButton(
            icon: Icon(Icons.lightbulb),
            onPressed: ThemeService().switchTheme,
          ),
          PopupMenuButton<String>(
            onSelected: LocaleService().changeLocale,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'vi',
                  child: Text('Tiếng Việt',
                      style: TextStyle(
                          color: LocaleService().languageCode == 'vi'
                              ? Colors.red
                              : Colors.blue)),
                ),
                PopupMenuItem<String>(
                  value: 'en',
                  child: Text('English',
                      style: TextStyle(
                          color: LocaleService().languageCode == 'en'
                              ? Colors.red
                              : Colors.blue)),
                ),
                PopupMenuItem<String>(
                  value: 'es',
                  child: Text('Espanol',
                      style: TextStyle(
                          color: LocaleService().languageCode == 'es'
                              ? Colors.red
                              : Colors.blue)),
                ),
              ];
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Center(
        child: _widgetOptions[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.post_add),
              tooltip: 'Posts here',
              label: 'Posts',
              backgroundColor: Colors.green),
          BottomNavigationBarItem(
              icon: Icon(Icons.delivery_dining),
              tooltip: 'Shipments here',
              label: 'Shipments',
              backgroundColor: Colors.yellow),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            tooltip: 'Contacts here',
            label: 'Contacts',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            tooltip: 'Chats here',
            label: 'Chats',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            tooltip: 'Profile here',
            label: 'Profile',
            backgroundColor: Colors.blue,
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        backgroundColor: Colors.blue,
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
}
