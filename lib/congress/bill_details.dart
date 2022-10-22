import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:us_congress_vote_tracker/constants/animated_widgets.dart';
import 'package:us_congress_vote_tracker/congress/member_details.dart';
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:us_congress_vote_tracker/constants/themes.dart';
import 'package:us_congress_vote_tracker/constants/widgets.dart';
import 'package:us_congress_vote_tracker/functions/functions.dart';
import 'package:us_congress_vote_tracker/models/bill_payload_model.dart';
import 'package:us_congress_vote_tracker/services/admob/admob_ad_library.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/house_stock_watch_model.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/senate_stock_watch_model.dart';
import 'package:us_congress_vote_tracker/services/propublica/propublica_api.dart';

class BillDetail extends StatefulWidget {
  final String url;
  final List<HouseStockWatch> houseStockWatchList;
  final List<SenateStockWatch> senateStockWatchList;
  BillDetail(this.url, this.houseStockWatchList, this.senateStockWatchList);

  @override
  _BillDetailState createState() => new _BillDetailState();
}

class _BillDetailState extends State<BillDetail> {
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
          List.from(userDatabase.get('userIdList')).any(
              (element) => element.toString().startsWith('$oldUserIdPrefix'));
      houseStockWatchList = widget.houseStockWatchList;
      senateStockWatchList = widget.senateStockWatchList;
    });
  }

  Future<void> getBillData() async {
    setState(() => _isLoading = true);
    setState(() {
      subscriptionAlertsList =
          List.from(userDatabase.get('subscriptionAlertsList'));
      memberContainerColor = Theme.of(context).primaryColor.withOpacity(0.15);
      memberContainerTextColor = Color(0xffffffff);
    });

    await PropublicaApi.fetchSingleBill(widget.url.toLowerCase())
        .then((bills) => setState(() => billInfoList = bills));

    if (billInfoList.length > 0) {
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
        title:
            new Text('Bill Detail', style: GoogleFonts.bangers(fontSize: 25)),
        actions: <Widget>[
          new IconButton(
              icon: Icon(Icons.share),
              onPressed: () async => await Messages.shareContent(true))
        ],
      ),
      body: _isLoading || bill == null
          ? AnimatedWidgets.circularProgressWatchtower(context,
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

                String _thisBillString =
                    'bill_${bill.first.billId}_${bill.first.shortTitle}_${bill.first.billUri}_${bill.first.latestMajorActionDate}_bill';

                return new RefreshIndicator(
                  child: Container(
                    color: Theme.of(context).colorScheme.background,
                    child: new ListView(
                      physics: new BouncingScrollPhysics(),
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
                          child: new Card(
                            elevation: 0.0,
                            child: new Column(
                              children: <Widget>[
                                new Container(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.15),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: new Row(
                                      children: <Widget>[
                                        FaIcon(FontAwesomeIcons.scroll,
                                            size: 13),
                                        SizedBox(width: 10),
                                        new Expanded(
                                          child: new Container(
                                            margin: new EdgeInsets.all(5.0),
                                            child: new Text(
                                              bill.first.bill,
                                              style: new TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        userIsPremium || userIsLegacy
                                            ? SizedBox(
                                                height: 20,
                                                child: new ElevatedButton.icon(
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
                                                          .add(_thisBillString);
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
                                            : SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                ),
                                new Container(
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
                                  child: new Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: new Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        new Column(
                                          children: [
                                            new GestureDetector(
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
                                              child: new Container(
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
                                        new Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: new Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              new Text(
                                                'Sponsored by:',
                                                style: new TextStyle(
                                                    color:
                                                        memberContainerTextColor,
                                                    // color: Colors.black,
                                                    fontSize: 12.0,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                              new SizedBox(height: 1),
                                              new Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  new Text(
                                                    '${bill.first.sponsorTitle.replaceFirst('Rep.', 'Hon.')} ${bill.first.sponsor} of ${bill.first.sponsorState}',
                                                    style: new TextStyle(
                                                        color:
                                                            memberContainerTextColor,
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  new SizedBox(width: 5),
                                                  new CircleAvatar(
                                                    radius: 8,
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .primaryColor
                                                            .withOpacity(0.15),
                                                    child: new CircleAvatar(
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
                                                      child: new Text(
                                                        bill.first.sponsorParty,
                                                        style: new TextStyle(
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
                                              new SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  new Text(
                                                    'Co-Sponsors: ',
                                                    style: new TextStyle(
                                                        color:
                                                            memberContainerTextColor,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                  new Text(
                                                    bill.first.cosponsorsByParty
                                                                .d !=
                                                            null
                                                        ? '${bill.first.cosponsorsByParty.d} Dem.'
                                                        : '0 Dem',
                                                    style: new TextStyle(
                                                        color:
                                                            memberContainerTextColor,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                  new SizedBox(width: 10),
                                                  new Text(
                                                    bill.first.cosponsorsByParty
                                                                .r !=
                                                            null
                                                        ? '${bill.first.cosponsorsByParty.r} Rep.'
                                                        : '0 Rep.',
                                                    style: new TextStyle(
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
                                                  new Text(
                                                    'Sponsors Withdrawn: ',
                                                    style: new TextStyle(
                                                        color:
                                                            memberContainerTextColor,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                  new Text(
                                                    bill.first
                                                        .withdrawnCosponsors
                                                        .toString(),
                                                    style: new TextStyle(
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
                                                  new Text(
                                                    'Votes: ',
                                                    style: new TextStyle(
                                                        color:
                                                            memberContainerTextColor,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                  new Text(
                                                    bill.first.votes.length
                                                        .toString(),
                                                    style: new TextStyle(
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
                                    ? new SizedBox.shrink()
                                    : new Column(
                                        children: [
                                          new Row(
                                            children: <Widget>[
                                              new Expanded(
                                                child: new Container(
                                                  margin:
                                                      new EdgeInsets.fromLTRB(
                                                          10, 10, 10, 0),
                                                  child: new Text(
                                                    'Subject',
                                                    style: new TextStyle(
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          new Row(
                                            children: <Widget>[
                                              new Expanded(
                                                child: new Container(
                                                  margin:
                                                      new EdgeInsets.fromLTRB(
                                                          10, 0, 10, 0),
                                                  child: new Text(
                                                    bill.first.primarySubject,
                                                    style: new TextStyle(
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
                                new Row(
                                  children: <Widget>[
                                    new Expanded(
                                      child: new Container(
                                        margin: new EdgeInsets.fromLTRB(
                                            10, 10, 10, 0),
                                        child: new Text(
                                          bill.first.shortTitle,
                                          style: new TextStyle(
                                              // color: Colors.black,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                new Row(
                                  children: <Widget>[
                                    new Expanded(
                                      child: new Container(
                                        margin: new EdgeInsets.fromLTRB(
                                            10, 0, 10, 0),
                                        child: new Text(
                                          bill.first.title,
                                          style: new TextStyle(
                                              // color: Colors.black,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                new Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Expanded(
                                      child: new Container(
                                        margin: new EdgeInsets.only(
                                            top: 10, left: 10.0),
                                        child: new Text(
                                          'Latest Action:',
                                          style: new TextStyle(
                                              // color: Colors.blue[900],
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                new Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Expanded(
                                      child: new Container(
                                        margin: new EdgeInsets.fromLTRB(
                                            10, 0, 10, 0),
                                        child: new Text(
                                          bill.first.latestMajorAction +
                                              '  ' +
                                              formatter.format(bill
                                                  .first.latestMajorActionDate),
                                          style: new TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                bill.first.committees.isEmpty
                                    ? new SizedBox.shrink()
                                    : new Column(
                                        children: [
                                          new Row(
                                            children: <Widget>[
                                              new Expanded(
                                                child: new Container(
                                                  margin: new EdgeInsets.only(
                                                      top: 10, left: 10.0),
                                                  child: new Text(
                                                    'Committee: ',
                                                    style: new TextStyle(
                                                        // color: Colors.black,
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          new Row(
                                            children: <Widget>[
                                              new Expanded(
                                                child: new Container(
                                                  margin:
                                                      new EdgeInsets.fromLTRB(
                                                          10, 0, 10, 0),
                                                  child: new Text(
                                                    bill.first.committees,
                                                    style: new TextStyle(
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
                                new Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Expanded(
                                      child: new Container(
                                        margin: new EdgeInsets.only(
                                            top: 10, left: 10.0),
                                        child: new Text(
                                          'Passage:',
                                          style: new TextStyle(
                                              // color: Colors.blue[900],
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                new Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Expanded(
                                      child: new Container(
                                        margin: new EdgeInsets.only(left: 10.0),
                                        child: bill.first.housePassage == null
                                            ? new Text(
                                                'Introduced: Date not available')
                                            : new Text(
                                                'Introduced: ' +
                                                    formatter.format(bill
                                                        .first.introducedDate),
                                                style: new TextStyle(
                                                    // color: Colors.blue[900],
                                                    fontSize: 14.0,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                new Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Expanded(
                                      child: new Container(
                                        margin: new EdgeInsets.only(left: 10.0),
                                        child: bill.first.housePassage == null
                                            ? new Text(
                                                'House: Date not available')
                                            : new Text(
                                                'House: ' +
                                                    formatter.format(bill
                                                        .first.housePassage),
                                                style: new TextStyle(
                                                    // color: Colors.blue[900],
                                                    fontSize: 14.0,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                new Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Expanded(
                                      child: new Container(
                                        margin: new EdgeInsets.only(left: 10.0),
                                        child: bill.first.senatePassage == null
                                            ? new Text(
                                                'Senate: Date not available')
                                            : new Text(
                                                'Senate: ' +
                                                    formatter.format(bill
                                                        .first.senatePassage),
                                                style: new TextStyle(
                                                    // color: Colors.blue[900],
                                                    fontSize: 14.0,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                bill.first.summary.isEmpty
                                    ? new SizedBox.shrink()
                                    : new Column(
                                        children: [
                                          new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              new Expanded(
                                                child: new Container(
                                                  margin: new EdgeInsets.only(
                                                      top: 10, left: 10.0),
                                                  child: new Text(
                                                    'Summary:',
                                                    style: new TextStyle(
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              new Expanded(
                                                child: new Container(
                                                  margin:
                                                      new EdgeInsets.fromLTRB(
                                                          10, 0, 10, 0),
                                                  child: new Text(
                                                    bill.first.summary,
                                                    style: new TextStyle(
                                                        // color: Colors.black,
                                                        fontSize: 14.0),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                new Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      new Text('Additional details:',
                                          style: new TextStyle(
                                              // color: Colors.black,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold)),
                                      new SizedBox(width: 10),
                                      new RichText(
                                        text: new TextSpan(
                                          style: new TextStyle(
                                              color: Colors.blue,
                                              fontSize: 12.0,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.bold),
                                          text: 'congress.gov',
                                          recognizer: new TapGestureRecognizer()
                                            ..onTap = () {
                                              launchUrl(Uri.parse(bill
                                                  .first.congressdotgovUrl
                                                  .toString()));
                                            },
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      bill.first.gpoPdfUri == null
                                          ? SizedBox.shrink()
                                          : RichText(
                                              text: new TextSpan(
                                                style: new TextStyle(
                                                    color:
                                                        bill.first.gpoPdfUri ==
                                                                null
                                                            ? null
                                                            : Colors.blue,
                                                    // color: bill.first.gpoPdfUri == null ? Colors.grey[400] : Colors.blue,
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
                                                    new TapGestureRecognizer()
                                                      ..onTap = bill.first
                                                                  .gpoPdfUri ==
                                                              null
                                                          ? null
                                                          : () => Functions
                                                              .linkLaunch(
                                                                  context,
                                                                  bill.first
                                                                      .gpoPdfUri,
                                                                  userDatabase,
                                                                  userIsPremium,
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
                  onRefresh: getBillData,
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
                  ? SizedBox.shrink()
                  : bannerAdContainer,
              SharedWidgets.createdByContainer(
                  context, userIsPremium, userDatabase),
            ],
          ),
        ),
      ),
    );
  }
}
