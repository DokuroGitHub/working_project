import 'package:flutter/material.dart';

import '/app/home/member/posts/components/video_player_box.dart';
import '/models/attachment.dart';
import '/models/my_user.dart';

class PostAttachments extends StatelessWidget {
  const PostAttachments({Key? key, required this.myUser, required this.attachments})
      : super(key: key);
  final MyUser myUser;
  final List<Attachment> attachments;

  final String defaultThumbURL =
      'https://i0.wp.com/media.discordapp.net/attachments/781870041862897684/784806733431701514/EIB7R00XUAAwQ6a.png';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _listItemInRow(context)),
      ),
    );
  }

  Widget _imageItem(String? thumbURL, {void Function()? onTap}) {
    return GestureDetector(
        onTap: onTap,
        child: FadeInImage.assetNetwork(
          alignment: Alignment.topCenter,
          placeholder: 'assets/images/video_place_here.png',
          image: thumbURL ?? defaultThumbURL,
          fit: BoxFit.fill,
        ));
  }

  Widget _item(Attachment attachment) {
    if (attachment.type == 'IMAGE') {
      return _imageItem(attachment.thumbURL, onTap: () {
        print('tap IMAGE');
      });
    }
    if (attachment.type == 'VIDEO') {
      return VideoPlayerBox(
          //myUser: myUser,
        attachment: attachment);
    }
    if (attachment.type == 'GIF') {
      return _imageItem(attachment.thumbURL, onTap: () {
        print('tap GIF');
      });
    }
    if (attachment.type == 'FILE') {
      return _imageItem(attachment.thumbURL, onTap: () {
        print('tap FILE');
      });
    }
    return _imageItem(attachment.thumbURL, onTap: () {
      print('tap FILE');
    });
  }

  List<Widget> _listItemInRow(BuildContext context) {
    if (attachments.isEmpty) {
      return [];
    }
    if (attachments.length == 1) {
      return [
        Expanded(child: _item(attachments[0])),
      ];
    }
    if (attachments.length == 2) {
      //TODO: 2 item, hang doc
      Expanded(
        child: Column(children: [
          _item(attachments[0]),
          _item(attachments[1]),
        ]),
      );
      //TODO: 2 item, hang ngang
      return [
        Expanded(child: _item(attachments[0])),
        Expanded(child: _item(attachments[1])),
      ];
    }
    if (attachments.length == 3) {
      //TODO: 3 item, 2 trai 1 phai
      [
        Expanded(
          child: Column(children: [
            Expanded(child: _item(attachments[0])),
            Expanded(child: _item(attachments[1])),
          ]),
        ),
        Expanded(child: _item(attachments[2])),
      ];
      //TODO: 3 item, 2 tren 1 duoi
      return [
        Expanded(
          child: Column(children: [
            Row(children: [
              Expanded(child: _item(attachments[0])),
              Expanded(child: _item(attachments[1])),
            ]),
            Expanded(child: _item(attachments[2])),
          ]),
        ),
      ];
    }
    if (attachments.length == 4) {
      //TODO: 4 items, 2 trai 2 phai
      return [
        Expanded(
          child: Column(children: [
            Expanded(child: _item(attachments[0])),
            Expanded(child: _item(attachments[1])),
          ]),
        ),
        Expanded(
          child: Column(children: [
            Expanded(child: _item(attachments[2])),
            Expanded(child: _item(attachments[3])),
          ]),
        ),
      ];
    }
    //TODO: 5 items tro len
    return [
      Expanded(
        child: Column(children: [
          Expanded(child: _item(attachments[0])),
          Expanded(child: _item(attachments[1])),
        ]),
      ),
      Expanded(
        child: Column(children: [
          Expanded(child: _item(attachments[2])),
          Stack(alignment: AlignmentDirectional.bottomEnd, children: [
            _item(attachments[3]),
            Text(
              '+${attachments.length - 4} item(s)...',
              style: const TextStyle(fontSize: 25, color: Colors.white),
            ),
          ]),
        ]),
      ),
    ];
  }
}
