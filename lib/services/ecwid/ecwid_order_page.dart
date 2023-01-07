import 'package:animate_do/animate_do.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:congress_watcher/constants/animated_widgets.dart';
import 'package:congress_watcher/constants/constants.dart';
import 'package:congress_watcher/constants/styles.dart';
import 'package:congress_watcher/constants/themes.dart';
import 'package:congress_watcher/functions/functions.dart';
import 'package:congress_watcher/models/order_detail.dart';
import 'package:congress_watcher/services/ecwid/ecwid_store_model.dart';
import 'package:congress_watcher/services/emailjs/emailjs_api.dart';

import '../../app_user/user_profile.dart';

class EcwidOrderPage extends StatefulWidget {
  const EcwidOrderPage(
      {Key key, this.title, this.productId, this.product, this.creditsToBuy})
      : super(key: key);
  final String title;
  final EcwidStoreItem product;
  final int productId;
  final int creditsToBuy;

  @override
  EcwidOrderPageState createState() => EcwidOrderPageState();
}

class EcwidOrderPageState extends State<EcwidOrderPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await init();
      },
    );
    super.initState();
  }

  // @override
  // void dispose() {}

  Future<void> init() async {
    setState(() => _loading = true);
    await setInitialVariables();
    setState(() => _loading = false);
  }

  Future<void> setInitialVariables() async {
    await Functions.getUserLevels().then(((status) => setState(() {
          userIs = status;
          userIsDev = status[0];
          userIsPremium = status[1];
          userIsLegacy = status[2];
        })));

    List<Option> allOptions = widget.product.options;

    if (allOptions.isNotEmpty) await buildDropDownOptionsList(allOptions);

    /// ECWID STORE PRODUCTS LIST
    try {
      setState(() => ecwidStoreItems =
          ecwidStoreFromJson(userDatabase.get('ecwidProducts')).items);
    } catch (e) {
      logger.w(
          '^^^^^ ERROR RETRIEVING ECWID STORE ITEMS DATA FROM DBASE (ECWID_STORE_API): $e ^^^^^');
    }

    /// PRODUCT ORDERS LIST
    try {
      setState(() => productOrdersList =
          orderDetailListFromJson(userDatabase.get('ecwidProductOrdersList'))
              .orders);
    } catch (e) {
      logger.w(
          '^^^^^ ERROR RETRIEVING PAST PRODUCT ORDERS DATA FROM DBASE (ECWID_STORE_API): $e ^^^^^');
    }

    /// ECWID PRODUCT INFORMATION
    setState(() {
      pageTitle = widget.title;
      product = widget.product;
      productId = widget.productId;
      creditsToBuy = widget.creditsToBuy;
      darkTheme = userDatabase.get('darkTheme');
      credits = userDatabase.get('credits');
      permCredits = userDatabase.get('permCredits');
      purchCredits = userDatabase.get('purchCredits');
      totalCredits = credits + permCredits;
      newEcwidProducts = userDatabase.get('newEcwidProducts');

      initialUserId = List<String>.from(userDatabase.get('userIdList'))
          .firstWhere((element) =>
              element.split('<|:|>')[0].toLowerCase() == 'newuser');
      lastUserId = List<String>.from(userDatabase.get('userIdList')).last;
      orderId = 'EPO${random.nextInt(999999)}';
      orderIdExtended =
          'EPO${random.nextInt(999999)}-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}-${initialUserId.split('<|:|>')[1]}';
      currentUserAddress =
          UserAddress.fromJson(userDatabase.get('currentLocation'));
    });
  }

  Future<void> buildDropDownOptionsList(
    List<Option> listOfOptions,
  ) async {
    /// BUILD LIST OF DROPDOWN BUTTONS
    for (int i = 0; i < listOfOptions.length; i++) {
      Option thisOption = listOfOptions[i];
      String option = thisOption.name;
      optionChoiceList.add(OptionChoice(listOfOptions[i].name, ''));
      dropdownButtonList.add(DropdownButtonFormField<String>(
        isExpanded: true,
        value: optionChoiceList[i].choice,
        hint: Text('${optionChoiceList[i].option.toUpperCase()} *'),
        validator: (value) =>
            value == null || value.isEmpty ? '$option is required' : null,
        decoration: InputDecoration(
            errorStyle: TextStyle(color: darkTheme ? altHighlightColor : null)),
        items: thisOption.choices
            .map((e) => e.text)
            .toList()
            .map<DropdownMenuItem<String>>(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: (String choice) {
          if (choice != null) {
            List<OptionChoice> list = optionChoiceList;
            debugPrint(
                'CURRENT OPTION-CHOICE LIST: ${list.map((e) => e.toString())}');
            list.removeAt(i);
            list.insert(i, OptionChoice(option, choice));
            setState(() => optionChoiceList = list);
            debugPrint(
                'UPDATED OPTION-CHOICE LIST: ${optionChoiceList.map((e) => e.toString())}');
          }
        },
      ));
    }
    debugPrint(
        'FINAL OPTION-CHOICE LIST: ${optionChoiceList.map((e) => e.toString())}');
  }

  static final _ecwidFormKey = GlobalKey<FormState>();

  Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
  String pageTitle = '';
  bool darkTheme = false;
  String backgroundImage = 'assets/congress_pic_${random.nextInt(4)}.png';
  bool _loading = false;
  List<bool> userIs = [false, false, false];
  bool userIsDev = false;
  bool userIsPremium = false;
  bool userIsLegacy = false;

  String initialUserId = '';
  String lastUserId = '';
  UserAddress currentUserAddress;
  int credits = 0;
  int permCredits = 0;
  int purchCredits = 0;
  int totalCredits = 0;

  int productId = 0;
  EcwidStoreItem product;
  // List<Option> allOptions = [];
  List<OptionChoice> optionChoiceList = [];
  List<DropdownButtonFormField<String>> dropdownButtonList = [];
  int creditsToBuy = 0;
  bool canBuy = false;

  bool newEcwidProducts = false;
  List<EcwidStoreItem> ecwidStoreItems = [];
  List<Order> productOrdersList = [];

  String orderId = '';
  String orderIdExtended = '';
  final String orderDate =
      dateWithTimeAndSecondsFormatter.format(DateTime.now());

  String _email = '';
  String _firstName = '';
  String _lastName = '';
  String _phone = '';
  String _address1 = '';
  String _address2 = '';
  String _city = '';
  String _state = '';
  String _zip = '';
  String _fullAddress = '';

  bool addressConfirmed = false;
  bool inSalesArea = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box(appDatabase).listenable(keys: [
          'darkTheme',
          'credits',
          'permCredits',
          'purchCredits',
          'ecwidProducts',
          'ecwidProuctOrdersList',
          'userIsPremium',
          'userIdList',
          'subscriptionAlertsList'
        ]),
        builder: (context, box, widget) {
          darkTheme = userDatabase.get('darkTheme');
          credits = userDatabase.get('credits');
          permCredits = userDatabase.get('permCredits');
          purchCredits = userDatabase.get('purchCredits');
          totalCredits = credits + permCredits + purchCredits;
          canBuy = totalCredits >= creditsToBuy;

          return SafeArea(
              child: Scaffold(
            appBar: AppBar(
              title: Text(pageTitle),
            ),
            body: _loading || product == null
                ? AnimatedWidgets.circularProgressWatchtower(
                    context, userDatabase,
                    isFullScreen: true)
                : SafeArea(
                    child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          image: DecorationImage(
                              opacity: 0.15,
                              image: AssetImage(backgroundImage),
                              repeat: ImageRepeat.repeat,
                              colorFilter: ColorFilter.mode(
                                  Theme.of(context).colorScheme.background,
                                  BlendMode.color)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: BounceInUp(
                            child: ListView(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                Text(
                                  'Order: $orderId'.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: Styles.regularStyle.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                InteractiveViewer(
                                  // constrained: false,
                                  child: ZoomIn(
                                    // from: 30,
                                    // duration: Duration(milliseconds: 250),
                                    // delay: Duration(milliseconds: 1000),
                                    child: Container(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background
                                          .withOpacity(0.5),
                                      alignment: Alignment.center,
                                      height: 200,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          opacity: 0.3,
                                          image: NetworkImage(
                                            product.hdThumbnailUrl,
                                          ),
                                          fit: BoxFit.cover,
                                          onError: (error, stackTrace) =>
                                              const AssetImage(
                                                  'assets/intro_background.png'),
                                          // colorFilter: ColorFilter.mode(
                                          //     Theme.of(context)
                                          //         .colorScheme
                                          //         .background,
                                          //     BlendMode.color),
                                        ),
                                      ),
                                      foregroundDecoration: BoxDecoration(
                                        border: Border.all(width: 1),
                                        borderRadius: BorderRadius.circular(5),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            product.hdThumbnailUrl,
                                          ),
                                          fit: BoxFit.contain,
                                          onError: (error, stackTrace) =>
                                              const AssetImage(
                                                  'assets/intro_background.png'),
                                        ),
                                      ),
                                      // child: BackdropFilter(
                                      //   filter: ImageFilter.blur(
                                      //       sigmaX: 10, sigmaY: 10),
                                      //   child: Container(
                                      //       height: 150, color: Colors.transparent),
                                      // ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        product.name.toUpperCase(),
                                        // softWrap: true,
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: Styles.regularStyle.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Price: $creditsToBuy Credits',
                                        style: Styles.regularStyle.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Credits Available: $totalCredits',
                                        style: Styles.regularStyle.copyWith(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: !canBuy
                                                ? darkTheme
                                                    ? null
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .error
                                                : darkTheme
                                                    ? alertIndicatorColorBrightGreen
                                                    : alertIndicatorColorDarkGreen),
                                      ),
                                    ],
                                  ),
                                ),
                                Card(
                                  elevation: 0,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .background
                                      .withOpacity(0.75),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 0, 10, 20),
                                    child: Form(
                                      key: _ecwidFormKey,
                                      child: Scrollbar(
                                        child: ListView(
                                          shrinkWrap: true,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          children: [
                                            dropdownButtonList.isEmpty
                                                ? const SizedBox.shrink()
                                                : ListBody(
                                                    children:
                                                        dropdownButtonList),
                                            TextFormField(
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              validator: (val) =>
                                                  EmailValidator.validate(val)
                                                      ? null
                                                      : "Email",
                                              decoration: InputDecoration(
                                                  hintText:
                                                      'Email *'.toUpperCase(),
                                                  errorStyle: TextStyle(
                                                      color: darkTheme
                                                          ? altHighlightColor
                                                          : null)),
                                              onChanged: (val) =>
                                                  setState(() => _email = val),
                                            ),
                                            TextFormField(
                                              keyboardType: TextInputType.text,
                                              validator: (val) => val == null ||
                                                      val.length < 2 ||
                                                      val.length > 20
                                                  ? 'Must be 2 to 20 characters'
                                                  : null,
                                              decoration: InputDecoration(
                                                hintText: 'First Name *'
                                                    .toUpperCase(),
                                                errorStyle: TextStyle(
                                                    color: darkTheme
                                                        ? altHighlightColor
                                                        : null),
                                              ),
                                              onChanged: (val) => setState(
                                                  () => _firstName = val),
                                            ),
                                            // SizedBox(width: 10),
                                            TextFormField(
                                              keyboardType: TextInputType.text,
                                              validator: (val) => val == null ||
                                                      val.length < 5 ||
                                                      val.length > 20
                                                  ? 'Must be 5 to 20 characters'
                                                  : null,
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Last Name *'.toUpperCase(),
                                                errorStyle: TextStyle(
                                                    color: darkTheme
                                                        ? altHighlightColor
                                                        : null),
                                              ),
                                              onChanged: (val) => setState(
                                                  () => _lastName = val),
                                            ),
                                            TextFormField(
                                              keyboardType: TextInputType.phone,
                                              // validator: (val) => val == null ||
                                              //         val.isEmpty
                                              //     ? '10 Digit Phone'
                                              //     : val.length < 10 || val.length > 10
                                              //         ? '10 digits without dashes'
                                              //         : null,
                                              decoration: InputDecoration(
                                                  hintText: 'Phone number'
                                                      .toUpperCase(),
                                                  errorStyle: TextStyle(
                                                      color: darkTheme
                                                          ? altHighlightColor
                                                          : null)),
                                              onChanged: (val) =>
                                                  setState(() => _phone = val),
                                            ),
                                            TextFormField(
                                              keyboardType: TextInputType.text,
                                              validator: (val) => val == null ||
                                                      val.isEmpty
                                                  ? 'Address'
                                                  // : val.length < 5 || val.length > 20
                                                  //     ? 'User must be 5 to 20 characters'
                                                  : null,
                                              decoration: InputDecoration(
                                                  hintText: 'Street Address *'
                                                      .toUpperCase(),
                                                  errorStyle: TextStyle(
                                                      color: darkTheme
                                                          ? altHighlightColor
                                                          : null)),
                                              onChanged: (val) => setState(
                                                  () => _address1 = val),
                                            ),
                                            TextFormField(
                                              keyboardType: TextInputType.text,
                                              // validator: (val) => val == null || val.isEmpty
                                              //     ? 'Address2'
                                              //     : val.length < 5 || val.length > 20
                                              //         ? 'User must be 5 to 20 characters'
                                              //         : null,
                                              decoration: InputDecoration(
                                                  hintText:
                                                      'Apt., P.O. Box, etc.'
                                                          .toUpperCase(),
                                                  errorStyle: TextStyle(
                                                      color: darkTheme
                                                          ? altHighlightColor
                                                          : null)),
                                              onChanged: (val) => setState(
                                                  () => _address2 = val),
                                            ),
                                            TextFormField(
                                              keyboardType: TextInputType.text,
                                              validator: (val) => val == null ||
                                                      val.isEmpty
                                                  ? 'City'
                                                  // : val.length < 5 || val.length > 20
                                                  //     ? 'User must be 5 to 20 characters'
                                                  : null,
                                              decoration: InputDecoration(
                                                  hintText:
                                                      'City *'.toUpperCase(),
                                                  errorStyle: TextStyle(
                                                      color: darkTheme
                                                          ? altHighlightColor
                                                          : null)),
                                              onChanged: (val) =>
                                                  setState(() => _city = val),
                                            ),
                                            TextFormField(
                                              keyboardType: TextInputType.text,
                                              validator: (val) => val == null ||
                                                      val.isEmpty
                                                  ? 'State Abbr.'
                                                  : val.length < 2 ||
                                                          val.length > 2 ||
                                                          !statesMap.keys.any((abbr) =>
                                                              abbr
                                                                  .toString()
                                                                  .toLowerCase() ==
                                                              _state
                                                                  .toLowerCase())
                                                      ? 'State Abbr. must be 2 character US Territory code'
                                                      : null,
                                              decoration: InputDecoration(
                                                  hintText: 'State Abbr. *'
                                                      .toUpperCase(),
                                                  errorStyle: TextStyle(
                                                      color: darkTheme
                                                          ? altHighlightColor
                                                          : null)),
                                              onChanged: (val) =>
                                                  setState(() => _state = val),
                                            ),
                                            TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              validator: (val) => val == null ||
                                                      val.isEmpty
                                                  ? '5 Digit Zip'
                                                  : val.length < 5 ||
                                                          val.length > 5
                                                      ? 'Zip must be a 5 digit code'
                                                      : null,
                                              decoration: InputDecoration(
                                                  hintText: '5 Digit Zip *'
                                                      .toUpperCase(),
                                                  errorStyle: TextStyle(
                                                      color: darkTheme
                                                          ? altHighlightColor
                                                          : null)),
                                              onChanged: (val) =>
                                                  setState(() => _zip = val),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.fromLTRB(20, 5, 10, 15),
                                //   child: ListBody(children: [
                                //     Text('$_firstName $_lastName'.toUpperCase()),
                                //     _phone.isEmpty
                                //         ? SizedBox.shrink()
                                //         : Text(_phone.toUpperCase()),
                                //     Text(_address1.toUpperCase()),
                                //     _address2.isEmpty
                                //         ? SizedBox.shrink()
                                //         : Text(_address2.toUpperCase()),
                                //     Text('$_city $_state $_zip'.toUpperCase()),
                                //   ]),
                                // ),
                              ],
                            ),
                          ),
                          // ),
                        )),
                  ),
            bottomNavigationBar: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: SizedBox(
                  height: 25,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.transparent)),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Maybe Later',
                            style: TextStyle(
                                color: userDatabase.get('darkTheme')
                                    ? null
                                    : Theme.of(context).primaryColorDark),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Theme.of(context).primaryColorDark)),
                            onPressed: () async {
                              if (_ecwidFormKey.currentState.validate()) {
                                await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    setState(() => _fullAddress =
                                        "$_address1\n$_address2\n$_city, $_state $_zip");
                                    return AlertDialog(
                                      title:
                                          const Text('Confirm Order Details'),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            const Text(
                                                'Please confirm your name and delivery address. Incorrect information will delay delivery of your order.\n'),
                                            Text(
                                                'Order: $orderId\nPrice: $creditsToBuy Credits\n'
                                                    .toUpperCase()),
                                            Text(
                                                'Product: ${product.name} ${optionChoiceList.isEmpty ? '' : '\nOptions: ${optionChoiceList.map((e) => e.toString())}'}\n'
                                                    .toUpperCase()),
                                            Text(
                                                'Ship To: $_firstName $_lastName\n$_fullAddress'
                                                    .toUpperCase()),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () {
                                            Navigator.maybePop(context);
                                          },
                                        ),
                                        OutlinedButton(
                                          child: const Text('Approve'),
                                          onPressed: () {
                                            setState(
                                                () => addressConfirmed = true);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (addressConfirmed) {
                                  try {
                                    /// DEDUCT REQUIRED CREDITS
                                    debugPrint(
                                        "PROCESSING CREDITS... (ecwid_order_page)");
                                    Functions.processCredits(false,
                                        creditsToRemove: creditsToBuy);
                                    // if (credits >= creditsToBuy) {
                                    //   int _newCredits = credits - creditsToBuy;
                                    //   userDatabase.put('credits', _newCredits);
                                    // } else {
                                    //   int _newCredits = 0;
                                    //   int _newPermCredits = permCredits -
                                    //       (creditsToBuy - credits);
                                    //   userDatabase.put('credits', _newCredits);
                                    //   userDatabase.put(
                                    //       'permCredits', _newPermCredits);
                                    // }

                                    /// UPDATE USER EMAILS
                                    debugPrint(
                                        "UPDATING USER EMAILS LIST... (ecwid_order_page)");
                                    List<String> userEmailList = List.from(
                                        userDatabase.get('userEmailList'));
                                    if (!userEmailList.any((element) =>
                                        element.toLowerCase() ==
                                        _email.toLowerCase())) {
                                      userEmailList
                                          .add('$_email<|:|>${DateTime.now()}');
                                    }

                                    debugPrint(
                                        "UPDATING RECENT ORDERS LIST... (ecwid_order_page)");
                                    productOrdersList.insert(
                                        0,
                                        Order(
                                            orderDate: DateTime.now(),
                                            orderId: orderId,
                                            orderIdExtended: orderIdExtended,
                                            userName:
                                                lastUserId.split('<|:|>')[0],
                                            userId:
                                                initialUserId.split('<|:|>')[1],
                                            productId: product.id.toString(),
                                            productName: product.name,
                                            productOptions: optionChoiceList
                                                    .map((e) => e)
                                                    .toList()
                                                    .isEmpty
                                                ? 'No Options'
                                                : optionChoiceList
                                                    .map((e) => e.toString())
                                                    .toString()
                                                    .toUpperCase(),
                                            productDescription:
                                                product.description,
                                            productPrice:
                                                '$creditsToBuy Credits',
                                            productImageUrl: product.imageUrl,
                                            customerName:
                                                '$_firstName $_lastName',
                                            customerId:
                                                initialUserId.split('<|:|>')[1],
                                            customerPhone: _phone,
                                            customerShippingAddress:
                                                _fullAddress,
                                            customerEmail: _email));

                                    userDatabase.put(
                                        'ecwidProductOrdersList',
                                        orderDetailListToJson(OrderDetailList(
                                            orders: productOrdersList)));

                                    debugPrint(
                                        "ADDING 100 TEMPORARY REWARD CREDITS... (ecwid_order_page)");
                                    await Functions.processCredits(true,
                                        creditsToAdd: 100);

                                    debugPrint(
                                        "SENDING EMAILS... (ecwid_order_page)");

                                    /// SEND EMAIL, POPUP & NOTIFICATION
                                    await EmailjsApi
                                        .sendEcwidOrderWithCreditsEmail(
                                      '${product.name} - $orderId'
                                          .toUpperCase(),
                                      '[Address Confirmed] $_firstName $_lastName has just ordered ${product.name}'
                                          .toUpperCase(),
                                      _email,
                                      '$_firstName $_lastName'.toUpperCase(),
                                      customerPhone: _phone.toUpperCase(),
                                      customerAddress:
                                          _fullAddress.toUpperCase(),
                                      orderId: orderId.toUpperCase(),
                                      orderIdExtended:
                                          orderIdExtended.toUpperCase(),
                                      orderDate: orderDate.toUpperCase(),
                                      creditsUsed:
                                          creditsToBuy.toString().toUpperCase(),
                                      productName: product.name.toUpperCase(),
                                      productOptions: optionChoiceList
                                              .map((e) => e)
                                              .toList()
                                              .isEmpty
                                          ? 'No Options'
                                          : optionChoiceList
                                              .map((e) => e.toString())
                                              .toString()
                                              .toUpperCase(),
                                      productImageUrl: product.imageUrl,
                                      otherProductInfo:
                                          'Printful ID: ${product.id} - Ecwid SKU: ${product.sku}',
                                      allProductInfo:
                                          product.toJson().toString(),
                                      appUserId: initialUserId.toUpperCase(),
                                      appUserStatus: userIsDev
                                          ? 'Developer'
                                          : userIsPremium
                                              ? 'Premium'
                                              : userIsLegacy
                                                  ? 'Legacy'
                                                  : 'Free',
                                      appUserLocation: currentUserAddress
                                          .toString()
                                          .toUpperCase(),
                                    );

                                    debugPrint(
                                        "INITIATING POP-UP TOAST... (ecwid_order_page)");
                                    Messages.showMessage(
                                        context: context,
                                        message:
                                            'Your order for ${product.name} has been received and is in process!',
                                        networkImageUrl: product.imageUrl,
                                        isAlert: false);

                                    debugPrint(
                                        "POPPING 1ST CONTEXT... (ecwid_order_page)");
                                    Navigator.pop(context);

                                    debugPrint(
                                        "SENDING IN-APP NOTIFICATION... (ecwid_order_page)");
                                    Messages.sendNotification(
                                        context: context,
                                        source: 'ecwid',
                                        summaryTitle: 'Your Recent Order',
                                        title: 'Your order has been received',
                                        messageBody:
                                            'Your order ($orderId) of ${product.name} has been received and is in process. Check your email $_email for additional information.',
                                        additionalData: 'product');

                                    // debugPrint(
                                    //     "POPPING 2ND CONTEXT... (ecwid_order_page)");
                                    // Navigator.maybePop(context);
                                    debugPrint(
                                        "PROCESSING COMPLETE (ecwid_order_page)");
                                  } catch (e) {
                                    debugPrint(
                                        "ERROR DURING PRODUCT PURCHASE PROCESS (ecwid_order_page): $e");
                                  }
                                }
                              } else {
                                logger.d('***** Data is invalid *****');
                              }
                            },
                            child: const Text(
                              'Buy Now',
                              style: TextStyle(color: darkThemeTextColor),
                            )),
                      ),
                    ],
                  ),
                )),
          ));
        });
  }
}

class OptionChoice {
  OptionChoice(this.option, this.choice);
  final String option;
  final String choice;

  @override
  String toString() {
    return '$option: $choice';
    // super.toString();
  }
}
