import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/common_widgets/avatar.dart';
import '/constants/strings.dart';
import '/models/address.dart';
import '/models/my_user.dart';
import '/services/auth_service.dart';
import '/services/database_service.dart';

class FinishMyUserInfoPage extends StatefulWidget {
  const FinishMyUserInfoPage({required this.user});

  final User user;

  @override
  _FinishMyUserInfoPageState createState() =>
      _FinishMyUserInfoPageState();
}

class _FinishMyUserInfoPageState extends State<FinishMyUserInfoPage> {
  final FocusScopeNode _node = FocusScopeNode();
  final TextEditingController _addressDetailsController = TextEditingController();
  final TextEditingController _addressStreetController = TextEditingController();
  final TextEditingController _addressDistrictController = TextEditingController();
  final TextEditingController _addressCityController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _selfIntroductionController = TextEditingController();
  String _role = 'MEMBER';

  //TODO: _signOut
  Future<void> _signOut(BuildContext context) async {
    try {
      await AuthService().signOut();
    } catch (e) {
      //TODO: show dialog
      unawaited(showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(Strings.logoutFailed),
          content: const Text('content'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('defaultActionText'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ));
    }
  }

  //TODO: are you sure/_confirmSignOut
  Future<void> _confirmSignOut(BuildContext context) async {
      final bool didRequestSignOut = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(Strings.logout),
          content: const Text(Strings.logoutAreYouSure),
          actions: <Widget>[
            ElevatedButton(
              child: const Text(Strings.cancel),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: const Text(Strings.logout),
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

  //TODO: _addMyUser
  Future<void> _addMyUser(BuildContext context) async {
    try {
      String myUserId = widget.user.uid;
      //TODO: new
      MyUser myUser = MyUser(
        address: Address(
          details: _addressDetailsController.text,
          street: _addressStreetController.text,
          district: _addressDistrictController.text,
          city: _addressCityController.text,
          location: null,
        ),
        birthDate: DateTime.tryParse(_birthDateController.text),
        createdAt: DateTime.now(),
        email: widget.user.email,
        isActive: true,
        isBlocked: false,
        lastSignInAt: DateTime.now(),
        name: _nameController.text,
        phoneNumber: widget.user.phoneNumber,
        photoURL: widget.user.photoURL,
        role: _role,
        selfIntroduction: _selfIntroductionController.text,
        shipperInfo: null,
      );
      await DatabaseService().addMyUserToDBWithId(myUserId, myUser.toMap());
    } catch (e) {
      unawaited(showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error occurred'),
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

  //TODO: are you sure/_confirmAddMyUser
  Future<void> _confirmAddMyUser(BuildContext context) async {
    final bool didRequestSignOut = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ho??n t???t th??m th??ng tin'),
        content: const Text('B???n c?? ch???c ???? ho??n th??nh? Nh???ng th??ng tin n??y s??? c?? ??ch cho vi???c s??? d???ng ???ng d???ng'),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('H???y'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: const Text('X??c nh???n'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ??
        false;
    if (didRequestSignOut == true) {
      await _addMyUser(context);
    }
  }

  @override
  void initState() {
    super.initState();
    //TODO: init strings sht
    _nameController.text = widget.user.displayName??'';
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed
    _node.dispose();
    _addressDetailsController.dispose();
    _addressStreetController.dispose();
    _addressDistrictController.dispose();
    _addressCityController.dispose();
    _birthDateController.dispose();
    _nameController.dispose();
    _selfIntroductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: const Text('Th??m th??ng tin'),
          actions: [
            //TODO: sign out button
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out this account',
              onPressed: () {
                _confirmSignOut(context);
              },
            ),
          ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130.0),
          child: _buildUserInfo(widget.user),
        ),
      ),
      //backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        //TODO: input fields
        child: _buildInPutFields(context),
      ),
    );
  }

  //TODO: app bar contains user photo
  Widget _buildUserInfo(User user) {
    return Column(
      children: [
        Avatar(
          photoUrl: user.photoURL,
          radius: 50,
          borderColor: Colors.black54,
          borderWidth: 2.0,
        ),
        const SizedBox(height: 8),
        Text(
          user.email??'ch??a thi???t l???p gmail',
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          user.phoneNumber??'ch??a thi???t l???p s??? ??i???n tho???i',
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  //TODO: all input fields
  Widget _buildInPutFields(BuildContext context) {
    return FocusScope(
      node: _node,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8.0),
          _buildNameField(),
          const SizedBox(height: 8.0),
          _buildBirthDateField(),
          const SizedBox(height: 8.0),
          _buildAddressStreetField(),
          const SizedBox(height: 8.0),
          _buildAddressDistrictField(),
          const SizedBox(height: 8.0),
          _buildAddressCityField(),
          const SizedBox(height: 8.0),
          _buildAddressDetailsField(),
          const SizedBox(height: 8.0),
          _buildSelfIntroductionField(),
          const SizedBox(height: 8.0),
          _buildRoleField(),
          const SizedBox(height: 8.0),
          ElevatedButton(
            child: const Text('X??c nh???n'),
            onPressed: (){
              //TODO: add vao db
              _confirmAddMyUser(context);
            },
          ),
          const SizedBox(height: 8.0),

        ],
      ),
      ),
    );
  }

  Widget _buildAddressDetailsField() {
    return TextFormField(
      //key: const Key('email'),
      controller: _addressDetailsController,
      decoration: const InputDecoration(
        labelText: '?????a ch??? chi ti???t',
        hintText: 'Vui l??ng ??i???n ?????a ch??? ?????y ?????',
        border: OutlineInputBorder(),
        enabled: true,
      ),
      autocorrect: false,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.light,
      onEditingComplete: _node.nextFocus,
    );
  }

  Widget _buildAddressStreetField() {
    return TextFormField(
      //key: const Key('email'),
      controller: _addressStreetController,
      decoration: const InputDecoration(
        labelText: '?????a ch??? ???????ng',
        hintText: 'Vui l??ng ??i???n ?????a ch??? ???????ng',
        border: OutlineInputBorder(),
        enabled: true,
      ),
      autocorrect: false,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.light,
      onEditingComplete: _node.nextFocus,
    );
  }

  Widget _buildAddressDistrictField() {
    return TextFormField(
      //key: const Key('email'),
      controller: _addressDistrictController,
      decoration: const InputDecoration(
        labelText: 'Qu???n/huy???n',
        hintText: 'Vui l??ng ??i???n qu???n/huy???n',
        border: OutlineInputBorder(),
        enabled: true,
      ),
      autocorrect: false,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.light,
      onEditingComplete: _node.nextFocus,
    );
  }

  Widget _buildAddressCityField() {
    return TextFormField(
      //key: const Key('email'),
      controller: _addressCityController,
      decoration: const InputDecoration(
        labelText: 'T???nh/Th??nh ph???',
        hintText: 'Vui l??ng ??i???n t???nh th??nh',
        border: OutlineInputBorder(),
        enabled: true,
      ),
      autocorrect: false,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.light,
      onEditingComplete: _node.nextFocus,
    );
  }

  Widget _buildBirthDateField() {
    return TextField(
      readOnly: true,
      controller: _birthDateController,
      decoration: const InputDecoration(
        labelText: 'Ng??y sinh',
        hintText: 'Vui l??ng ch???n ng??y sinh',
        border: OutlineInputBorder(),
        enabled: true,
      ),
      onTap: () async {
        var date =  await showDatePicker(
            context: context,
            initialDate:DateTime.utc(2000),
            firstDate:DateTime(1900),
            lastDate: DateTime(2021));
        if(date!=null) {
          _birthDateController.text = date.toString().substring(0, 10);
        }
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      //key: const Key('name'),
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'H??? v?? t??n',
        hintText: 'Vui l??ng ??i???n h??? t??n',
        border: OutlineInputBorder(),
        enabled: true,
      ),
      autocorrect: false,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.light,
      onEditingComplete: _node.nextFocus,
    );
  }

  Widget _buildSelfIntroductionField() {
    return TextFormField(
      //key: const Key('name'),
      controller: _selfIntroductionController,
      decoration: const InputDecoration(
        labelText: 'T??? gi???i thi???u, ch??m ng??n,..',
        hintText: 'Vui l??ng gi???i thi???u b???n th??n, ch??m ng??n,..',
        border: OutlineInputBorder(),
        enabled: true,
      ),
      autocorrect: false,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.light,
      onEditingComplete: _node.nextFocus,
    );
  }

  Widget _buildRoleField() {
    return Column(
      children: <Widget>[
        //TODO:
        Row(children: const [Text('Vai tr??'), Spacer()]),
        //TODO: MEMBER
        RadioListTile<String>(
          title: const Text('Ng?????i d??ng'),
          value: 'MEMBER',
          groupValue: _role,
          onChanged: (value) {
            setState(() {
              _role = value!;
            });
          },
        ),
        //TODO: SHIPPER
        RadioListTile<String>(
          title: const Text('Shipper'),
          value: 'SHIPPER',
          groupValue: _role,
          onChanged: (value) {
            setState(() {
              _role = value!;
            });
          },
        ),
      ],
    );
  }

}