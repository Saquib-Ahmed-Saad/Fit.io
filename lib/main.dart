import 'package:flutter/material.dart';

import 'fitio/app_controller.dart';
import 'fitio/fitio_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController();
  await controller.initialize();
  runApp(FitioApp(controller: controller));
}
