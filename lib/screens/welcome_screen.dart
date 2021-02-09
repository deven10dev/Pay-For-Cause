import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pay_for_cause/screens/select_city_screen.dart';
import 'package:pay_for_cause/widgets/no_internet_widget.dart';
import 'package:pay_for_cause/screens/admin_control_screen.dart';
import 'package:pay_for_cause/screens/navigation_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false, signIn = true;
  final _auth = FirebaseAuth.instance;
  final dbRef = FirebaseDatabase.instance.reference();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: NoInternetWidget(),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  SizedBox(height: 56),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Pay For Cause',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 35),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Material(
                          shape: Border(
                            bottom: BorderSide(
                              color: signIn
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: FlatButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: () {
                              if (!isLoading) {
                                setState(() {
                                  signIn = !signIn;
                                });
                              }
                            },
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                color: signIn
                                    ? Theme.of(context).primaryColor
                                    : Colors.green[200],
                                fontSize: 24.0,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        Material(
                          shape: Border(
                            bottom: BorderSide(
                              color: !signIn
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: FlatButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: () {
                              if (!isLoading) {
                                setState(() {
                                  signIn = !signIn;
                                });
                              }
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: !signIn
                                    ? Theme.of(context).primaryColor
                                    : Colors.green[200],
                                fontSize: 24.0,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      validator: (val) => val.isEmpty ? "Enter an email" : null,
                      controller: nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'User Name',
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextFormField(
                      validator: (val) => val.length < 6
                          ? "Enter a password 6+ chars long"
                          : null,
                      obscureText: true,
                      controller: passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: RaisedButton(
                        textColor: Colors.white,
                        color: Theme.of(context).primaryColor,
                        child: Text(signIn ? 'Login' : 'Register'),
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState.validate()) {
                            if (!isLoading) {
                              setState(() {
                                isLoading = true;
                              });

                              if (signIn) {
                                try {
                                  final existingUser =
                                      await _auth.signInWithEmailAndPassword(
                                    email: nameController.text,
                                    password: passwordController.text,
                                  );
                                  dbRef
                                      .child('Admin Control')
                                      .child('email')
                                      .once()
                                      .then((data) {
                                    if (data.value == _auth.currentUser.email) {
                                      Navigator.popAndPushNamed(
                                          context, AdminControlScreen.id);
                                    } else {
                                      if (existingUser != null) {
                                        dbRef
                                            .child('User Details')
                                            .child(nameController.text
                                                .substring(
                                                    0,
                                                    nameController.text
                                                        .indexOf('@')))
                                            .child('type')
                                            .once()
                                            .then(
                                          (user) {
                                            if (user.value == 'user') {
                                              dbRef
                                                  .child('User Details')
                                                  .child(FirebaseAuth.instance
                                                      .currentUser.email
                                                      .substring(
                                                          0,
                                                          FirebaseAuth.instance
                                                              .currentUser.email
                                                              .indexOf('@')))
                                                  .child('city')
                                                  .once()
                                                  .then((data) {
                                                data.value != null
                                                    ? Navigator.popAndPushNamed(
                                                        context,
                                                        NavigationScreen.id)
                                                    : Navigator.popAndPushNamed(
                                                        context,
                                                        SelectCityScreen.id);
                                              });
                                            } else {
                                              setState(() {
                                                isLoading = false;
                                              });
                                              Navigator.popAndPushNamed(
                                                  context, NavigationScreen.id);
                                            }
                                          },
                                        );
                                      }
                                    }
                                  });
                                } catch (e) {}
                              } else {
                                dbRef
                                    .child('User Details')
                                    .child(nameController.text
                                        .toLowerCase()
                                        .substring(
                                            0,
                                            nameController.text
                                                .toLowerCase()
                                                .indexOf('@')))
                                    .child('type')
                                    .set('user');

                                dbRef
                                    .child('User Details')
                                    .child(nameController.text
                                        .toLowerCase()
                                        .substring(
                                            0,
                                            nameController.text
                                                .toLowerCase()
                                                .indexOf('@')))
                                    .child('email')
                                    .set(nameController.text.toLowerCase());

                                try {
                                  final newUser = await _auth
                                      .createUserWithEmailAndPassword(
                                    email: nameController.text,
                                    password: passwordController.text,
                                  );
                                  if (newUser != null) {
                                    Navigator.popAndPushNamed(
                                        context, NavigationScreen.id);
                                  }
                                } catch (e) {}
                              }
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Text(
                          signIn
                              ? 'Does not have account?'
                              : 'Already have an account?',
                        ),
                        FlatButton(
                          textColor: Theme.of(context).primaryColor,
                          child: Text(
                            signIn ? 'Sign Up' : 'Log In',
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () async {
                            if (!isLoading) {
                              setState(() {
                                signIn = !signIn;
                              });
                            }
                          },
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ),
                  isLoading
                      ? Container(
                          padding: EdgeInsets.all(10),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
