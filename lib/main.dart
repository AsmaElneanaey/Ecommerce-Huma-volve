import 'package:flutter/material.dart';

import 'core/services/deep_link_service.dart';
import 'core/theme.dart';
import 'features/details/screens/product_details_screen.dart';
import 'features/main_navigation/screens/main_navigation_screen.dart';
import 'features/splash/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialRoute();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _checkInitialRoute() {
    final defaultRoute =
        WidgetsBinding.instance.platformDispatcher.defaultRouteName;
    if (defaultRoute.isNotEmpty && defaultRoute != '/') {
      DeepLinkService.handleDeepLink(defaultRoute);
    }
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    final uri = routeInformation.uri.toString();
    final handled = DeepLinkService.handleDeepLink(uri);
    if (handled) return true;
    return super.didPushRouteInformation(routeInformation);
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: DeepLinkService.navigatorKey,
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final productId = DeepLinkService.extractProductId(settings.name);
        if (productId != null) {
          return MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(productId: productId),
            settings: settings,
          );
        }
        if (settings.name == '/home') {
          return MaterialPageRoute(
            builder: (_) => const MainNavigationScreen(),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      },
    );
  }
}
