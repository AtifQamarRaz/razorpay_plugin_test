import 'package:flutter/material.dart';
import 'package:razorpay_flutter_customui/model/bank_model.dart';
import 'package:razorpay_flutter_customui/razorpay_flutter_customui.dart';


class BankListScreen extends StatefulWidget {
  final List<Bank> bankList;
  final Razorpay razorpay;

  BankListScreen({
    required this.bankList,
    required this.razorpay
  });

  @override
  State<BankListScreen> createState() => _BankListScreenState();
}

class _BankListScreenState extends State<BankListScreen> {
  TextEditingController editingController = TextEditingController();
  var banks = List.empty();

  @override
  void initState() {
    banks = widget.bankList;
    super.initState();

  }

  void filterSearchResults(String query) {
    setState(() {
      banks = widget.bankList.where((element) => element.name!.toLowerCase().contains(query.toLowerCase())).toList();

    });
  }


  @override
  Widget build(BuildContext context) {
    bool isLoading = false;
    return Scaffold(
      appBar: AppBar(
        title: Text('Bank List'),
      ),
      body: Column(
        children: [
          isLoading
              ? CircularProgressIndicator(
            backgroundColor: Colors.grey,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          )
              : SizedBox(height: 2,),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (value) {
               filterSearchResults(value);
              },
              controller: editingController,
              decoration: InputDecoration(
                  labelText: "Search for bank",
                  hintText: "Search for bank",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: banks.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isLoading = true;
                    });
                    widget.razorpay.getBankAccounts(banks[index]);
                  },
                  child: ListTile(
                    title: Text(banks[index].name!),
                    leading:
                    FadeInImage.assetNetwork(
                      placeholder: "images/bank_placeholder.png",
                      image: banks[index].logo!,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

