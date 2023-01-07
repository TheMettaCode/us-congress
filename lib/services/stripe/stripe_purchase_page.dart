import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:congress_watcher/constants/animated_widgets.dart';
import 'package:congress_watcher/constants/constants.dart';
import 'package:congress_watcher/models/order_detail.dart';
import 'package:congress_watcher/services/stripe/stripe_models/product.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../../app_user/user_profile.dart';
import '../../functions/functions.dart';

class StripePurchasePage extends StatefulWidget {
  const StripePurchasePage(
      {Key key,
      this.thisStripeUser,
      this.thisStripeProduct,
      this.thisStripePaymentLink})
      : super(key: key);
  final UserProfile thisStripeUser;
  final StripeProduct thisStripeProduct;
  final String thisStripePaymentLink;

  @override
  StripePurchasePageState createState() => StripePurchasePageState();
}

class StripePurchasePageState extends State<StripePurchasePage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (Platform.isAndroid) {}
        await setInitialValues();
      },
    );
    super.initState();
  }

  // @override
  // void dispose() {}

  Future<void> setInitialValues() async {
    setState(() => _loading = true);

    /// USER INFORMATION

    // UserProfile thisUser = await AppUser.getUserProfile();
    // UserProfile user;
    // try {
    //   thisUser = userProfileFromJson(userDatabase.get('userProfile'));
    //   debugPrint(
    //       '[STRIPE PURCHASE PAGE SET INIT VALUES] USER PROFILE RETRIEVED FROM DBASE: ${thisUser.userId}');
    // } catch (e) {
    //   debugPrint(
    //       '[STRIPE PURCHASE PAGE SET INIT VALUES] ERROR RETRIEVING USER PROFILE FROM DBASE');
    // }

    PlatformWebViewControllerCreationParams params =
        const PlatformWebViewControllerCreationParams();
    WebViewController wvController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xffffffff))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            Navigator.pop(context);
            Messages.showMessage(
                context: context,
                message: 'Could not launch link',
                isAlert: true);
          },
          onNavigationRequest: (NavigationRequest request) {
            // if (request.url.startsWith('https://www.youtube.com/')) {
            //   return NavigationDecision.prevent;
            // }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.thisStripePaymentLink));

    if (wvController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (wvController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    try {
      productOrdersList =
          orderDetailListFromJson(userDatabase.get('ecwidProductOrdersList'))
              .orders;
    } catch (e) {
      productOrdersList = [];
      logger.w(
          '[STRIPE PURCHASE PAGE SET INIT VALUES] ERROR RETRIEVING PAST PRODUCT ORDERS DATA FROM DBASE: $e');
    }

    setState(() {
      stripeTestMode = userDatabase.get('stripeTestMode');
      thisStripeUser = widget.thisStripeUser;
      thisStripeProduct = widget.thisStripeProduct;
      thisStripePaymentLink = widget.thisStripePaymentLink;
      pageTitle = widget.thisStripeProduct.name;
      webViewController = wvController;
      webViewParams = params;
      _loading = false;
    });
  }

  Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
  bool _loading = false;
  bool stripeTestMode = false;

  WebViewController webViewController;
  // AndroidWebViewControllerCreationParams webViewParams;
  PlatformWebViewControllerCreationParams webViewParams;

  StripeProduct thisStripeProduct;
  String thisStripePaymentLink;
  String pageTitle = '';
  UserProfile thisStripeUser;

  int backgroundFetches = 0;
  List<Order> productOrdersList = [];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box(appDatabase).listenable(keys: [
          'stripeCustomer',
          'stripeTestCustomer',
          'stripeTestMode',
          'backgroundFetches'
        ]),
        builder: (context, box, widget) {
          stripeTestMode = userDatabase.get('stripeTestMode');
          backgroundFetches = userDatabase.get('backgroundFetches');

          return _loading
              ? AnimatedWidgets.circularProgressWatchtower(
                  context, userDatabase,
                  isFullScreen: true)
              : SafeArea(
                  child: Scaffold(
                  appBar: AppBar(
                    title: Text(pageTitle),
                  ),
                  body: _loading
                      ? AnimatedWidgets.circularProgressWatchtower(
                          context, userDatabase,
                          isFullScreen: true)
                      : WebViewWidget(
                          // initialUrl: thisStripePaymentLink,
                          // javascriptMode: JavascriptMode.unrestricted,
                          // onWebResourceError: (WebResourceError webResourceError) {
                          //   Navigator.pop(context);
                          //   Messages.showMessage(
                          //       context: context, message: 'Could not launch link', isAlert: true);
                          // },
                          controller: webViewController,
                          // params: webViewParams,
                        ),
                  // bottomSheet: ,
                  // bottomNavigationBar: Container(
                  //     height: 50,
                  //     color: Colors.green,
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Text('Bottom Navigation Bar',
                  //             style: Styles.googleStyle.copyWith(color: darkThemeTextColor)),
                  //       ],
                  //     )),
                ));
        });
  }
}
