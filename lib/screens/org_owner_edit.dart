import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pay_for_cause/models/current_user.dart';
import 'package:pay_for_cause/models/owner_edit.dart';
import 'package:pay_for_cause/widgets/no_internet_widget.dart';
import 'package:provider/provider.dart';

class OrgOwnerEdit extends StatelessWidget {
  static const id = 'org_owner_edit';

  OrgOwnerEdit({this.editData});
  final editData;
  final dbRef = FirebaseDatabase.instance.reference();
  final List days = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  @override
  Widget build(BuildContext context) {
    print(Provider.of<OwnerEdit>(context, listen: false).lunchMenu);
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Mess'),
        leading: BackButton(
          onPressed: () {
            Provider.of<OwnerEdit>(context, listen: false).changedData = {};
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            child: FlatButton(
              onPressed: () {
                for (var edit in Provider.of<OwnerEdit>(context, listen: false)
                    .changedData
                    .entries
                    .map((e) => "${e.key}")
                    .toList()) {
                  dbRef
                      .child('Mess')
                      .child(
                          Provider.of<CurrentUser>(context, listen: false).city)
                      .child('mess')
                      .child(editData['name'])
                      .child(edit)
                      .set(Provider.of<OwnerEdit>(context, listen: false)
                          .changedData[edit]);
                }
                Provider.of<OwnerEdit>(context, listen: false).changedData = {};
                Navigator.pop(context);
              },
              color: Colors.white,
              child: Text(
                'Save',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: NoInternetWidget(),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                TextAndField(
                  title: ['status', 'Status'],
                  labelText: editData['status'],
                ),
                TextAndField(
                  title: ['lunchTime', 'Lunch Time'],
                  labelText: editData['lunchTime'],
                ),
                TextAndField(
                  title: ['dinnerTime', 'Dinner Time'],
                  labelText: editData['dinnerTime'],
                ),
                TextAndField(
                  title: ['type', 'Type'],
                  labelText: editData['type'],
                ),
                TextAndField(
                  title: ['contactNo', 'Contact No.'],
                  labelText: editData['contactNo'],
                ),
                TextAndField(
                  title: ['address', 'Address'],
                  labelText: editData['address'],
                ),
                TextAndField(
                  title: ['distance', 'Distance'],
                  labelText: editData['distance'],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 100,
                  height: 20,
                  child: Divider(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TextAndField extends StatelessWidget {
  TextAndField({this.title, this.labelText});

  final List title;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 5),
        Text(
          title[1],
          style: TextStyle(fontSize: 18),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(10),
            child: TextFormField(
              onChanged: (text) {
                Provider.of<OwnerEdit>(context, listen: false)
                    .changedData[title[0]] = text;
              },
              initialValue: labelText,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
          ),
        )
      ],
    );
  }
}

//                 for (String day in days)
//                   Column(
//                     children: [
//                       SizedBox(height: 8),
//                       Text(
//                         day[0].toUpperCase() + day.substring(1),
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 3),
//                       for (var dish in editData['lunchMenu'][day]
//                           .entries
//                           .map((e) => e.key)
//                           .toList()
//                             ..sort())
//                         DishAndPrice(
//                           day: day,
//                           dish: dish,
//                           con: TextEditingController(text: dish),
//                           price: editData['lunchMenu'][day][dish].toString(),
//                         ),
//                     ],
//                   ),

// class DishAndPrice extends StatelessWidget {
//   DishAndPrice({this.dish, this.price, this.day, this.con});
//   final String dish;
//   final String price;
//   final String day;
//   final TextEditingController con;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           flex: 3,
//           child: Container(
//             padding: EdgeInsets.all(10),
//             child: TextFormField(
//               onChanged: (dishName) {
//                 Provider.of<OwnerEdit>(context, listen: false).lunchMenu[day] =
//                     {dishName: 'a'};
//               },
//               keyboardType: TextInputType.multiline,
//               maxLines: null,
//               // initialValue: dish,
//               controller: con,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Dish',
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           child: Container(
//             padding: EdgeInsets.all(10),
//             child: TextFormField(
//               onChanged: (dishPrice) {},
//               keyboardType: TextInputType.multiline,
//               maxLines: null,
//               initialValue: price,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Price',
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
