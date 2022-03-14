import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eshop/Model/Section_Model.dart';
import 'package:eshop/Provider/CartProvider.dart';
import 'package:eshop/Provider/SettingProvider.dart';
import 'package:eshop/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/PaymentRadio.dart';
import '../Helper/Session.dart';
import '../Helper/SimBtn.dart';
import '../Helper/String.dart';
import '../Helper/Stripe_Service.dart';
import '../Model/Model.dart';
import 'Cart.dart';
import 'Order_Success.dart';

class Payment extends StatefulWidget {
  final Function update;
  final String? msg;

  Payment(this.update, this.msg);

  @override
  State<StatefulWidget> createState() {
    return StatePayment();
  }
}

List<Model> timeSlotList = [];
String? allowDay;
bool codAllowed = true;
String? bankName, bankNo, acName, acNo, exDetails;

class StatePayment extends State<Payment> with TickerProviderStateMixin {
  bool _isLoading = true;
  String? startingDate;

  // StateSetter? checkoutState;
  bool deliverable = false;
  bool  _placeOrder = true;
  bool  isLoading = false;

  List<Model> deliverableList = [];

  TextEditingController noteC = new TextEditingController();

  late bool cod,
      paypal,
      razorpay,
      paumoney,
      paystack,
      flutterwave,
      stripe,
      paytm = true,
      gpay = false,
      bankTransfer = true;
  List<RadioModel> timeModel = [];
  List<RadioModel> payModel = [];
  List<RadioModel> timeModelList = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<String?> paymentMethodList = [];
  List<String> paymentIconList = [
    'assets/images/cod.svg',
    // 'assets/images/paypal.svg',
    // 'assets/images/payu.svg',
    // 'assets/images/rozerpay.svg',
    // 'assets/images/paystack.svg',
    // 'assets/images/flutterwave.svg',
    // 'assets/images/stripe.svg',
    // 'assets/images/paytm.svg',
    // Platform.isIOS ? 'assets/images/applepay.svg' : 'assets/images/gpay.svg',
    // 'assets/images/banktransfer.svg',
  ];

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  // final plugin = PaystackPlugin();

  @override
  void initState() {
    super.initState();
    _getdateTime();
    timeSlotList.length = 0;
    selectedMethod = 0;

    new Future.delayed(Duration.zero, () {
      paymentMethodList = [
        getTranslated(context, 'COD_LBL'),
        // getTranslated(context, 'PAYPAL_LBL'),
        // getTranslated(context, 'PAYUMONEY_LBL'),
        // getTranslated(context, 'RAZORPAY_LBL'),
        // getTranslated(context, 'PAYSTACK_LBL'),
        // getTranslated(context, 'FLUTTERWAVE_LBL'),
        // getTranslated(context, 'STRIPE_LBL'),
        // getTranslated(context, 'PAYTM_LBL'),
        // Platform.isIOS
        //     ? getTranslated(context, 'APPLEPAY')
        //     : getTranslated(context, 'GPAY'),
        // getTranslated(context, 'BANKTRAN'),
      ];
      payMethod = paymentMethodList.first;
    });
    if (widget.msg != '')
      WidgetsBinding.instance!
          .addPostFrameCallback((_) => setSnackbar(widget.msg!));
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
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  _getdateTime();
                } else {
                  await buttonController!.reverse();
                  if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBar(getTranslated(context, 'PAYMENT_METHOD_LBL')!, context),
      body: _isNetworkAvail
          ? _isLoading
          ? getProgress()
          : Stack(
            children: [
              Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Consumer<UserProvider>(
                            builder: (context, userProvider, _) {
                              return Card(
                                elevation: 0,
                                child: userProvider.curBalance != "0" &&
                                    userProvider.curBalance.isNotEmpty &&
                                    userProvider.curBalance != ""
                                    ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: CheckboxListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.all(0),
                                    value: isUseWallet,
                                    onChanged: (bool? value) {
                                      if (mounted)
                                        setState(() {
                                          isUseWallet = value;
                                          if (value!) {
                                            if (totalPrice <=
                                                double.parse(
                                                    userProvider
                                                        .curBalance)) {
                                              remWalBal = (double.parse(
                                                  userProvider
                                                      .curBalance) -
                                                  totalPrice);
                                              usedBal = totalPrice;
                                              payMethod = "Wallet";

                                              isPayLayShow = false;
                                            } else {
                                              remWalBal = 0;
                                              usedBal = double.parse(
                                                  userProvider
                                                      .curBalance);
                                              isPayLayShow = true;
                                            }

                                            totalPrice =
                                                totalPrice - usedBal;
                                          } else {
                                            totalPrice =
                                                totalPrice + usedBal;
                                            remWalBal = double.parse(
                                                userProvider
                                                    .curBalance);
                                            payMethod = null;
                                            selectedMethod = null;
                                            usedBal = 0;
                                            isPayLayShow = true;
                                          }

                                          widget.update();
                                        });
                                    },
                                    title: Text(
                                      getTranslated(
                                          context, 'USE_WALLET')!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!.copyWith(color:  Theme.of(context).colorScheme.fontColor),
                                    ),
                                    subtitle: Padding(
                                      padding:
                                      const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Text(
                                        isUseWallet!
                                            ? getTranslated(context,
                                            'REMAIN_BAL')! +
                                            " : " +
                                            CUR_CURRENCY! +
                                            " " +
                                            remWalBal
                                                .toStringAsFixed(2)
                                            : getTranslated(context,
                                            'TOTAL_BAL')! +
                                            " : " +
                                            CUR_CURRENCY! +
                                            " " +
                                            double.parse(
                                                userProvider
                                                    .curBalance)
                                                .toStringAsFixed(2),
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Theme.of(context).colorScheme.black),
                                      ),
                                    ),
                                  ),
                                )
                                    : Container(),
                              );
                            }),
                        isTimeSlot!
                            ? Card(
                          elevation: 0,
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  getTranslated(
                                      context, 'PREFERED_TIME')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!.copyWith(color:  Theme.of(context).colorScheme.fontColor),
                                ),
                              ),
                              Divider(),
                              Container(
                                height: 90,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection:
                                    Axis.horizontal,
                                    itemCount: int.parse(allowDay!),
                                    itemBuilder: (context, index) {
                                      return dateCell(index);
                                    }),
                              ),
                              Divider(),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics:
                                  NeverScrollableScrollPhysics(),
                                  itemCount: timeModel.length,
                                  itemBuilder: (context, index) {
                                    return timeSlotItem(index);
                                  })
                            ],
                          ),
                        )
                            : Container(),
                        isPayLayShow!
                            ? Card(
                          elevation: 0,
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  getTranslated(
                                      context, 'SELECT_PAYMENT')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!.copyWith(color:  Theme.of(context).colorScheme.fontColor),
                                ),
                              ),
                              Divider(),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics:
                                  NeverScrollableScrollPhysics(),
                                  itemCount:
                                  paymentMethodList.length,
                                  itemBuilder: (context, index) {
                                    if (index == 0 && cod)
                                      return paymentItem(index);
                                    // else if (index == 1 && paypal)
                                    //   return paymentItem(index);
                                    // else if (index == 2 && paumoney)
                                    //   return paymentItem(index);
                                    // else if (index == 3 && razorpay)
                                    //   return paymentItem(index);
                                    // else if (index == 4 && paystack)
                                    //   return paymentItem(index);
                                    // else if (index == 5 &&
                                    //     flutterwave)
                                    //   return paymentItem(index);
                                    // else if (index == 6 && stripe)
                                    //   return paymentItem(index);
                                    // else if (index == 7 && paytm)
                                    //   return paymentItem(index);
                                    // else if (index == 8 && gpay)
                                    //   return paymentItem(index);
                                    // else if (index == 9 &&
                                    //     bankTransfer)
                                    //   return paymentItem(index);
                                    else
                                      return Container();
                                  }),
                            ],
                          ),
                        )
                            : Container()
                      ],
                    ),
                  ),
                ),
                SimBtn(
                  size: 0.8,
                  title: getTranslated(context, 'PLACE_ORDER'),
                  onBtnSelected: () {
                    if (double.parse(
                        MIN_ALLOW_CART_AMT!) >
                        oriPrice) {
                      setSnackbar(
                        getTranslated(context,
                            'MIN_CART_AMT')!,);
                    } else if (!deliverable) {
                      checkDeliverable();
                    } else
                      confirmDialog();
                  },
                ),
              ],
        ),
      ),
              showCircularProgress(context.read<CartProvider>().isProgress, colors.primary)
            ],
          )
          : noInternet(context),
    );
  }

  Widget showCircularProgress(bool _isProgress, Color color) {
    if (_isProgress) {
      return Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(color),
          ));
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Future<void> checkDeliverable() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);

        var parameter = {
          USER_ID: CUR_USERID,
          ADD_ID: selAddress,
        };

        Response response =
        await post(checkCartDelApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        var data = getdata["data"];
        context.read<CartProvider>().setProgress(false);

        if (error) {
          deliverableList = (data as List)
              .map((data) => new Model.checkDeliverable(data))
              .toList();

          // checkoutState!(() {
          deliverable = false;
          _placeOrder = true;
          // });

          setSnackbar(msg!);
        } else {
          deliverableList = (data as List)
              .map((data) => new Model.checkDeliverable(data))
              .toList();

          // checkoutState!(() {
          deliverable = true;
          // });
          confirmDialog();
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  void confirmDialog() {
    showGeneralDialog(
        barrierColor: Theme.of(context).colorScheme.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  contentPadding: const EdgeInsets.all(0),
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                            child: Text(
                              getTranslated(context, 'CONFIRM_ORDER')!,
                              style: Theme.of(this.context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .fontColor),
                            )),
                        Divider(
                            color: Theme.of(context).colorScheme.lightBlack),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, 'SUBTOTAL')!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack2),
                                  ),
                                  Text(
                                    CUR_CURRENCY! +
                                        " " +
                                        oriPrice.toStringAsFixed(2),
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, 'DELIVERY_CHARGE')!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack2),
                                  ),
                                  Text(
                                    CUR_CURRENCY! +
                                        " " +
                                        delCharge.toStringAsFixed(2),
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              isPromoValid!
                                  ? Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(
                                        context, 'PROMO_CODE_DIS_LBL')!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack2),
                                  ),
                                  Text(
                                    CUR_CURRENCY! +
                                        " " +
                                        promoAmt.toStringAsFixed(2),
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )
                                  : Container(),
                              isUseWallet!
                                  ? Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, 'WALLET_BAL')!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack2),
                                  ),
                                  Text(
                                    CUR_CURRENCY! +
                                        " " +
                                        usedBal.toStringAsFixed(2),
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )
                                  : Container(),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      getTranslated(context, 'TOTAL_PRICE')!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .lightBlack2),
                                    ),
                                    Text(
                                      CUR_CURRENCY! +
                                          " ${totalPrice.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .fontColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  /* decoration: BoxDecoration(
                                    color: colors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),*/
                                  child: TextField(
                                    controller: noteC,
                                    style:
                                    Theme.of(context).textTheme.subtitle2,
                                    decoration: InputDecoration(
                                      contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor:
                                      colors.primary.withOpacity(0.1),
                                      //isDense: true,
                                      hintText: getTranslated(context, 'NOTE'),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ]),
                  actions: <Widget>[
                    new TextButton(
                        child: Text(getTranslated(context, 'CANCEL')!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.lightBlack,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          // checkoutState!(() {
                          _placeOrder = true;
                          // });
                          Navigator.pop(context);
                        }),
                    new TextButton(
                        child: Text(getTranslated(context, 'DONE')!,
                            style: TextStyle(
                                color: colors.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(context);

                          placeOrder('');///Only COD available now
                          // doPayment();
                        })
                  ],
                )),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }

  Future<void> addTransaction(String? tranId, String orderID, String? status,
      String? msg, bool redirect) async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        ORDER_ID: orderID,
        TYPE: payMethod,
        TXNID: tranId,
        AMOUNT: totalPrice.toString(),
        STATUS: status,
        MSG: msg
      };
      Response response =
      await post(addTransactionApi, body: parameter, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String? msg1 = getdata["message"];
      if (!error) {
        if (redirect) {
          // CUR_CART_COUNT = "0";

          context.read<UserProvider>().setCartCount("0");
          clearAll();

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => OrderSuccess()),
              ModalRoute.withName('/home'));
        }
      } else {
        setSnackbar(msg1!);
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!);
    }
  }

  Future<void> placeOrder(String? tranId) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      context.read<CartProvider>().setProgress(true);

      SettingProvider settingsProvider =
      Provider.of<SettingProvider>(this.context, listen: false);

      String? mob = settingsProvider.mobile;

      String? varientId, quantity;

      List<SectionModel> cartList = context.read<CartProvider>().cartList;
      for (SectionModel sec in cartList) {
        varientId = varientId != null
            ? varientId + "," + sec.varientId!
            : sec.varientId;
        quantity = quantity != null ? quantity + "," + sec.qty! : sec.qty;
      }
      String payVia = "COD";
      // if (payMethod == getTranslated(context, 'COD_LBL'))
      //   payVia = "COD";
      // else if (payMethod == getTranslated(context, 'PAYPAL_LBL'))
      //   payVia = "PayPal";
      // else if (payMethod == getTranslated(context, 'PAYUMONEY_LBL'))
      //   payVia = "PayUMoney";
      // else if (payMethod == getTranslated(context, 'RAZORPAY_LBL'))
      //   payVia = "RazorPay";
      // else if (payMethod == getTranslated(context, 'PAYSTACK_LBL'))
      //   payVia = "Paystack";
      // else if (payMethod == getTranslated(context, 'FLUTTERWAVE_LBL'))
      //   payVia = "Flutterwave";
      // else
      if (payMethod == getTranslated(context, 'STRIPE_LBL'))
        payVia = "Stripe";
      else{
        payVia = "COD";
      }
      // else if (payMethod == getTranslated(context, 'PAYTM_LBL'))
      //   payVia = "Paytm";
      // else if (payMethod == "Wallet")
      //   payVia = "Wallet";
      // else if (payMethod == getTranslated(context, 'BANKTRAN'))
      //   payVia = "bank_transfer";
      try {
        var parameter = {
          USER_ID: CUR_USERID,
          MOBILE: mob,
          PRODUCT_VARIENT_ID: varientId,
          QUANTITY: quantity,
          TOTAL: oriPrice.toString(),
          FINAL_TOTAL: totalPrice.toString(),
          DEL_CHARGE: delCharge.toString(),
          // TAX_AMT: taxAmt.toString(),
          TAX_PER: taxPer.toString(),

          PAYMENT_METHOD: payVia,
          ADD_ID: selAddress,
          ISWALLETBALUSED: isUseWallet! ? "1" : "0",
          WALLET_BAL_USED: usedBal.toString(),
          ORDER_NOTE: noteC.text
        };

        if (isTimeSlot!) {
          parameter[DELIVERY_TIME] = selTime ?? 'Anytime';
          parameter[DELIVERY_DATE] = selDate ?? '';
        }
        if (isPromoValid!) {
          parameter[PROMOCODE] = promocode;
          parameter[PROMO_DIS] = promoAmt.toString();
        }

        if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
          parameter[ACTIVE_STATUS] = WAITING;
        } else if (payMethod == getTranslated(context, 'STRIPE_LBL')) {
          if (tranId == "succeeded")
            parameter[ACTIVE_STATUS] = PLACED;
          else
            parameter[ACTIVE_STATUS] = WAITING;
        } else if (payMethod == getTranslated(context, 'BANKTRAN')) {
          parameter[ACTIVE_STATUS] = WAITING;
        }

        Response response =
        await post(placeOrderApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));
        _placeOrder = true;
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            String orderId = getdata["order_id"].toString();
            if (payMethod == getTranslated(context, 'RAZORPAY_LBL')) {
              addTransaction(tranId, orderId, SUCCESS, msg, true);
            } else if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
              // paypalPayment(orderId);
            } else if (payMethod == getTranslated(context, 'STRIPE_LBL')) {
              addTransaction(stripePayId, orderId,
                  tranId == "succeeded" ? PLACED : WAITING, msg, true);
            } else if (payMethod == getTranslated(context, 'PAYSTACK_LBL')) {
              addTransaction(tranId, orderId, SUCCESS, msg, true);
            } else if (payMethod == getTranslated(context, 'PAYTM_LBL')) {
              addTransaction(tranId, orderId, SUCCESS, msg, true);
            } else {
              context.read<UserProvider>().setCartCount("0");

              clearAll();

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => OrderSuccess()),
                  ModalRoute.withName('/home'));
            }
          } else {
            setSnackbar(msg!);
            context.read<CartProvider>().setProgress(false);
          }
        }
      } on TimeoutException catch (_) {
        if (mounted)
          // checkoutState!(() {
          _placeOrder = true;
        // });
        context.read<CartProvider>().setProgress(false);
      }
    } else {
      if (mounted)
        // checkoutState!(() {
        _isNetworkAvail = false;
      // });
    }
  }

  clearAll() {
    totalPrice = 0;
    oriPrice = 0;

    taxPer = 0;
    delCharge = 0;
    addressList.clear();
    // cartList.clear();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      context.read<CartProvider>().setCartlist([]);
      context.read<CartProvider>().setProgress(false);
    });

    promoAmt = 0;
    remWalBal = 0;
    usedBal = 0;
    payMethod = '';
    isPromoValid = false;
    isUseWallet = false;
    isPayLayShow = true;
    selectedMethod = null;
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

  dateCell(int index) {
    DateTime today = DateTime.parse(startingDate!);
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selectedDate == index ? colors.primary : null),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('EEE').format(today.add(Duration(days: index))),
              style: TextStyle(
                  color: selectedDate == index
                      ? Theme.of(context).colorScheme.lightBlack
                      : Theme.of(context).colorScheme.lightBlack2),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                DateFormat('dd').format(today.add(Duration(days: index))),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selectedDate == index
                        ? Theme.of(context).colorScheme.lightBlack
                        : Theme.of(context).colorScheme.lightBlack2),
              ),
            ),
            Text(
              DateFormat('MMM').format(today.add(Duration(days: index))),
              style: TextStyle(
                  color: selectedDate == index
                      ? Theme.of(context).colorScheme.lightBlack
                      : Theme.of(context).colorScheme.lightBlack2),
            ),
          ],
        ),
      ),
      onTap: () {
        DateTime date = today.add(Duration(days: index));

        if (mounted) selectedDate = index;
        selectedTime = null;
        selTime = null;
        selDate = DateFormat('yyyy-MM-dd').format(date);
        timeModel.clear();
        DateTime cur = DateTime.now();
        DateTime tdDate = DateTime(cur.year, cur.month, cur.day);
        if (date == tdDate) {
          if (timeSlotList.length > 0) {
            for (int i = 0; i < timeSlotList.length; i++) {
              DateTime cur = DateTime.now();
              String time = timeSlotList[i].lastTime!;
              DateTime last = DateTime(
                  cur.year,
                  cur.month,
                  cur.day,
                  int.parse(time.split(':')[0]),
                  int.parse(time.split(':')[1]),
                  int.parse(time.split(':')[2]));

              if (cur.isBefore(last)) {
                timeModel.add(new RadioModel(
                    isSelected: i == selectedTime ? true : false,
                    name: timeSlotList[i].name,
                    img: ''));
              }
            }
          }
        } else {
          if (timeSlotList.length > 0) {
            for (int i = 0; i < timeSlotList.length; i++) {
              timeModel.add(new RadioModel(
                  isSelected: i == selectedTime ? true : false,
                  name: timeSlotList[i].name,
                  img: ''));
            }
          }
        }
        setState(() {});
      },
    );
  }

  Future<void> _getdateTime() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      timeSlotList.clear();
      try {
        var parameter = {TYPE: PAYMENT_METHOD, USER_ID: CUR_USERID};
        Response response =
        await post(getSettingApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          // String msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];
            var time_slot = data["time_slot_config"];
            allowDay = time_slot["allowed_days"];
            isTimeSlot =
            time_slot["is_time_slots_enabled"] == "1" ? true : false;
            startingDate = time_slot["starting_date"];
            codAllowed = data["is_cod_allowed"] == 1 ? true : false;

            var timeSlots = data["time_slots"];
            timeSlotList = (timeSlots as List)
                .map((timeSlots) => new Model.fromTimeSlot(timeSlots))
                .toList();

            if (timeSlotList.length > 0) {
              for (int i = 0; i < timeSlotList.length; i++) {
                if (selectedDate != null) {
                  DateTime today = DateTime.parse(startingDate!);

                  DateTime date = today.add(Duration(days: selectedDate!));

                  DateTime cur = DateTime.now();
                  DateTime tdDate = DateTime(cur.year, cur.month, cur.day);

                  if (date == tdDate) {
                    DateTime cur = DateTime.now();
                    String time = timeSlotList[i].lastTime!;
                    DateTime last = DateTime(
                        cur.year,
                        cur.month,
                        cur.day,
                        int.parse(time.split(':')[0]),
                        int.parse(time.split(':')[1]),
                        int.parse(time.split(':')[2]));

                    if (cur.isBefore(last)) {
                      timeModel.add(new RadioModel(
                          isSelected: i == selectedTime ? true : false,
                          name: timeSlotList[i].name,
                          img: ''));
                    }
                  } else {
                    timeModel.add(new RadioModel(
                        isSelected: i == selectedTime ? true : false,
                        name: timeSlotList[i].name,
                        img: ''));
                  }
                } else {
                  timeModel.add(new RadioModel(
                      isSelected: i == selectedTime ? true : false,
                      name: timeSlotList[i].name,
                      img: ''));
                }
              }
            }

            var payment = data["payment_method"];

            cod = codAllowed
                ? payment["cod_method"] == "1"
                ? true
                : false
                : false;
            paypal = payment["paypal_payment_method"] == "1" ? true : false;
            paumoney =
            payment["payumoney_payment_method"] == "1" ? true : false;
            flutterwave =
            payment["flutterwave_payment_method"] == "1" ? true : false;
            razorpay = payment["razorpay_payment_method"] == "1" ? true : false;
            paystack = payment["paystack_payment_method"] == "1" ? true : false;
            stripe = payment["stripe_payment_method"] == "1" ? true : false;
            paytm = payment["paytm_payment_method"] == "1" ? true : false;
            bankTransfer =
            payment["direct_bank_transfer"] == "1" ? true : false;

            // if (razorpay) razorpayId = payment["razorpay_key_id"];
            // if (paystack) {
            // paystackId = payment["paystack_key_id"];

            // plugin.initialize(publicKey: paystackId!);
            // }
            // if (stripe) {
            //   stripeId = payment['stripe_publishable_key'];
            //   stripeSecret = payment['stripe_secret_key'];
            //   stripeCurCode = payment['stripe_currency_code'];
            //   stripeMode = payment['stripe_mode'] ?? 'test';
            // StripeService.secret = stripeSecret;
            // StripeService.init(stripeId, stripeMode);
            // }
            // if (paytm) {
            //   paytmMerId = payment['paytm_merchant_id'];
            //   paytmMerKey = payment['paytm_merchant_key'];
            //   payTesting =
            //       payment['paytm_payment_mode'] == 'sandbox' ? true : false;
            // }

            if (bankTransfer) {
              bankName = payment['bank_name'];
              bankNo = payment['bank_code'];
              acName = payment['account_name'];
              acNo = payment['account_number'];
              exDetails = payment['notes'];
            }

            for (int i = 0; i < paymentMethodList.length; i++) {
              payModel.add(RadioModel(
                  isSelected: i == selectedMethod ? true : false,
                  name: paymentMethodList[i],
                  img: paymentIconList[i]));
            }
          } else {
            // setSnackbar(msg);
          }
        }
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      } on TimeoutException catch (_) {
        //setSnackbar( getTranslated(context,'somethingMSg'));
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  Widget timeSlotItem(int index) {
    return new InkWell(
      onTap: () {
        if (mounted)
          setState(() {
            selectedTime = index;
            selTime = timeModel[selectedTime!].name;
            //timeSlotList[selectedTime].name;
            timeModel.forEach((element) => element.isSelected = false);
            timeModel[index].isSelected = true;
          });
      },
      child: new RadioItem(timeModel[index]),
    );
  }

  Widget paymentItem(int index) {
    return new InkWell(
      onTap: () {
        if (mounted)
          setState(() {
            selectedMethod = index;
            payMethod = paymentMethodList[selectedMethod!];

            payModel.forEach((element) => element.isSelected = false);
            payModel[index].isSelected = true;
          });
      },
      child: new RadioItem(payModel[index]),
    );
  }
}
