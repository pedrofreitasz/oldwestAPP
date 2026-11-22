import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'screens/menu_screen.dart';
import 'services/api_client.dart';
import 'state/cart_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OldwestApp());
}

class OldwestApp extends StatefulWidget {
  const OldwestApp({super.key});

  @override
  State<OldwestApp> createState() => _OldwestAppState();
}

class _OldwestAppState extends State<OldwestApp> {
  final ApiClient _api = ApiClient();
  final CartController _cart = CartController();

  @override
  void dispose() {
    _cart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'oldwest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: MenuScreen(api: _api, cart: _cart),
      );
}
