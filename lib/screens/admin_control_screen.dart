import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pay_for_cause/screens/welcome_Screen.dart';
import 'package:pay_for_cause/screens/change_accounts_type_screen.dart';

class AdminControlScreen extends StatefulWidget {
  static const id = 'admin_control_screen';

  @override
  _AdminControlScreenState createState() => _AdminControlScreenState();
}

class _AdminControlScreenState extends State<AdminControlScreen> {
  final _auth = FirebaseAuth.instance;
  final dbRef = FirebaseDatabase.instance.reference();
  List _qalist = [];

  final TextEditingController queCon1 = TextEditingController();
  final TextEditingController queCon2 = TextEditingController();
  final TextEditingController queCon3 = TextEditingController();

  final TextEditingController ansCon1 = TextEditingController();
  final TextEditingController ansCon2 = TextEditingController();
  final TextEditingController ansCon3 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pay For Cause (Admin)')),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: [
            AdminQAWidget(queCon: queCon1, ansCon: ansCon1),
            AdminQAWidget(queCon: queCon2, ansCon: ansCon2),
            AdminQAWidget(queCon: queCon3, ansCon: ansCon3),
            Row(
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: RaisedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();

                      _qalist.clear();
                      _qalist.add([queCon1.text, ansCon1.text]);
                      _qalist.add([queCon2.text, ansCon2.text]);
                      _qalist.add([queCon3.text, ansCon3.text]);

                      dbRef
                          .child('Admin Control')
                          .child('Question and Answers')
                          .once()
                          .then((data) {
                        Map temp = data.value;
                        bool didBreak = true;

                        for (int i = 0; i < data.value.length; i++) {
                          if (data.value.containsKey(_qalist[i][0])) {
                            if (data.value[_qalist[i][0]].toString() ==
                                _qalist[i][1]) {
                              temp.remove(_qalist[i][0]);
                              didBreak = false;
                              print(temp);
                            } else {
                              Fluttertoast.showToast(
                                msg: 'One or more question or answer is wrong',
                                toastLength: Toast.LENGTH_LONG,
                              );
                              break;
                            }
                          } else {
                            Fluttertoast.showToast(
                              msg: 'One or more question or answer is wrong',
                              toastLength: Toast.LENGTH_LONG,
                            );
                            break;
                          }
                        }

                        if (!didBreak) {
                          Navigator.pushNamed(context, ChangeAccountsType.id);
                        }
                      });
                    },
                    textColor: Colors.white,
                    color: Colors.green,
                    child: Text('Go'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: RaisedButton(
                    onPressed: () async {
                      await _auth.signOut();
                      FocusScope.of(context).unfocus();
                      Navigator.popAndPushNamed(context, WelcomeScreen.id);
                    },
                    textColor: Colors.white,
                    color: Colors.red,
                    child: Text('Log Out'),
                  ),
                ),
                SizedBox(width: 10),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class AdminQAWidget extends StatelessWidget {
  AdminQAWidget({this.queCon, this.ansCon});
  final TextEditingController queCon;
  final TextEditingController ansCon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: queCon,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Question',
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: ansCon,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Answer',
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: Divider(color: Colors.black),
        ),
      ],
    );
  }
}
