import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/models/attachment.dart';
import '/models/my_user.dart';
import '/models/post.dart';
import '/routing/app_router.dart';
import '/services/database_service.dart';

class EditPostPage extends StatefulWidget {
  const EditPostPage({Key? key, required this.myUser, this.post}) : super(key: key);
  final MyUser myUser;
  final Post? post;

  static Future<void> _show(BuildContext context, {required MyUser myUser, Post? post}) async {
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.editPostPage,
      arguments: {
        'myUser': myUser,
        'post': post
      }
    );
  }

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();

  String? _text;

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _text = widget.post?.text;
    }
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      try {
        //TODO: new
          final post = Post(
                  attachments: [
                    Attachment(
                      thumbURL: 'thumbURL.com',
                      fileURL: 'fileURL.com',
                      type:'FILE',
                    )
                  ], //TODO: can xu ly list attachments
                  text: _text,
                  createdAt: widget.post?.createdAt??DateTime.now(),
                  createdBy: widget.myUser.id!,
                  editedAt: widget.post!=null?DateTime.now():null,
                  shipmentId: null, //TODO: can add shipment truoc
              );
          if(widget.post==null){
            //TODO: add
            await DatabaseService().addPost(post.toMap());
          }else{
            //TODO: update
            await DatabaseService().updatePost(widget.post!.id!, post.toMap());
          }
          Navigator.of(context).pop();
      } catch (e) {
        //TODO: show dialog
        unawaited(showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Operation failed'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(widget.post == null ? 'New Post' : 'Edit Post'),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            onPressed: () => _submit(),
          ),
        ],
      ),
      body: _buildContents(),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContents() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(),
      ),
    );
  }

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        decoration: const InputDecoration(labelText: 'Post content'),
        keyboardAppearance: Brightness.light,
        initialValue: _text,
        validator: (value) =>
            (value ?? '').isNotEmpty ? null : null,
        onSaved: (value) => _text = value,
      ),
    ];
  }
}
