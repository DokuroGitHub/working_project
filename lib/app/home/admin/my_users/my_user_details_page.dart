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
import 'package:working_project/services/database_service.dart';

class MyUserDetailsPage extends StatefulWidget {
  const MyUserDetailsPage({required this.myUser, required this.myUserId2});

  final MyUser myUser;
  final String myUserId2;

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<MyUserDetailsPage> {

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

  AppBar buildAppBar(MyUser myUser) {
    return AppBar(
      title: const Text(Strings.accountPage),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.lightbulb),
          color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          onPressed: () {
            //TODO: xu ly
            _showActions(context);
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: _buildUserInfo(myUser),
      ),
    );
  }

  Widget _address(MyUser myUser) {
    if (myUser.address == null) {
      return Container();
    }
    String? details = myUser.address!.details;
    String? city = myUser.address!.city;
    String? district = myUser.address!.district;
    String? street = myUser.address!.street;
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

  Widget _birthDate(MyUser myUser) {
    if (myUser.birthDate == null) {
      return Container();
    }
    return Row(children: [
      const Icon(Icons.date_range_outlined),
      const SizedBox(width: 10),
      Text('Ngày sinh: ${myUser.birthDate!.toString()}'),
    ]);
  }

  Widget _createdAt(MyUser myUser) {
    return Row(children: [
      const Icon(Icons.date_range_outlined),
      const SizedBox(width: 10),
      Text('Tham gia lúc: ${myUser.createdAt.toString()}'),
    ]);
  }

  Widget _email(MyUser myUser) {
    if (myUser.email == null) {
      return Container();
    }
    return Row(children: [
      const Icon(Icons.mail_outline_outlined),
      const SizedBox(width: 10),
      Text('Email: ${myUser.email!}'),
    ]);
  }

  Widget _isActive(MyUser myUser) {
    if (myUser.isActive) {
      return Row(children: const [
        Icon(Icons.online_prediction_outlined),
        SizedBox(width: 10),
        Text('Online: Đang hoạt động'),
      ]);
    }
    String text =
        'Online: Hoạt động cách đây ${Helper.timeToString(myUser.lastSignInAt).toString()}';
    return Row(children: [
      const Icon(Icons.online_prediction_outlined),
      const SizedBox(width: 10),
      Text(text),
    ]);
  }

  Widget _isBlock(MyUser myUser) {
    if (myUser.isBlocked) {
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

  Widget _lastSignInAt(MyUser myUser) {
    return Row(children: [
      const Icon(Icons.date_range_outlined),
      const SizedBox(width: 10),
      Text('Đăng nhập lần cuối: ${myUser.lastSignInAt}'),
    ]);
  }

  Widget _name(MyUser myUser) {
    return Row(children: [
      const Icon(Icons.tag_faces_outlined),
      const SizedBox(width: 10),
      Text('Tên: ${myUser.name ?? ''}'),
    ]);
  }

  Widget _phoneNumber(MyUser myUser) {
    return Row(children: [
      const Icon(Icons.phone),
      const SizedBox(width: 10),
      const Text('Số điện thoại: '),
      Container(
        child:
        Text(myUser.phoneNumber ?? 'Người dùng chưa thiết lập sđt'),
        padding: const EdgeInsets.all(5.0),
        decoration: const BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
      ),
    ]);
  }

  Widget _role(MyUser myUser) {
    return Row(children: [
      const Icon(Icons.people_alt_outlined),
      const SizedBox(width: 10),
      const Text('Role: '),
      Container(
        child: Text(myUser.role),
        padding: const EdgeInsets.all(5.0),
        decoration: const BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
      ),
    ]);
  }

  Widget _selfIntroduction(MyUser myUser) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.event_note_outlined),
      const SizedBox(width: 10),
      const Text('Giới thiệu: '),
      const SizedBox(width: 10),
      Container(
        child: Text(myUser.selfIntroduction ?? ''),
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

  Widget _shipperInfo(MyUser myUser) {
    if (myUser.shipperInfo == null) {
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
                  child: Text(myUser.shipperInfo!.vehicleType ?? ''),
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
                      'Miêu tả: ${myUser.shipperInfo!.vehicleDescription ?? ''}'),
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
                  child: Text(myUser.shipperInfo!.status ?? ''),
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

  Widget _feedback(MyUser myUser) {
    return StreamBuilder(
      stream: DatabaseService().getStreamListFeedback(myUser.id!),
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
                      context, widget.myUser, myUser.id!);
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


  Future<void> _blockMyUser() async {
    MyUser? myUser = await DatabaseService().getMyUserByDocumentId(widget.myUserId2);
    if(myUser!=null){
      myUser.isBlocked = !myUser.isBlocked;
      await DatabaseService().updateMyUserOnDB(myUser.id!, myUser.toMap());
    }
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
                            _blockMyUser();
                          },
                          child: const Text('Khóa người dùng')),
                    ),
                    const Spacer(),
                  ]),
                ]),
          ),
        ),
      ),
    );
  }

  Widget _buildMyUser(){
    return StreamBuilder(stream: DatabaseService().getStreamMyUserByDocumentId(widget.myUserId2),
      builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
      if(snapshot.data!=null){
        MyUser myUser = snapshot.data!;
        return Scaffold(
          appBar: buildAppBar(myUser),
          body: Column(children: [
            //TODO: fields
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    reverse: false,
                    child: Column(
                      children: [
                        //TODO: address
                        _address(myUser),
                        const SizedBox(height: 10),
                        //TODO: _birthDate
                        _birthDate(myUser),
                        const SizedBox(height: 10),
                        //TODO: _createdAt
                        _createdAt(myUser),
                        const SizedBox(height: 10),
                        //TODO: _email
                        _email(myUser),
                        const SizedBox(height: 10),
                        //TODO: _isActive
                        _isActive(myUser),
                        const SizedBox(height: 10),
                        //TODO: _isBlock
                        _isBlock(myUser),
                        const SizedBox(height: 10),
                        //TODO: _lastSignInAt
                        _lastSignInAt(myUser),
                        const SizedBox(height: 10),
                        //TODO: _name
                        _name(myUser),
                        const SizedBox(height: 10),
                        //TODO: _phoneNumber
                        _phoneNumber(myUser),
                        const SizedBox(height: 10),
                        //TODO: _role
                        _role(myUser),
                        const SizedBox(height: 10),
                        //TODO: _selfIntroduction
                        _selfIntroduction(myUser),
                        const SizedBox(height: 10),
                        //TODO: _shipperInfo
                        _shipperInfo(myUser),
                        const SizedBox(height: 10),
                        //TODO: _feedback
                        _feedback(myUser),
                      ],
                    ),
                  ),
                )),
          ]),
        );
      }
      return const Text('_buildMyUser waitttt');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMyUser();
  }
}
