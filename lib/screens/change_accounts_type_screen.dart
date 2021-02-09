import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangeAccountsType extends StatefulWidget {
  static const id = 'change_accounts_type';

  @override
  _ChangeAccountsTypeState createState() => _ChangeAccountsTypeState();
}

class _ChangeAccountsTypeState extends State<ChangeAccountsType> {
  final dbRef = FirebaseDatabase.instance.reference();

  final TextEditingController _controller = TextEditingController();
  bool changeToUser = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Pay For Cause (Admin)')),
        body: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FlatButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      changeToUser = true;
                    });
                  },
                  textColor: changeToUser ? Colors.white : Colors.black,
                  color: changeToUser ? Colors.blue : Colors.transparent,
                  child: Text('Change to User'),
                ),
                FlatButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      changeToUser = false;
                    });
                  },
                  textColor: !changeToUser ? Colors.white : Colors.black,
                  color: !changeToUser ? Colors.blue : Colors.transparent,
                  child: Text('Change to Organization'),
                )
              ],
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Emails',
                ),
              ),
            ),
            SizedBox(height: 15),
            Container(
              height: 50,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: RaisedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  dbRef
                      .child('User Details')
                      .child(_controller.text.toLowerCase().substring(
                          0, _controller.text.toLowerCase().indexOf('@')))
                      .child('type')
                      .once()
                      .then((data) {
                    if (data.value != null) {
                      dbRef
                          .child('User Details')
                          .child(_controller.text.toLowerCase().substring(
                              0, _controller.text.toLowerCase().indexOf('@')))
                          .child('type')
                          .set(changeToUser ? 'user' : 'organization');
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Invalid Email',
                        toastLength: Toast.LENGTH_LONG,
                      );
                    }
                    print(data.value);
                  });
                },
                textColor: Colors.white,
                color: Colors.green,
                child: Text('Change'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
