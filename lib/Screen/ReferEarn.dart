import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Provider/SettingProvider.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../Helper/Color.dart';
import '../Helper/SimBtn.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';

class ReferEarn extends StatefulWidget {
  @override
  _ReferEarnState createState() => _ReferEarnState();
}

class _ReferEarnState extends State<ReferEarn> {

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();


  String _linkMessage = '';

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  Future<void> initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      Navigator.pushNamed(context, dynamicLinkData.link.path);
    }).onError((error) {});
  }

  Future<void> _createDynamicLink(bool short) async {
    SettingProvider settingsProvider =
    Provider.of<SettingProvider>(context, listen: false);
    print("~~~${settingsProvider.referalCode}");
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://tamyeezbidiya.page.link',
      link: Uri.parse(
          'http://supermarket.tamyeez.bidiya.com/?refId=${settingsProvider.referalCode}'),
      androidParameters: AndroidParameters(
        packageName: 'supermarket.tamyeez.bidiya',
        minimumVersion: 21,
      ),
      iosParameters:  IOSParameters(
          bundleId: "supermarket.tamyeez.bidiya",
          appStoreId: "1602651171",
          minimumVersion: "10.0"),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink =
      await dynamicLinks.buildShortLink(parameters);
      url = shortLink.shortUrl;
    } else {
      url = await dynamicLinks.buildLink(parameters);
    }

    setState(() {
      _linkMessage = url.toString();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: getSimpleAppBar(getTranslated(context, 'REFEREARN')!, context),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/images/refer.svg",
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 28.0),
                  child: Text(
                    getTranslated(context, 'REFEREARN')!,
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(color: Theme.of(context).colorScheme.fontColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    getTranslated(context, 'REFER_TEXT')!,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 28.0),
                  child: Text(
                    getTranslated(context, 'YOUR_CODE')!,
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(color: Theme.of(context).colorScheme.fontColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      decoration: new BoxDecoration(
                          border: Border.all(
                              width: 1, style: BorderStyle.solid,
                            color: colors.secondary,),
                        borderRadius: BorderRadius.circular(4),

                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          REFER_CODE!,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(color: Theme.of(context).colorScheme.fontColor),
                        ),
                      )),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.lightWhite,
                          borderRadius:
                              new BorderRadius.all(const Radius.circular(4.0))),
                      child: Text(getTranslated(context, 'TAP_TO_COPY')!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.button!.copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                              ))),
                  onPressed: () {
                    Clipboard.setData(new ClipboardData(text: REFER_CODE));
                    setSnackbar('Refercode Copied to clipboard');
                  },
                ),
                SimBtn(
                  size: 0.8,
                  title: getTranslated(context, "SHARE_APP"),
                  onBtnSelected: () async{
                    await _createDynamicLink(true);
                    var str =
                        "$appName\n\nRefer Code:$REFER_CODE\n\nYou can find our app from below url\n$_linkMessage";
                   await Share.share(str);

                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
}
