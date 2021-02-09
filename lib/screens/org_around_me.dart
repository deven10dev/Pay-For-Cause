import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pay_for_cause/widgets/no_internet_widget.dart';
import 'package:pay_for_cause/widgets/org_info_card.dart';
import 'package:provider/provider.dart';
import 'package:pay_for_cause/models/current_user.dart';
import 'package:pay_for_cause/models/city_info.dart';
import 'package:pay_for_cause/widgets/custom_drawer.dart';
import 'package:pay_for_cause/widgets/no_org_widget.dart';

class OrgAroundMe extends StatefulWidget {
  static const String id = 'org_around_me_screen';

  @override
  _OrgAroundMeState createState() => _OrgAroundMeState();
}

class _OrgAroundMeState extends State<OrgAroundMe> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final dbRef = FirebaseDatabase.instance.reference();
  final userName = FirebaseAuth.instance.currentUser.email
      .substring(0, FirebaseAuth.instance.currentUser.email.indexOf('@'));
  final userDetails =
      FirebaseDatabase.instance.reference().child('User Details');
  dynamic orgPath;
  dynamic cityData;

  @override
  void initState() {
    cityData = Provider.of<CityDataList>(context, listen: false).cityInfo;
    orgPath = FirebaseDatabase.instance
        .reference()
        .child('NGO')
        .child(Provider.of<CurrentUser>(context, listen: false).city)
        .child('ngo');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(title: Text('Pay For Cause')),
      drawer: CustomDrawer(cityData: cityData),
      body: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: NoInternetWidget(),
        child: Provider.of<CurrentUser>(context, listen: false)
                .noNgoCity
                .contains(Provider.of<CurrentUser>(context, listen: false).city)
            ? NoOrgWidget()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    for (var orgName
                        in Provider.of<CurrentUser>(context, listen: false)
                            .ngoList)
                      OrgInfoCard(
                          orgName: orgName,
                          rating:
                              orgPath.child(orgName).child('rating').onValue,
                          address:
                              orgPath.child(orgName).child('address').onValue,
                          type: orgPath.child(orgName).child('type').onValue,
                          status:
                              orgPath.child(orgName).child('status').onValue,
                          bannerURL: orgPath
                              .child(orgName)
                              .child('bannerURL')
                              .onValue),
                  ],
                ),
              ),
      ),
    );
  }
}
