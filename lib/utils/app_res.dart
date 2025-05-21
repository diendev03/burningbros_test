import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
class AppRes{
  static void showSnackBar(BuildContext context, dynamic message,{bool isError=false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.toString()),
        backgroundColor: isError?Colors.red:Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
  Future<bool> checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult.first == ConnectivityResult.wifi ||
        connectivityResult.first == ConnectivityResult.mobile;
  }
}