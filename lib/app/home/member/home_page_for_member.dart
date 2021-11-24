import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../locale_service.dart';
import '../../../theme_service.dart';
import '/app/home/member/posts/posts_page.dart';
import '/app/home/member/shipments/shipments_page.dart';
import '/models/my_user.dart';
import '../account/account_page.dart';
import 'chats/chats_page.dart';
import 'contacts/contacts_page.dart';

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
        title: const Text('Home page for member 25 11'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb),
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
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
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
