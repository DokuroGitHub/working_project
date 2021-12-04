import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:working_project/app/home/feedbacks/components/feedback_attachments.dart';
import 'package:working_project/app/home/feedbacks/components/summary.dart';
import 'package:working_project/app/home/feedbacks/feedbacks_page.dart';
import 'package:working_project/common_widgets/avatar.dart';
import 'package:working_project/common_widgets/helper.dart';
import 'package:working_project/constants/strings.dart';
import 'package:working_project/models/feedback.dart';
import 'package:working_project/models/my_user.dart';
import 'package:working_project/services/auth_service.dart';
import 'package:working_project/services/database_service.dart';

import '../../../../locale_service.dart';
import '../../../../theme_service.dart';

class Body extends StatefulWidget {
  const Body({required this.myUser, required this.myUser2, this.controller});

  final MyUser myUser;
  final MyUser myUser2;
  final ScrollController? controller;

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Future<void> _signOut(BuildContext context) async {
    try {
      await AuthService().signOut();
    } catch (e) {
      //TODO: show dialog
      unawaited(showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.logoutFailed),
          content: Text(AppLocalizations.of(context)!.logoutFailed),
          actions: <Widget>[
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ));
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final bool didRequestSignOut = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.logoutAreYouSure),
        actions: <Widget>[
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.ok),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ??
        false;
    if (didRequestSignOut == true) {
      await _signOut(context);
    }
  }

  Widget _buildUserInfo(MyUser user) {
    return Column(
      children: [
        Avatar(
          photoUrl: user.photoURL,
          radius: 30,
          borderColor: Colors.black54,
          borderWidth: 2.0,
        ),
        const SizedBox(height: 8),
        Text(
          user.email ?? 'Người dùng chưa thiết lập gmail',
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          user.phoneNumber ?? 'Người dùng chưa thiết lập số điện thoại',
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: const Text(Strings.accountPage),
      actions: <Widget>[
        if (widget.myUser2.id! == widget.myUser.id!)
          Row(children: [
            IconButton(
              icon: const Icon(Icons.lightbulb),
              color: Theme.of(context).appBarTheme.titleTextStyle?.color,
              onPressed: ThemeService().switchTheme,
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert,
                color: Theme.of(context).appBarTheme.titleTextStyle?.color,
              ),
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
            TextButton(
              child: Text(AppLocalizations.of(context)!.logout,style: Theme.of(context).textTheme.bodyText1),
              onPressed: () => _confirmSignOut(context),
            ),
          ]),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: _buildUserInfo(widget.myUser2),
      ),
    );
  }

  Widget _address() {
    if (widget.myUser2.address == null) {
      return Container();
    }
    String? details = widget.myUser2.address!.details;
    String? city = widget.myUser2.address!.city;
    String? district = widget.myUser2.address!.district;
    String? street = widget.myUser2.address!.street;
    String address = '';
    if (details != null) {
      address = details;
    } else {
      address = '$street, $district, $city';
    }
    address.replaceAll(',,', ',');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Địa chỉ:'),
      const SizedBox(height: 10),
      Row(children: [
        const SizedBox(width: 20),
        const Icon(Icons.location_pin),
        const SizedBox(width: 10),
        Text(address),
      ]),
    ]);
  }

  Widget _birthDate() {
    if (widget.myUser2.birthDate == null) {
      return Container();
    }
    return Row(children: [
      const Icon(Icons.date_range_outlined),
      const SizedBox(width: 10),
      Text('Ngày sinh: ${widget.myUser2.birthDate!.toString()}'),
    ]);
  }

  Widget _createdAt() {
    return Row(children: [
      const Icon(Icons.date_range_outlined),
      const SizedBox(width: 10),
      Text('Tham gia lúc: ${widget.myUser2.createdAt.toString()}'),
    ]);
  }

  Widget _email() {
    if (widget.myUser2.email == null) {
      return Container();
    }
    return Row(children: [
      const Icon(Icons.mail_outline_outlined),
      const SizedBox(width: 10),
      Text('Email: ${widget.myUser2.email!}'),
    ]);
  }

  Widget _isActive() {
    if (widget.myUser2.isActive) {
      return Row(children: const [
        Icon(Icons.online_prediction_outlined),
        SizedBox(width: 10),
        Text('Online: Đang hoạt động'),
      ]);
    }
    String text =
        'Online: Hoạt động cách đây ${Helper.timeToString(widget.myUser2.lastSignInAt).toString()}';
    return Row(children: [
      const Icon(Icons.online_prediction_outlined),
      const SizedBox(width: 10),
      Text(text),
    ]);
  }

  Widget _isBlock() {
    if (widget.myUser2.isBlocked) {
      return Row(children: const [
        Icon(Icons.block_outlined),
        SizedBox(width: 10),
        Text('Block: Tài khoản đang bị khóa'),
      ]);
    }
    return Row(children: const [
      Icon(Icons.block_outlined),
      SizedBox(width: 10),
      Text('Block: Tài khoản không bị khóa'),
    ]);
  }

  Widget _lastSignInAt() {
    return Row(children: [
      const Icon(Icons.date_range_outlined),
      const SizedBox(width: 10),
      Text('Đăng nhập lần cuối: ${widget.myUser2.lastSignInAt}'),
    ]);
  }

  Widget _name() {
    return Row(children: [
      const Icon(Icons.tag_faces_outlined),
      const SizedBox(width: 10),
      Text('Tên: ${widget.myUser2.name ?? ''}'),
    ]);
  }

  Widget _phoneNumber() {
    return Row(children: [
      const Icon(Icons.phone),
      const SizedBox(width: 10),
      const Text('Số điện thoại: '),
      Container(
        child:
        Text(widget.myUser2.phoneNumber ?? 'Người dùng chưa thiết lập sđt'),
        padding: const EdgeInsets.all(5.0),
        decoration: const BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
      ),
    ]);
  }

  Widget _role() {
    return Row(children: [
      const Icon(Icons.people_alt_outlined),
      const SizedBox(width: 10),
      const Text('Role: '),
      Container(
        child: Text(widget.myUser2.role),
        padding: const EdgeInsets.all(5.0),
        decoration: const BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
      ),
    ]);
  }

  Widget _selfIntroduction() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.event_note_outlined),
      const SizedBox(width: 10),
      const Text('Giới thiệu: '),
      const SizedBox(width: 10),
      Container(
        child: Text(widget.myUser2.selfIntroduction ?? ''),
        padding: const EdgeInsets.all(15.0),
        constraints:
        BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .6),
        decoration: const BoxDecoration(
          color: Colors.amberAccent,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
      ),
    ]);
  }

  bool _showShipperInfo = true;

  Widget _shipperInfo() {
    if (widget.myUser2.shipperInfo == null) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          child: Row(children: const [
            Icon(Icons.local_shipping_outlined),
            SizedBox(width: 10),
            Text('Thông tin shipper: '),
          ]),
          onTap: () {
            setState(() {
              _showShipperInfo = !_showShipperInfo;
            });
          },
        ),
        const SizedBox(height: 10),
        if (_showShipperInfo)
          Container(
            padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.handyman_outlined),
                const SizedBox(width: 10),
                const Text('Loại phương tiện: '),
                Container(
                  child: Text(widget.myUser2.shipperInfo!.vehicleType ?? ''),
                  padding: const EdgeInsets.all(5.0),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.event_note_outlined),
                const SizedBox(width: 10),
                const Text('Miêu tả: '),
                const SizedBox(width: 10),
                Container(
                  child: Text(
                      'Miêu tả: ${widget.myUser2.shipperInfo!.vehicleDescription ?? ''}'),
                  padding: const EdgeInsets.all(15.0),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * .6),
                  decoration: const BoxDecoration(
                    color: Colors.amberAccent,
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.loop),
                const SizedBox(width: 10),
                const Text('Trạng thái: '),
                Container(
                  child: Text(widget.myUser2.shipperInfo!.status ?? ''),
                  padding: const EdgeInsets.all(5.0),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                ),
              ]),
            ]),
          ),
        if (!_showShipperInfo)
          Row(children: const [SizedBox(width: 50), Icon(Icons.expand)]),
      ],
    );
  }

  Widget _createdBy(String myUserId) {
    return StreamBuilder(
      stream: DatabaseService().getStreamMyUserByDocumentId(myUserId),
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

  Widget _rating(num star) {
    switch (star) {
      case 5:
        return Row(children: const [
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
        ]);
      case 4:
        return Row(children: const [
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
        ]);
      case 3:
        return Row(children: const [
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
        ]);
      case 2:
        return Row(children: const [
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
        ]);
      case 1:
        return Row(children: const [
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
        ]);
      default:
        return Row(children: const [
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
        ]);
    }
  }

  Widget _feedbackItem(FeedBack feedback) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration: const BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //TODO: avatar+name+rate+date
        Row(children: [
          _createdBy(feedback.createdBy),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _rating(feedback.rating),
            const SizedBox(height: 10),
            Text(Helper.timeToString(feedback.createdAt)),
          ]),
        ]),
        //TODO: text
        Text(feedback.text ?? ''),
        //TODO: attachments
        Column(children: [
          Row(children: const [
            Icon(Icons.attachment),
            SizedBox(width: 10),
            Text('Tệp đính kèm: '),
          ]),
          const SizedBox(width: 10),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .3),
            padding: const EdgeInsets.all(5.0),
            decoration: const BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: FeedBackAttachments(
                myUser: widget.myUser, attachments: feedback.attachments),
          ),
        ]),
        //TODO: reply
        if (feedback.reply != null)
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('Phản hồi:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(Helper.timeToString(feedback.reply!.createdAt)),
              ]),
              Text(feedback.reply!.text),
            ]),
          ),
      ]),
    );
  }

  Future<void> _showFeedBacksPage(
      BuildContext context, MyUser myUser, String myUserId2) async {
    await FeedBacksPage.showPlz(context, myUser, myUserId2);
  }

  Widget _feedback() {
    return StreamBuilder(
      stream: DatabaseService().getStreamListFeedback(widget.myUser2.id!),
      builder: (BuildContext context, AsyncSnapshot<List<FeedBack>> snapshot) {
        if (snapshot.hasData) {
          List<FeedBack> feedBacks = snapshot.data!;
          return Column(children: [
            Row(children: [
              Text(AppLocalizations.of(context)!.rateAndFeedBacks),
              const Spacer(),
              TextButton(child: Text(AppLocalizations.of(context)!.viewAll),
                onPressed: () {
                  //TODO: xem tat ca
                  print('summary, click xem tat ca');
                  _showFeedBacksPage(
                      context, widget.myUser, widget.myUser2.id!);
                },
              ),
            ]),
            //TODO: summary
            Summary(feedBacks: feedBacks),
            const SizedBox(height: 10),
            //TODO: 1 review
            if(feedBacks.isNotEmpty) _feedbackItem(feedBacks.first),
          ]);
        }
        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Column(children: [
        //TODO: fields
        Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                controller: widget.controller,
                reverse: false,
                child: Column(
                  children: [
                    //TODO: address
                    _address(),
                    const SizedBox(height: 10),
                    //TODO: _birthDate
                    _birthDate(),
                    const SizedBox(height: 10),
                    //TODO: _createdAt
                    _createdAt(),
                    const SizedBox(height: 10),
                    //TODO: _email
                    _email(),
                    const SizedBox(height: 10),
                    //TODO: _isActive
                    _isActive(),
                    const SizedBox(height: 10),
                    //TODO: _isBlock
                    _isBlock(),
                    const SizedBox(height: 10),
                    //TODO: _lastSignInAt
                    _lastSignInAt(),
                    const SizedBox(height: 10),
                    //TODO: _name
                    _name(),
                    const SizedBox(height: 10),
                    //TODO: _phoneNumber
                    _phoneNumber(),
                    const SizedBox(height: 10),
                    //TODO: _role
                    _role(),
                    const SizedBox(height: 10),
                    //TODO: _selfIntroduction
                    _selfIntroduction(),
                    const SizedBox(height: 10),
                    //TODO: _shipperInfo
                    _shipperInfo(),
                    const SizedBox(height: 10),
                    //TODO: _feedback
                    _feedback(),
                  ],
                ),
              ),
            )),
        //TODO: call, sms, chat
        if (widget.myUser2.id! != widget.myUser.id!)
          Row(children: [
            Row(children: const [Icon(Icons.call), Text('Gọi điện')]),
            Row(children: const [Icon(Icons.sms), Text('Gửi SMS')]),
            Row(children: const [Icon(Icons.chat), Text('Chat')]),
          ]),
      ]),
    );
  }
}
