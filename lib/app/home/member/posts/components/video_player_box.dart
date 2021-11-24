import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '/models/attachment.dart';
import '/models/my_user.dart';

const String defaultThumbURL =
    'https://i0.wp.com/media.discordapp.net/attachments/781870041862897684/784806733431701514/EIB7R00XUAAwQ6a.png';

class VideoPlayerBox extends StatefulWidget {
  const VideoPlayerBox(
      {Key? key, required this.myUser, required this.attachment})
      : super(key: key);

  final MyUser myUser;
  final Attachment attachment;

  @override
  _VideoPlayerBoxState createState() => _VideoPlayerBoxState();
}

class _VideoPlayerBoxState extends State<VideoPlayerBox> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  bool _showControllerButtons = true;

  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    //String defaultVideoURL = 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

    _controller = VideoPlayerController.network(widget.attachment.fileURL);

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controller to loop the video.
    _controller.setLooping(true);

    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  Widget _controllerButtons() {
    return ElevatedButton(
      onPressed: () {
        // Wrap the play or pause in a call to `setState`. This ensures the
        // correct icon is shown.
        setState(() {
          // If the video is playing, pause it.
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            // If the video is paused, play it.
            _controller.play();
          }
        });
      },
      // Display the correct icon depending on the state of the player.
      child: Icon(
        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the VideoPlayerController has finished initialization, use
          // the data it provides to limit the aspect ratio of the video.
          return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(alignment: AlignmentDirectional.center, children: [
                //TODO: Video Box
                VideoPlayer(_controller),
                //TODO: tap on video
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    print('VideoPlayer tap');
                    setState(() {
                      _showControllerButtons = !_showControllerButtons;
                    });
                  },
                  child: Container(color: Colors.transparent),
                ),
                //TODO: controller buttons
                if (_showControllerButtons) _controllerButtons(),
              ]));
        } else {
          return Stack(children: [
            FadeInImage.assetNetwork(
              alignment: Alignment.topCenter,
              placeholder: 'images/video_place_here.png',
              image: widget.attachment.thumbURL ?? defaultThumbURL,
              fit: BoxFit.fill,
            ),
            const Center(child: CircularProgressIndicator()),
          ]);
        }
      },
    );
  }
}
