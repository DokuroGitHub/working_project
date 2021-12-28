import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:working_project/services/storage_service.dart';

import '/models/attachment.dart';
import '/models/my_user.dart';
import '/models/post.dart';
import '/routing/app_router.dart';
import '/services/database_service.dart';
import 'components/my_user_avatar.dart';
import 'components/my_user_name.dart';
import 'components/rating_widget.dart';

class EditPostPage extends StatefulWidget {
  const EditPostPage({Key? key, required this.myUser, this.post})
      : super(key: key);
  final MyUser myUser;
  final Post? post;

  static Future<void> showPlz(BuildContext context,
      {required MyUser myUser, Post? post}) async {
    await Navigator.of(context, rootNavigator: true).pushNamed(
        AppRoutes.editPostPage,
        arguments: {'myUser': myUser, 'post': post});
  }

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {

  bool _showBottom = false;
  final FocusNode _focusNode = FocusNode();
  //final TextEditingController _textController = TextEditingController();
  bool _ableToPost = false;
  String _text = '';

  //TODO: file components
  List<File> pickingFiles = [];
  List<Uint8List?> pickingFileThumbnails = [];

  @override
  void initState() {
    super.initState();

    _text = widget.post?.text??'';
    // _textController.text = widget.post?.text??'';
    // _textController.addListener(() {
    //   if(_textController.text.trim().isNotEmpty || pickingFiles.isNotEmpty){
    //     setState(() {
    //       _ableToPost = true;
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    //_textController.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  Widget _attachedFiles(){
    if(pickingFiles.isEmpty) {
      return Container();
    }
    return GridView.count(
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      shrinkWrap: true,
      crossAxisCount: 3,
      children: List.generate(
        pickingFiles.length,
            (i) {
          return Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.grey[200],
              border: Border.all(color: Colors.grey, width: 2),
            ),
            child: Stack(
                children: [
                  if(pickingFileThumbnails[i] !=null) Center(child: Image.memory(pickingFileThumbnails[i]!)),
                  if(pickingFileThumbnails[i] ==null) Center(child: Image.file(pickingFiles[i])),
                  Positioned(top: -10, right: -10,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        setState(() {
                          pickingFiles.removeAt(i);
                          pickingFileThumbnails.removeAt(i);
                        });
                        if(pickingFiles.isEmpty && _text.trim().isEmpty){
                          setState(() {
                            _ableToPost = false;
                          });
                        }
                      },
                    ),
                  ),
                ]),
          );
        },
      ),
    );
  }

  Future<Uint8List?> _filePathToThumbnails(File file)async{
    if(_filePathToType(file.path)=='VIDEO'){
      return await VideoThumbnail.thumbnailData(
        video: file.path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 256, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        //quality: 25,
      );
    }
    return null;
  }

  String _filePathToType(String filePath){
    switch(filePath.substring(filePath.length-3).toUpperCase()){
      case 'JPG':
      case 'PNG':
      case 'EBM':
        return 'IMAGE';
      case 'GIF':
        return 'GIF';
      case 'MP4':
        return 'VIDEO';
      case 'MP3':
        return 'AUDIO';
      default:
        return 'FILE';
    }
  }

  Future _getImageGallery() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;

    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      final thumbnail = await _filePathToThumbnails(file);
      setState(() {
        pickingFiles.add(file);
        pickingFileThumbnails.add(thumbnail);
        _ableToPost = true;
      });
    }
  }

  Future _getImageCamera() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;

    pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      final thumbnail = await _filePathToThumbnails(file);
      setState(() {
        pickingFiles.add(file);
        pickingFileThumbnails.add(thumbnail);
        _ableToPost = true;
      });
    }
  }

  Future _getVideoGallery() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;

    pickedFile = await imagePicker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      final thumbnail = await _filePathToThumbnails(file);
      setState(() {
        pickingFiles.add(file);
        pickingFileThumbnails.add(thumbnail);
        _ableToPost = true;
      });
    }
  }

  Future _getVideoCamera() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;

    pickedFile = await imagePicker.pickVideo(source: ImageSource.camera);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      final thumbnail = await _filePathToThumbnails(file);
      setState(() {
        pickingFiles.add(file);
        pickingFileThumbnails.add(thumbnail);
        _ableToPost = true;
      });
    }
  }

  Future _getFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      for(int i = 0;i<files.length;i++){
        File file = File(files[i].path);
        final thumbnail = await _filePathToThumbnails(file);
        setState(() {
          pickingFiles.add(file);
          pickingFileThumbnails.add(thumbnail);
          _ableToPost = true;
        });
      }
    } else {
      // User canceled the picker
    }
  }

  Future<String?> _uploadFile(File file, String postId) async {
    try {
      String fileName = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      UploadTask uploadTask = StorageService().uploadFileInPost(
        file: file,
        fileName: fileName,
        myUserId: widget.myUser.id!,
        postId: postId,
      );
      TaskSnapshot snapshot = await uploadTask;
      String fileURL = await snapshot.ref.getDownloadURL();
      return fileURL;
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }
  Future<String?> _uploadData(Uint8List data, String postId) async {
    try {
      String fileName = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      UploadTask uploadTask = StorageService().uploadDataInPost(
        data: data,
        fileName: fileName,
        postId: postId,
        myUserId: widget.myUser.id!,
      );
      TaskSnapshot snapshot = await uploadTask;
      String fileURL = await snapshot.ref.getDownloadURL();
      return fileURL;
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  Future<void> _submit() async {
    _focusNode.unfocus();
    //String text = _textController.text.trim();
    String text = _text.trim();
    print('text: $text');
    if(widget.post==null) {
      //TODO: new post
      if (text.isNotEmpty || pickingFiles.isNotEmpty) {
        try {
          //TODO: new
          final post = Post(
            attachments: [],
            text: text,
            createdAt: DateTime.now(),
            createdBy: widget.myUser.id!,
            editedAt: DateTime.now(),
            shipmentId: null,
          );
          //TODO: add
          String? postId = await DatabaseService().addPost(post.toMap());
          if (postId != null) {
            //TODO: up files
            List<Attachment> attachments = [];
            for (int i = 0; i < pickingFiles.length; i++) {
              File file = pickingFiles[i];
              //File thumbnailFile = File.fromRawPath(pickingFileThumbnails[i]);
              String? fileURL = await _uploadFile(file, postId);
              String? thumbURL;
              if (pickingFileThumbnails[i] != null) {
                thumbURL = await _uploadData(pickingFileThumbnails[i]!, postId);
              }
              //TODO: cha biet lay thumbURL ntn
              if (fileURL != null) {
                Attachment attachment = Attachment(
                  fileURL: fileURL,
                  thumbURL: thumbURL,
                  type: _filePathToType(file.path),
                );
                attachments.add(attachment);
              }
            }
            //TODO: update post
            post.attachments = attachments;
            await DatabaseService().updatePost(postId, post.toMap());

            //TODO: everything ok
            unawaited(showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(
                    title: const Text('Thành công'),
                    content: const Text('Đăng bài viết thành công'),
                    actions: <Widget>[
                      ElevatedButton(
                        child: const Text('Ok'),
                        onPressed: (){
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
            ));
          }else{
            //TODO: show dialog
            unawaited(showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(
                    title: const Text('Lỗi'),
                    content: const Text('Đăng bài viết thất bại'),
                    actions: <Widget>[
                      ElevatedButton(
                        child: const Text('Ok'),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
            ));
          }
        }catch (e) {
          //TODO: show dialog
          unawaited(showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
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
    }else{
      //TODO: edit post

    }
  }

  AppBar _buildAppBar(){
    return AppBar(
      elevation: 2.0,
      leading: BackButton(color: Theme.of(context).textTheme.bodyText1?.color,),
      title: Center(
          child: Text(
              widget.post == null ? 'Tạo bài viết' : 'Chỉnh sửa bài viết')),
      actions: <Widget>[
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: TextButton(
            child: const Text(
              'Đăng',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            style: TextButton.styleFrom(
              backgroundColor: _ableToPost
                  ? Colors.blue
                  : Colors.grey,
            ),
            onPressed: () => _submit(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildContents(),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  Widget _buildContents() {
    return Stack(
      children: [
        //TODO: contents
        Column(mainAxisSize: MainAxisSize.max, children: [
          //TODO:avatar +name + text + files
          Expanded(
            child: SingleChildScrollView(
              child: Card(
                color: Theme.of(context).backgroundColor,
                child: Column(children: [
                  //TODO: avatar+name
                  Row(
                    children: [
                      //TODO: img
                      MyUserAvatar(
                          myUser: null,
                          myUserId: widget.myUser.id,
                          onTap: () {
                            print('tap avatar');
                          }),

                      const SizedBox(
                        width: 10.0,
                      ),

                      //TODO: name+rating+date
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              //TODO: name
                              MyUserName(
                                  myUserId: widget.myUser.id!,
                                  onTap: () {
                                    print('tap name');
                                  }),
                              const SizedBox(width: 15.0),
                              //TODO: rating
                              RatingWidget(myUserId: widget.myUser.id!),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                  //TODO: text
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: _focusNode,
                          //controller: _textController,
                          onChanged: (text){
                            _text = text;
                            if(_text.trim().isNotEmpty || pickingFiles.isNotEmpty){
                              setState(() {
                                _ableToPost = true;
                              });
                            }else{
                              setState(() {
                                _ableToPost = false;
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: "Type something...",
                            border: InputBorder.none,
                          ),
                          autocorrect: false,
                          //onEditingComplete: _node.nextFocus,
                        ),
                      ),
                    ],
                  ),
                  //TODO: attachedFiles
                  _attachedFiles(),
                ]),
              ),
            ),
          ),
          //TODO: bottom bar
          Container(
            height: 70.0,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.photo_library,
                    color: Colors.green,
                    size: 35,
                  ),
                  onPressed: () {
                    setState(() {
                      _showBottom = true;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person_add_alt_1,
                      color: Colors.blue, size: 35),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.tag_faces, color: Colors.orange, size: 35),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 35,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, size: 35),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ]),

        //TODO: add pickingFiles
        _showBottom
            ? Stack(children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                print('tap, _showBottom = false');
                setState(() {
                  _showBottom = false;
                });
              },
            ),
          ),
          Positioned(
            bottom: 90,
            left: 25,
            right: 25,
            child: Container(
              padding: const EdgeInsets.all(25.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 5),
                      blurRadius: 15.0,
                      color: Colors.grey)
                ],
              ),
              child: GridView.count(
                mainAxisSpacing: 21.0,
                crossAxisSpacing: 21.0,
                shrinkWrap: true,
                crossAxisCount: 3,
                children: List.generate(
                  icons.length,
                      (i) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.grey[200],
                        border: Border.all(color: myGreen, width: 2),
                      ),
                      child: IconButton(
                        icon: Icon(
                          icons[i],
                          color: myGreen,
                        ),
                        onPressed: () {
                          setState(() {
                            _showBottom = false;
                          });
                          if(i==0){
                            _getImageGallery();
                          }
                          if(i==1){
                            _getImageCamera();
                          }
                          if(i==2){
                            _getVideoGallery();
                          }
                          if(i==3){
                            _getVideoCamera();
                          }
                          if(i==4){
                            _getFiles();
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ])
            : Container(),
      ],
    );
  }
}

List<IconData> icons = [
  Icons.image,
  Icons.camera,
  Icons.video_collection,
  Icons.video_call,
  Icons.attachment,
  Icons.gif
];


Color myGreen = const Color(0xff4bb17b);