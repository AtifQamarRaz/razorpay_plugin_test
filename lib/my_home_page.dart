import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:razorpay_flutter_customui/model/Sim.dart';
import 'package:razorpay_flutter_customui/model/bank_account.dart';
import 'package:razorpay_flutter_customui/model/bank_model.dart';
import 'package:razorpay_flutter_customui/model/upi_account.dart';
import 'package:razorpay_flutter_customui/razorpay_flutter_customui.dart';
import 'package:razorpay_plugin_test/sim_dialog.dart';
import 'package:razorpay_plugin_test/turbo_upi_model.dart';

import 'bank_account_dialog.dart';
import 'bank_list_screen_page.dart';
import 'card_dialog.dart';
import 'get_linked_upi_account_page.dart';
import 'package:razorpay_flutter_customui/model/Error.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String turboUpiMerchantKey = 'rzp_test_0wFRWIZnH65uny';
  String turboUpiHandle = 'axisbank';

  String selectedPaymentType = 'CARD';
  String key = "rzp_test_1DP5mmOlF5G5ag";
  String? availableUpiApps;
  bool showUpiApps = false;
  TurboUPIModel? turboUPIModel;

  //rzp_test_1DP5mmOlF5G5ag  ---> Debug Key
  //rzp_live_6KzMg861N1GUS8  ---> Live Key
  //rzp_live_cepk1crIu9VkJU  ---> Pay with Cred

  Map<String, dynamic>? netBankingOptions;
  Map<String, dynamic>? walletOptions;
  String? upiNumber;

  Map<dynamic, dynamic>? paymentMethods;

  late Razorpay _razorpay;
  Map<String, dynamic>? commonPaymentOptions;
  TextEditingController _controllerMerchantKey = new TextEditingController();
  TextEditingController _controllerHandle = new TextEditingController();

  final int _CODE_EVENT_SUCCESS = 200;
  final int _CODE_EVENT_ERROR = 201;
  bool isLoading = false;


  @override
  void initState() {
    turboUPIModel = TurboUPIModel();
    initValueForTurboUPI();
    _razorpay = Razorpay(key);
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_UPI_TURBO_LINK_NEW_UPI_ACCOUNT,
        _handleNewUpiAccountResponse);



    super.initState();
  }


  void handleCallback(String result) {
    print('Callback result: $result');
  }


  void initValueForTurboUPI(){
    _controllerMerchantKey.text = turboUpiMerchantKey;
    _controllerHandle.text = turboUpiHandle;
    turboUPIModel?.merchantKey = turboUpiMerchantKey;
    turboUPIModel?.handle = turboUpiHandle ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _controllerMerchantKey,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'MerchantKey',
                ),
                onChanged: (newValue) => turboUPIModel?.merchantKey = newValue,
              ),
            ),
            SizedBox(height: 16.0),
            Flexible(
              child: TextField(
                controller: _controllerHandle,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'Handle',
                ),
                onChanged: (newValue) => turboUPIModel?.handle = newValue,
              ),
            ),
            SizedBox(height: 16.0),
            Flexible(
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'Mobile Number',
                ),
                onChanged: (newValue) => turboUPIModel?.mobileNumber = newValue,
              ),
            ),
            SizedBox(height: 6.0),
            isLoading
                ? CircularProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            )
                : SizedBox(height: 2,),
            ElevatedButton(
                onPressed: () {
                  var error = validateTurboUpiFields();
                  if (error != '') {
                    print(error);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(error)));
                    return;
                  }

                  _razorpay.upiTurbo.linkNewUpiAccount(customerMobile : turboUPIModel?.mobileNumber);
                },
                child: Text('GetLinkNewUpiAccounts')),
            SizedBox(height: 6.0),
            ElevatedButton(
                onPressed: () {
                  var error = validateTurboUpiFields();
                  if (error != '') {
                    print(error);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(error)));
                    return;
                  }
                  setState(() {
                    isLoading = true;
                  });

                  _razorpay.upiTurbo.linkNewUpiAccount(customerMobile : turboUPIModel?.mobileNumber);
                },
                child: Text('GetLinkedUpiAccounts')),
            SizedBox(height: 16.0),

          ],
        ),
      ),

    );
  }

  String validateTurboUpiFields() {
    if ((turboUPIModel?.merchantKey == '') ||
        (turboUPIModel?.merchantKey == null)) {
      return 'Merchant Key Cannot be Empty';
    }
    if ((turboUPIModel?.handle == '') || (turboUPIModel?.handle == null)) {
      return 'Handle Cannot be Empty';
    }
    if ((turboUPIModel?.mobileNumber == '') ||
        (turboUPIModel?.mobileNumber == null)) {
      return 'Mobile Number Cannot be Empty';
    }

    return '';
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
    _controllerHandle.dispose();
    _controllerMerchantKey.dispose();
  }

  void _handlePaymentSuccess(Map<dynamic, dynamic> response) {

    final snackBar = SnackBar(
      content: Text(
        'Payment Success : ${response.toString()}',
      ),
      action: SnackBarAction(
        label: 'Okay',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    print('Payment Success Response : $response');
  }

  void _handlePaymentError(Map<dynamic, dynamic> response) {
    final snackBar = SnackBar(
      content: Text(
        'Payment Error : ${response.toString()}',
      ),
      action: SnackBarAction(
        label: 'Okay',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    print('Payment Error Response : $response');
  }

  // UPI Turbo

  void _handleNewUpiAccountResponse(dynamic response) {
    print("_handleNewUpiAccountResponse() response : ${response} ");

    if (response["error"] != null ) {
      Error error = response["error"];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Action : ${response["action"]}\nError Code : ${error.errorCode} Error Description : ${error.errorDescription}")));
      setState(() {isLoading = false;});
      return;
    }

    switch (response["action"]) {
      case "ASK_FOR_PERMISSION":
        print("ASK_FOR_PERMISSION called");
        setState(() {
          isLoading = false;
        });
        _razorpay.upiTurbo.askForPermission();
        break;
      case "LOADER_DATA":
        print("LOADER_DATA called");
        setState(() {
          isLoading = true;
        });
        break;
      case "STATUS":
        print("STATUS called ${response[""]}");
        setState(() {
          isLoading = false;
        });
        /*
          if status have no error then in response["data"] upiAccounts will return .
          merchant can use this response["data"] upiAccounts or can again call
          _razorpay.getLinkedUpiAccounts(turboUPIModel?.mobileNumber)
       */
        Navigator.pop(context);
        getLinkedUpiAccounts();
        break;
      case "SELECT_SIM":
        print("SELECT_SIM called data :  ${response["data"]}");
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimDialog(
              sims: response["data"],
              razorpay: _razorpay,
            );
          },
        );
        break;
      case "SELECT_BANK":
        setState(() {
          isLoading = false;
        });
        print("SELECT_BANK called data :  ${response["data"]}");
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                BankListScreen(razorpay: _razorpay, allbanks: response["data"]),
          ),
        );
        break;
      case "SELECT_BANK_ACCOUNT":
        setState(() {
          isLoading = false;
        });
        print("SELECT_BANK_ACCOUNT called data :  ${response["data"]}");
        var bankAccounts = response["data"];
        if (bankAccounts.isEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("No Account Found")));
          return;
        }
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return BankAccountDialog(
              bankAccounts: bankAccounts,
              razorpay: _razorpay,
            );
          },
        );
        break;
      case "SETUP_UPI_PIN":
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CardDialog(
              upiAccount: null,
              razorpay: _razorpay,
            );
          },
        );
        break;
      default:
        print('Wrong action :  ${response["action"]}');
    }
  }

  void getLinkedUpiAccounts() {
    _razorpay.upiTurbo.getLinkedUpiAccounts(
        customerMobile: turboUPIModel?.mobileNumber,
        onSuccess: (List<UpiAccount> upiAccounts){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) {
                return GetLinkedUPIAccountPage(
                    razorpay: _razorpay, upiAccounts: upiAccounts);
              },
            ),
          );
        },
        onFailure: (Error error) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error : ${error.errorDescription}")));
        });
  }

}