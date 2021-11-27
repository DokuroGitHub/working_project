import 'package:flutter/material.dart';

import '/app/home/member/posts/components/post_attachments.dart';
import '/models/my_user.dart';
import '/models/parcel.dart';
import '/models/shipment.dart';
import '/services/database_service.dart';

import 'my_user_avatar.dart';

class PostShipment extends StatelessWidget {
  const PostShipment({Key? key, required this.myUser, required this.shipment})
      : super(key: key);
  final MyUser myUser;
  final Shipment shipment;

  final String defaultThumbURL =
      'https://i0.wp.com/media.discordapp.net/attachments/781870041862897684/784806733431701514/EIB7R00XUAAwQ6a.png';

  Widget _text(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  String _service(String service) {
    String _service;
    switch (service) {
      case 'NHANH':
        _service = 'Ship Nhanh';
        break;
      case 'TIETKIEM':
        _service = 'Tiết kiệm';
        break;
      default:
        _service = '';
        break;
    }
    return _service;
  }

  String _type(String type) {
    String _type;
    switch (type) {
      case 'SHIPHANG':
        _type = 'Ship Hàng';
        break;
      case 'GRAB':
        _type = 'Grab';
        break;
      default:
        _type = '';
        break;
    }
    return _type;
  }

  Widget _grabOrParcel() {
    if (shipment.parcel == null) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 10.0),
        //TODO: addressFrom
        _text('Ship From: ${shipment.addressFrom?.details ?? ''}'),
        const SizedBox(
          height: 5.0,
        ),
        //TODO: addressTo
        _text('Ship To: ${shipment.addressTo?.details ?? ''}'),
      ]);
    } else {
      return _parcel(shipment.parcel!);
    }
  }

  Widget _parcel(Parcel parcel) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _text('Thông tin hàng vận chuyển'),
      const SizedBox(height: 10.0),
      _text('Name From: ${parcel.nameFrom ?? ''}'),
      const SizedBox(height: 10.0),
      _text('Phone From: ${parcel.phoneFrom ?? ''}'),
      const SizedBox(height: 10.0),
      _text('Name To: ${parcel.nameTo ?? ''}'),
      const SizedBox(height: 10.0),
      _text('Phone To: ${parcel.phoneTo ?? ''}'),
      const SizedBox(height: 10.0),
      _text('Description: ${parcel.description ?? ''}'),
      const SizedBox(height: 10.0),
      _text('Width: ${parcel.width ?? '0'}cm'),
      const SizedBox(height: 10.0),
      _text('Length: ${parcel.length ?? '0'}cm'),
      const SizedBox(height: 10.0),
      _text('Height: ${parcel.height ?? '0'}cm'),
      const SizedBox(height: 10.0),
      _text('Weight: ${parcel.weight ?? '0'}Kg'),
      const SizedBox(height: 10.0),
    ]);
  }

  Widget _shippersEnrolled() {
    List<Widget> shippersEnrolled = [];
    if (shipment.shippersEnrolled.length < 6) {
      for (var item in shipment.shippersEnrolled) {
        shippersEnrolled.add(Row(children: [
          MyUserAvatar(
              myUserId: item,
              onTap: () {
                print('tap avatar of user: $item');
              }),
          const SizedBox(width: 10),
        ]));
      }
    }else{
      for (int index in [0,4]) {
        shippersEnrolled.add(Row(children: [
          MyUserAvatar(
              myUserId: shipment.shippersEnrolled[index],
              onTap: () {
                print('tap avatar of user: ${shipment.shippersEnrolled[index]}');
              }),
          const SizedBox(width: 10),
        ]));
      }
      shippersEnrolled.add(Row(children: [
        MyUserAvatar(
            myUserId: shipment.shippersEnrolled[5],
            onTap: () {
              print('tap avatar of user: ${shipment.shippersEnrolled[5]}');
            }),
        const SizedBox(width: 10),
        Text('Và ${shipment.shippersEnrolled.length-6} người khác'),
      ]));
    }

    return Row(children: shippersEnrolled);
  }

  Future<void> _enroll(String myUserId, String shipmentId)async{
    var shipperEnrolled = shipment.shippersEnrolled;
    if(!shipperEnrolled.contains(myUserId)) {
      shipperEnrolled.add(myUserId);
    }else{
      shipperEnrolled.remove(myUserId);
    }
    Map<String, dynamic> shipmentMap = {
      'shippersEnrolled': shipperEnrolled,
    };
    DatabaseService().updateShipment(shipmentId, shipmentMap);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //TODO: attachments
        PostAttachments(myUser: myUser, attachments: shipment.attachments),
        const SizedBox(
          height: 5.0,
        ),
        //TODO: shipment id
        _text('Ship ID: ${shipment.id!}'),
        const SizedBox(
          height: 5.0,
        ),

        //TODO: type
        _text('Type: ${_type(shipment.type)}'),
        const SizedBox(
          height: 5.0,
        ),

        //TODO: service
        _text('Service: ${_service(shipment.service)}'),
        const SizedBox(
          height: 5.0,
        ),

        //TODO: price
        _text('Ship Fee: ${shipment.cod}'),
        const SizedBox(
          height: 5.0,
        ),

        //TODO: type SHIPHANG thi co parcel
        _grabOrParcel(),
        const SizedBox(
          height: 5.0,
        ),

        //TODO: price
        _text('Lưu chú: ${shipment.notes ?? ''}'),
        const SizedBox(
          height: 5.0,
        ),

        //TODO: shippersEnrolled
        _text('Shipper đăng kí: ${shipment.shippersEnrolled}'),
        const SizedBox(
          height: 5.0,
        ),

        //TODO: shipperId
        _text(
            'Shipper được giao: ${shipment.shipperId ?? 'Chưa giao cho shipper nào'}'),
        const SizedBox(
          height: 5.0,
        ),

        //TODO: status
        _text('Trạng thái: ${shipment.status}'),

        const Divider(
          thickness: 1.5,
          color: Color(0xFF505050),
        ),

        //TODO: shipperEnrolled
        _shippersEnrolled(),
        //TODO: btn add
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: (){
                  print('tap Enroll btn');
                  _enroll(myUser.id!, shipment.id!);
                },
                icon: const Icon(
                  Icons.library_add,
                  color: Color(0xFF505050),
                ),
                label: Text(shipment.shippersEnrolled.contains(myUser.id!)?'Out':'Enroll'),
              ),
            ),
          ],
        )
      ],
    );
  }
}
