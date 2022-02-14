import 'dart:async';
import 'package:eshop/Provider/SettingProvider.dart';
import 'package:eshop/Screen/Intro_Slider.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Helper/Color.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import 'package:flutter_svg/flutter_svg.dart';


//splash screen of app
class Splash extends StatefulWidget {
    Splash({this.initialLink});
    final PendingDynamicLinkData? initialLink;
    @override
    _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<Splash> {
    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

    String link = 'aaaa';
getLink(){
    SettingProvider settingsProvider =
    Provider.of<SettingProvider>(context, listen: false);
    settingsProvider.setDynamicLink = (widget.initialLink?.link.queryParameters['refId'].toString() ?? "");
    link = settingsProvider.dynamicLink.toString();
}

    @override
    void initState() {
        super.initState();
        getLink();
        startTime();
    }

    @override
    Widget build(BuildContext context) {
        deviceHeight = MediaQuery.of(context).size.height;
        deviceWidth = MediaQuery.of(context).size.width;

        SystemChrome.setEnabledSystemUIOverlays([]);
        return Scaffold(
            key: _scaffoldKey,
            body: Stack(
                children: <Widget>[
                    Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: back(),
                        child: Center(
                            child: SvgPicture.asset(
                                'assets/images/splashlogo.svg'
                            ),
                        ),
                    ),
                    Image.asset(
                       'assets/images/doodle.png',
                        fit: BoxFit.fill,
                        width: double.infinity,
                        height: double.infinity,
                    ),
                ],
            ),
        );
    }

    startTime() async {
        var _duration = Duration(seconds: 2);
        return Timer(_duration, navigationPage);
    }

    Future<void> navigationPage() async {

        SettingProvider settingsProvider =
        Provider.of<SettingProvider>(this.context, listen: false);

        bool isFirstTime = await settingsProvider.getPrefrenceBool(ISFIRSTTIME);
        if (isFirstTime) {
            Navigator.pushReplacementNamed(context, "/home");
        } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => IntroSlider(),
                ));
        }
    }


    setSnackbar(String msg) {
        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
            content: new Text(
                msg,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.black),
            ),
            backgroundColor: Theme.of(context).colorScheme.white,
            elevation: 1.0,
        ));
    }

    @override
    void dispose() {
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        super.dispose();
    }

}