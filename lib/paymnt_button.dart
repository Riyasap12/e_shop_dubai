// import 'Helper/Session.dart';
// import 'Helper/String.dart';
// import 'Screen/Cart.dart';
//
// Widget simButton(){
//   return SimBtn(
//       size: 0.4,
//       title: getTranslated(
//           context, 'PLACE_ORDER'),
//       onBtnSelected: _placeOrder
//           ? () {
//         checkoutState!(() {
//           _placeOrder = false;
//         });
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (BuildContext context) =>
//                     ManageAddress(
//                       home: false,
//                     )));
//
//         if (selAddress == null ||
//             selAddress!.isEmpty) {
//           msg = getTranslated(
//               context,
//               'addressWarning');
//           Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (BuildContext
//                 context) =>
//                     ManageAddress(
//                       home: false,
//                     ),
//               ));
//           checkoutState!(() {
//             _placeOrder = true;
//           });
//         } else if (payMethod ==
//             null ||
//             payMethod!.isEmpty) {
//           msg = getTranslated(
//               context,
//               'payWarning');
//           Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (BuildContext
//                   context) =>
//                       Payment(
//                           updateCheckout,
//                           msg)));
//           checkoutState!(() {
//             _placeOrder = true;
//           });
//         } else if (isTimeSlot! &&
//             int.parse(allowDay!) >
//                 0 &&
//             (selDate == null ||
//                 selDate!.isEmpty)) {
//           msg = getTranslated(
//               context,
//               'dateWarning');
//           Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (BuildContext
//                   context) =>
//                       Payment(
//                           updateCheckout,
//                           msg)));
//           checkoutState!(() {
//             _placeOrder = true;
//           });
//         } else if (isTimeSlot! &&
//             timeSlotList.length >
//                 0 &&
//             (selTime == null ||
//                 selTime!.isEmpty)) {
//           msg = getTranslated(
//               context,
//               'timeWarning');
//           Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (BuildContext
//                   context) =>
//                       Payment(
//                           updateCheckout,
//                           msg)));
//           checkoutState!(() {
//             _placeOrder = true;
//           });
//         } else if (double.parse(
//             MIN_ALLOW_CART_AMT!) >
//             oriPrice) {
//           setSnackbar(
//               getTranslated(context,
//                   'MIN_CART_AMT')!,
//               _checkscaffoldKey);
//         } else if (!deliverable) {
//           checkDeliverable();
//         } else
//           confirmDialog();
//       }
//           : null);
// }