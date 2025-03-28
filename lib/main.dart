import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:juber_car_booking/firebase_options.dart';
import 'package:juber_car_booking/screens/JCBDriverSignUpScreen.dart';
import 'package:juber_car_booking/screens/JCBGetStartedScreen.dart';
import 'package:juber_car_booking/screens/JCBLoginScreen.dart';
import 'package:juber_car_booking/screens/JCBSignUpScreen.dart';
import 'package:juber_car_booking/screens/JCBSplashScreen.dart';
import 'package:juber_car_booking/screens/driver_screens/JCBDriverHomeScreen.dart';
import 'package:juber_car_booking/services/authentication.dart';
import 'package:juber_car_booking/store/AppStore.dart';
import 'package:juber_car_booking/utils/AppTheme.dart';
import 'package:nb_utils/nb_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

AppStore appStore = AppStore();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        scrollBehavior: SBehavior(),
        navigatorKey: navigatorKey,
        title: 'Juber Car Booking',
        debugShowCheckedModeBanner: false,
        theme: AppThemeData.lightTheme,
        darkTheme: AppThemeData.darkTheme,
        themeMode: appStore.isDarkModeOn ? ThemeMode.dark : ThemeMode.light,
        home: JCBSplashScreen(),
        routes: {
          '/home': (context) => IsUserLoggedIn(),
          '/login': (context) => JCBLoginScreen(),
          '/signup': (context) => JCBSignUpScreen(),
          '/startScreen': (context) => JCBGetStartedScreen(),
          '/driverSignUp': (context) => JCBDriverSignUpScreen(),
          '/driverHomeScreen': (context) => JCBDriverHomeScreen(),
        },
        // supportedLocales: LanguageDataModel.languageLocales(),
/*        localizationsDelegates: [
          AppLocalizations(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(appStore.selectedLanguage.validate(value: AppConstant.defaultLanguage)),*/
      ),
    );
  }
}

class IsUserLoggedIn extends StatefulWidget {
  const IsUserLoggedIn({super.key});

  @override
  State<IsUserLoggedIn> createState() => _IsUserLoggedInState();
}

class _IsUserLoggedInState extends State<IsUserLoggedIn> {
  @override
  void initState() {
    FireBaseAuthentication.isUserLoggedIn().then((onValue) => {
          if (onValue == true)
            {Navigator.pushReplacementNamed(context, '/home')}
          else
            {Navigator.pushReplacementNamed(context, '/login')}
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
