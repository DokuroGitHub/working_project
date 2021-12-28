import 'package:flutter/material.dart';
import 'package:working_project/app/home/admin/charts/components/line_chart/line_model.dart';
import 'package:working_project/models/my_user.dart';
import 'package:working_project/services/database_service.dart';

import 'samples/line_chart_sample1.dart';
import 'samples/line_chart_sample2.dart';

class LineChartPage extends StatelessWidget {
  const LineChartPage({Key? key}) : super(key: key);

  int _monthGap(DateTime dateTime1, DateTime dateTime2) {
    int gap = 0;
    final year1 = dateTime1.year;
    final year2 = dateTime2.year;
    final month1 = dateTime1.month;
    final month2 = dateTime2.month;
    final yearGap = year1 - year2;
    final monthGap = month1 - month2;
    if (year1 == year2) {
      gap = yearGap * 12 + monthGap;
    }
    return gap;
  }

  String _monthIntToString(int month) {
    while (month < 1) {
      month += 12;
    }
    while (month > 12) {
      month -= 12;
    }
    switch (month) {
      case 1:
        return 'JAN';
      case 2:
        return 'FEB';
      case 3:
        return 'MAR';
      case 4:
        return 'APR';
      case 5:
        return 'MAY';
      case 6:
        return 'JUN';
      case 7:
        return 'JUL';
      case 8:
        return 'AUG';
      case 9:
        return 'SEP';
      case 10:
        return 'OCT';
      case 11:
        return 'NOV';
      case 12:
        return 'DEC';
      default:
        return '';
    }
  }

  Widget _buildCharts() {
    return StreamBuilder(
      stream: DatabaseService().getStreamListMyUser(),
      builder: (BuildContext context, AsyncSnapshot<List<MyUser>> snapshot) {
        if (snapshot.data != null) {
          List<MyUser> myUsers = snapshot.data!;
          final now = DateTime.now();
          final monthNow = now.month;
          List<String> roles = [];
          List<Line> lines = [];
          //TODO: count role types
          for (int i = 0; i < myUsers.length; i++) {
            String role = myUsers[i].role;
            if (!roles.contains(role)) {
              roles.add(role);
            }
          }
          //TODO: count monthly
          for (int i = 0; i < roles.length; i++) {
            String role = roles[i];
            int value1 = 0;
            int value2 = 0;
            int value3 = 0;
            int value4 = 0;
            int value5 = 0;
            int value6 = 0;
            int value7 = 0;
            int value8 = 0;
            int value9 = 0;
            int value10 = 0;
            int value11 = 0;
            int value12 = 0;
            for (int j = 0; j < myUsers.length; j++) {
              if (role == myUsers[j].role) {
                //TODO: compare month gap
                int monthGap = _monthGap(now, myUsers[j].createdAt);
                switch (monthGap) {
                  case 11:
                    value1++;
                    break;
                  case 10:
                    value2++;
                    break;
                  case 9:
                    value3++;
                    break;
                  case 8:
                    value4++;
                    break;
                  case 7:
                    value5++;
                    break;
                  case 6:
                    value6++;
                    break;
                  case 5:
                    value7++;
                    break;
                  case 4:
                    value8++;
                    break;
                  case 3:
                    value9++;
                    break;
                  case 2:
                    value10++;
                    break;
                  case 1:
                    value11++;
                    break;
                  case 0:
                    value12++;
                    break;
                  default:
                }
              }
            }
            Line line = Line(
              title: role,
              value1: value1,
              value2: value2,
              value3: value3,
              value4: value4,
              value5: value5,
              value6: value6,
              value7: value7,
              value8: value8,
              value9: value9,
              value10: value10,
              value11: value11,
              value12: value12,
            );
            lines.add(line);
          }
          int maxY = 0;
          for (int i = 0; i < lines.length; i++) {
            if (maxY < lines[i].value1) {
              maxY = lines[i].value1;
            }
            if (maxY < lines[i].value2) {
              maxY = lines[i].value2;
            }
            if (maxY < lines[i].value3) {
              maxY = lines[i].value3;
            }
            if (maxY < lines[i].value4) {
              maxY = lines[i].value4;
            }
            if (maxY < lines[i].value5) {
              maxY = lines[i].value5;
            }
            if (maxY < lines[i].value6) {
              maxY = lines[i].value6;
            }
            if (maxY < lines[i].value7) {
              maxY = lines[i].value7;
            }
            if (maxY < lines[i].value8) {
              maxY = lines[i].value8;
            }
            if (maxY < lines[i].value9) {
              maxY = lines[i].value9;
            }
            if (maxY < lines[i].value10) {
              maxY = lines[i].value10;
            }
            if (maxY < lines[i].value11) {
              maxY = lines[i].value11;
            }
            if (maxY < lines[i].value12) {
              maxY = lines[i].value12;
            }
          }
          num temp = maxY;
          int zeros = 10;
          while (temp > 1) {
            zeros = zeros * 10;
            temp = temp / 10;
          }
          num y1 = 0;
          num y2 = 0;
          num y3 = 0;
          num y4 = 0;
          num y5 = 0;
          if (maxY < zeros / 2) {
            y5 = zeros / 2;
          } else {
            y5 = zeros;
          }
          y1 = y5 / 5;
          y2 = 2 * y5 / 5;
          y3 = 3 * y5 / 5;
          y4 = 4 * y5 / 5;
          LineModel lineModel1 = LineModel(
            title: 'Thống kê tài khoản được tạo trong 12 tháng',
            x1: _monthIntToString(monthNow - 11),
            x2: _monthIntToString(monthNow - 10),
            x3: _monthIntToString(monthNow - 9),
            x4: _monthIntToString(monthNow - 8),
            x5: _monthIntToString(monthNow - 7),
            x6: _monthIntToString(monthNow - 6),
            x7: _monthIntToString(monthNow - 5),
            x8: _monthIntToString(monthNow - 4),
            x9: _monthIntToString(monthNow - 3),
            x10: _monthIntToString(monthNow - 2),
            x11: _monthIntToString(monthNow - 1),
            x12: _monthIntToString(monthNow),
            y1: y1.toString(),
            y2: y2.toString(),
            y3: y3.toString(),
            y4: y4.toString(),
            y5: y5.toString(),
            lines: lines,
          );
          //TODO: chart 2
          int value1 = 0;
          int value2 = 0;
          int value3 = 0;
          int value4 = 0;
          int value5 = 0;
          int value6 = 0;
          int value7 = 0;
          int value8 = 0;
          int value9 = 0;
          int value10 = 0;
          int value11 = 0;
          int value12 = 0;
          for (int i = 0; i < lines.length; i++) {
            value1+=lines[i].value1;
            value2+=lines[i].value2;
            value3+=lines[i].value3;
            value4+=lines[i].value4;
            value5+=lines[i].value5;
            value6+=lines[i].value6;
            value7+=lines[i].value7;
            value8+=lines[i].value8;
            value9+=lines[i].value9;
            value10+=lines[i].value10;
            value11+=lines[i].value11;
            value12+=lines[i].value12;
          }
          num lineModel2y1 = 0;
          num lineModel2y2 = 0;
          num lineModel2y3 = 0;
          num lineModel2y4 = 0;
          num lineModel2y5 = 0;
          num temp2 = maxY;
          int zeros2 = 10;
          while (temp2 > 1) {
            zeros2 = zeros2 * 10;
            temp2 = temp2 / 10;
          }
          if (maxY < zeros2 / 2) {
            lineModel2y5 = zeros2 / 2;
          } else {
            lineModel2y5 = zeros2;
          }
          lineModel2y1 = lineModel2y5 / 5;
          lineModel2y2 = 2 * lineModel2y5 / 5;
          lineModel2y3 = 3 * lineModel2y5 / 5;
          lineModel2y4 = 4 * lineModel2y5 / 5;
          Line line = Line(title: 'sum line',
              value1: value1,
              value2: value2,
              value3: value3,
              value4: value4,
              value5: value5,
              value6: value6,
              value7: value7,
              value8: value8,
              value9: value9,
              value10: value10,
              value11: value11,
              value12: value12,
          );

          LineModel lineModel2 = LineModel(
            title: 'sum',
            x1: lineModel1.x1,
            x2: lineModel1.x2,
            x3: lineModel1.x3,
            x4: lineModel1.x4,
            x5: lineModel1.x5,
            x6: lineModel1.x6,
            x7: lineModel1.x7,
            x8: lineModel1.x8,
            x9: lineModel1.x9,
            x10: lineModel1.x10,
            x11: lineModel1.x11,
            x12: lineModel1.x12,
            y1: lineModel2y1.toString(),
            y2: lineModel2y2.toString(),
            y3: lineModel2y3.toString(),
            y4: lineModel2y4.toString(),
            y5: lineModel2y5.toString(),
            lines: [line],
          );

          return Column(children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 28,
                right: 28,
              ),
              child: LineChartSample1(lineModel: lineModel1),
            ),
            const SizedBox(
              height: 22,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 28.0, right: 28),
              child: LineChartSample2(lineModel: lineModel2),
            ),
            const SizedBox(height: 22),
          ]);
        } else {
          return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff262545),
      child: ListView(
        children: <Widget>[
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: 36.0,
                top: 24,
              ),
              child: Text(
                'Line Chart',
                style: TextStyle(
                    color: Color(
                      0xff6f6f97,
                    ),
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          _buildCharts(),
        ],
      ),
    );
  }
}
