import 'package:flutter/cupertino.dart';

class CityInfo {
  CityInfo({this.cityName, this.totalOrg});

  final String cityName;
  final String totalOrg;
}

class CityDataList extends ChangeNotifier {
  List<CityInfo> cityInfo = [];

  void addData(List<CityInfo> data) {
    bool flag = true;

    for (int i = 0; i < data.length; i++) {
      for (int j = 0; j < cityInfo.length; j++) {
        if (data[i].cityName == cityInfo[j].cityName) {
          flag = false;
          break;
        }
      }

      if (flag) {
        cityInfo.add(data[i]);
      }
    }
  }
}
