import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pay_for_cause/models/current_user.dart';
import 'package:pay_for_cause/screens/select_city_screen.dart';
import 'package:pay_for_cause/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({this.cityData});
  final List cityData;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: ListTile(
              leading: Icon(
                Icons.account_circle_sharp,
                size: 55,
                color: Colors.white70,
              ),
              title: Text(
                _auth.currentUser.email
                    .substring(0, _auth.currentUser.email.indexOf('@')),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              subtitle: Text(
                _auth.currentUser.email,
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          if (Provider.of<CurrentUser>(context, listen: false).type != 'user')
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
            ),
          if (Provider.of<CurrentUser>(context, listen: false).type == 'user')
            ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.popAndPushNamed(
                  context,
                  SelectCityScreen.id,
                  arguments: cityData,
                );
              },
              leading: Icon(Icons.location_city),
              title: Text('Change Your City'),
              subtitle: Text(
                Provider.of<CurrentUser>(context, listen: false).city,
              ),
              isThreeLine: true,
            ),
          ListTile(
            onTap: () async {
              await _auth.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, WelcomeScreen.id, (Route<dynamic> route) => false);
            },
            leading: Icon(Icons.logout),
            title: Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
