import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pay_for_cause/models/current_user.dart';
import 'package:pay_for_cause/models/donation_info.dart';
import 'package:pay_for_cause/widgets/no_internet_widget.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class DonationScreen extends StatefulWidget {
  static const String id = 'donation_screen';

  DonationScreen({this.ngoData});
  final Map<String, dynamic> ngoData;

  @override
  _DonationScreenState createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  TextEditingController _controller = TextEditingController();
  Razorpay _razorpay;
  final dbRef = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();

    _razorpay = new Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckOut() {
    var options = {
      "key": "rzp_test_PDOE0KZjhtjSdT",
      "amount": num.parse(_controller.text) * 100,
      "name": widget.ngoData['name'],
      "description": widget.ngoData['upiID'],
      "prefill": {
        "contact": Provider.of<DonationInfo>(context, listen: false).phoneNo,
        "email": Provider.of<DonationInfo>(context, listen: false).emailID,
      },
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e.toString);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    var dbPath = dbRef
        .child('NGO')
        .child(Provider.of<CurrentUser>(context, listen: false).city)
        .child('ngo')
        .child(widget.ngoData['name'])
        .child('moneyRaised');
    var preVal = await dbPath.once();

    Fluttertoast.showToast(msg: "SUCCESS: " + response.paymentId);
    dbPath.set(preVal.value + num.parse(_controller.text));
    Navigator.pop(context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "ERROR: Payment Aborted");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "EXTERNAL WALLET: " + response.walletName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.ngoData['name'] ?? 'Pay For Cause')),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ConnectivityWidgetWrapper(
          disableInteraction: true,
          offlineWidget: NoInternetWidget(),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  validator: (val) => val.isEmpty ? "Enter an amount" : null,
                  keyboardType: TextInputType.number,
                  controller: _controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Amount to pay',
                  ),
                ),
              ),
              SizedBox(height: 12),
              RaisedButton(
                onPressed: () {
                  if (_controller.text.isNotEmpty &&
                      RegExp(r'^[0-9]+$').hasMatch(_controller.text) &&
                      num.parse(_controller.text) > 0) {
                    openCheckOut();
                  } else {
                    Fluttertoast.showToast(msg: 'Enter a valid amount');
                  }
                },
                color: Colors.lightGreen,
                child: Text(
                  "Donate Now",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
