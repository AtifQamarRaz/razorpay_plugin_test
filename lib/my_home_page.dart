
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter_customui/model/upi_account.dart';
import 'package:razorpay_flutter_customui/model/Error.dart';
import 'package:razorpay_flutter_customui/razorpay_flutter_customui.dart';
import 'package:razorpay_plugin_test/sim_dialog.dart';
import 'package:razorpay_plugin_test/tpv_dialog.dart';
import 'package:razorpay_plugin_test/turbo_upi_model.dart';

import 'bank_account_dialog.dart';
import 'bank_list_screen_page.dart';
import 'card_dialog.dart';
import 'get_linked_upi_account_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String key = "rzp_test_5sHeuuremkiApj"; //    //rzp_test_0wFRWIZnH65uny //rzp_test_5sHeuuremkiApj

  String? availableUpiApps;
  bool showUpiApps = false;
  TurboUPIModel? turboUPIModel;


  late Razorpay _razorpay;
  Map<String, dynamic>? commonPaymentOptions;
  TextEditingController _controllerMerchantKey = new TextEditingController();
  TextEditingController _controllerHandle = new TextEditingController();
  TextEditingController _controllerMobile = new TextEditingController();

  final int _CODE_EVENT_SUCCESS = 200;
  final int _CODE_EVENT_ERROR = 201;
  bool isLoading = false;

  // For Turbo UPI
  String turboUpiHandle = 'axisbank';
  String mobileNo = "";

  @override
  void initState() {
    turboUPIModel = TurboUPIModel();
    initValueForTurboUPI();
    _razorpay = Razorpay(key);
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_UPI_TURBO_LINK_NEW_UPI_ACCOUNT, _handleNewUpiAccountResponse);
    super.initState();
  }

  void initValueForTurboUPI(){
    _controllerMerchantKey.text = key;
    _controllerHandle.text = turboUpiHandle;
    turboUPIModel?.merchantKey = key;
    turboUPIModel?.handle = turboUpiHandle ;
    _controllerMobile.text = mobileNo;
    turboUPIModel?.mobileNumber = mobileNo;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Turbo UPI Razorpay'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                  controller: _controllerMobile ,
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
                    _razorpay.upiTurbo.linkNewUpiAccount(
                        customerMobile: turboUPIModel?.mobileNumber);
                  },
                  child: Text('LinkNewUpiAccount')),
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
                    getLinkedUpiAccounts();
                  },
                  child: Text('GetLinkedUpiAccounts')),
              SizedBox(height: 8.0),
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return TpvDialog(
                          customerMobile : turboUPIModel!.mobileNumber,
                          razorpay: _razorpay,
                        );
                      },
                    );
                  },
                  child: Text('TurboViaTPV')),
              SizedBox(height: 8.0),
              SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }

  void getLinkedUpiAccounts() {
    print("getLinkedUpiAccounts()");
    _razorpay.upiTurbo.getLinkedUpiAccounts(
        customerMobile: turboUPIModel?.mobileNumber,
        onSuccess: (List<UpiAccount> upiAccounts){
          print("onSuccess() upiAccounts");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) {
                return GetLinkedUPIAccountPage(
                    razorpay: _razorpay, upiAccounts: upiAccounts ,
                    keyValue : key);
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
