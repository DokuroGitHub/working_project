import 'package:flutter/material.dart';
import 'package:working_project/models/feedback.dart';

import '/services/database_service.dart';

class RatingWidget extends StatelessWidget {
  const RatingWidget({Key? key, required this.myUserId, this.onTap})
      : super(key: key);
  final String myUserId;
  final VoidCallback? onTap;

  Widget _rating({required num rating, required num length}) {
    return InkWell(
        onTap: onTap,
        child: Tooltip(
            message: '$length lượt đánh giá',
            child: Row(children: [
              Text(rating.toString(),
                  style: const TextStyle(color: Colors.amber)),
              const Icon(Icons.star, color: Colors.amber)
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService().getStreamListFeedback(myUserId),
      builder: (BuildContext context, AsyncSnapshot<List<FeedBack>> snapshot) {
        if (snapshot.hasError) {
          print(
              'rating_widget, getStreamListFeedback hasError: ${snapshot.error}');
          return Container();
        }
        if (snapshot.hasData) {
          List<num> listRating = snapshot.data!.map((e) => e.rating).toList();
          num rating = 0;
          num sum = 0;
          num length = listRating.length;
          for (var item in listRating) {
            sum += item;
          }
          if (length > 0) {
            rating = sum / length;
          }
          return _rating(rating: rating, length: length);
        }
        return Container();
      },
    );
  }
}
