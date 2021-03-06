import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:working_project/app/home/member/shipments/edit_shipment/edit_shipment_page.dart';
import 'package:working_project/app/home/member/shipments/shipment_details/shipment_details_page.dart';

import '/models/my_user.dart';
import '/models/shipment.dart';
import '/services/database_service.dart';

class ShipmentsPage extends StatefulWidget {
  const ShipmentsPage({required this.myUser, this.controller});

  final MyUser myUser;
  final ScrollController? controller;

  @override
  _ShipmentsPageState createState() => _ShipmentsPageState();
}

class _ShipmentsPageState extends State<ShipmentsPage> {
  //Let's add the color code for our project
  Color bgBlack = const Color(0xFF1a1a1a);
  Color mainBlack = const Color(0xFF262626);
  Color fbBlue = const Color(0xFF2D88FF);
  Color mainGrey = const Color(0xFF505050);

  Future<void> _showShipmentDetailsPage(BuildContext context, String shipmentId) async {
    await ShipmentDetailsPage.showPlz(context: context, myUser: widget.myUser, shipmentId: shipmentId);
  }

  Future<void> _showEditShipmentPage(BuildContext context) async {
    await EditShipmentPage.showPlz(context: context, myUser: widget.myUser, shipment: null);
  }

  Widget _shipmentItem(BuildContext context, Shipment shipment) {
    return GestureDetector(
      onTap: () {
        print(
            'shipments_page, _shipmentItem, tap Shipment.id: ${shipment.id!}');
        //TODO: qua trang details
        _showShipmentDetailsPage(context, shipment.id!);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: const Color(0xFF262626),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //TODO: id, createdAt, addressFrom/To,...
              Text(shipment.id!, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBlack,
      //TODO: appBar
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: mainBlack,
        actions: [
          Expanded(
              child: TextField(
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 25.0),
                hintText: "Search something...",
                filled: true,
                fillColor: mainGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                )),
          )),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      //TODO: list shipments
      body: StreamBuilder(
          stream: DatabaseService().getStreamListShipment(),
          builder: (BuildContext ctx, AsyncSnapshot<List<Shipment>> snapshot) {
            if (snapshot.hasError) {
              print('shipments,  shipments has error: ${snapshot.error}');
              return Container();
            }
            if (snapshot.hasData) {
              List<Shipment> shipments = snapshot.data!;
              return ListView.builder(
                controller: widget.controller,
                itemCount: shipments.length,
                itemBuilder: (BuildContext ctx, int index) {
                  //if(shipments[index].createdBy == widget.myUser.id!)
                  return _shipmentItem(context, shipments[index]);
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
      floatingActionButton: FloatingActionButton(
          tooltip: 'Th??m m???i shipment',
          hoverColor: Colors.redAccent,
          child: const Icon(Icons.add),
          onPressed: () {
            _showEditShipmentPage(context);
          }),
    );
  }
}
