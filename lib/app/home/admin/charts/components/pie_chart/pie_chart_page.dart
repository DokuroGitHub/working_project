import 'package:flutter/material.dart';
import 'package:working_project/app/home/admin/charts/components/pie_chart/pie_model.dart';
import 'package:working_project/models/my_user.dart';
import 'package:working_project/services/database_service.dart';

import 'samples/pie_chart_sample1.dart';
import 'samples/pie_chart_sample2.dart';
import 'samples/pie_chart_sample3.dart';

class PieChartPage extends StatelessWidget {
  final Color barColor = Colors.white;
  final Color barBackgroundColor = const Color(0xff72d8bf);
  final double width = 22;

  const PieChartPage({Key? key}) : super(key: key);

  Widget _buildPieCharts(){
    return StreamBuilder(
      stream: DatabaseService().getStreamListMyUser(),
      builder: (BuildContext context, AsyncSnapshot<List<MyUser>> snapshot) {
        if(snapshot.data!=null){
          List<PieModel> pies = [];
          List<MyUser> myUsers = snapshot.data!;
          List<String> roles = [];
          for(int i = 0;i<myUsers.length;i++){
            String role = myUsers[i].role;
            if(!roles.contains(role)){
              roles.add(role);
            }
          }
          for(int i = 0;i<roles.length;i++){
            String role = roles[i];
            int count = 0;
            for(int j = 0;j<myUsers.length;j++){
              if(role==myUsers[j].role){
                count++;
              }
            }
            double value = count/myUsers.length;
            PieModel pie = PieModel(title: role, count: count, value: value);
            pies.add(pie);
          }

          return Column(children: [
            PieChartSample1(pies: pies),
            const SizedBox(
              height: 12,
            ),
            PieChartSample2(pies:pies),
            const SizedBox(
              height: 12,
            ),
            PieChartSample3(pies: pies),
          ],);
        }else{
          return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffeceaeb),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: ListView(
          children: <Widget>[
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  'Pie Chart',
                  style: TextStyle(
                      color: Color(
                        0xff333333,
                      ),
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            //TODO:
            _buildPieCharts(),
          ],
        ),
      ),
    );
  }
}
