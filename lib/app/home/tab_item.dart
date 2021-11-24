import 'package:flutter/material.dart';
import '/constants/keys.dart';
import '/constants/strings.dart';

enum TabItem { posts, shipments, contacts, chats, account }

class TabItemData {
  const TabItemData(
      {required this.key, required this.title, required this.icon});

  final String key;
  final String title;
  final IconData icon;

  static const Map<TabItem, TabItemData> allTabs = {
    TabItem.posts: TabItemData(
      key: Keys.postsTab,
      title: Strings.posts,
      icon: Icons.post_add,
    ),
    TabItem.shipments: TabItemData(
      key: Keys.shipmentsTab,
      title: Strings.shipments,
      icon: Icons.delivery_dining,
    ),
    TabItem.contacts: TabItemData(
      key: Keys.contactsTab,
      title: Strings.contacts,
      icon: Icons.contacts,
    ),
    TabItem.chats: TabItemData(
      key: Keys.chatsTab,
      title: Strings.chats,
      icon: Icons.chat,
    ),
    TabItem.account: TabItemData(
      key: Keys.accountTab,
      title: Strings.account,
      icon: Icons.person,
    ),
  };
}
