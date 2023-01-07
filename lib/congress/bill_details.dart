import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:congress_watcher/constants/animated_widgets.dart';
import 'package:congress_watcher/congress/member_details.dart';
import 'package:congress_watcher/constants/constants.dart';
import 'package:congress_watcher/constants/themes.dart';
import 'package:congress_watcher/constants/widgets.dart';
import 'package:congress_watcher/functions/functions.dart';
import 'package:congress_watcher/models/bill_payload_model.dart';
import 'package:congress_watcher/services/admob/admob_ad_library.dart';
import 'package:congress_watcher/services/congress_stock_watch/house_stock_watch_model.dart';
import 'package:congress_watcher/services/congress_stock_watch/senate_stock_watch_model.dart';
import 'package:congress_watcher/functions/propublica_api_functions.dart';

class BillDetail extends StatefulWidget {
  final String url;
  final List<HouseStockWatch> houseStockWatchList;
  final List<SenateStockWatch> senateStockWatchList;
  const BillDetail(
      this.url, this.houseStockWatchList, this.senateStockWatchList,
      {Key key})
      : super(key: key);

  @override
  BillDetailState createState() => BillDetailState();
}

class BillDetailState extends State<BillDetail> {
  Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
  bool _isLoading = true;
  bool userIsPremium = false;
  bool userIsLegacy = false;
  List<Result> billInfoList;
  Color memberContainerColor;
  Color memberContainerTextColor;
  Container bannerAdContainer = Container();
  bool showBannerAd = true;
  bool adLoaded = false;
  List<dynamic> subscriptionAlertsList = [];
  List<HouseStockWatch> houseStockWatchList = [];
  List<SenateStockWatch> senateStockWatchList = [];

  String randomAssetImageUrl = 'assets/congress_pic_0.png';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await setVariables();
      await getBillData();
    });
  }

  Future<void> setVariables() async {
    setState(() {
      userIsPremium = userDatabase.get('userIsPremium');
      userIsLegacy = !userDatabase.get('userIsPremium') &&
          List.from(userDatabase.get('userIdList'))
              .any((element) => element.toString().startsWith(oldUserIdPrefix));
      houseStockWatchList = widget.houseStockWatchList;
      senateStockWatchList = widget.senateStockWatchList;
    });

    setState(() =>
        randomAssetImageUrl = 'assets/congress_pic_${random.nextInt(4)}.png');
  }

  Future<void> getBillData() async {
    setState(() => _isLoading = true);
    setState(() {
      subscriptionAlertsList =
          List.from(userDatabase.get('subscriptionAlertsList'));
      memberContainerColor = Theme.of(context).primaryColor.withOpacity(0.15);
      memberContainerTextColor = const Color(0xffffffff);
    });

    await PropublicaApi.fetchSingleBill(widget.url.toLowerCase())
        .then((bills) => setState(() => billInfoList = bills));

    if (billInfoList.isNotEmpty) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ADMOB INFORMATION HERE
    if (!adLoaded && !userIsPremium) {
      final BannerAd thisBanner = AdMobLibrary().defaultBanner();

      thisBanner?.load();

      if (thisBanner != null) {
        setState(() {
          adLoaded = true;
          bannerAdContainer =
              AdMobLibrary().bannerContainer(thisBanner, context);
        });
      }
    }

    var bill = billInfoList;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Bill Detail', style: GoogleFonts.bangers(fontSize: 25)),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async => await Messages.shareContent(true))
        ],
      ),
      body: _isLoading || bill == null
          ? AnimatedWidgets.circularProgressWatchtower(context, userDatabase,
              isFullScreen: true)
          : ValueListenableBuilder(
              valueListenable: Hive.box(appDatabase).listenable(keys: [
                'darkTheme',
                'userIsPremium',
                'userIdList',
                'subscriptionAlertsList'
              ]),
              builder: (context, box, widget) {
                dynamic sponsorImage = NetworkImage(
                    'https://www.congress.gov/img/member/${bill.first.sponsorId.toLowerCase()}.jpg');

                String thisBillString =
                    'bill_${bill.first.billId}_${bill.first.shortTitle}_${bill.first.billUri}_${bill.first.latestMajorActionDate}_bill';

                return RefreshIndicator(
                  onRefresh: getBillData,
                  child: Container(
                    // color: Theme.of(context).colorScheme.background,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      image: DecorationImage(
                          opacity: 0.15,
                          image: AssetImage(randomAssetImageUrl),
                          repeat: ImageRepeat.repeat,
                          // fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.background,
                              BlendMode.color)),
                    ),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        FadeIn(
                          child: Image.asset(
                              'assets/congress_pic_${random.nextInt(4)}.png',
                              height: 125,
                              fit: BoxFit.cover,
                              color: Theme.of(context).primaryColor,
                              colorBlendMode: BlendMode.softLight),
                        ),
                        Container(
                          margin: const EdgeInsets.all(5.0),
                          child: Card(
                            elevation: 0.0,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.15),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Row(
                                      children: <Widget>[
                                        const FaIcon(FontAwesomeIcons.scroll,
                                            size: 13),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.all(5.0),
                                            child: Text(
                                              bill.first.bill,
                                              style: const TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        userIsPremium || userIsLegacy
                                            ? SizedBox(
                                                height: 20,
                                                child: ElevatedButton.icon(
                                                  icon: AnimatedWidgets.flashingEye(
                                                      context,
                                                      List.from(userDatabase.get(
                                                              'subscriptionAlertsList'))
                                                          .any((element) => element
                                                              .toString()
                                                              .toLowerCase()
                                                              .startsWith(
                                                                  'bill_${bill.first.billId}'
                                                                      .toLowerCase())),
                                                      true,
                                                      size: 11,
                                                      sameColorBright: true),
                                                  label: Text(
                                                    List.from(userDatabase.get(
                                                                'subscriptionAlertsList'))
                                                            .any((element) => element
                                                                .toString()
                                                                .toLowerCase()
                                                                .startsWith(
                                                                    'bill_${bill.first.billId}'
                                                                        .toLowerCase()))
                                                        ? 'ON'
                                                        : 'OFF',
                                                    style: GoogleFonts.bangers(
                                                        color: Colors.white,
                                                        fontSize: 17),
                                                  ),
                                                  onPressed: () async {
                                                    if (!List.from(userDatabase.get(
                                                            'subscriptionAlertsList'))
                                                        .any((element) => element
                                                            .toString()
                                                            .toLowerCase()
                                                            .startsWith(
                                                                'bill_${bill.first.billId}'
                                                                    .toLowerCase()))) {
                                                      subscriptionAlertsList
                                                          .add(thisBillString);
                                                      userDatabase.put(
                                                          'subscriptionAlertsList',
                                                          subscriptionAlertsList);

                                                      logger
                                                          .i(bill.first.billId);
                                                      logger.i(userDatabase.get(
                                                          'subscriptionAlertsList'));

                                                      // if (!userDatabase
                                                      //     .get('billAlerts'))
                                                      //   userDatabase.put(
                                                      //       'billAlerts', true);

                                                      await Functions
                                                          .processCredits(true);
                                                    } else {
                                                      subscriptionAlertsList.removeWhere(
                                                          (element) => element
                                                              .toString()
                                                              .toLowerCase()
                                                              .startsWith(
                                                                  'bill_${bill.first.billId}'
                                                                      .toLowerCase()));
                                                      userDatabase.put(
                                                          'subscriptionAlertsList',
                                                          subscriptionAlertsList);
                                                    }
                                                  },
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty.all<
                                                              Color>(Theme.of(
                                                                  context)
                                                              .primaryColorDark)),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  color: userDatabase.get('darkTheme') == true
                                      ? memberContainerColor
                                      : bill.first.sponsorParty.toLowerCase() ==
                                              'd'
                                          ? democratColor
                                          : bill.first.sponsorParty
                                                      .toLowerCase() ==
                                                  'r'
                                              ? republicanColor
                                              : bill.first.sponsorParty
                                                          .toLowerCase() ==
                                                      'i'
                                                  ? independentColor
                                                  : memberContainerColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        MemberDetail(
                                                            bill.first
                                                                .sponsorId,
                                                            houseStockWatchList,
                                                            senateStockWatchList),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: 85,
                                                width: 60,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: AssetImage(
                                                          'assets/congress_pic_${random.nextInt(4)}.png'),
                                                      colorFilter: ColorFilter.mode(
                                                          userDatabase.get(
                                                                  'darkTheme')
                                                              ? Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary
                                                              : Colors
                                                                  .transparent,
                                                          BlendMode.color)),
                                                ),
                                                foregroundDecoration:
                                                    BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  image: DecorationImage(
                                                    onError: (error,
                                                            stackTrace) =>
                                                        AssetImage(
                                                            'assets/congress_pic_${random.nextInt(4)}.png'),
                                                    fit: BoxFit.cover,
                                                    image: sponsorImage,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Sponsored by:',
                                                style: TextStyle(
                                                    color:
                                                        memberContainerTextColor,
                                                    // color: Colors.black,
                                                    fontSize: 12.0,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                              const SizedBox(height: 1),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '${bill.first.sponsorTitle.replaceFirst('Rep.', 'Hon.')} ${bill.first.sponsor} of ${bill.first.sponsorState}',
                                                    style: TextStyle(
                                                        color:
                                                            memberContainerTextColor,
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  CircleAvatar(
                                                    radius: 8,
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .primaryColor
                                                            .withOpacity(0.15),
                                                    child: CircleAvatar(
                                                      backgroundColor: bill
                                                                  .first
                                                                  .sponsorParty
                                                                  .toLowerCase() ==
                                                              'd'
                                                          ? democratColor
                                                          : bill.first.sponsorParty
                                                                      .toLowerCase() ==
                                                                  'r'
                                                              ? republicanColor
                                                              : independentColor,
                                                      radius: 7,
                                                      child: Text(
                                                        bill.first.sponsorParty,
                                                        style: const TextStyle(
                                                            leadingDistribution:
                                                                TextLeadingDistribution
                                                                    .even,
                                                            color: Color(
                                                                0xffffffff),
                                                            fontSize: 10.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Co-Sponsors: ',
                                                    style: TextStyle(
                                                        color:
                                                            memberContainerTextColor,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                  Text(
                                                    bill.first.cosponsorsByParty
                                                                .d !=
                                                            null
                                                        ? '${bill.first.cosponsorsByParty.d} Dem.'
                                                        : '0 Dem',
                                                    style: TextStyle(
                                                        color:
                                                            memberContainerTextColor,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    bill.first.cosponsorsByParty
                                                                .r !=
                                                            null
                                                        ? '${bill.first.cosponsorsByParty.r} Rep.'
                                                        : '0 Rep.',
                                                    style: TextStyle(
                                                        color:
                                                            memberContainerTextColor,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ],
                                              ),
                                              // new SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Sponsors Withdrawn: ',
                                                    style: TextStyle(
                                                        color:
                                                            memberContainerTextColor,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                  Text(
                                                    bill.first
                                                        .withdrawnCosponsors
                                                        .toString(),
                                                    style: TextStyle(
                                                        color:
                                                            memberContainerTextColor,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ],
                                              ),
                                              Wrap(
                                                children: [
                                                  Text(
                                                    'Votes: ',
                                                    style: TextStyle(
                                                        color:
                                                            memberContainerTextColor,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                  Text(
                                                    bill.first.votes.length
                                                        .toString(),
                                                    style: TextStyle(
                                                        color:
                                                            memberContainerTextColor,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                bill.first.primarySubject.isEmpty
                                    ? const SizedBox.shrink()
                                    : Column(
                                        children: [
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 10, 10, 0),
                                                  child: const Text(
                                                    'Subject',
                                                    style: TextStyle(
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 0, 10, 0),
                                                  child: Text(
                                                    bill.first.primarySubject,
                                                    style: const TextStyle(
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            10, 10, 10, 0),
                                        child: Text(
                                          bill.first.shortTitle,
                                          style: const TextStyle(
                                              // color: Colors.black,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            10, 0, 10, 0),
                                        child: Text(
                                          bill.first.title,
                                          style: const TextStyle(
                                              // color: Colors.black,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            top: 10, left: 10.0),
                                        child: const Text(
                                          'Latest Action:',
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            10, 0, 10, 0),
                                        child: Text(
                                          '${bill.first.latestMajorAction}  ${formatter.format(bill.first.latestMajorActionDate)}',
                                          style: const TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                bill.first.committees.isEmpty
                                    ? const SizedBox.shrink()
                                    : Column(
                                        children: [
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 10, left: 10.0),
                                                  child: const Text(
                                                    'Committee: ',
                                                    style: TextStyle(
                                                        // color: Colors.black,
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 0, 10, 0),
                                                  child: Text(
                                                    bill.first.committees,
                                                    style: const TextStyle(
                                                        // color: Colors.black,
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            top: 10, left: 10.0),
                                        child: const Text(
                                          'Passage:',
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(left: 10.0),
                                        child: bill.first.housePassage == null
                                            ? const Text(
                                                'Introduced: Date not available')
                                            : Text(
                                                'Introduced: ${formatter.format(bill.first.introducedDate)}',
                                                style: const TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(left: 10.0),
                                        child: bill.first.housePassage == null
                                            ? const Text(
                                                'House: Date not available')
                                            : Text(
                                                'House: ${formatter.format(bill.first.housePassage)}',
                                                style: const TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(left: 10.0),
                                        child: bill.first.senatePassage == null
                                            ? const Text(
                                                'Senate: Date not available')
                                            : Text(
                                                'Senate: ${formatter.format(bill.first.senatePassage)}',
                                                style: const TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                bill.first.summary.isEmpty
                                    ? const SizedBox.shrink()
                                    : Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 10, left: 10.0),
                                                  child: const Text(
                                                    'Summary:',
                                                    style: TextStyle(
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 0, 10, 0),
                                                  child: Text(
                                                    bill.first.summary,
                                                    style: const TextStyle(
                                                        // color: Colors.black,
                                                        fontSize: 14.0),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text('Additional details:',
                                          style: TextStyle(
                                              // color: Colors.black,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 10),
                                      RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                              color:
                                                  userDatabase.get('darkTheme')
                                                      ? null
                                                      : Theme.of(context)
                                                          .primaryColorDark,
                                              fontSize: 12.0,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.bold),
                                          text: 'congress.gov',
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              launchUrl(Uri.parse(bill
                                                  .first.congressdotgovUrl
                                                  .toString()));
                                            },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      bill.first.gpoPdfUri == null
                                          ? const SizedBox.shrink()
                                          : RichText(
                                              text: TextSpan(
                                                style: TextStyle(
                                                    color: userDatabase.get(
                                                                'darkTheme') ||
                                                            bill.first
                                                                    .gpoPdfUri ==
                                                                null
                                                        ? null
                                                        : Theme.of(context)
                                                            .primaryColorDark,
                                                    fontSize: 12.0,
                                                    decoration:
                                                        bill.first.gpoPdfUri ==
                                                                null
                                                            ? null
                                                            : TextDecoration
                                                                .underline,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                text: 'gpo pdf',
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = bill.first
                                                                  .gpoPdfUri ==
                                                              null
                                                          ? null
                                                          : () => Functions
                                                              .linkLaunch(
                                                                  context,
                                                                  bill.first
                                                                      .gpoPdfUri,
                                                                  /* userDatabase ,
                                                      userIsPremium,*/
                                                                  isPdf: true),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              !showBannerAd || userIsPremium
                  ? const SizedBox.shrink()
                  : bannerAdContainer,
              SharedWidgets.createdByContainer(context, userDatabase),
            ],
          ),
        ),
      ),
    );
  }
}
