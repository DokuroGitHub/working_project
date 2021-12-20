import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:working_project/app/home/feedbacks/feedbacks_page.dart';
import 'package:working_project/app/home/member/posts/post_details_page.dart';
import 'package:working_project/app/home/messages/messages_page.dart';
import 'package:working_project/services/message_service.dart';

import '/app/home/account/account_page.dart';

import '/app/home/member/shipments/edit_shipment/edit_shipment_page.dart';
import '/common_widgets/avatar.dart';
import '/constants/ui.dart';
import '/models/feedback.dart';
import '/models/my_user.dart';
import '/models/offer.dart';
import '/models/shipment.dart';
import '/services/database_service.dart';
import 'shipment_attachments.dart';

class Body extends StatefulWidget {
  const Body({required this.myUser, required this.shipment});

  final MyUser myUser;
  final Shipment shipment;

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Future<void> _showEditShipmentPage(BuildContext context) async {
    await EditShipmentPage.showPlz(
        context: context, myUser: widget.myUser, shipment: widget.shipment);
  }

  Future<void> _showProfilePage(BuildContext context, String myUserId2) async {
    await AccountPage.showPlz(context: context, myUser: widget.myUser, myUserId2: myUserId2);
  }

  Future<void> _showMessagesPage(BuildContext context, String myUserId2) async {
    await MessagesPage.showPlz(context: context, myUser: widget.myUser, myUserId2: myUserId2);
  }

  Widget _circleAvatar({String? photoURL}) {
    return CircleAvatar(
      backgroundImage: NetworkImage(photoURL ?? defaultPhotoURL),
      radius: 25.0,
    );
  }

  Widget _avatar(String myUserId) {
    return StreamBuilder(
        stream: DatabaseService().getStreamMyUserByDocumentId(myUserId),
        builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
          if (snapshot.hasError) {
            return _circleAvatar();
          }
          if (snapshot.hasData) {
            //TODO: avatar
            return _circleAvatar(photoURL: snapshot.data?.photoURL);
          } else {
            return _circleAvatar();
          }
        });
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(children: [
        BackButton(color: Theme.of(context).textTheme.bodyText1?.color),
        const Text('Thông tin chi tiết'),
      ]),
      actions: [
        IconButton(
          icon: const Icon(Icons.local_phone),
          color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.lightbulb),
          color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          onPressed: () {
            //TODO: xu ly report
            _showActions(context);
          },
        ),
        const SizedBox(width: kDefaultPadding / 2),
      ],
    );
  }

  Widget _addressFrom() {
    if (widget.shipment.addressFrom == null) {
      return Container();
    }
    String? details = widget.shipment.addressFrom?.details;
    String? city = widget.shipment.addressFrom?.city;
    String? district = widget.shipment.addressFrom?.district;
    String? street = widget.shipment.addressFrom?.street;
    String address = '';
    if (details != null) {
      address = details;
    } else {
      address = '$street, $district, $city';
    }
    address.replaceAll(',,', ',');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Địa chỉ bắt đầu:'),
      const SizedBox(height: 10),
      Row(children: [
        const SizedBox(width: 20),
        const Icon(Icons.location_pin),
        const SizedBox(width: 10),
        Text(address),
      ]),
    ]);
  }

  Widget _addressTo() {
    if (widget.shipment.addressTo == null) {
      return Container();
    }
    String? details = widget.shipment.addressTo?.details;
    String? city = widget.shipment.addressTo?.city;
    String? district = widget.shipment.addressTo?.district;
    String? street = widget.shipment.addressTo?.street;
    String address = '';
    if (details != null) {
      address = details;
    } else {
      address = '$street, $district, $city';
    }
    address.replaceAll(',,', ',');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Địa chỉ đến:'),
      const SizedBox(height: 10),
      Row(children: [
        const SizedBox(width: 20),
        const Icon(Icons.location_pin),
        const SizedBox(width: 10),
        Text(address),
      ]),
    ]);
  }

  Widget _attachments() {
    return Column(children: [
      Row(children: const [
        Icon(Icons.attachment),
        SizedBox(width: 10),
        Text('Tệp đính kèm: '),
      ]),
      const SizedBox(width: 10),
      Container(
        padding: const EdgeInsets.all(5.0),
        decoration: const BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        child: ShipmentAttachments(
          myUser: widget.myUser,
          attachments: widget.shipment.attachments,
        ),
      ),
    ]);
  }

  Widget _cod() {
    return Row(children: [
      const Icon(Icons.monetization_on_outlined),
      const SizedBox(width: 10),
      Text('Tiền phí: ${widget.shipment.cod} vnđ'),
    ]);
  }

  Widget _createdAt() {
    return Row(children: [
      const Icon(Icons.date_range_outlined),
      const SizedBox(width: 10),
      Text('Tạo lúc: ${widget.shipment.createdAt.toString()}'),
    ]);
  }

  Widget _notes() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.event_note_outlined),
      const SizedBox(width: 10),
      const Text('Lưu chú: '),
      const SizedBox(width: 10),
      Container(
        child: Text(widget.shipment.notes ?? ''),
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

  Widget _type() {
    //TODO: SHIPHANG
    if (widget.shipment.type == 'SHIPHANG') {
      return Row(children: [
        const Icon(Icons.category_outlined),
        const SizedBox(width: 10),
        const Text('Loại ship: '),
        const SizedBox(width: 10),
        const Icon(Icons.card_giftcard_outlined),
        const SizedBox(width: 10),
        Container(
          child: Text(widget.shipment.type),
          padding: const EdgeInsets.all(5.0),
          decoration: const BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
        ),
      ]);
    }
    //TODO: SHIPNGUOI
    return Row(children: [
      const Icon(Icons.category_outlined),
      const SizedBox(width: 10),
      const Text('Loại ship: '),
      const SizedBox(width: 10),
      const Icon(Icons.people_alt_outlined),
      const SizedBox(width: 10),
      Container(
        child: Text(widget.shipment.type),
        padding: const EdgeInsets.all(5.0),
        decoration: const BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
      ),
    ]);
  }

  bool _showParcel = true;

  Widget _parcel() {
    print('build parcel');
    if (widget.shipment.parcel == null) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          child: Row(children: const [
            Icon(Icons.card_giftcard_outlined),
            SizedBox(width: 10),
            Text('Thông tin hàng: '),
          ]),
          onTap: () {
            setState(() {
              _showParcel = !_showParcel;
            });
          },
        ),
        const SizedBox(height: 10),
        if (_showParcel)
          Container(
            padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.code),
                const SizedBox(width: 10),
                Text('CODE: ${widget.shipment.parcel!.code ?? ''}'),
              ]),
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.emoji_people),
                const SizedBox(width: 10),
                Text(
                    'Người đưa hàng: ${widget.shipment.parcel!.nameFrom ?? ''}'),
              ]),
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.phone),
                const SizedBox(width: 10),
                const Text('Sđt người đưa hàng: '),
                TextButton(
                  child: Text(widget.shipment.parcel!.phoneFrom ?? ''),
                  onPressed: () {},
                ),
              ]),
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.emoji_people),
                const SizedBox(width: 10),
                Text(
                    'Người nhận hàng: ${widget.shipment.parcel!.nameTo ?? ''}'),
              ]),
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.phone),
                const SizedBox(width: 10),
                const Text('Sđt người nhận hàng: '),
                TextButton(
                  child: Text(widget.shipment.parcel!.phoneTo ?? ''),
                  onPressed: () {},
                ),
              ]),
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.event_note_outlined),
                const SizedBox(width: 10),
                const Text('Miêu tả: '),
                const SizedBox(width: 10),
                Container(
                  child: Text(widget.shipment.parcel!.description ?? ''),
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
                const Icon(Icons.format_size_outlined),
                const SizedBox(width: 10),
                Text('Chiều dài(cm): ${widget.shipment.parcel!.length ?? ''}'),
              ]),
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.format_size_outlined),
                const SizedBox(width: 10),
                Text('Chiều rộng(cm): ${widget.shipment.parcel!.width ?? ''}'),
              ]),
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.format_size_outlined),
                const SizedBox(width: 10),
                Text('Chiều cao(cm): ${widget.shipment.parcel!.height ?? ''}'),
              ]),
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.format_size_sharp),
                const SizedBox(width: 10),
                Text(
                    'Trọng lượng(kg): ${widget.shipment.parcel!.weight ?? ''}'),
              ]),
            ]),
          ),
        if (!_showParcel)
          Row(children: const [SizedBox(width: 50), Icon(Icons.expand)]),
      ],
    );
  }

  Widget _postId(BuildContext context) {
    if (widget.shipment.postId == null) {
      return Container();
    }
    return Row(children: [
      const Icon(Icons.post_add_outlined),
      const SizedBox(width: 10),
      const Text('Bài post: '),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: () {
          //TODO: open post
          print('shipment_details, click postId: ${widget.shipment.postId}');
          String? postId = widget.shipment.postId;
          if(postId!=null) {
            PostDetailsPage.showPlz(context, widget.myUser, postId);
          }else{
            final snackBar = SnackBar(
              content: const Text('Không tìm thấy bài viết !'),
              action: SnackBarAction(
                label: 'Ok',
                onPressed: () {
                },
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        child: Container(
          child: Text(widget.shipment.postId!),
          padding: const EdgeInsets.all(5.0),
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
        ),
      ),
    ]);
  }

  Widget _service() {
    //TODO: NHANH
    if (widget.shipment.service == 'NHANH') {
      return Row(children: [
        const Icon(Icons.speed_outlined),
        const SizedBox(width: 10),
        const Text('Gói dịch vụ: '),
        const SizedBox(width: 10),
        const Icon(Icons.fastfood),
        const SizedBox(width: 10),
        Container(
          child: Text(widget.shipment.service),
          padding: const EdgeInsets.all(5.0),
          decoration: const BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
        ),
      ]);
    }
    //TODO: TIETKIEM
    return Row(children: [
      const Icon(Icons.speed_outlined),
      const SizedBox(width: 10),
      const Text('Gói dịch vụ: '),
      const SizedBox(width: 10),
      const Icon(Icons.free_breakfast),
      const SizedBox(width: 10),
      Container(
        child: Text(widget.shipment.service),
        padding: const EdgeInsets.all(5.0),
        decoration: const BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
      ),
    ]);
  }

  Widget _shipperId() {
    if (widget.shipment.shipperId == null) {
      return Row(children: const [
        Icon(Icons.local_shipping_outlined),
        SizedBox(width: 10),
        Text('Shipper được giao: Chưa giao cho shipper nào'),
      ]);
    }
    return Row(children: [
      const Icon(Icons.local_shipping_outlined),
      const SizedBox(width: 10),
      const Text('Shipper được giao:'),
      const SizedBox(width: 10),
      Tooltip(
          child: _avatar(widget.shipment.shipperId!),
          message: 'ShipperId: ${widget.shipment.shipperId!}'),
    ]);
  }

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
        } else {
          print('PostBox, _rating, snapshot feedback hasData false');
          return Container();
        }
      },
    );
  }

  //TODO: _acceptOffer
  Future<void> _acceptOffer(BuildContext context, String shipperId) async {
    try {
      //TODO: update shipment
      widget.shipment.shipperId = shipperId;
      widget.shipment.status = ShipmentStatus.SHIPPERDANGGIAO;
      await DatabaseService()
          .updateShipment(widget.shipment.id!, widget.shipment.toMap());

      //TODO: everything ok
      final snackBar = SnackBar(
        content: const Text('Accepted offer successfully !'),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      print('sending email');
      String? winnerEmail;
      List<String> loserEmails = [];
      for(int i=0;i<widget.shipment.shippersEnrolled.length;i++){
        MyUser? myUser = await DatabaseService().getMyUserByDocumentId(widget.shipment.shippersEnrolled[i]);
        String? email = myUser?.email;
        if(email!=null) {
          if(myUser!.id! == shipperId){
            winnerEmail = email;
          }else {
            loserEmails.add(email);
          }
        }
      }
      //TODO: send mail
      MessageService().sendMail(winnerEmail: winnerEmail, loserEmails: loserEmails);

    } catch (e) {
      unawaited(showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error occurred'),
          content: Text(e.toString()),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ));
    }
  }

  //TODO: are you sure/_confirm
  Future<void> _confirmAcceptOffer(BuildContext context, Offer offer) async {
    final bool didRequest = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Chấp nhận offer?'),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Are you sure to acc this offer?'),
                      const SizedBox(height: 10),
                      Row(children: [
                        const Icon(Icons.attach_money),
                        Text('Price(vnđ): ${offer.price}'),
                      ]),
                      RichText(
                        text: TextSpan(
                          children: [
                            const WidgetSpan(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2.0),
                                child: Icon(Icons.description),
                              ),
                            ),
                            TextSpan(
                                text: 'Notes: ${offer.notes}',
                                style: Theme.of(context).textTheme.bodyText1),
                          ],
                        ),
                      ),
                    ]),
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                child: const Text('Ok'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
    if (didRequest == true) {
      await _acceptOffer(context, offer.createdBy);
    }
  }

  //TODO: _offerItemLongPress
  Future<void> _offerItemLongPress(BuildContext context, String myUserId2) async {
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
                            _showProfilePage(context, myUserId2);
                          },
                          child: const Text('Xem profile')),
                    ),
                    const Spacer(),
                  ]),
                  Row(children: [
                    const Spacer(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .5,
                      child: TextButton(
                          onPressed: () {
                            print('call');
                            Navigator.of(context2).pop();
                          },
                          child: const Text('Gọi')),
                    ),
                    const Spacer(),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    const Spacer(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .5,
                      child: TextButton(
                          onPressed: () {
                            print('sms');
                            Navigator.of(context2).pop();
                          },
                          child: const Text('Nhắn tin SMS')),
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
                            _showMessagesPage(context, myUserId2);
                          },
                          child: const Text('Chat')),
                    ),
                    const Spacer(),
                  ]),
                ]),
          ),
        ),
      ),
    );
  }

  Widget _offerItem(Offer offer) {
    return StreamBuilder(
      stream: DatabaseService().getStreamMyUserByDocumentId(offer.createdBy),
      builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
        if (snapshot.hasError) {
          return Container();
        }
        if (snapshot.hasData) {
          MyUser myUser = snapshot.data!;
          return ListTile(
            onTap: () {
              //TODO: confirm acc this offer?
              _confirmAcceptOffer(context, offer);
            },
            onLongPress: () {
              //TODO: show dialog/view info
              _offerItemLongPress(context, offer.createdBy);
            },
            tileColor: Theme.of(context).backgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            leading: _circleAvatar(photoURL: myUser.photoURL),
            title: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(myUser.name ?? '', overflow: TextOverflow.ellipsis,),
              const SizedBox(width: 5),
              _rating(context, offer.createdBy),
            ]),
            subtitle: Text(myUser.phoneNumber ?? ''),
            trailing: SizedBox(
              width: MediaQuery.of(context).size.width * .35,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Offer: ${offer.price} vnđ'),
                    Text(
                      'Notes: ${offer.notes}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _shippersEnrolled() {
    if (widget.shipment.shippersEnrolled.isEmpty) {
      return Row(children: const [
        Icon(Icons.people_alt_outlined),
        SizedBox(width: 10),
        Text('Shipper đăng kí: Chưa có shipper nào'),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: const [
        Icon(Icons.people_alt_outlined),
        SizedBox(width: 10),
        Text('Shipper đăng kí:'),
      ]),
      StreamBuilder(
        stream: DatabaseService().getStreamListOffer(widget.shipment.id!),
        builder: (BuildContext context, AsyncSnapshot<List<Offer>> snapshot) {
          if (snapshot.hasError) {
            return Container();
          }
          if (snapshot.hasData) {
            List<Offer> offers = snapshot.data!;
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: offers.map((e) {
                  return Column(children: [
                    _offerItem(e),
                    const SizedBox(height: 5),
                  ]);
                }).toList());
          }
          return Container();
        },
      ),
    ]);
  }

  Widget _status() {
    return Row(children: [
      const Icon(Icons.timelapse_outlined),
      const SizedBox(width: 10),
      const Text('Status: '),
      const SizedBox(width: 10),
      Container(
          child: Text(widget.shipment.status),
          padding: const EdgeInsets.all(5.0),
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.all(Radius.circular(25)),
          )),
    ]);
  }


  Future<void> _changeShipmentStatus() async {
    Shipment? shipment = await DatabaseService().getShipmentByDocumentId(widget.shipment.id!);
    if(shipment!=null){
      if(shipment.status == 'SHIPPERDANGGIAO'){
        shipment.status = 'DAXONG';
      }else{
        shipment.status = 'SHIPPERDANGGIAO';
      }
      await DatabaseService().updateShipment(shipment.id!, shipment.toMap());
    }
  }

  Future<void> _sendFeedback(BuildContext context) async {
    Shipment? shipment = await DatabaseService().getShipmentByDocumentId(widget.shipment.id!);
    if(shipment!=null){
      String? shipperId = shipment.shipperId;
      if(shipperId!=null) {
        if(widget.myUser.id! == shipment.createdBy) {
          //TODO: đánh giá shipper
          FeedBacksPage.showPlz(context, widget.myUser, shipperId);
        }
        if(widget.myUser.id! == shipperId) {
          //TODO: đánh giá chủ shipment
          FeedBacksPage.showPlz(context, widget.myUser, shipment.createdBy);
        }
      }else{
        const snackBar = SnackBar(content: Text('Shippment chưa được giao cho shipper nào'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
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
                            _changeShipmentStatus();
                          },
                          child: const Text('Thay đổi trạng thái shipment')),
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
                            _sendFeedback(context);
                          },
                          child: const Text('Gửi feedback')),
                    ),
                    const Spacer(),
                  ]),
                ]),
          ),
        ),
      ),
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
            reverse: false,
            child: Column(
              children: [
                //TODO: addressFrom
                _addressFrom(),
                const SizedBox(height: 10),
                //TODO: _addressTo
                _addressTo(),
                const SizedBox(height: 10),
                //TODO: attachments
                _attachments(),
                const SizedBox(height: 10),
                //TODO: cod
                _cod(),
                const SizedBox(height: 10),
                //TODO: createdAt
                _createdAt(),
                const SizedBox(height: 10),
                //TODO: notes
                _notes(),
                const SizedBox(height: 10),
                //TODO: type
                _type(),
                const SizedBox(height: 10),
                //TODO: parcel
                _parcel(),
                const SizedBox(height: 10),
                //TODO: postId
                _postId(context),
                const SizedBox(height: 10),
                //TODO: service
                _service(),
                const SizedBox(height: 10),
                //TODO: _status
                _status(),
                const SizedBox(height: 10),
                //TODO: _shipperId
                _shipperId(),
                const SizedBox(height: 10),
                //TODO: _shippersEnrolled
                _shippersEnrolled(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        )),
        //TODO: call, sms, chat
        Row(children: [
          Row(children: const [Icon(Icons.call), Text('Gọi điện')]),
          Row(children: const [Icon(Icons.sms), Text('Gửi SMS')]),
          Row(children: const [Icon(Icons.chat), Text('Chat')]),
        ]),
      ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () {
          if (widget.shipment.status == 'DANGTIMSHIPPER') {
            //TODO: go to edit
            _showEditShipmentPage(context);
          } else {
            final snackBar = SnackBar(
              content: const Text(
                  'Shipment đang trong giai đoạn thực hiện, không thể chỉnh sửa !'),
              action: SnackBarAction(
                label: 'Ok',
                onPressed: () {
                  // Some code to undo the change.
                },
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
      ),
    );
  }
}
