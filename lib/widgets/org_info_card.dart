import 'package:cached_network_image_builder/cached_network_image_builder.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pay_for_cause/models/current_user.dart';
import 'package:pay_for_cause/screens/org_info_screen.dart';
import 'package:pay_for_cause/widgets/loading_circle_avatar.dart';
import 'package:pay_for_cause/widgets/skeleton_widget.dart';
import 'package:provider/provider.dart';

class OrgInfoCard extends StatelessWidget {
  OrgInfoCard({
    @required this.orgName,
    @required this.rating,
    @required this.bannerURL,
    @required this.type,
    @required this.status,
    @required this.address,
  });

  final bannerURL;
  final String orgName;
  final address;
  final rating;
  final type;
  final status;

  final dbRef = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        dbRef
            .child('NGO')
            .child(Provider.of<CurrentUser>(context, listen: false).city)
            .child('ngo')
            .child(orgName)
            .once()
            .then((data) async {
          var path = dbRef
              .child('NGO')
              .child(Provider.of<CurrentUser>(context, listen: false).city)
              .child('ngo')
              .child(orgName);
          var upiID = await path.child('upiID').once();

          // TODO: Change the aguments according to org info screen
          Navigator.pushNamed(context, OrgInfoScreen.id,
              arguments: <String, dynamic>{
                'name': orgName,
                'images': data.value['images'],
                'missionStatement': path.child('missionStatement').onValue,
                'links': path.child('links').onValue,
                'ownerEmail': path.child('owner email').onValue,
                'contactNo': path.child('contactNo').onValue,
                'address': path.child('address').onValue,
                'time': path.child('time').onValue,
                'upiID': upiID.value,
                'workingDays': path.child('workingDays').onValue,
              });
        });
      },
      child: Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white70, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: AspectRatio(
                  aspectRatio: 2.35 / 1,
                  child: StreamBuilder(
                    stream: bannerURL,
                    builder: (context, snap) {
                      if (snap.hasData && snap.data != null) {
                        return CachedNetworkImageBuilder(
                          url: snap.data.snapshot.value,
                          placeHolder: LoadingCircleAvatar(orgName[0]),
                          errorWidget: LoadingCircleAvatar(orgName[0]),
                          builder: (image) {
                            return Image.file(
                              image,
                              fit: BoxFit.fill,
                            );
                          },
                        );
                      } else {
                        return SkeletonWidget();
                      }
                    },
                  )),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 20.0,
                top: 15.0,
                right: 10.0,
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 150,
                        child: Text(
                          orgName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 3, horizontal: 5),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                            child: Row(
                              children: [
                                StreamBuilder(
                                  stream: rating,
                                  builder: (context, snap) {
                                    if (snap.hasData && snap.data != null) {
                                      return Text(
                                        snap.data.snapshot.value.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
                                    } else {
                                      return Text(
                                        '?',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.star,
                                  size: 17,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "·",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 5),
                          StreamBuilder(
                            stream: address,
                            builder: (context, snap) {
                              if (snap.hasData && snap.data != null) {
                                return Text(
                                  snap.data.snapshot.value,
                                  overflow: TextOverflow.ellipsis,
                                );
                              } else {
                                return SkeletonWidget();
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StreamBuilder(
                        stream: status,
                        builder: (context, snap) {
                          if (snap.hasData && snap.data != null) {
                            return Text(
                              snap.data.snapshot.value,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: snap.data.snapshot.value.toLowerCase() ==
                                        'open'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          } else {
                            return SkeletonWidget();
                          }
                        },
                      ),
                      SizedBox(height: 5.0),
                      StreamBuilder(
                        stream: type,
                        builder: (context, snap) {
                          if (snap.hasData && snap.data != null) {
                            return Text(
                              snap.data.snapshot.value,
                              overflow: TextOverflow.fade,
                            );
                          } else {
                            return SkeletonWidget();
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
