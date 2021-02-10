import 'package:pay_for_cause/models/city_info.dart';
import 'package:pay_for_cause/models/current_user.dart';
import 'package:pay_for_cause/models/donation_info.dart';
import 'package:pay_for_cause/models/owner_edit.dart';
import 'package:pay_for_cause/screens/donation_screen.dart';
import 'package:pay_for_cause/screens/org_info_screen.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pay_for_cause/screens/navigation_screen.dart';
import 'package:pay_for_cause/screens/org_around_me.dart';
import 'package:pay_for_cause/screens/select_city_screen.dart';
import 'package:pay_for_cause/screens/welcome_screen.dart';
import 'package:pay_for_cause/screens/admin_control_screen.dart';
import 'package:pay_for_cause/screens/change_accounts_type_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  bool isLoggedIn() {
    try {
      final _auth = FirebaseAuth.instance;
      return _auth.currentUser != null ? true : false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CityDataList>(
          create: (context) => CityDataList(),
        ),
        ChangeNotifierProvider<CurrentUser>(
          create: (context) => CurrentUser(),
        ),
        ChangeNotifierProvider<OwnerEdit>(
          create: (context) => OwnerEdit(),
        ),
        ChangeNotifierProvider<DonationInfo>(
          create: (context) => DonationInfo(),
        ),
      ],
      child: ConnectivityAppWrapper(
        app: MaterialApp(
          theme: ThemeData(primaryColor: Colors.green),
          initialRoute: isLoggedIn() ? NavigationScreen.id : WelcomeScreen.id,
          routes: {
            WelcomeScreen.id: (context) => WelcomeScreen(),
            NavigationScreen.id: (context) => NavigationScreen(),
            SelectCityScreen.id: (context) => SelectCityScreen(),
            OrgAroundMe.id: (context) => OrgAroundMe(),
            AdminControlScreen.id: (context) => AdminControlScreen(),
            ChangeAccountsType.id: (context) => ChangeAccountsType(),
            OrgInfoScreen.id: (context) => OrgInfoScreen(
                  ngoData: ModalRoute.of(context).settings.arguments,
                ),
            DonationScreen.id: (context) => DonationScreen(
                  ngoData: ModalRoute.of(context).settings.arguments,
                ),
          },
        ),
      ),
    );
  }
}
