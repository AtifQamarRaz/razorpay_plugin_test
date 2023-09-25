import 'package:flutter/material.dart';
import 'package:razorpay_flutter_customui/model/upi_account.dart';
import 'package:razorpay_flutter_customui/razorpay_flutter_customui.dart';

import 'card_dialog.dart';

class GetLinkedUPIAccountPage extends StatelessWidget {
  final List<UpiAccount> upiAccounts;
  final Razorpay razorpay;

  const GetLinkedUPIAccountPage({
    required this.upiAccounts,
    required this.razorpay,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Turbo UPI'),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: ListView.builder(
              itemCount: upiAccounts.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(10.0),
                  margin: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("VPA : ${upiAccounts[index].vpa?.address}",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                      SizedBox(
                        height: 15,
                      ),
                      ElevatedButton(
                          onPressed: () {

                            Map<String, dynamic> payload = {
                              "key":"rzp_test_0wFRWIZnH65uny",
                              "currency": "INR",
                              "amount": 100,
                              "contact": "8145628647",
                              "method": "upi",
                              "email": "vivekshindhe@gmail.com",
                              "upi": {
                                "mode": "in_app",
                                "flow": "in_app"
                              }
                            };

                            Map<String, dynamic> turboPayload = {
                              "upiAccount": razorpay.getUpiAccountStr(upiAccounts[index]),
                              "payload": payload,
                            };


                            razorpay.submit(turboPayload);

                          },
                          child: Text('Pay Rs 1.00')),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                razorpay.getBalance(upiAccounts[index]);
                              },
                              child: Text('Get Balance')),
                          ElevatedButton(
                              onPressed: () {
                                razorpay.changeUpiPin(upiAccounts[index]);
                              },
                              child: Text('Change UPI Pin')),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CardDialog(
                                      upiAccount : upiAccounts[index],
                                      razorpay: razorpay,
                                    );
                                  },
                                );
                                //CardDialog.showCustomDialog(context , upiAccounts[index] , razorpay);
                              },
                              child: Text('Reset PIN')),
                          ElevatedButton(
                              onPressed: () {
                                razorpay.delink(upiAccounts[index]);
                              },
                              child: Text('DeLink')),
                        ],
                      )
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}
