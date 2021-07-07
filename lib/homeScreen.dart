import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:videodown/Pages/discoverPage.dart';
import 'package:videodown/Pages/downloadsPage.dart';
import 'package:videodown/Pages/homePage.dart';
import 'package:videodown/Pages/musicPage.dart';
import 'package:videodown/Pages/samplePage.dart';
import 'package:videodown/configuration.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 2;
  final pages = [
    DiscoverPage(),
    SamplePage(),
    HomePage(),
    MusicPage(),
    DownloadsPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomNavBar(),
      appBar: AppBar(
        title: const Text(
          'Example',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.blue,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: PageTransitionSwitcher(
        transitionBuilder: (child, animation, secondaryAnimation) =>
            FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        ),
        child: pages[index],
      ),
    );
  }

  Widget bottomNavBar() {
    return ConvexAppBar(
      style: TabStyle.reactCircle,
      top: -20,
      curveSize: 100,
      elevation: 1,
      backgroundColor: primaryBgColor,
      activeColor: Colors.amberAccent,
      color: primaryColor,
      items: [
        TabItem(icon: CupertinoIcons.book),
        TabItem(icon: CupertinoIcons.settings),
        TabItem(icon: CupertinoIcons.house),
        TabItem(icon: CupertinoIcons.double_music_note),
        TabItem(icon: CupertinoIcons.arrow_down_circle),
      ],
      initialActiveIndex: 2,
      onTap: (int index) => setState(() => this.index = index),
    );
  }
}
