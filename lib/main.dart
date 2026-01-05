import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/services/customers_services.dart';
import 'package:warsha_commerce/services/orders_service.dart';
import 'package:warsha_commerce/services/products_service.dart';
import 'package:warsha_commerce/services/user_service.dart';
import 'package:warsha_commerce/utils/navigator.dart';
import 'package:warsha_commerce/view_models/cart_v_m.dart';
import 'package:warsha_commerce/view_models/customers_v_m.dart';
import 'package:warsha_commerce/view_models/order_v_m.dart';
import 'package:warsha_commerce/view_models/product_v_m.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';
import 'package:warsha_commerce/views/home/home.dart';
import 'package:warsha_commerce/views/orders/orders_history.dart';
import 'package:warsha_commerce/views/shopping_cart/shopping_cart.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:warsha_commerce/views/sign_in/profile.dart';
import 'package:warsha_commerce/views/sign_in/sign_in.dart';
import 'package:warsha_commerce/utils/firebase_options.dart';
import 'controllers/time_line.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  runApp(
    MultiProvider(
      providers: [
        //providers used for dependency injection
        Provider<ProductService>(create: (_) => ProductService()),
        Provider<OrdersService>(create: (_) => OrdersService()),
        Provider<UserService>(create: (_) => UserService()),
        Provider<CustomerService>(create: (_) => CustomerService()),

        ChangeNotifierProvider<TimelineController>(
          create: (context) => TimelineController(),
        ),

        ChangeNotifierProvider<UserViewModel>(
          create: (context) => UserViewModel(context.read<UserService>()),
        ),

        ChangeNotifierProvider<CustomerVM>(
          create: (context) => CustomerVM(context.read<CustomerService>()),
        ),

        //injecting product with api services
        ChangeNotifierProvider<CartVM>(
          create: (context) => CartVM(
            context.read<OrdersService>(),
            context.read<UserViewModel>(),
          ),
        ),

        //injecting product with api services
        ChangeNotifierProvider<OrderVM>(
          create: (context) => OrderVM(
            context.read<OrdersService>(),
            context.read<UserViewModel>(),
          ),
        ),

        //injecting product with api services
        ChangeNotifierProvider<ProductVM>(
          create: (context) => ProductVM(context.read<ProductService>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'El Warsha',
      debugShowCheckedModeBanner: false,
      // Use settings model locale, fallback to 'en'
      locale: Locale('ar', 'AE'),
      supportedLocales: const [Locale('ar', 'AE')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorKey: navigatorKey,
      theme: ThemeData(
        fontFamily: 'cairo',
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black.withAlpha(200),
          selectionColor: Colors.black.withAlpha(50),
          selectionHandleColor: Colors.black.withAlpha(50),
        ),
        dividerTheme: DividerThemeData(color: Colors.grey.shade300),
        colorScheme: ColorScheme.light(
          onPrimary: Colors.white,
          onTertiary: Colors.white,
          secondary: Colors.black87,
          onSurface: Colors.grey.shade700,
          surface: Colors.grey.shade50,
          primary: Colors.grey.shade300,
        ),
      ),
      home: const Home(),
      routes: {
        '/home': (context) => const Home(),
        '/shopping_cart': (context) => ShoppingCart(),
        '/profile': (context) => const DeliveryDetailsPage(),
        '/login': (context) => const Profile(),
        '/orders_history': (context) => const OrdersHistory(),
      },
    );
  }
}
