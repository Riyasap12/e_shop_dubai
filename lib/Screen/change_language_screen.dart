import 'package:eshop/Helper/AppBtn.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Helper/cropped_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../main.dart';
import 'Intro_Slider.dart';

class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({Key? key}) : super(key: key);

  @override
  State<ChangeLanguage> createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage>  with TickerProviderStateMixin {
  AnimationController? buttonController;
  Animation? buttonSqueezeanimation;

  @override
  void initState() {
    super.initState();
    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(new CurvedAnimation(
      parent: buttonController!,
      curve: new Interval(
        0.0,
        0.150,
      ),
    ));
    _changeLan('ar', context);
  }
  void _changeLan(String language, BuildContext ctx) async {
    Locale _locale = await setLocale(language);

    MyApp.setLocale(ctx, _locale);
  }
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Theme.of(context).colorScheme.white,
      body: Container(
        decoration: back(),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/doodle.png',
              fit: BoxFit.fill,
              width: double.infinity,
              height: double.infinity,
            ),

            Center(
              child: ClipPath(
                clipper: ContainerClipper(),
                child: Container(
                  alignment: Alignment.center,
                  color: Theme.of(context).colorScheme.white,
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom * 0.8),
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.95,

                  child: Padding(
                      padding: const EdgeInsets.only(left: 15,right: 15,top: 90,bottom: 25),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text("Choose Language",
                              style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                  color: colors.grad1Color, fontWeight: FontWeight.bold,fontSize: 25)),
                        ),
                       SizedBox(height: 20,),
                       InkWell(
                         onTap: (){
                           _changeLan('ar', context);
                           setState(() {
                             selectedIndex =0;
                           });
                         },
                         child: Container(
                         padding: EdgeInsets.symmetric(horizontal: 24,vertical: 10),
                         decoration: BoxDecoration(color: colors.grad1Color,borderRadius: BorderRadius.circular(16)),
                         child: Row(
                           children: [
                             Container(
                               height: 25.0,
                               decoration: BoxDecoration(
                                   shape: BoxShape.circle,
                                   color: selectedIndex == 0
                                       ? Colors.green
                                       : Theme.of(context).colorScheme.white,
                                   border: Border.all(color: colors.grad1Color)),
                               child: Padding(
                                 padding: const EdgeInsets.all(2.0),
                                 child: selectedIndex == 0
                                     ? Icon(
                                   Icons.check,
                                   size: 17.0,
                                   color: Theme.of(context).colorScheme.gray,
                                 )
                                     : Icon(
                                   Icons.check_box_outline_blank,
                                   size: 15.0,
                                   color: Theme.of(context).colorScheme.white,
                                 ),
                               ),
                             ),
                             SizedBox(width: 16,),
                             Text("Arabic",style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                 color: colors.red, fontWeight: FontWeight.bold,fontSize: 20)),
                           ],
                         ),
                         ),
                       ),
                        SizedBox(height: 20,),
                        InkWell(
                          onTap: (){
                            _changeLan('en', context);
                            setState(() {
                              selectedIndex =1;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 24,vertical: 10),
                            decoration: BoxDecoration(color: colors.grad1Color,borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              children: [
                                Container(
                                  height: 25.0,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: selectedIndex == 1
                                          ? Colors.green
                                          : Theme.of(context).colorScheme.white,
                                      border: Border.all(color: colors.grad1Color)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: selectedIndex == 1
                                        ? Icon(
                                      Icons.check,
                                      size: 17.0,
                                      color: Theme.of(context).colorScheme.gray,
                                    )
                                        : Icon(
                                      Icons.check_box_outline_blank,
                                      size: 15.0,
                                      color: Theme.of(context).colorScheme.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16,),
                                Text("English",style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                    color: colors.red, fontWeight: FontWeight.bold,fontSize: 20)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),
                        AppBtn(
                          title: "Next",
                          btnAnim: buttonSqueezeanimation,
                          btnCntrl: buttonController,
                          onBtnSelected: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IntroSlider(),
                                ));
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              // textDirection: Directionality.of(context),
              left: (MediaQuery.of(context).size.width / 2) - 49,
              // right: ((MediaQuery.of(context).size.width /2)-55),

              top: (MediaQuery.of(context).size.height * 0.2-15
              ),
              //  bottom: height * 0.1,
              child: SizedBox(
                width: 100,
                height: 100,
                child: SvgPicture.asset(
                  'assets/images/loginlogo.svg',
                  // color: Colors.blue,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
