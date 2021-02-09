import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pay_for_cause/models/current_user.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:pay_for_cause/models/city_info.dart';
import 'package:pay_for_cause/screens/org_around_me.dart';
import 'package:pay_for_cause/widgets/no_internet_widget.dart';

class SelectCityScreen extends StatefulWidget {
  static const String id = 'select_city_screen';

  @override
  _SelectCityScreenState createState() => _SelectCityScreenState();
}

class _SelectCityScreenState extends State<SelectCityScreen> {
  final dbRef = FirebaseDatabase.instance.reference();
  final _auth = FirebaseAuth.instance;
  List<CityInfo> cityData;

  @override
  void initState() {
    cityData = Provider.of<CityDataList>(context, listen: false).cityInfo;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[300],
      body: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: NoInternetWidget(),
        child: Column(
          children: [
            SizedBox(height: 56),
            Container(
              child: Text(
                'Select Your City',
                style: Theme.of(context).textTheme.headline4.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    for (int tile = 0; tile < cityData.length; tile++)
                      Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Card(
                          child: ListTile(
                            onTap: () {
                              dbRef
                                  .child('User Details')
                                  .child(_auth.currentUser.email.substring(
                                      0, _auth.currentUser.email.indexOf('@')))
                                  .child('city')
                                  .set(cityData[tile].cityName);
                              Provider.of<CurrentUser>(context, listen: false)
                                  .city = cityData[tile].cityName;
                              dbRef
                                  .child('NGO')
                                  .child(Provider.of<CurrentUser>(context,
                                          listen: false)
                                      .city)
                                  .child('ngo')
                                  .once()
                                  .then((data) {
                                Provider.of<CurrentUser>(context, listen: false)
                                    .ngoList = [];
                                if (data.value != null) {
                                  Provider.of<CurrentUser>(context,
                                              listen: false)
                                          .ngoList =
                                      data.value.entries
                                          .map((e) => "${e.key}")
                                          .toList();
                                }
                                Navigator.popAndPushNamed(
                                    context, OrgAroundMe.id);
                              });
                            },
                            title: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child:
                                  Center(child: Text(cityData[tile].cityName)),
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Center(
                                child: Text(Provider.of<CityDataList>(context,
                                            listen: false)
                                        .cityInfo[tile]
                                        .totalOrg +
                                    " Organisation"),
                              ),
                            ),
                            isThreeLine: true,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
