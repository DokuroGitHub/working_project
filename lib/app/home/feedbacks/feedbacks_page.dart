import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:working_project/models/attachment.dart';
import 'package:working_project/models/reply.dart';
import 'package:working_project/services/storage_service.dart';
import '/app/home/feedbacks/components/feedback_attachments.dart';
import '/app/home/feedbacks/components/summary.dart';
import '/app/home/member/posts/components/my_user_avatar.dart';
import '/app/home/messages/messages_page.dart';
import '/common_widgets/avatar.dart';
import '/common_widgets/helper.dart';
import '/constants/ui.dart';
import '/models/feedback.dart';
import '/models/my_user.dart';
import '/routing/app_router.dart';
import '/services/database_service.dart';

class FeedBacksPage extends StatefulWidget {
  const FeedBacksPage({required this.myUser, required this.myUserId2});

  final MyUser myUser;
  final String myUserId2;

  static Future<void> showPlz(BuildContext context, MyUser myUser, String myUserId2) async {
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.feedbacksPage,
      arguments: {
        'myUser': myUser,
        'myUserId2': myUserId2,
      },
    );
  }

  @override
  State<FeedBacksPage> createState() => _FeedBacksPageState();
}

class _FeedBacksPageState extends State<FeedBacksPage> {
  FeedBackQuery feedBacksQuery = FeedBackQuery.createdAtDesc;

  Future<void> _showMessagesPage(BuildContext context, MyUser myUser, String myUserId2) async {
    if(myUser.id! != myUserId2) {
      //TODO: chua test
      await MessagesPage.showPlz(context:context, myUser:myUser, myUserId2:myUserId2);
    }else{
      print('ko the nhan tin cho chinh minh');
      const snackBar = SnackBar(content: Text('Không thể nhắn tin cho chính mình'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

    }
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const BackButton(),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*.5),
              child: Text(AppLocalizations.of(context)!.rateAndFeedBacks,overflow: TextOverflow.ellipsis)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.local_phone),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.message_outlined),
          onPressed: () {
            _showMessagesPage(context, widget.myUser, widget.myUserId2);
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Column(children: [
          MyUserAvatar(myUser:null,myUserId: widget.myUserId2),
          const SizedBox(height: kDefaultPadding * 0.75),
          StreamBuilder(
            stream:
            DatabaseService().getStreamMyUserByDocumentId(widget.myUserId2),
            builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
              if (snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(snapshot.data!.name ?? ''),
                    Text(snapshot.data!.phoneNumber ?? ''),
                  ],
                );
              }
              return Container();
            },
          ),
        ]),
      ),
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Logout':
        print('logout');
        break;
      case 'Settings':
        print('settings');
        break;
    }
  }

  Widget _createdBy(String myUserId) {
    return StreamBuilder(
      stream: DatabaseService().getStreamMyUserByDocumentId(myUserId),
      builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
        if (snapshot.hasError) {
          return Container();
        }
        if (snapshot.hasData) {
          return Row(children: [
            Avatar(
              photoUrl: snapshot.data!.photoURL,
              radius: 15,
              borderColor: Colors.black54,
              borderWidth: 1.0,
            ),
            const SizedBox(width: 10),
            Text(snapshot.data!.name ?? ''),
          ]);
        }
        return Container();
      },
    );
  }

  Widget _rating(num star) {
    switch (star) {
      case 5:
        return Row(children: const [
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
        ]);
      case 4:
        return Row(children: const [
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
        ]);
      case 3:
        return Row(children: const [
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
        ]);
      case 2:
        return Row(children: const [
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
        ]);
      case 1:
        return Row(children: const [
          Icon(Icons.star, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
        ]);
      default:
        return Row(children: const [
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
          Icon(Icons.star_border, color: Colors.orange),
        ]);
    }
  }

  Widget _feedbackItem(FeedBack feedback) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration: const BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //TODO: avatar+name+rate+date
        Row(children: [
          _createdBy(feedback.createdBy),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _rating(feedback.rating),
            const SizedBox(height: 10),
            Text(Helper.timeToString(feedback.createdAt)),
          ]),
        ]),
        //TODO: text
        Text(feedback.text ?? ''),
        //TODO: attachments
        Column(children: [
          Row(children: const [
            Icon(Icons.attachment),
            SizedBox(width: 10),
            Text('Tệp đính kèm: '),
          ]),
          const SizedBox(width: 10),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .3),
            padding: const EdgeInsets.all(5.0),
            decoration: const BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: FeedBackAttachments(
                myUser: widget.myUser, attachments: feedback.attachments),
          ),
        ]),
        //TODO: reply
        if(feedback.reply==null && true) TextButton(child: const Text('Trả lời'),
          onPressed: () {
          setState(() {
            _showReplyInputRow = !_showReplyInputRow;
          });
          },
        ),
        if(_showReplyInputRow) _replyInputFieldWidget(feedback.id!),
        if (feedback.reply != null)
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('Phản hồi:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(Helper.timeToString(feedback.reply!.createdAt)),
              ]),
              Text(feedback.reply!.text),
            ]),
          ),
      ]),
    );
  }

  Future<void> _showFilters() async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Sắp xếp theo'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  setState(() {
                    feedBacksQuery = FeedBackQuery.createdAtDesc;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Gần đây nhất'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  setState(() {
                    feedBacksQuery = FeedBackQuery.createdAtAsc;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Cũ nhất'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  setState(() {
                    feedBacksQuery = FeedBackQuery.ratingDesc;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Điểm đánh giá cao nhất'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  setState(() {
                    feedBacksQuery = FeedBackQuery.ratingAsc;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Điểm đánh giá thấp nhất'),
              ),
            ],
          );
        });
  }

  //TODO: working--sending feedback
  //TODO: ------working----------start
  bool _showBottom = false;
  bool _showInputRow = false;
  bool _showReplyInputRow = false;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _replyFocusNode = FocusNode();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  num _ratingStar = 5;
  //TODO: file components
  List<File> pickingFiles = [];
  List<Uint8List?> pickingFileThumbnails = [];

  @override
  void dispose() {
    _focusNode.dispose();
    _replyFocusNode.dispose();
    _messageController.dispose();
    _replyController.dispose();
    super.dispose();
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
        });
      }
    } else {
      // User canceled the picker
    }
  }

  Future<String?> _uploadFile(File file) async {
    try {
      String fileName = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      UploadTask uploadTask = StorageService().uploadFileInFeedBack(
        file: file,
        fileName: fileName,
        myUserId2: widget.myUserId2,
        myUserId: widget.myUser.id!,
      );
      TaskSnapshot snapshot = await uploadTask;
      String fileURL = await snapshot.ref.getDownloadURL();
      return fileURL;
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }
  Future<String?> _uploadData(Uint8List data) async {
    try {
      String fileName = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      UploadTask uploadTask = StorageService().uploadDataInFeedBack(
        data: data,
        fileName: fileName,
        myUserId2: widget.myUserId2,
        myUserId: widget.myUser.id!,
      );
      TaskSnapshot snapshot = await uploadTask;
      String fileURL = await snapshot.ref.getDownloadURL();
      return fileURL;
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
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

  Future _sendFeedBack() async {
    _focusNode.unfocus();

    String text = _messageController.text.trim();
    print('text: $text');
    List<Attachment> attachments = [];
    for(int i = 0; i< pickingFiles.length; i++) {
      File file = pickingFiles[i];
      //File thumbnailFile = File.fromRawPath(pickingFileThumbnails[i]);
      String? fileURL = await _uploadFile(file);
      String? thumbURL;
      if(pickingFileThumbnails[i]!=null){
        thumbURL = await _uploadData(pickingFileThumbnails[i]!);
      }
      //TODO: cha biet lay thumbURL ntn
      if(fileURL!=null) {
        Attachment attachment = Attachment(
          fileURL: fileURL,
          thumbURL: thumbURL,
          type: _filePathToType(file.path),
        );
        attachments.add(attachment);
      }
    }

    //TODO: clean inputs
    _messageController.clear();
    setState(() {
      pickingFiles = [];
      pickingFileThumbnails = [];
    });

    if (text.isNotEmpty || attachments.isNotEmpty) {
      String myUserId = widget.myUser.id!;
      //TODO: new
      FeedBack feedBack = FeedBack(
        attachments: attachments,
        createdAt: DateTime.now(),
        createdBy: myUserId,
        text: text,
        rating: _ratingStar,
      );
      //TODO: add
      await DatabaseService().addFeedbackToMyUser(widget.myUserId2, feedBack.toMap());
    }
  }

  Future _sendReply(String feedBackId) async {
    _replyFocusNode.unfocus();

    String text = _replyController.text.trim();
    print('text: $text');

    //TODO: clean inputs
    _replyController.clear();

    if (text.isNotEmpty) {
      FeedBack? feedBack = await DatabaseService().getFeedBackByDocumentId(feedBackId: feedBackId, myUserId: widget.myUserId2);
      if(feedBack!=null){
        Reply reply = Reply(
            createdAt:DateTime.now(),
          text: text,
        );
        feedBack.reply = reply;
        await DatabaseService().updateFeedBackOnDB(feedBackId: feedBackId, map: feedBack.toMap(), myUserId: widget.myUserId2);
      }
    }
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
              border: Border.all(color: Colors.green, width: 2),
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
                      },
                    ),
                  ),
                ]),
          );
        },
      ),
    );
  }

  Widget _inputFieldWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 32,
            color: const Color(0xFF087949).withOpacity(0.08),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            InkWell(
              child: const Icon(
                Icons.add_circle,
                color: kPrimaryColor,
              ),
              onTap: () {
                setState(() {
                  _showBottom = true;
                });
              },
            ),
            const SizedBox(width: kDefaultPadding),
            const Icon(Icons.mic, color: kPrimaryColor),
            const SizedBox(width: kDefaultPadding / 2),
            Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kDefaultPadding * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                      children: [
                        _attachedFiles(),
                        Row(
                          children: [
                            Icon(
                              Icons.sentiment_satisfied_alt_outlined,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.color
                                  ?.withOpacity(0.64),
                            ),
                            const SizedBox(width: kDefaultPadding / 4),
                            Expanded(
                              child: TextField(
                                focusNode: _focusNode,
                                controller: _messageController,
                                decoration: const InputDecoration(
                                  hintText: "Type message",
                                  border: InputBorder.none,
                                ),
                                autocorrect: false,
                                //onEditingComplete: _node.nextFocus,
                              ),
                            ),
                            Icon(
                              Icons.attach_file,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.color
                                  ?.withOpacity(0.64),
                            ),
                            const SizedBox(width: kDefaultPadding / 4),
                            Icon(
                              Icons.camera_alt_outlined,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.color
                                  ?.withOpacity(0.64),
                            ),
                          ],
                        ),
                      ]),
                )),
            const SizedBox(width: kDefaultPadding),
            IconButton(
                icon: const Icon(Icons.send, color: kPrimaryColor),
                onPressed: () {
                  //TODO: send message
                  _sendFeedBack();
                }),
          ],
        ),
      ),
    );
  }

  Widget _replyInputFieldWidget(String feedBackId) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 32,
            color: const Color(0xFF087949).withOpacity(0.08),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kDefaultPadding * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Expanded(
                    child: TextField(
                      focusNode: _replyFocusNode,
                      controller: _replyController,
                      decoration: const InputDecoration(
                        hintText: "Viết phản hồi",
                        border: InputBorder.none,
                      ),
                      autocorrect: false,
                      //onEditingComplete: _node.nextFocus,
                    ),
                  ),
                )),
            const SizedBox(width: kDefaultPadding),
            IconButton(
                icon: const Icon(Icons.send, color: kPrimaryColor),
                onPressed: () {
                  //TODO: send message
                  _sendReply(feedBackId);
                }),
          ],
        ),
      ),
    );
  }
  //TODO: ------working----------end
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Stack(
        children: [
          Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            reverse: false,
            child: StreamBuilder(
              stream:
              DatabaseService().getStreamListFeedback(widget.myUserId2, query: feedBacksQuery),
              builder: (BuildContext context,
                  AsyncSnapshot<List<FeedBack>> snapshot) {
                if (snapshot.hasError) {
                  return Container();
                }
                if (snapshot.hasData) {
                  List<FeedBack> feedBacks = snapshot.data!;
                  return Column(children: [
                    Column(children: [
                      Row(children: const [
                        Text('Xếp hạng & nhận xét'),
                        Spacer(),
                      ]),
                      Summary(feedBacks: feedBacks),
                      Row(children: [
                        const Text('Chạm để xếp hạng'),
                        IconButton(
                            onPressed: () {
                              print('1 star');
                              setState(() {
                                _ratingStar = 1;
                              });
                            },
                            icon: Icon(Icons.star,
                                color: (_ratingStar>=1)?Colors.orange : Colors.white,
                            ),
                        ),
                        IconButton(
                            onPressed: () {
                              print('2 star');
                              setState(() {
                                _ratingStar = 2;
                              });
                            },
                          icon: Icon(Icons.star,
                            color: (_ratingStar>=2)?Colors.orange : Colors.white,
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              print('3 star');
                              setState(() {
                                _ratingStar = 3;
                              });
                            },
                          icon: Icon(Icons.star,
                            color: (_ratingStar>=3)?Colors.orange : Colors.white,
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              print('4 star');
                              setState(() {
                                _ratingStar = 4;
                              });
                            },
                          icon: Icon(Icons.star,
                            color: (_ratingStar>=4)?Colors.orange : Colors.white,
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              print('5 star');
                              setState(() {
                                _ratingStar = 5;
                              });
                            },
                          icon: Icon(Icons.star,
                            color: (_ratingStar>=5)?Colors.orange : Colors.white,
                          ),
                        ),
                      ]),
                      GestureDetector(
                        onTap: () {
                          print('tap add nhận xét');
                          setState(() {
                            _showInputRow = !_showInputRow;
                          });
                        },
                        child: Row(children: const [
                          Icon(Icons.note_add_outlined),
                          Text('Viết nhận xét',
                              style: TextStyle(color: Colors.blue)),
                        ]),
                      ),
                      if(_showInputRow) _inputFieldWidget(),
                      Row(children: [
                        const Spacer(),
                        TextButton(
                            onPressed: () {
                              _showFilters();
                            },
                            child: const Text('Sắp xếp theo')),
                      ]),
                    ]),
                    Column(
                        children: feedBacks.map((feedBack) {
                          return Column(children:[
                            _feedbackItem(feedBack),
                            const SizedBox(height: 10),
                          ]);
                        }).toList()),
                  ]);
                } else {
                  return Container();
                }
              },
            ),
          ),
          ),
          if(_showBottom) Stack(children: [
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
          ]),
        ]
      ),
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