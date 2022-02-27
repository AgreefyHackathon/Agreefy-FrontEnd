import 'dart:async';
import 'dart:developer';

import 'package:at_app_flutter/at_app_flutter.dart' show AtEnv;
import 'package:at_chat_flutter/at_chat_flutter.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart'
    show Onboarding;
import 'package:at_utils/at_logger.dart' show AtSignLogger;
import 'Contacts.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;

import 'package:google_fonts/google_fonts.dart';

final AtSignLogger _logger = AtSignLogger(AtEnv.appNamespace);

Future<void> main() async {
  // * AtEnv is an abtraction of the flutter_dotenv package used to
  // * load the environment variables set by at_app
  try {
    await AtEnv.load();
  } catch (e) {
    _logger.finer('Environment failed to load from .env: ', e);
  }
  runApp(const MyApp());
}

Future<AtClientPreference> loadAtClientPreference() async {
  var dir = await getApplicationSupportDirectory();

  return AtClientPreference()
    ..rootDomain = AtEnv.rootDomain
    ..namespace = AtEnv.appNamespace
    ..hiveStoragePath = dir.path
    ..commitLogPath = dir.path
    ..isLocalStoreRequired = true;
  // TODO
  // * By default, this configuration is suitable for most applications
  // * In advanced cases you may need to modify [AtClientPreference]
  // * Read more here: https://pub.dev/documentation/at_client/latest/at_client/AtClientPreference-class.html
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // * load the AtClientPreference in the background
  Future<AtClientPreference> futurePreference = loadAtClientPreference();

  double _mediaHeight = 0;
  double _mediaWidth = 0;

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Builder(
            builder: (context) => Center(
              child: Column(children: <Widget>[
                SizedBox(
                  height: 120,
                ),
                Image(
                    image: AssetImage("assets/logo.png"),
                    width: 230,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                      "Welcome to Agreefy!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(color: Color(0xff004c4c), fontSize: 30)),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                      "An end-to-end encrypted app to sign lease agreements!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(color: Color(0xff004c4c), fontSize: 22)),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  child: ElevatedButton(
                    onPressed: () async {
                      Onboarding(
                        context: context,
                        atClientPreference: await futurePreference,
                        domain: AtEnv.rootDomain,
                        rootEnvironment: AtEnv.rootEnvironment,
                        appAPIKey: AtEnv.appApiKey,
                        onboard: (value, atsign) {
                          _logger.finer('Successfully onboarded $atsign');
                          AtClientManager atClientManager =
                              AtClientManager.getInstance();
                          initializeContactsService(
                              rootDomain: AtEnv.rootDomain);
                          initializeChatService(atClientManager, atsign!);
                        },
                        onError: (error) {
                          _logger.severe('Onboarding throws $error error');
                        },
                        nextScreen: const ContactScreen(),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xff21d0b2)), shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                        )
                    )
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2,vertical: 4),
                      child: Text(
                        'Get Started',
                        style: GoogleFonts.roboto(
                            fontSize: 28, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                                "Already have an account? Sign In",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        )
                    )
                ),
                SizedBox(height: 20,)
              ]),
            ),
          ),
        ));
  }
}

/* 
child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.yellow, Colors.blue],
            )),
          ), */
