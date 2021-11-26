import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/models/post.dart';
import '/models/address.dart';
import '/models/attachment.dart';
import '/models/my_user.dart';
import '/models/parcel.dart';
import '/models/shipment.dart';
import '/services/database_service.dart';

class EditShipmentPage extends StatefulWidget {
  const EditShipmentPage({required this.myUser, this.shipment});

  final MyUser myUser;
  final Shipment? shipment;

  @override
  _EditShipmentPageState createState() => _EditShipmentPageState();
}

class _EditShipmentPageState extends State<EditShipmentPage> {
  final FocusScopeNode _node = FocusScopeNode();

  final TextEditingController _addressFromController = TextEditingController();
  final TextEditingController _addressFromDetailsController =
      TextEditingController();
  final TextEditingController _addressFromStreetController =
      TextEditingController();
  final TextEditingController _addressFromDistrictController =
      TextEditingController();
  final TextEditingController _addressFromCityController =
      TextEditingController();

  final TextEditingController _addressToController = TextEditingController();
  final TextEditingController _addressToDetailsController =
      TextEditingController();
  final TextEditingController _addressToStreetController =
      TextEditingController();
  final TextEditingController _addressToDistrictController =
      TextEditingController();
  final TextEditingController _addressToCityController =
      TextEditingController();

  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  final TextEditingController _parcelController = TextEditingController();
  final TextEditingController _parcelCodeController = TextEditingController();
  final TextEditingController _parcelDescriptionController =
      TextEditingController();
  final TextEditingController _parcelHeightController = TextEditingController();
  final TextEditingController _parcelLengthController = TextEditingController();
  final TextEditingController _parcelNameFromController =
      TextEditingController();
  final TextEditingController _parcelNameToController = TextEditingController();
  final TextEditingController _parcelPhoneFromController =
      TextEditingController();
  final TextEditingController _parcelPhoneToController =
      TextEditingController();
  final TextEditingController _parcelWeightToController =
      TextEditingController();
  final TextEditingController _parcelWidthToController =
      TextEditingController();

  final TextEditingController _codController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _codErrorText;
  final num _distance = 10;
  num _weight = 0;
  num _length = 0;
  num _width = 0;
  num _height = 0;

  //TODO: _saveChanges
  Future<void> _saveChanges(BuildContext context) async {
    if (widget.shipment == null) {
      //TODO: add
      try {
        //TODO: new
        var addressFrom = _addressFromController.text.isNotEmpty
            ? Address(
                details: _addressFromDetailsController.text,
                street: _addressFromStreetController.text,
                district: _addressFromDistrictController.text,
                city: _addressFromCityController.text,
                location: null,
              )
            : null;
        var addressTo = _addressToController.text.isNotEmpty
            ? Address(
                details: _addressToDetailsController.text,
                street: _addressToStreetController.text,
                district: _addressToDistrictController.text,
                city: _addressToCityController.text,
                location: null,
              )
            : null;
        var attachment1 = 1 == 2
            ? Attachment(
                thumbURL: '',
                fileURL: '',
                type: 'IMAGE',
              )
            : null;
        List<Attachment> attachments = [];
        if (attachment1 != null) {
          attachments.add(attachment1);
        }
        num cod = num.tryParse(_codController.text) ?? 0;
        var parcel = _typeController.text=='SHIPHANG' && _parcelController.text.isNotEmpty
            ? Parcel(
                code: _parcelCodeController.text,
                description: _parcelDescriptionController.text,
                height: num.tryParse(_parcelHeightController.text) ?? 0,
                length: num.tryParse(_parcelLengthController.text) ?? 0,
                nameFrom: _parcelNameFromController.text,
                nameTo: _parcelNameToController.text,
                phoneFrom: _parcelPhoneFromController.text,
                phoneTo: _parcelPhoneToController.text,
                weight: num.tryParse(_parcelWeightToController.text) ?? 0,
                width: num.tryParse(_parcelWidthToController.text) ?? 0,
              )
            : null;
        //TODO: shipment
        Shipment shipment = Shipment(
          addressFrom: addressFrom,
          addressTo: addressTo,
          attachments: attachments,
          cod: cod,
          createdAt: DateTime.now(),
          createdBy: widget.myUser.id!,
          notes: _notesController.text,
          parcel: parcel,
          postId: null,
          service: _serviceController.text,
          shipperId: null,
          shippersEnrolled: [],
          status: 'DANGTIMSHIPPER',
          type: _typeController.text,
        );
        //TODO: add shipment
        String? shipmentId =
            await DatabaseService().addShipment(shipment.toMap());
        if (shipmentId == null) {
          throw Exception('Thêm shipment thất bại');
        }
        //TODO: post
        Post post = Post(
          attachments: [],
          text: null,
          createdAt: DateTime.now(),
          createdBy: widget.myUser.id!,
          editedAt: null,
          shipmentId: shipmentId,
        );
        //TODO: add post
        String? postId = await DatabaseService().addPost(post.toMap());
        if (postId == null) {
          throw Exception('Thêm post thất bại');
        }

        //TODO: update shipment
        shipment.postId = postId;
        await DatabaseService().updateShipment(shipmentId, shipment.toMap());

        //TODO: everything ok
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Added shipment successfully'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('ok'),
                onPressed: () {
                  //TODO: back to list shipments
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
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
    } else {
      //TODO: update
      try {
        var addressFrom = _addressFromController.text.isNotEmpty
            ? Address(
                details: _addressFromDetailsController.text,
                street: _addressFromStreetController.text,
                district: _addressFromDistrictController.text,
                city: _addressFromCityController.text,
                location: null,
              )
            : null;
        var addressTo = _addressToController.text.isNotEmpty
            ? Address(
                details: _addressToDetailsController.text,
                street: _addressToStreetController.text,
                district: _addressToDistrictController.text,
                city: _addressToCityController.text,
                location: null,
              )
            : null;
        var attachment1 = 1 == 2
            ? Attachment(
                thumbURL: '',
                fileURL: '',
                type: 'IMAGE',
              )
            : null;
        List<Attachment> attachments = [];
        if (attachment1 != null) {
          attachments.add(attachment1);
        }
        num cod = num.tryParse(_codController.text) ?? 0;
        var parcel = _typeController.text=='SHIPHANG' && _parcelController.text.isNotEmpty
            ? Parcel(
                code: _parcelCodeController.text,
                description: _parcelDescriptionController.text,
                height: num.tryParse(_parcelHeightController.text) ?? 0,
                length: num.tryParse(_parcelLengthController.text) ?? 0,
                nameFrom: _parcelNameFromController.text,
                nameTo: _parcelNameToController.text,
                phoneFrom: _parcelPhoneFromController.text,
                phoneTo: _parcelPhoneToController.text,
                weight: num.tryParse(_parcelWeightToController.text) ?? 0,
                width: num.tryParse(_parcelWidthToController.text) ?? 0,
              )
            : null;
        //TODO: shipment
        Shipment shipment = widget.shipment!;
        shipment.addressFrom = addressFrom;
        shipment.addressTo = addressTo;
        shipment.cod = cod;
        shipment.notes = _notesController.text;
        shipment.parcel = parcel;
        shipment.service = _serviceController.text;
        shipment.type = _typeController.text;

        //TODO: updateShipment
        await DatabaseService().updateShipment(shipment.id!, shipment.toMap());

        //TODO: everything ok
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Updated shipment successfully'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('ok'),
                onPressed: () {
                  //TODO: back to list shipments
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
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
  }

  bool _isValidCod() {
    var x = num.tryParse(_codController.text);
    if (x == null) {
      setState(() {
        _codErrorText = 'Phí ship phải là dạng số';
      });
      return false;
    } else {
      if(x<0){
        setState(() {
          _codErrorText = 'Phí ship không được âm';
        });
      }else {
        setState(() {
          _codErrorText = null;
        });
      }
      return true;
    }
  }

  bool _isFormValid() {
    if (!_isValidCod()) {
      return false;
    }
    return true;
  }

  //TODO: are you sure/_confirm
  Future<void> _confirmSaveChanges(BuildContext context) async {
    if (!_isFormValid()) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Form is invalid'),
          content:
              const Text('Please finish the form without any invalid field'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }
    final bool didRequest = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Save changes'),
            content: const Text('Are you sure'),
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
      await _saveChanges(context);
    }
  }

  Widget _appBarTitle() {
    if (widget.shipment == null) {
      return const Text('Add new shipment');
    }
    return const Text('Edit shipment');
  }

  Widget _buildAddressFromField() {
    return TextField(
      readOnly: true,
      controller: _addressFromController,
      decoration: const InputDecoration(
        labelText: 'Address from',
        helperText: 'Vui lòng hoàn thành AddressFrom',
        border: OutlineInputBorder(),
        enabled: true,
      ),
      onTap: () async {
        await showDialog<void>(
          context: context,
          builder: (BuildContext _context) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .8),
              child: AlertDialog(
                  title: const Text('Address From'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        //TODO: street
                        TextFormField(
                          controller: _addressFromStreetController,
                          decoration: const InputDecoration(
                            labelText: 'Đường',
                            hintText: 'Vui lòng điền địa chỉ đường',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                        ),
                        //TODO: district
                        TextFormField(
                          controller: _addressFromDistrictController,
                          decoration: const InputDecoration(
                            labelText: 'Quận/huyện',
                            hintText: 'Vui lòng điền quận/huyện',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                        ),
                        //TODO: city
                        TextFormField(
                          controller: _addressFromCityController,
                          decoration: const InputDecoration(
                            labelText: 'Tỉnh/thành',
                            hintText: 'Vui lòng điền tỉnh/thành phố',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                        ),
                        //TODO: details
                        TextFormField(
                          controller: _addressFromDetailsController,
                          decoration: const InputDecoration(
                            labelText: 'Chi tiết',
                            hintText: 'Vui lòng điền địa chỉ chi tiết',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          keyboardType: TextInputType.text,
                          onEditingComplete: () {
                            _node.nextFocus();
                            Navigator.of(_context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(_context).pop();
                        },
                        child: const Text('Close')),
                  ]),
            );
          },
        );
        var details = _addressFromDetailsController.text;
        var street = _addressFromStreetController.text;
        var district = _addressFromDistrictController.text;
        var city = _addressFromCityController.text;
        _addressFromController.text =
            'street: ${street.trim()}, district: ${district.trim()}, city: ${city.trim()}, details: ${details.trim()}';
      },
    );
  }

  Widget _buildAddressToField() {
    return TextField(
      readOnly: true,
      controller: _addressToController,
      decoration: const InputDecoration(
        labelText: 'Address to',
        helperText: 'Vui lòng hoàn thành AddressTo',
        border: OutlineInputBorder(),
        enabled: true,
      ),
      onTap: () async {
        await showDialog<void>(
          context: context,
          builder: (BuildContext _context) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .8),
              child: AlertDialog(
                  title: const Text('Address To'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        //TODO: street
                        TextFormField(
                          controller: _addressToStreetController,
                          decoration: const InputDecoration(
                            labelText: 'Đường',
                            hintText: 'Vui lòng điền địa chỉ đường',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                        ),
                        //TODO: district
                        TextFormField(
                          controller: _addressToDistrictController,
                          decoration: const InputDecoration(
                            labelText: 'Quận/huyện',
                            hintText: 'Vui lòng điền quận/huyện',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                        ),
                        //TODO: city
                        TextFormField(
                          controller: _addressToCityController,
                          decoration: const InputDecoration(
                            labelText: 'Tỉnh/thành',
                            hintText: 'Vui lòng điền tỉnh/thành phố',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                        ),
                        //TODO: details
                        TextFormField(
                          controller: _addressToDetailsController,
                          decoration: const InputDecoration(
                            labelText: 'Chi tiết',
                            hintText: 'Vui lòng điền địa chỉ chi tiết',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          onEditingComplete: () {
                            _node.nextFocus();
                            Navigator.of(_context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(_context).pop();
                        },
                        child: const Text('Close')),
                  ]),
            );
          },
        );
        var details = _addressToDetailsController.text;
        var street = _addressToStreetController.text;
        var district = _addressToDistrictController.text;
        var city = _addressToCityController.text;
        _addressToController.text =
            'street: ${street.trim()}, district: ${district.trim()}, city: ${city.trim()}, details: ${details.trim()}';
      },
    );
  }

  String _codRecommended() {
    num cod = 0;
    //TODO: somehow plz find me the distance(km) between 2 address
    if (_typeController.text == 'SHIPHANG') {
      num weight = 0;
      if (_weight == 0) {
        weight = _length * _width * _height / 5000;
      } else {
        weight = _weight;
      }
      if (_serviceController.text == 'TIETKIEM') {
        //TODO: SHIPHANG, TIETKIEM
        if (weight * _distance < 5) {
          cod = 32000;
        } else {
          cod = 32000 + 5000 * (weight * _distance - 1);
        }
      } else {
        //TODO: SHIPHANG, NHANH
        if (weight * _distance < 5) {
          cod = 49000;
        } else {
          cod = 49000 + 10000 * (weight * _distance - 1);
        }
      }
    } else {
      //TODO: ship nguoi re hon ship hang?
      if (_serviceController.text == 'TIETKIEM') {
        //TODO: SHIPNGUOI, TIETKIEM
        if (_distance < 5) {
          cod = 15000;
        } else {
          cod = 15000 + 5000 * (_distance - 1);
        }
      } else {
        //TODO: SHIPNGUOI, NHANH
        if (_distance < 5) {
          cod = 22000;
        } else {
          cod = 22000 + 8000 * (_distance - 1);
        }
      }
    }
    return 'Phí ship khiến nghị: $cod vnđ trở lên';
  }

  Widget _buildCodField() {
    return TextFormField(
      controller: _codController,
      decoration: InputDecoration(
        errorText: _codErrorText,
        labelText: 'Tiền phí(vnđ)',
        hintText: 'Vui lòng điền tiền phí',
        helperText: _codRecommended(),
        border: const OutlineInputBorder(),
        enabled: true,
      ),
      autocorrect: false,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      onEditingComplete: _node.nextFocus,
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Notes',
        hintText: 'Vui lòng điền lưu chú',
        border: OutlineInputBorder(),
        enabled: true,
      ),
      autocorrect: false,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      onEditingComplete: _node.nextFocus,
    );
  }

  Widget _buildParcelField() {
    return TextField(
      readOnly: true,
      controller: _parcelController,
      decoration: const InputDecoration(
        labelText: 'Kiện hàng',
        helperText: 'Vui lòng hoàn thành thông tin kiện hàng',
        border: OutlineInputBorder(),
        enabled: true,
      ),
      onTap: () async {
        await showDialog<void>(
          context: context,
          builder: (BuildContext _context) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .8),
              child: AlertDialog(
                  title: const Text('Parcel'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        //TODO: code
                        TextFormField(
                          controller: _parcelCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Mã hàng',
                            hintText: 'Vui lòng điền mã kiện hàng',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                        ),
                        //TODO: nameFrom
                        TextFormField(
                          controller: _parcelNameFromController,
                          decoration: const InputDecoration(
                            labelText: 'Tên người gửi',
                            hintText: 'Vui lòng điền tên người gửi',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                        ),
                        //TODO: phoneFrom
                        TextFormField(
                          controller: _parcelPhoneFromController,
                          decoration: const InputDecoration(
                            labelText: 'Sđt người gửi',
                            hintText: 'Vui lòng điền sđt người gửi',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                        ),
                        //TODO: nameTo
                        TextFormField(
                          controller: _parcelNameToController,
                          decoration: const InputDecoration(
                            labelText: 'Tên người nhận',
                            hintText: 'Vui lòng điền tên người nhận',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                        ),
                        //TODO: phoneTo
                        TextFormField(
                          controller: _parcelPhoneToController,
                          decoration: const InputDecoration(
                            labelText: 'Sđt người nhận',
                            hintText: 'Vui lòng điền sđt người nhận',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                        ),
                        //TODO: description
                        TextFormField(
                          controller: _parcelDescriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Đặc tả',
                            hintText: 'Vui lòng điền đặc tả',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                        ),
                        //TODO: length
                        TextFormField(
                          controller: _parcelLengthController,
                          decoration: const InputDecoration(
                            labelText: 'Chiều dài(cm)',
                            hintText: 'Vui lòng điền hiều dài kiện hàng',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                        ),
                        //TODO: width
                        TextFormField(
                          controller: _parcelWidthToController,
                          decoration: const InputDecoration(
                            labelText: 'Chiều rộng(cm)',
                            hintText: 'Vui lòng điền chiều rộng kiện hàng',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                        ),
                        //TODO: height
                        TextFormField(
                          controller: _parcelHeightController,
                          decoration: const InputDecoration(
                            labelText: 'Chiều cao(cm)',
                            hintText: 'Vui lòng điền chiều cao kiện hàng',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                        ),
                        //TODO: weight
                        TextFormField(
                          controller: _parcelWeightToController,
                          decoration: const InputDecoration(
                            labelText: 'Trọng lượng(kg)',
                            hintText: 'Vui lòng điền trọng lượng kiện hàng',
                            border: OutlineInputBorder(),
                          ),
                          autocorrect: false,
                          keyboardType: TextInputType.text,
                          onEditingComplete: () {
                            _node.nextFocus();
                            Navigator.of(_context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(_context).pop();
                        },
                        child: const Text('Close')),
                  ]),
            );
          },
        );
        var description = _parcelDescriptionController.text;
        var code = _parcelCodeController.text;
        var weight = _parcelWeightToController.text;
        var length = _parcelLengthController.text;
        var width = _parcelWidthToController.text;
        var height = _parcelHeightController.text;
        _parcelController.text =
            'code: ${code.trim()}, weight: ${weight.trim()}, length: ${length.trim()}, width: ${width.trim()}, height: ${height.trim()}, description: ${description.trim()}';
      },
    );
  }

  Widget _buildServiceField() {
    return Column(
      children: <Widget>[
        //TODO:
        Row(children: const [Text('Service'), Spacer()]),
        //TODO: TIETKIEM
        RadioListTile<String>(
          title: const Text('Tiết kiệm'),
          value: 'TIETKIEM',
          groupValue: _serviceController.text,
          onChanged: (value) {
            setState(() {
              _serviceController.text = value!;
            });
          },
        ),
        //TODO: NHANH
        RadioListTile<String>(
          title: const Text('Nhanh'),
          value: 'NHANH',
          groupValue: _serviceController.text,
          onChanged: (value) {
            setState(() {
              _serviceController.text = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTypeField() {
    return Column(
      children: <Widget>[
        //TODO: title
        Row(children: const [Text('Type'), Spacer()]),
        //TODO: SHIPHANG
        RadioListTile<String>(
          title: const Text('Ship hàng'),
          value: 'SHIPHANG',
          groupValue: _typeController.text,
          onChanged: (value) {
            setState(() {
              _typeController.text = value!;
            });
          },
        ),
        //TODO: SHIPNGUOI
        RadioListTile<String>(
          title: const Text('Ship người'),
          value: 'SHIPNGUOI',
          groupValue: _typeController.text,
          onChanged: (value) {
            setState(() {
              _typeController.text = value!;
            });
          },
        ),
      ],
    );
  }

  //TODO: all input fields here
  Widget _buildInPutFields(BuildContext context) {
    return FocusScope(
      node: _node,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8.0),
            _buildAddressFromField(),
            const SizedBox(height: 8.0),
            _buildAddressToField(),
            const SizedBox(height: 8.0),
            _buildTypeField(),
            const SizedBox(height: 8.0),
            if (_typeController.text == 'SHIPHANG') _buildParcelField(),
            const SizedBox(height: 8.0),
            _buildServiceField(),
            const SizedBox(height: 8.0),
            _buildCodField(),
            const SizedBox(height: 8.0),
            _buildNotesField(),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    //TODO: init strings sht
    _addressFromController.text = widget.shipment?.addressFrom?.details ?? '';
    _addressFromDetailsController.text =
        widget.shipment?.addressFrom?.details ?? '';
    _addressFromStreetController.text =
        widget.shipment?.addressFrom?.street ?? '';
    _addressFromDistrictController.text =
        widget.shipment?.addressFrom?.district ?? '';
    _addressFromCityController.text = widget.shipment?.addressFrom?.city ?? '';

    _addressToController.text = widget.shipment?.addressTo?.details ?? '';
    _addressToDetailsController.text =
        widget.shipment?.addressTo?.details ?? '';
    _addressToStreetController.text = widget.shipment?.addressTo?.street ?? '';
    _addressToDistrictController.text =
        widget.shipment?.addressTo?.district ?? '';
    _addressToCityController.text = widget.shipment?.addressTo?.city ?? '';

    _serviceController.text = widget.shipment?.service ?? 'TIETKIEM';
    _typeController.text = widget.shipment?.type ?? 'SHIPHANG';

    _parcelController.text = widget.shipment?.parcel?.description ?? '';
    _parcelCodeController.text = widget.shipment?.parcel?.code ?? '';
    _parcelDescriptionController.text =
        widget.shipment?.parcel?.description ?? '';
    _parcelHeightController.text =
        widget.shipment?.parcel?.height.toString() ?? '';
    _parcelLengthController.text =
        widget.shipment?.parcel?.length.toString() ?? '';
    _parcelNameFromController.text = widget.shipment?.parcel?.nameFrom ?? '';
    _parcelNameToController.text = widget.shipment?.parcel?.nameTo ?? '';
    _parcelPhoneFromController.text = widget.shipment?.parcel?.phoneFrom ?? '';
    _parcelPhoneToController.text = widget.shipment?.parcel?.phoneTo ?? '';
    _parcelWeightToController.text =
        widget.shipment?.parcel?.weight.toString() ?? '';
    _parcelWidthToController.text =
        widget.shipment?.parcel?.width.toString() ?? '';

    _codController.text = widget.shipment?.cod.toString() ?? '';
    _notesController.text = widget.shipment?.parcel?.code ?? '';

    _weight = num.tryParse(_parcelWeightToController.text) ?? _weight;
    _length = num.tryParse(_parcelLengthController.text) ?? _length;
    _width = num.tryParse(_parcelWidthToController.text) ?? _width;
    _height = num.tryParse(_parcelHeightController.text) ?? _height;
    //TODO: co the thay = onChange

    _codController.addListener(() {
      _isValidCod();
    });
    _parcelWeightToController.addListener(() {
      setState(() {
        _weight = num.tryParse(_parcelWeightToController.text) ?? _weight;
      });
    });
    _parcelLengthController.addListener(() {
      setState(() {
        _length = num.tryParse(_parcelLengthController.text) ?? _length;
      });
    });
    _parcelWidthToController.addListener(() {
      setState(() {
        _width = num.tryParse(_parcelWidthToController.text) ?? _width;
      });
    });
    _parcelHeightController.addListener(() {
      setState(() {
        _height = num.tryParse(_parcelHeightController.text) ?? _height;
      });
    });

  }

  @override
  void dispose() {
    //TODO: Clean up the controller when the widget is removed
    _node.dispose();

    _addressFromController.dispose();
    _addressFromDetailsController.dispose();
    _addressFromStreetController.dispose();
    _addressFromDistrictController.dispose();
    _addressFromCityController.dispose();

    _addressToController.dispose();
    _addressToDetailsController.dispose();
    _addressToStreetController.dispose();
    _addressToDistrictController.dispose();
    _addressToCityController.dispose();

    _serviceController.dispose();
    _typeController.dispose();

    _parcelController.dispose();
    _parcelCodeController.dispose();
    _parcelDescriptionController.dispose();
    _parcelHeightController.dispose();
    _parcelLengthController.dispose();
    _parcelNameFromController.dispose();
    _parcelNameToController.dispose();
    _parcelPhoneFromController.dispose();
    _parcelPhoneToController.dispose();
    _parcelWeightToController.dispose();
    _parcelWidthToController.dispose();

    _codController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('edit_shipment_page');
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        leading: const BackButton(),
        title: _appBarTitle(),
        actions: [
          TextButton(
            child: Row(children: [
              Text('Save changes', style: Theme.of(context).textTheme.button),
              Icon(Icons.save,
                  color: Theme.of(context).textTheme.button?.color),
            ]),
            onPressed: () {
              _confirmSaveChanges(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        //TODO: input fields
        child: _buildInPutFields(context),
      ),
    );
  }
}
