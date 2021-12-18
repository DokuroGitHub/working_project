import 'package:flutter/material.dart';
import 'package:working_project/common_widgets/full_file_view_page.dart';

import '/app/home/member/posts/components/video_player_box.dart';
import '/models/attachment.dart';
import '/models/my_user.dart';

class MessageAttachments extends StatelessWidget {
  const MessageAttachments(
      {Key? key, required this.myUser, required this.attachments})
      : super(key: key);
  final MyUser myUser;
  final List<Attachment> attachments;
  final int maxColumn = 3;
  final String defaultThumbURL =
      'https://i0.wp.com/media.discordapp.net/attachments/781870041862897684/784806733431701514/EIB7R00XUAAwQ6a.png';

  @override
  Widget build(BuildContext context) {
    return _listItems(context);
  }

  Future<void> _showFullFileViewPage(
      BuildContext context, Attachment attachment) async {
    await FullFileViewPage.showPlz(context: context, attachment: attachment);
  }

  Row _row(BuildContext context, int len, int rowN) {
    List<Widget> itemsInRow = [];
    //TODO: co row chac chan nItem 1->maxColumn
    int nItem = maxColumn;
    if (maxColumn * rowN > len) {
      //TODO: o row cuoi cung nItem<maxColumn
      nItem = (len - 1) % maxColumn + 1;
    }
    for (var i = 0; i < nItem; i++) {
      int index = maxColumn * (rowN - 1) + i;
      print('len: $len, rowN: $rowN, nItem: $nItem, index: $index');
      itemsInRow.add(Expanded(child: _item(context, attachments[index])));
    }
    return Row(children: itemsInRow);
  }

  List<Widget> _rows(BuildContext context) {
    int len = attachments.length;
    if (len == 0) {
      //TODO: len=0, 0 row
      return [];
    }
    //TODO: len 1 2 3 dc 1 row, 4 5 6 dc 2 row, 7 8 9 dc 3 row
    int nRow = (len - 1) ~/ maxColumn + 1;
    print('message_attachments, len: $len, nRow: $nRow');
    List<Widget> rows = [];
    //TODO: nROw
    for (var i = 1; i < nRow + 1; i++) {
      rows.add(_row(context, len, i));
    }
    return rows;
  }

  Widget _listItems(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: _rows(context));
  }

  Widget _imageItem(String? thumbURL, {void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        clipBehavior: Clip.antiAlias,
        child: FadeInImage.assetNetwork(
          alignment: Alignment.topCenter,
          placeholder: 'assets/images/video_place_here.png',
          image: thumbURL ?? defaultThumbURL,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget _item(BuildContext context, Attachment attachment) {
    if (attachment.type == 'IMAGE') {
      return _imageItem(attachment.thumbURL??attachment.fileURL, onTap: () {
        print('tap IMAGE');
        _showFullFileViewPage(context, attachment);
      });
    }
    if (attachment.type == 'VIDEO') {
      return VideoPlayerBox(
        //myUser: myUser,
        attachment: attachment,
        onDoubleTap: () {
          _showFullFileViewPage(context, attachment);
        },
      );
    }
    if (attachment.type == 'GIF') {
      return VideoPlayerBox(
        //myUser: myUser,
        attachment: attachment,
        onDoubleTap: () {
          _showFullFileViewPage(context, attachment);
        },
      );
    }
    if (attachment.type == 'FILE') {
      return _imageItem(attachment.thumbURL, onTap: () {
        print('tap FILE');
      });
    }
    return _imageItem(attachment.thumbURL??attachment.fileURL, onTap: () {
      print('tap FILE');
    });
  }
}

class ImageDialog extends StatelessWidget {
  const ImageDialog(this.image);

  final Widget image;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 200,
        height: 200,
        child: image,
      ),
    );
  }
}
