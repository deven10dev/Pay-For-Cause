import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pay_for_cause/models/donation_info.dart';
import 'package:provider/provider.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:pay_for_cause/screens/org_around_me.dart';
import 'package:pay_for_cause/screens/select_city_screen.dart';
import 'package:pay_for_cause/screens/admin_control_screen.dart';
import 'package:pay_for_cause/models/city_info.dart';
import 'package:pay_for_cause/models/current_user.dart';
import 'package:pay_for_cause/screens/org_info_screen.dart';

class NavigationScreen extends StatefulWidget {
  static const String id = 'navigation_screen';

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final _auth = FirebaseAuth.instance;
  final dbRef = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    setCurrentUserUID();
    setUserCharacteristics();
    isCitySelected();
  }

  setCurrentUserUID() {
    dbRef
        .child('User Details')
        .child(_auth.currentUser.email
            .substring(0, _auth.currentUser.email.indexOf('@')))
        .child('uid')
        .set(_auth.currentUser.uid);
  }

  isCitySelected() {
    List dataList = <CityInfo>[];
    Map cityDataMap;
    List<String> cityNameList = [];

    dbRef.child('NGO').once().then((cData) {
      cData.value.forEach((key, value) {
        cityNameList.add(key);
      });
      cityNameList.sort();
      cityDataMap = cData.value;

      for (int i = 0; i < cityNameList.length; i++) {
        dataList.add(CityInfo(
          cityName: cityNameList[i],
          totalOrg: cityDataMap[cityNameList[i]]['ngo'] != null
              ? cityDataMap[cityNameList[i]]['ngo'].length.toString()
              : '0',
        ));
      }

      Provider.of<CityDataList>(context, listen: false).addData(dataList);

      dbRef.child('Admin Control').child('email').once().then((data) {
        if (data.value == _auth.currentUser.email) {
          Navigator.popAndPushNamed(context, AdminControlScreen.id);
        } else {
          dbRef
              .reference()
              .child('User Details')
              .child(FirebaseAuth.instance.currentUser.email
                  .substring(0, _auth.currentUser.email.indexOf('@')))
              .child('city')
              .once()
              .then((data) {
            dbRef
                .child('User Details')
                .child(_auth.currentUser.email.toLowerCase().substring(
                    0, _auth.currentUser.email.toLowerCase().indexOf('@')))
                .child('type')
                .once()
                .then((user) {
              if (user.value == 'user') {
                data.value != null
                    ? dbRef
                        .child('NGO')
                        .child(Provider.of<CurrentUser>(context, listen: false)
                            .city)
                        .child('ngo')
                        .once()
                        .then((data) {
                        Provider.of<CurrentUser>(context, listen: false)
                            .ngoList = [];
                        if (data.value != null) {
                          Provider.of<CurrentUser>(context, listen: false)
                                  .ngoList =
                              data.value.entries
                                  .map((e) => "${e.key}")
                                  .toList();
                        }
                        Navigator.popAndPushNamed(context, OrgAroundMe.id);
                      })
                    : Navigator.popAndPushNamed(context, SelectCityScreen.id);
              } else if (user.value == 'organization') {
                dbRef
                    .child('User Details')
                    .child(_auth.currentUser.email.toLowerCase().substring(
                        0, _auth.currentUser.email.toLowerCase().indexOf('@')))
                    .once()
                    .then((user) {
                  dbRef
                      .child('NGO')
                      .child(user.value['city'])
                      .child('ngo')
                      .child(user.value['owner'])
                      .once()
                      .then((data) {
                    if (data.value['owner email'] == _auth.currentUser.email) {
                      var path = dbRef
                          .child('NGO')
                          .child(
                              Provider.of<CurrentUser>(context, listen: false)
                                  .city)
                          .child('ngo')
                          .child(user.value['owner']);

                      dbRef
                          .child('NGO')
                          .child(
                              Provider.of<CurrentUser>(context, listen: false)
                                  .city)
                          .child('ngo')
                          .child(user.value['owner'])
                          .once()
                          .then((data) {
                        // TODO: Change the arguments according to requiements
                        Navigator.popAndPushNamed(context, OrgInfoScreen.id,
                            arguments: <String, dynamic>{
                              'name': user.value['owner'],
                              'images': data.value['images'],
                              'missionStatement':
                                  path.child('missionStatement').onValue,
                              'links': path.child('links').onValue,
                              'ownerEmail': path.child('owner email').onValue,
                              'contactNo': path.child('contactNo').onValue,
                              'address': path.child('address').onValue,
                              'time': path.child('time').onValue,
                              'workingDays': path.child('workingDays').onValue,
                              'moneyRaised': path.child('moneyRaised').onValue,
                            });
                      });
                    }
                  });
                });
              }
            });
          });
        }
      });
    });
  }

  void setUserCharacteristics() {
    dbRef
        .child('User Details')
        .child(_auth.currentUser.email
            .substring(0, _auth.currentUser.email.indexOf('@')))
        .child('city')
        .once()
        .then((data) {
      Provider.of<CurrentUser>(context, listen: false).city = data.value;
    });

    Provider.of<DonationInfo>(context, listen: false).emailID =
        _auth.currentUser.email;

    dbRef
        .child('User Details')
        .child(_auth.currentUser.email
            .toLowerCase()
            .substring(0, _auth.currentUser.email.toLowerCase().indexOf('@')))
        .child('type')
        .once()
        .then((data) {
      Provider.of<CurrentUser>(context, listen: false).type = data.value;
    });

    dbRef.child('NGO').once().then((data) {
      for (var i in data.value.keys) {
        dbRef.child('NGO').child(i).child('ngo').once().then((data) {
          if (data.value == null) {
            Provider.of<CurrentUser>(context, listen: false).noNgoCity.add(i);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.delayed(Duration(milliseconds: 700)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done)
            return Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.width - 150,
                width: MediaQuery.of(context).size.width - 150,
                child: LoadingIndicator(
                  indicatorType: Indicator.orbit,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            );
          else
            return Container();
        },
      ),
    );
  }
}
