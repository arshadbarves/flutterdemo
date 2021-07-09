import 'dart:async';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:videodown/Services/downloadService.dart';
import 'package:videodown/configuration.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'Services/youtubeService.dart';
import 'homeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _intentDataStreamSubscription;
  String? _sharedText;
  late DownloadService downloadService;
  late YouTubeService youTubeService;

  @override
  void initState() {
    super.initState();
    Permission.storage.request();
    SystemAlertWindow.checkPermissions;
    youTubeService = YouTubeService();
    downloadService = DownloadService();
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        _sharedText = value;
        print("Shared: $_sharedText");
      });
      // _showSheetWithoutList(value);
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      setState(() {
        _sharedText = value;
        print("Shared: $_sharedText");
      });
      // _showSheetWithoutList(value);
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        snackBarTheme: SnackBarThemeData(
            elevation: 10,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)))),
        scaffoldBackgroundColor: primaryBgColor,
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: DoubleBack(
        onFirstBackPress: (context) {
          final snackBar = SnackBar(
              margin: EdgeInsets.all(30.0),
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              content: Text('Press back again to exit'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        child: HomeScreen(),
      ),
    );
  }
}
