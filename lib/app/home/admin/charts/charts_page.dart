import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/models/my_user.dart';
import 'components/line_chart/line_chart_page.dart';
import 'components/pie_chart/pie_chart_page.dart';
import 'components/utils/platform_info.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({required this.myUser, this.controller});

  final MyUser myUser;
  final ScrollController? controller;

  @override
  createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  int _currentPage = 0;

  final _controller = PageController(initialPage: 0);
  final _duration = const Duration(milliseconds: 300);
  final _curve = Curves.easeInOutCubic;
  final _pages = const [
    LineChartPage(),
    PieChartPage(),
  ];

  bool get isDesktopOrWeb => PlatformInfo().isDesktopOrWeb();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page!.round();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          physics: isDesktopOrWeb
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          controller: _controller,
          children: _pages,
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(36,16,16,60),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Visibility(
              visible: _currentPage != 0,
              child: FloatingActionButton(
                onPressed: () => _controller.previousPage(
                    duration: _duration, curve: _curve),
                child: const Icon(Icons.chevron_left_rounded),
              ),
            ),
            const Spacer(),
            Visibility(
              visible: _currentPage != _pages.length - 1,
              child: FloatingActionButton(
                onPressed: () => _controller.nextPage(
                    duration: _duration, curve: _curve),
                child: const Icon(Icons.chevron_right_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

