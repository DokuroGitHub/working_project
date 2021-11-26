import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '/routing/app_router.dart';
import 'shipment_attachments.dart';
import '/common_widgets/avatar.dart';
import '/constants/ui.dart';
import '/models/feedback.dart';
import '/models/my_user.dart';
import '/models/offer.dart';
import '/models/shipment.dart';
import '/services/database_service.dart';

class Body extends StatefulWidget {
  const Body({required this.myUser, required this.shipment});

  final MyUser myUser;
  final Shipment shipment;

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {

  Future<void> _showEditShipmentPage(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.editShipmentPage,
      arguments: {
        'myUser': widget.myUser,
        'shipment': widget.shipment,
      },
    );
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
      title: Row(children: const [
        BackButton(),
        Text('Thông tin chi tiết'),
      ]),
      actions: [
        IconButton(
          icon: const Icon(Icons.local_phone),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {},
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
                  onPressed: () {

                  },
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
                    onPressed: () {

                    },
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

  Widget _postId() {
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

  Widget _shippersEnrolledItem(String myUserId) {
    return GestureDetector(
      onTap: (){
        //TODO: view profile
        print('shipment body, tap _shippersEnrolledItem with myUserId: $myUserId');
      },
      child: Container(
        padding: const EdgeInsets.all(5.0),
        decoration: const BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        child: Row(children: [
          //TODO: avatar+name+phone
          StreamBuilder(
              stream: DatabaseService().getStreamMyUserByDocumentId(myUserId),
              builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
                if (snapshot.hasError) {
                  return Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * .5));
                }
                if (snapshot.hasData) {
                  return Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * .5),
                    child: Row(children: [
                      //TODO: avatar
                      _circleAvatar(photoURL: snapshot.data!.photoURL),
                      //TODO: name+rating+phone
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //TODO: name+rating
                            Row(mainAxisSize: MainAxisSize.min,
                                children:[
                              Text(snapshot.data!.name ?? ''),
                              const SizedBox(width: 10),
                              _rating(context, myUserId),
                            ]),
                            //TODO: phone
                            Text(snapshot.data!.phoneNumber ?? ''),
                          ]),
                    ]),
                  );
                }
                return ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * .5),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }),
          //TODO: price+notes
          StreamBuilder(
              stream: DatabaseService()
                  .getStreamOfferByDocumentId(widget.shipment.id!, myUserId),
              builder: (BuildContext context, AsyncSnapshot<Offer?> snapshot) {
                if (snapshot.hasError) {
                  return Container();
                }
                if (snapshot.hasData) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Offer: ${snapshot.data!.price} vnđ'),
                        Text('Notes: ${snapshot.data!.notes}'),
                      ]);
                } else {
                  return Container();
                }
              }),
        ]),
      ),
    );
  }

  Widget _shippersEnrolled() {
    List<String> myUserIds = widget.shipment.shippersEnrolled;
    if (myUserIds.isEmpty) {
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
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: myUserIds.map((e) {
            return Column(children: [
              _shippersEnrolledItem(e),
              const SizedBox(height: 10),
            ]);
          }).toList()),
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
                _postId(),
                const SizedBox(height: 10),
                //TODO: service
                _service(),
                const SizedBox(height: 10),
                //TODO: _shipperId
                _shipperId(),
                const SizedBox(height: 10),
                //TODO: _shippersEnrolled
                _shippersEnrolled(),
                const SizedBox(height: 10),
                //TODO: _status
                _status(),
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
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.edit),
        onPressed: () {
          if(widget.shipment.status=='DANGTIMSHIPPER') {
            //TODO: go to edit
            _showEditShipmentPage(context);
          }else{
            final snackBar = SnackBar(
              content: const Text('Shipment đang trong giai đoạn thực hiện, không thể chỉnh sửa !'),
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
