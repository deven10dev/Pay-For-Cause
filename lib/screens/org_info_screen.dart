import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pay_for_cause/models/donation_info.dart';
import 'package:pay_for_cause/screens/donation_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image_builder/cached_network_image_builder.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pay_for_cause/models/current_user.dart';
import 'package:pay_for_cause/screens/welcome_screen.dart';
import 'package:pay_for_cause/widgets/loading_circle_avatar.dart';
import 'package:pay_for_cause/widgets/no_internet_widget.dart';
import 'package:pay_for_cause/widgets/skeleton_widget.dart';
import 'package:provider/provider.dart';

class OrgInfoScreen extends StatelessWidget {
  static const String id = 'org_info_screen';

  OrgInfoScreen({this.ngoData});
  final Map<String, dynamic> ngoData;
  final PageController _controller = PageController();
  final _auth = FirebaseAuth.instance;
  final dbRef = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    final bool isOrg =
        Provider.of<CurrentUser>(context, listen: false).type == 'organization';

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(ngoData['name'] ?? 'Pay For Cause'),
        actions: [
          // isOrg
          //     ? Padding(
          //         padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
          //         child: FlatButton(
          //           onPressed: () {
          //             dbRef
          //                 .child('NGO')
          //                 .child(
          //                     Provider.of<CurrentUser>(context, listen: false)
          //                         .city)
          //                 .child('ngo')
          //                 .child(ngoData['name'])
          //                 .once()
          //                 .then((data) {
          //               Navigator.pushNamed(context, OrgOwnerEdit.id,
          //                   arguments: <String, dynamic>{
          //                     'name': ngoData['name'],
          //                     'status': data.value['status'],
          //                     'contactNo': data.value['contactNo'].toString(),
          //                     'address': data.value['address'],
          //                     'type': data.value['type'],
          //                   });
          //             });
          //           },
          //           color: Colors.white,
          //           child: Text(
          //             'Edit',
          //             style: TextStyle(
          //               fontSize: 16,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //       )
          //     : Container(),
          isOrg
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  child: FlatButton(
                    onPressed: () async {
                      await _auth.signOut();
                      Navigator.pushNamedAndRemoveUntil(context,
                          WelcomeScreen.id, (Route<dynamic> route) => false);
                    },
                    color: Colors.white,
                    child: Text(
                      'Log Out',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : Container(),
          !isOrg
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  child: FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(context, DonationScreen.id,
                          arguments: ngoData);
                    },
                    color: Colors.transparent,
                    child: Text(
                      'Donate',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : Container()
        ],
      ),
      body: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: NoInternetWidget(),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              // Image
              Container(
                color: Colors.white,
                height: 250,
                child: PageView(
                  controller: _controller,
                  physics: BouncingScrollPhysics(),
                  children: [
                    for (var image in ngoData['images']
                        .entries
                        .map((e) => "${e.key}")
                        .toList()
                          ..sort())
                      CachedNetworkImageBuilder(
                        url: ngoData['images'][image],
                        placeHolder: LoadingCircleAvatar(
                          ngoData['name'][0],
                        ),
                        errorWidget: LoadingCircleAvatar(
                          ngoData['name'][0],
                        ),
                        builder: (image) {
                          return Image.file(
                            image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.fill,
                          );
                        },
                      ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              // Money Raised
              isOrg
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: StreamBuilder(
                                stream: ngoData['moneyRaised'],
                                builder: (context, snap) {
                                  if (snap.hasData && snap.data != null) {
                                    return Text(
                                      'Money Raised:\n ₹ ' +
                                          snap.data.snapshot.value.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18),
                                    );
                                  } else {
                                    return SkeletonWidget();
                                  }
                                }),
                          ),
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(height: 8),

              // Mission Statement
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: StreamBuilder(
                          stream: ngoData['missionStatement'],
                          builder: (context, snap) {
                            if (snap.hasData && snap.data != null) {
                              return Text(
                                'Mission Statement: \n' +
                                    snap.data.snapshot.value.toString(),
                                textAlign: TextAlign.justify,
                                style: TextStyle(fontSize: 18),
                              );
                            } else {
                              return SkeletonWidget();
                            }
                          }),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              // Time
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 5,
                    child: Column(
                      children: [
                        SizedBox(height: 8),
                        StreamBuilder(
                            stream: ngoData['time'],
                            builder: (context, snap) {
                              if (snap.hasData && snap.data != null) {
                                return Text(
                                  'Working Time: ' + snap.data.snapshot.value,
                                  style: TextStyle(fontSize: 18),
                                );
                              } else {
                                return SkeletonWidget();
                              }
                            }),
                        SizedBox(height: 8),
                        StreamBuilder(
                            stream: ngoData['workingDays'],
                            builder: (context, snap) {
                              if (snap.hasData && snap.data != null) {
                                return Text(
                                  'Working Days: ' + snap.data.snapshot.value,
                                  style: TextStyle(fontSize: 18),
                                );
                              } else {
                                return SkeletonWidget();
                              }
                            }),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              // Contact Info
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: StreamBuilder(
                          stream: ngoData['contactNo'],
                          builder: (context, snap) {
                            if (snap.hasData && snap.data != null) {
                              return Text(
                                'Contact Number: ' +
                                    snap.data.snapshot.value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18),
                              );
                            } else {
                              return SkeletonWidget();
                            }
                          }),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              // Address
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: StreamBuilder(
                          stream: ngoData['address'],
                          builder: (context, snap) {
                            if (snap.hasData && snap.data != null) {
                              return Text(
                                snap.data.snapshot.value,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18),
                              );
                            } else {
                              return SkeletonWidget();
                            }
                          }),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              // Their Website Link
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: StreamBuilder(
                          stream: ngoData['links'],
                          builder: (context, snap) {
                            if (snap.hasData && snap.data != null) {
                              return Column(
                                children: [
                                  Text(
                                    "Find out more about us on:",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(height: 8),
                                  IconNText(
                                    iconData: Icons.link,
                                    text: "Website",
                                    snapshot: snap
                                        .data.snapshot.value['websiteLink']
                                        .toString(),
                                  ),
                                  IconNText(
                                    iconData: FontAwesomeIcons.instagram,
                                    text: "Instagram",
                                    snapshot: snap
                                        .data.snapshot.value['instagramLink']
                                        .toString(),
                                  ),
                                ],
                              );
                            } else {
                              return SkeletonWidget();
                            }
                          }),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class IconNText extends StatelessWidget {
  IconNText({this.iconData, this.text, this.snapshot});

  final IconData iconData;
  final String text;
  final snapshot;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(iconData),
        SizedBox(width: 5),
        Linkify(
          onOpen: (link) async {
            if (await canLaunch(link.url)) {
              await launch(link.url);
            } else {
              throw 'Could not launch $link';
            }
          },
          text: "$text: " + snapshot,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
