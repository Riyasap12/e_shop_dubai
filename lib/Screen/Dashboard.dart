import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/PushNotificationService.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Provider/UserProvider.dart';
import 'package:eshop/Screen/Favorite.dart';
import 'package:eshop/Screen/Login.dart';
import 'package:eshop/Screen/MyProfile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'All_Category.dart';
import 'Cart.dart';
import 'HomePage.dart';
import 'NotificationLIst.dart';
import 'Sale.dart';
import 'Search.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Dashboard> with TickerProviderStateMixin {
  int _selBottom = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final pushNotificationService = PushNotificationService(context: context);
    pushNotificationService.initialise();
    _tabController = TabController(
      length: 5,
      vsync: this,
    );
    _tabController.addListener(() {
      Future.delayed(Duration(seconds: 0)).then((value) {
        if (_tabController.index == 3) {
          if (CUR_USERID == null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Login(),
                ));
            _tabController.animateTo(0);
          }
        }
      });

      setState(() {
        _selBottom = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_tabController.index != 0) {
          _tabController.animateTo(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.lightWhite,
          appBar: _getAppBar(),
          body: TabBarView(
            controller: _tabController,
            children: [
              HomePage(),
              AllCategory(),
              Sale(),
              Cart(
                fromBottom: true,
              ),
              MyProfile()
            ],
          ),
          //fragments[_selBottom],
          bottomNavigationBar: _getBottomBar()),
    );
  }

  AppBar _getAppBar() {
    String? title;
    if (_selBottom == 1)
      title = getTranslated(context, 'CATEGORY');
    else if (_selBottom == 2)
      title = getTranslated(context, 'OFFER');
    else if (_selBottom == 3)
      title = getTranslated(context, 'MYBAG');
    else if (_selBottom == 4) title = getTranslated(context, 'PROFILE');

    return AppBar(
      centerTitle: _selBottom == 0 ? true : false,
      title: _selBottom == 0
          ? SvgPicture.asset('assets/images/titleicon.svg')
          : Text(
              title!,
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.normal
              ),
            ),

      leading: _selBottom == 0
          ? InkWell(
              child: Center(
                  child: SvgPicture.asset(
                imagePath + "search.svg",
                height: 20,
              )),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Search(),
                    ));
              },
            )
          : null,
      // iconTheme: new IconThemeData(color: colors.primary),
      // centerTitle:_curSelected == 0? false:true,
      actions: <Widget>[
        _selBottom == 0
            ? Container()
            : IconButton(
                icon: SvgPicture.asset(
                  imagePath + "search.svg",
                  height: 20,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Search(),
                      ));
                }),
        IconButton(
          icon: SvgPicture.asset(imagePath + "desel_notification.svg"),
          onPressed: () {
            CUR_USERID != null
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationList(),
                    ))
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(),
                    ));
          },
        ),
        IconButton(
          padding: EdgeInsets.all(0),
          icon: SvgPicture.asset(imagePath + "desel_fav.svg"),
          onPressed: () {
            CUR_USERID != null
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Favorite(),
                    ))
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(),
                    ));
          },
        ),

      ],
      backgroundColor: Theme.of(context).colorScheme.white,
    );
  }

  Widget _getBottomBar() {
    return Material(
        color: Theme.of(context).colorScheme.white,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.white,
            boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.black26, blurRadius: 10)],
          ),
          child: TabBar(
            onTap: (_) {
              if (_tabController.index == 3) {
                if (CUR_USERID == null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ));
                  _tabController.animateTo(0);
                }
              }
            },
            controller: _tabController,
            tabs: [
              Tab(
                icon: _selBottom == 0
                    ? SvgPicture.asset(imagePath + "sel_home.svg")
                    : SvgPicture.asset(imagePath + "desel_home.svg"),
                text:
                    _selBottom == 0 ? getTranslated(context, 'HOME_LBL') : null,
              ),
              Tab(
                icon: _selBottom == 1
                    ? SvgPicture.asset(imagePath + "category01.svg")
                    : SvgPicture.asset(imagePath + "category.svg"),
                text:
                    _selBottom == 1 ? getTranslated(context, 'category') : null,
              ),
              Tab(
                icon: _selBottom == 2
                    ? SvgPicture.asset(imagePath + "sale02.svg")
                    : SvgPicture.asset(imagePath + "sale.svg"),
                text: _selBottom == 2 ? getTranslated(context, 'SALE') : null,
              ),
              Tab(
                icon: Selector<UserProvider, String>(
                  builder: (context, data, child) {

                    return Stack(
                      children: [
                        Center(
                          child: _selBottom == 3
                              ? SvgPicture.asset(imagePath + "cart01.svg")
                              : SvgPicture.asset(imagePath + "cart.svg"),
                        ),
                        (data != null && data.isNotEmpty && data != "0")
                            ? new Positioned.directional(
                                bottom: _selBottom == 3 ? 6 : 20,
                                textDirection: Directionality.of(context),
                                end: 0,
                                child: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: colors.primary),
                                    child: new Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(3),
                                        child: new Text(
                                          data,
                                          style: TextStyle(
                                              fontSize: 7,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.white),
                                        ),
                                      ),
                                    )),
                              )
                            : Container()
                      ],
                    );
                  },
                  selector: (_, homeProvider) => homeProvider.curCartCount,
                ),


                text: _selBottom == 3 ? getTranslated(context, 'CART') : null,
              ),
              Tab(
                icon: _selBottom == 4
                    ? SvgPicture.asset(imagePath + "profile01.svg")
                    : SvgPicture.asset(imagePath + "profile.svg"),
                text:
                    _selBottom == 4 ? getTranslated(context, 'ACCOUNT') : null,
              ),
            ],
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: colors.primary, width: 5.0),
              insets: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 70.0),
            ),
            labelColor: colors.primary,
          ),
        ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
