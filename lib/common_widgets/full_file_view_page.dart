import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:working_project/app/home/member/posts/components/video_player_box.dart';
import 'package:working_project/models/attachment.dart';
import 'package:working_project/routing/app_router.dart';

class FullFileViewPage extends StatelessWidget {
  final Attachment attachment;

  const FullFileViewPage({Key? key, required this.attachment}) : super(key: key);

  static Future<void> showPlz({required BuildContext context, required Attachment attachment}) async {
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.fullFileViewPage,
      arguments: {
        'attachment': attachment,
      },
    );
  }

  final String _defaultThumbURL = 'https://media.discordapp.net/attachments/781870218192355329/795999369165930546/135564527_2670553363257472_1695878780981957578_o.png';

  Widget _image(){
    return Scaffold(
      appBar: AppBar(
          leading: const BackButton(),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent),
      body: PhotoView(imageProvider: NetworkImage(attachment.fileURL)),
    );
  }

  Widget _video(){
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          leading: const BackButton(),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent),
      body: Center(child: VideoPlayerBox(attachment: attachment)),
    );
  }

  Widget _default(){
    return Scaffold(
      appBar: AppBar(
          leading: const BackButton(),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent),
      body: PhotoView(imageProvider: NetworkImage(attachment.thumbURL??_defaultThumbURL)),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (attachment.type){
      case 'IMAGE':
        return _image();
      case 'GIF':
      case 'VIDEO':
        return _video();
      case 'FILE':
      default:
        return _default();
    }
  }
}
