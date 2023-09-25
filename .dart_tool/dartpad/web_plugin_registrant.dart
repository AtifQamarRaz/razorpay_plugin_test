// Flutter web plugin registrant file.
//
// Generated file. Do not edit.
//

// @dart = 2.13
// ignore_for_file: type=lint

import 'package:razorpay_flutter_customui/razorpay_flutter_customui_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  RazorpayFlutterCustomuiWeb.registerWith(registrar);
  registrar.registerMessageHandler();
}
