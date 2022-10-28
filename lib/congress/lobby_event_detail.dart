import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:us_congress_vote_tracker/constants/animated_widgets.dart';
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:us_congress_vote_tracker/constants/styles.dart';
import 'package:us_congress_vote_tracker/constants/themes.dart';
import 'package:us_congress_vote_tracker/constants/widgets.dart';
import 'package:us_congress_vote_tracker/functions/functions.dart';
import 'package:us_congress_vote_tracker/models/lobby_event_model.dart';
import 'package:us_congress_vote_tracker/models/lobby_event_specific_model.dart';
import 'package:us_congress_vote_tracker/services/admob/admob_ad_library.dart';
import 'package:us_congress_vote_tracker/services/propublica/propublica_api.dart';

class LobbyEventDetail extends StatefulWidget {
  // final LobbyingRepresentation thisLobbyEvent;
  final String thisLobbyEventId;
  const LobbyEventDetail(/*this.thisLobbyEvent,*/ {Key key, this.thisLobbyEventId = ''}) : super(key: key);

  @override
  LobbyEventDetailState createState() => LobbyEventDetailState();
}

class LobbyEventDetailState extends State<LobbyEventDetail> {
  Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
  bool _isLoading = false;
  bool userIsPremium = false;
  bool userIsLegacy = false;
  bool _darkTheme = false;
  Color _thisPanelColor;

  Container bannerAdContainer = Container();
  bool showBannerAd = true;
  bool adLoaded = false;
  String randomBackgroundImageString =
      'assets/lobbying${random.nextInt(2)}.png';

  LobbyingRepresentation thisLobbyEvent;
  SpecificLobbyResult thisSpecificLobbyEvent;
  // String _thisLobbyEventString;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await setVariables();
      await init();
    });
  }

  Future<void> setVariables() async {
    setState(() {
      userIsPremium = userDatabase.get('userIsPremium');
      userIsLegacy = !userDatabase.get('userIsPremium') &&
          List.from(userDatabase.get('userIdList')).any(
              (element) => element.toString().startsWith(oldUserIdPrefix));
      // thisLobbyEvent = widget.thisLobbyEvent;
      _isLoading = true;
      _thisPanelColor = alertIndicatorColorDarkGreen;
      _darkTheme = userDatabase.get('darkTheme');
      // subscriptionAlertsList =
      //     List.from(userDatabase.get('subscriptionAlertsList'));
    });
  }

  Future<void> init() async {
    if (/*widget.thisLobbyEvent == null && */ widget
        .thisLobbyEventId.isNotEmpty) {
      await PropublicaApi.fetchSingleLobbyEvent(widget.thisLobbyEventId)
          .then((value) => setState(() {
                thisSpecificLobbyEvent = value;
              }));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // ADMOB INFORMATION HERE
    if (!adLoaded && !userIsPremium) {
      final BannerAd thisBanner = AdMobLibrary().defaultBanner();

      thisBanner?.load();

      if (thisBanner != null) {
        // logger.d(
        // '***** This Banner Unit ID: ${thisBanner.adUnitId} - Key Words: ${thisBanner.request.keywords}');
        setState(() {
          adLoaded = true;
          bannerAdContainer =
              AdMobLibrary().bannerContainer(thisBanner, context);
        });

        // logger.d('***** Song Catalog Ad Loaded: ${thisBanner.adUnitId} *****');
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: alertIndicatorColorDarkGreen,
        centerTitle: true,
        title: Text('Lobbying Details',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.bangers(fontSize: 25)),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async => await Messages.shareContent(true))
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: thisSpecificLobbyEvent == null || _isLoading
            ? AnimatedWidgets.circularProgressWatchtower(context, userDatabase, userIsPremium,
                isLobby: true, isFullScreen: true)
            : fetchedEventDetails(
                context,
                userDatabase,
                _darkTheme,
                _thisPanelColor,
                thisSpecificLobbyEvent,
                userIsPremium,
                userIsLegacy,
                randomBackgroundImageString),
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
              SharedWidgets.createdByContainer(
                  context, userIsPremium, userDatabase),
            ],
          ),
        ),
      ),
    );
  }
}

fetchedEventDetails(
    BuildContext context,
    Box userDatabase,
    bool darkTheme,
    Color thisPanelColor,
    SpecificLobbyResult thisSpecificLobbyEvent,
    bool userIsPremium,
    bool userIsLegacy,
    String randomBackgroundImageString) {
  return ValueListenableBuilder(
      valueListenable: Hive.box(appDatabase).listenable(keys: [
        'darkTheme',
        'userIsPremium',
        'userIdList',
        'subscriptionAlertsList'
      ]),
      builder: (context, box, widget) {
        List<String> subscriptionAlertsList =
            List.from(userDatabase.get('subscriptionAlertsList'));
        final String thisLobbyEventString =
            'lobby_${thisSpecificLobbyEvent.id}_${thisSpecificLobbyEvent.lobbyingClient.name}_${thisSpecificLobbyEvent.specificIssues.first}_${thisSpecificLobbyEvent.lobbyingRegistrant.name}_${thisSpecificLobbyEvent.filings.first.filingDate}_lobby';

        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            FadeIn(
              child: Image.asset(randomBackgroundImageString,
                  color: alertIndicatorColorDarkGreen,
                  height: 125,
                  fit: BoxFit.cover,
                  colorBlendMode: BlendMode.softLight),
            ),
            Container(
              margin: const EdgeInsets.all(5.0),
              child: Card(
                elevation: 0.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      color: alertIndicatorColorDarkGreen.withOpacity(0.15),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            // new Expanded(
                            //   child: new
                            Container(
                              margin: const EdgeInsets.all(10.0),
                              child: Text(
                                'Lobbying ID#: ${thisSpecificLobbyEvent.id}',
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            // ),
                            userIsPremium || userIsLegacy
                                ? SizedBox(
                                    height: 20,
                                    child: ElevatedButton.icon(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            alertIndicatorMSPColorDarkGreen,
                                      ),
                                      icon: AnimatedWidgets.flashingEye(
                                          context,
                                          List<String>.from(userDatabase.get(
                                                  'subscriptionAlertsList'))
                                              .any((element) => element
                                                  .toLowerCase()
                                                  .startsWith(
                                                      'lobby_${thisSpecificLobbyEvent.id}'
                                                          .toLowerCase())),
                                          true,
                                          size: 11,
                                          sameColorBright: true),
                                      label: Text(
                                        List<String>.from(userDatabase.get(
                                                    'subscriptionAlertsList'))
                                                .any((element) => element
                                                    .toLowerCase()
                                                    .startsWith(
                                                        'lobby_${thisSpecificLobbyEvent.id}'
                                                            .toLowerCase()))
                                            ? 'ON'
                                            : 'OFF',
                                        style: GoogleFonts.bangers(
                                            color: Colors.white, fontSize: 17),
                                      ),
                                      onPressed: () async {
                                        if (!subscriptionAlertsList.any(
                                            (element) => element
                                                .toLowerCase()
                                                .startsWith(
                                                    'lobby_${thisSpecificLobbyEvent.id}'
                                                        .toLowerCase()))) {
                                          subscriptionAlertsList
                                              .add(thisLobbyEventString);
                                          userDatabase.put(
                                              'subscriptionAlertsList',
                                              subscriptionAlertsList);

                                          // if (!userDatabase
                                          //     .get('lobbyingAlerts'))
                                          //   userDatabase.put(
                                          //       'lobbyingAlerts', true);

                                          await Functions.processCredits(true);

                                          logger.d(
                                              '^^^^^ SUBSCRIPTIONS (add) TO DBASE: ${userDatabase.get('subscriptionAlertsList')} ^^^^^');
                                        } else {
                                          subscriptionAlertsList.removeWhere(
                                              (element) => element
                                                  .toLowerCase()
                                                  .startsWith(
                                                      'lobby_${thisSpecificLobbyEvent.id}'
                                                          .toLowerCase()));
                                          userDatabase.put(
                                              'subscriptionAlertsList',
                                              subscriptionAlertsList);

                                          logger.d(
                                              '^^^^^ SUBSCRIPTIONS (remove) FROM DBASE: ${userDatabase.get('subscriptionAlertsList')} ^^^^^');
                                        }
                                      },
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          // new Padding(
                          //   padding: const EdgeInsets.all(0.0),
                          //   child: new Column(
                          //     children: [
                          //       new GestureDetector(
                          //         // onTap: () {
                          //         // Navigator.push(
                          //         //   context,
                          //         //   MaterialPageRoute(
                          //         //     builder: (context) =>
                          //         //         LobbyEventDetail(
                          //         //             memberId: bill
                          //         //                 .first.sponsorId),
                          //         //   ),
                          //         // );
                          //         // },
                          //         child: new Container(
                          //           height: 85,
                          //           width: 60,
                          //           decoration: BoxDecoration(
                          //             borderRadius:
                          //                 BorderRadius.circular(3),
                          //             image: DecorationImage(
                          //               fit: BoxFit.cover,
                          //               image: AssetImage(
                          //                   'assets/lobbying.png'),
                          //             ),
                          //           ),
                          //           // foregroundDecoration: BoxDecoration(
                          //           //   borderRadius:
                          //           //       BorderRadius.circular(3),
                          //           //   image: DecorationImage(
                          //           //     fit: BoxFit.cover,
                          //           //     image:
                          //           //         NetworkImage(eventImageUrl),
                          //           //   ),
                          //           // ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Expanded(
                            child: Container(
                              color: alertIndicatorColorDarkGreen
                                  .withOpacity(0.15),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    /// CLIENT INFORMATION
                                    thisSpecificLobbyEvent
                                            .lobbyingClient.name.isEmpty
                                        ? const SizedBox.shrink()
                                        : ListTile(
                                            // isThreeLine: true,
                                            dense: true,
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
                                                    0, 0, 0, 0),
                                            enableFeedback: true,
                                            enabled: true,
                                            title: Text(
                                                'Client'.toUpperCase(),
                                                // maxLines: 1,
                                                // overflow: TextOverflow
                                                //     .ellipsis,
                                                style: Styles.regularStyle
                                                    .copyWith(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: darkTheme
                                                      ? null
                                                      : thisPanelColor,
                                                )),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    thisSpecificLobbyEvent.lobbyingClient.name,
                                                    style: Styles.regularStyle
                                                        .copyWith(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                thisSpecificLobbyEvent
                                                        .lobbyingClient
                                                        .generalDescription
                                                        .isEmpty
                                                    ? const SizedBox.shrink()
                                                    : Text(
                                                        thisSpecificLobbyEvent.lobbyingClient.generalDescription,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: Styles
                                                            .regularStyle
                                                            .copyWith(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                              ],
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// REGISTRANT INFORMATION
                          thisSpecificLobbyEvent.lobbyingRegistrant.name.isEmpty
                              ? const SizedBox.shrink()
                              : ListTile(
                                  // isThreeLine: true,
                                  dense: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  enableFeedback: true,
                                  enabled: true,
                                  title: Text('Registrant'.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Styles.regularStyle.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        color:
                                            darkTheme ? null : thisPanelColor,
                                      )),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          thisSpecificLobbyEvent.lobbyingRegistrant.name,
                                          // maxLines: 3,
                                          // overflow: TextOverflow.ellipsis,
                                          style: Styles.regularStyle.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      thisSpecificLobbyEvent.lobbyingRegistrant
                                              .generalDescription.isEmpty
                                          ? const SizedBox.shrink()
                                          : Text(
                                              thisSpecificLobbyEvent.lobbyingRegistrant.generalDescription,
                                              // maxLines: 3,
                                              // overflow: TextOverflow.ellipsis,
                                              style: Styles.regularStyle
                                                  .copyWith(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                    ],
                                  ),
                                ),

                          /// SPECIFIC ISSUES
                          thisSpecificLobbyEvent.specificIssues.isEmpty
                              ? const SizedBox.shrink()
                              : ListTile(
                                  // isThreeLine: true,
                                  dense: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  enableFeedback: true,
                                  enabled: true,
                                  title: Text('Specific Issues'.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Styles.regularStyle.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        color:
                                            darkTheme ? null : thisPanelColor,
                                      )),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        thisSpecificLobbyEvent.specificIssues
                                            .map(
                                              (e) => Text('• $e',
                                                  // maxLines: 3,
                                                  // overflow: TextOverflow.ellipsis,
                                                  style: Styles.regularStyle
                                                      .copyWith(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                            )
                                            .toList(),
                                  )),

                          /// LIST OF LOBBYISTS INFO
                          thisSpecificLobbyEvent.lobbyists.first.name.isEmpty
                              ? const SizedBox.shrink()
                              : ListTile(
                                  // isThreeLine: true,
                                  dense: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  enableFeedback: true,
                                  enabled: true,
                                  title: Text('Lobbyists'.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Styles.regularStyle.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        color:
                                            darkTheme ? null : thisPanelColor,
                                      )),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: thisSpecificLobbyEvent.lobbyists
                                        .map((e) => Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(e.name,
                                                    style: Styles.regularStyle
                                                        .copyWith(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                Wrap(
                                                  children: [
                                                    // SizedBox(width: 3),
                                                    Text(e.coveredPosition,
                                                        style: Styles
                                                            .regularStyle
                                                            .copyWith(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal)),
                                                  ],
                                                ),
                                                const SizedBox(height: 3),
                                              ],
                                            ))
                                        .toList(),
                                  ),
                                ),

                          /// LOBBY IDS
                          ListTile(
                              // isThreeLine: true,
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              enableFeedback: true,
                              enabled: true,
                              title: Text('Lobby Ids'.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Styles.regularStyle.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: darkTheme ? null : thisPanelColor,
                                  )),
                              subtitle: Text(
                                  'Event ID: ${thisSpecificLobbyEvent.id.isEmpty ? 'Not Available' : thisSpecificLobbyEvent.id.toString()}\nHouse ID: ${thisSpecificLobbyEvent.houseId.isEmpty ? 'Not Available' : thisSpecificLobbyEvent.houseId.toString()}\nSenate ID: ${thisSpecificLobbyEvent.senateId.isEmpty ? 'Not Available' : thisSpecificLobbyEvent.senateId.toString()}',
                                  // maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: Styles.regularStyle.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold))),

                          /// EFFECTIVE DATES
                          thisSpecificLobbyEvent.signedDate.isEmpty &&
                                  thisSpecificLobbyEvent.effectiveDate.isEmpty
                              ? const SizedBox.shrink()
                              : ListTile(
                                  // isThreeLine: true,
                                  dense: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  enableFeedback: true,
                                  enabled: true,
                                  title: Text('Effective Dates'.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Styles.regularStyle.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        color:
                                            darkTheme ? null : thisPanelColor,
                                      )),
                                  subtitle: Text(
                                      'Signed: ${thisSpecificLobbyEvent.signedDate.isEmpty ? 'Date Not Available' : thisSpecificLobbyEvent.signedDate.toString()}\nEffective: ${thisSpecificLobbyEvent.effectiveDate.isEmpty ? 'Date Not Available' : thisSpecificLobbyEvent.effectiveDate.toString()}',
                                      // maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: Styles.regularStyle.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold))),

                          /// LATEST FILING INFORMATION
                          ListTile(
                            dense: true,
                            contentPadding:
                                const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            enableFeedback: true,
                            enabled: true,
                            title: Text('Filings'.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Styles.regularStyle.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: darkTheme ? null : thisPanelColor,
                                )),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: thisSpecificLobbyEvent.filings
                                  .map((thisFiling) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2),
                                        child: InkWell(
                                          onTap: () => Functions.linkLaunch(
                                              context,
                                              thisFiling.pdfUrl,
                                              userDatabase,
                                              userIsPremium,
                                              appBarTitle:
                                                  'Lobbying #${thisSpecificLobbyEvent.id}',
                                              source: 'lobby',
                                              isPdf: false),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  '• Date: ${dateWithDayFormatter.format(thisFiling.filingDate)} - ${thisFiling.reportType} - ${thisFiling.reportYear}',
                                                  style: Styles.regularStyle
                                                      .copyWith(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                              FaIcon(
                                                  FontAwesomeIcons
                                                      .solidFileLines,
                                                  size: 10,
                                                  color: thisPanelColor)
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      });
}
