import 'package:flutter/material.dart';
import '/models/feedback.dart';

class Summary extends StatelessWidget {
  const Summary({required this.feedBacks});

  final List<FeedBack> feedBacks;

  String _rating() {
    List<num> _listRating = feedBacks.map((e) => e.rating).toList();
    double _rating = 0;
    double _sum = 0;
    int _length = _listRating.length;
    for (var item in _listRating) {
      _sum += item;
    }
    if (_length > 0) {
      _rating = _sum / _length;
    }
    return _rating.toStringAsFixed(1);
  }

  Widget _line(double len, double size) {
    return Container(
      constraints: BoxConstraints(maxWidth: len, maxHeight: 5),
      child: Row(children: [
        Container(
          constraints: BoxConstraints(maxWidth: size),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.amberAccent,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomLeft: Radius.circular(25)),
            ),
          ),
        ),
        Expanded(
          child: Container(
            child: Container(),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25)),
            ),
          ),
        )
      ]),
    );
  }

  Widget _ratingDetails(BuildContext context) {
    int total = feedBacks.length;
    if(total==0){
      total = 1;
    }
    int star5 = 0;
    int star4 = 0;
    int star3 = 0;
    int star2 = 0;
    int star1 = 0;
    for (var item in feedBacks) {
      switch (item.rating) {
        case 5:
          star5++;
          break;
        case 4:
          star4++;
          break;
        case 3:
          star3++;
          break;
        case 2:
          star2++;
          break;
        case 1:
          star1++;
          break;
        default:
          break;
      }
    }
    double maxSize = MediaQuery.of(context).size.width * .4;
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Row(children: [
        const Spacer(),
        const Icon(Icons.star),
        const Icon(Icons.star),
        const Icon(Icons.star),
        const Icon(Icons.star),
        const Icon(Icons.star),
        const SizedBox(width: 10),
        _line(maxSize, maxSize * star5 / total),
      ]),
      Row(children: [
        const Spacer(),
        const Icon(Icons.star),
        const Icon(Icons.star),
        const Icon(Icons.star),
        const Icon(Icons.star),
        const SizedBox(width: 10),
        _line(maxSize, maxSize * star4 / total),
      ]),
      Row(children: [
        const Spacer(),
        const Icon(Icons.star),
        const Icon(Icons.star),
        const Icon(Icons.star),
        const SizedBox(width: 10),
        _line(maxSize, maxSize * star3 / total),
      ]),
      Row(children: [
        const Spacer(),
        const Icon(Icons.star),
        const Icon(Icons.star),
        const SizedBox(width: 10),
        _line(maxSize, maxSize * star2 / total),
      ]),
      Row(children: [
        const Spacer(),
        const Icon(Icons.star),
        const SizedBox(width: 10),
        _line(maxSize, maxSize * star1 / total),
      ]),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        const SizedBox(width: 20),
        Column(children: [
          Text(_rating(), style: const TextStyle(fontSize: 35)),
          const Text('/5'),
        ]),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _ratingDetails(context),
            const SizedBox(height: 10),
            Text('${feedBacks.length} xếp hạng'),
          ]),
        ),
      ]),
    ]);
  }
}
