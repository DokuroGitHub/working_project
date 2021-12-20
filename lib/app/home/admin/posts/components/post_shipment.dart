import 'dart:async';

import 'package:flutter/material.dart';

import '/app/home/member/posts/components/post_attachments.dart';
import '/models/my_user.dart';
import '/models/offer.dart';
import '/models/parcel.dart';
import '/models/shipment.dart';
import '/services/database_service.dart';
import 'my_user_avatar.dart';

class PostShipment extends StatefulWidget {
  const PostShipment({Key? key, required this.myUser, required this.shipment})
      : super(key: key);
  final MyUser myUser;
  final Shipment shipment;

  @override
  State<PostShipment> createState() => _PostShipmentState();
}

class _PostShipmentState extends State<PostShipment> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    super.dispose();

    _priceController.dispose();
    _notesController.dispose();
  }

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
    if (widget.shipment.parcel == null) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 10.0),
        //TODO: addressFrom
        _text('Ship From: ${widget.shipment.addressFrom?.details ?? ''}'),
        const SizedBox(
          height: 5.0,
        ),
        //TODO: addressTo
        _text('Ship To: ${widget.shipment.addressTo?.details ?? ''}'),
      ]);
    } else {
      return _parcel(widget.shipment.parcel!);
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
    if (widget.shipment.shippersEnrolled.length < 6) {
      for (var item in widget.shipment.shippersEnrolled) {
        shippersEnrolled.add(Row(children: [
          MyUserAvatar(
            myUser: null,
              myUserId: item,
              onTap: () {
                print('tap avatar of user: $item');
              }),
          const SizedBox(width: 10),
        ]));
      }
    } else {
      for (int index in [0, 4]) {
        shippersEnrolled.add(Row(children: [
          MyUserAvatar(
            myUser: null,
              myUserId: widget.shipment.shippersEnrolled[index],
              onTap: () {
                print(
                    'tap avatar of user: ${widget.shipment.shippersEnrolled[index]}');
              }),
          const SizedBox(width: 10),
        ]));
      }
      shippersEnrolled.add(Row(children: [
        MyUserAvatar(
          myUser: null,
            myUserId: widget.shipment.shippersEnrolled[5],
            onTap: () {
              print(
                  'tap avatar of user: ${widget.shipment.shippersEnrolled[5]}');
            }),
        const SizedBox(width: 10),
        Text('Và ${widget.shipment.shippersEnrolled.length - 6} người khác'),
      ]));
    }

    return Row(children: shippersEnrolled);
  }

  Future<void> _offerClick(BuildContext context) async {
    try {
      //TODO: show form
      //TODO: get
      Offer? offer = await DatabaseService().getOffer(
          shipmentId: widget.shipment.id!, myUserId: widget.myUser.id!);
      if (offer != null) {
        //TODO: set
        _priceController.text = offer.price.toString();
        _notesController.text = offer.notes ?? '';
      }
      await showDialog<void>(
        context: context,
        builder: (BuildContext _context) {
          return ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .8),
            child: AlertDialog(
                title: const Text('Thông tin offer'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      //TODO: price
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Giá đề nghị',
                          hintText: 'Vui lòng trả giá cho chuyến ship này',
                          border: OutlineInputBorder(),
                        ),
                        autocorrect: false,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                      ),
                      //TODO: notes
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Lưu chú',
                          hintText: 'Vui lòng điền mục lưu chú',
                          border: OutlineInputBorder(),
                        ),
                        autocorrect: false,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      //TODO: new
                      Offer offer = Offer(
                        createdAt: DateTime.now(),
                        createdBy: widget.myUser.id!,
                        notes: _notesController.text,
                        price: num.tryParse(_priceController.text) ?? 0,
                      );
                      //TODO: add offer
                      DatabaseService().addOfferToShipmentWithId(
                        shipmentId: widget.shipment.id!,
                        myUserId: widget.myUser.id!,
                        offerMap: offer.toMap(),
                      );
                      //TODO: update
                      widget.shipment.shippersEnrolled.removeWhere(
                          (element) => element == widget.myUser.id!);
                      widget.shipment.shippersEnrolled.add(widget.myUser.id!);
                      DatabaseService().updateShipment(
                          widget.shipment.id!, widget.shipment.toMap());

                      //TODO: everything ok
                      Navigator.of(context).pop();
                      final snackBar = SnackBar(
                        content: const Text('Offer đã được lưu thành công !'),
                        action: SnackBarAction(
                          label: 'Ok',
                          onPressed: () {
                            // Some code to undo the change.
                          },
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    child: const Text('Xác nhận offer'),
                  ),
                ]),
          );
        },
      );
    } catch (e) {
      unawaited(showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error occurred'),
          content: Text(e.toString()),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('ok'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ));
    }
  }

  Future<void> _deleteOffer(BuildContext context) async {
    try {
      //TODO: deleteOffer
      await DatabaseService().deleteOffer(
          shipmentId: widget.shipment.id!, myUserId: widget.myUser.id!);
      //TODO: update
      widget.shipment.shippersEnrolled
          .removeWhere((element) => element == widget.myUser.id!);
      await DatabaseService()
          .updateShipment(widget.shipment.id!, widget.shipment.toMap());
      //TODO: everything ok
      final snackBar = SnackBar(
        content: const Text('Offer đã được xóa thành công !'),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      unawaited(showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error occurred'),
          content: Text(e.toString()),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('ok'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ));
    }
  }

  //TODO: are you sure/_confirm
  Future<void> _deleteOfferClick(BuildContext context) async {
    final bool didRequest = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xóa bỏ offer?'),
            content: const Text(
                'Are you sure to delete your offer in this shipment'),
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
      await _deleteOffer(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //TODO: attachments
        PostAttachments(
            myUser: widget.myUser, attachments: widget.shipment.attachments),
        const SizedBox(
          height: 5.0,
        ),
        //TODO: shipment id
        _text('Ship ID: ${widget.shipment.id!}'),
        const SizedBox(
          height: 5.0,
        ),

        //TODO: type
        _text('Type: ${_type(widget.shipment.type)}'),
        const SizedBox(
          height: 5.0,
        ),

        //TODO: service
        _text('Service: ${_service(widget.shipment.service)}'),
        const SizedBox(
          height: 5.0,
        ),

        //TODO: price
        _text('Ship Fee: ${widget.shipment.cod}'),
        const SizedBox(
          height: 5.0,
        ),

        //TODO: type SHIPHANG thi co parcel
        _grabOrParcel(),
        const SizedBox(
          height: 5.0,
        ),

        //TODO: price
        _text('Lưu chú: ${widget.shipment.notes ?? ''}'),
        const SizedBox(
          height: 5.0,
        ),

        //TODO: shippersEnrolled
        _text('Shipper đăng kí: ${widget.shipment.shippersEnrolled}'),
        const SizedBox(
          height: 5.0,
        ),

        //TODO: shipperId
        _text(
            'Shipper được giao: ${widget.shipment.shipperId ?? 'Chưa giao cho shipper nào'}'),
        const SizedBox(
          height: 5.0,
        ),

        //TODO: status
        _text('Trạng thái: ${widget.shipment.status}'),

        const Divider(
          thickness: 1.5,
          color: Color(0xFF505050),
        ),

        //TODO: shipperEnrolled
        _shippersEnrolled(),
        //TODO: btn add/edit
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () async {
                  await _offerClick(context);
                },
                icon: Icon(
                  widget.shipment.shippersEnrolled.contains(widget.myUser.id!)
                      ? Icons.library_add
                      : Icons.edit,
                  color: Theme.of(context).textTheme.button?.color,
                ),
                label: Text(
                  widget.shipment.shippersEnrolled.contains(widget.myUser.id!)
                      ? 'Edit offer'
                      : 'Add offer',
                  style: Theme.of(context).textTheme.button,
                ),
              ),
            ),
            if (widget.shipment.shippersEnrolled.contains(widget.myUser.id!))
              Expanded(
                child: TextButton.icon(
                  onPressed: () async {
                    await _deleteOfferClick(context);
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).textTheme.button?.color,
                  ),
                  label: Text(
                    'Delete offer',
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
              ),
          ],
        )
      ],
    );
  }
}
