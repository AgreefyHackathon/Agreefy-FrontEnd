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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.yellow,
          appBar: AppBar(
            centerTitle: true,
            title: Text('Agreefy',
                style: GoogleFonts.lobster(color: Colors.black, fontSize: 36)),
            backgroundColor: Colors.blue,
          ),
          body: Builder(
            builder: (context) => Center(
              child: Column(children: <Widget>[
                Text(
                    "Welcome to Agreefy! An End-to-End Encrypted app to sign lease agreenments!",
                    style: GoogleFonts.abel(color: Colors.black, fontSize: 24)),
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
                    child: Text(
                      'Create an @Sign!',
                      style: GoogleFonts.lobster(
                          fontSize: 36, color: Colors.black),
                    ),
                  ),
                ),
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
