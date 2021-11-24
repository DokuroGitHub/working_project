import 'package:flutter/material.dart';

import '/models/my_user.dart';
import '/models/shipment.dart';
import '/services/database_service.dart';

import 'components/body.dart';

class ShipmentDetailsPage extends StatefulWidget {
  const ShipmentDetailsPage({required this.myUser, required this.shipmentId});

  final MyUser myUser;
  final String shipmentId;

  @override
  State<ShipmentDetailsPage> createState() => _ShipmentDetailsPageState();
}

class _ShipmentDetailsPageState extends State<ShipmentDetailsPage> {

  @override
  Widget build(BuildContext context) {
    print('ShipmentDetailsPage');
    return StreamBuilder(
      stream: DatabaseService().getStreamShipmentByDocumentId(widget.shipmentId),
      builder: (BuildContext context,
          AsyncSnapshot<Shipment?> snapshot) {
        if (snapshot.hasError) {
          print('ShipmentDetailsPage error');
          return Container();
        }
        if (snapshot.hasData) {
          return Body(
              myUser: widget.myUser, shipment: snapshot.data!);
        } else {
          return Container();
        }
      },
    );
  }
}
