import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'dart:math';

var logger = Logger();
var loggerNoStack = Logger(printer: PrettyPrinter(colors: true, printEmojis: true, methodCount: 0));

/// DATE-TIME FORMATTING
final DateFormat formatter = DateFormat.yMEd();
final DateFormat timeFormatter = DateFormat('h:mm a');
final DateFormat localTimeFormatter = DateFormat.jm();
final DateFormat dateWithTimeFormatter = DateFormat('E, M/d h:mm a');
final DateFormat dateWithTimeOnlyFormatter = DateFormat('E, M/d h:mm');
final DateFormat dateWithTimeAndSecondsFormatter = DateFormat('E, M/d h:mm:ss a');
final DateFormat dateWithDayFormatter = DateFormat('E, M/d');
final DateFormat dateWithDayAndYearFormatter = DateFormat('E, M/d/y');
final DateFormat dateFormatter = DateFormat('M/d');
final NumberFormat formatCurrency = NumberFormat.simpleCurrency();

/// MATH
final Random random = Random();
const int newUserThreshold = 3;

/// App Constants
const String appTitle = 'US Congress';
// const String appDatabaseName = 'congress.db';
const String appDatabase = 'congress';
// const String appDatabaseTableName = 'congress';
const String googleAppLink = 'https://play.google.com/store/apps/details?id=com.uscongress.watch';
const String samsungAppLink = 'https://galaxy.store/congress';
const String amazonAppLink = 'https://www.amazon.com/gp/product/B0B2ZBYTB7';
const String appWebLink = 'https://us-congress.app';
const String appShare = 'Check out this $appTitle app. I thought you might be interested.\n'
    'Google Play App Store: $googleAppLink\n'
    // 'Samsung Galaxy App Store: $samsungAppLink\n'
    // 'Amazon App Store: $amazonAppLink'
    ;
const String appSupportEmail = 'mettacode@gmail.com';
const String appGitHubUrl = 'https://github.com/TheMettaCode/us_congress_web';

const double ecwidProductCreditMultiplier = 100.65;
const int maxEcwidProductCount = 1000;
const int capitolBabbleDelayMinutes = 20;

/// PEAK WEEKDAY TIME RANGE [8am CT - 12pm CT] && [3pm CT - 6pm CT]
bool isPeakCapitolBabblePostHours = (((DateTime.now().toUtc().hour >= 13 &&
            //     DateTime.now().toUtc().hour <= 17) ||
            // (DateTime.now().toUtc().hour >= 20 &&
            DateTime.now().toUtc().hour <= 23)) &&
        DateTime.now().toUtc().weekday != DateTime.saturday &&
        DateTime.now().toUtc().weekday != DateTime.sunday) ||

    /// PEAK SATURDAY TIME RANGE [10am CT - 12pm CT] && [3pm CT - 6pm CT]
    (((DateTime.now().toUtc().hour >= 15 &&
            //     DateTime.now().toUtc().hour <= 17) ||
            // (DateTime.now().toUtc().hour >= 20 &&
            DateTime.now().toUtc().hour <= 23)) &&
        DateTime.now().toUtc().weekday == DateTime.saturday) ||

    /// PEAK SUNDAY TIME RANGE [3pm CT - 6pm CT]
    (DateTime.now().toUtc().hour >= 20 &&
        DateTime.now().toUtc().hour <= 23 &&
        DateTime.now().toUtc().weekday == DateTime.sunday);

bool isCongressFloorActive =
    DateTime.now().weekday != DateTime.saturday && DateTime.now().weekday != DateTime.sunday;

const List<String> wordsToHash = [
  "Abortion",
  "abuse",
  "Afghanistan",
  "Agriculture",
  "Alcohol",
  "Amendment",
  "America",
  "American",
  "Americans",
  "bailout",
  "bicameral",
  "Biden",
  "Big Tech",
  "Big Pharma",
  "binary",
  "non binary",
  "Bitcoin",
  "border",
  "children",
  "China",
  "CIA",
  "Circuit Judge",
  "Civil Rights",
  "Congress",
  "Constitution",
  "conservative",
  "commerce",
  "commercial",
  "commodities",
  "corruption",
  "coupon",
  "crime",
  "Crypto",
  "Cryptocurrency",
  "Cyber Security",
  "debate",
  "debt",
  "DHS",
  "Democrat",
  "Democratic",
  "Democrats",
  "Democracy",
  "Dems",
  "discount",
  "domestic",
  "drug",
  "Emergency",
  "Election",
  "economy",
  "economic",
  "energy",
  "executive",
  "far left",
  "far right",
  "First Amendment",
  "Federal Reserve",
  "finance",
  "Federal",
  "FEMA",
  "FBI",
  "gay",
  "gender",
  "gender fluid",
  "Google",
  "google play",
  "Governor",
  "gender",
  "General Election",
  "Government",
  "GOP",
  "gun",
  "guns",
  "healthcare",
  "Homeland Security",
  "House",
  "Hunter Biden",
  "Infrastructure",
  "illegal",
  "immigration",
  "inflation",
  "insider trading",
  "Iran",
  "IRS",
  "Israel",
  "International",
  "Intelligence Agency",
  "Judge",
  "Justice",
  "Judicial",
  "labor",
  "Law",
  "Law and Order",
  "Legislature",
  "Legislative",
  "lobby",
  "lobbying",
  "left wing",
  "lesbian",
  "liberal",
  "MAGA",
  "manufacturing",
  "Mayor",
  "medicare",
  "men",
  "middle class",
  "Midterms",
  "Midterm Election",
  "Military",
  "my body my choice",
  "my money my choice",
  "NOW AVAILABLE",
  "NASDAQ",
  "NYSE",
  "Nuclear",
  "Natural Gas",
  "National Defense",
  "National Security",
  "nonpartisan",
  "NSA",
  "Oil",
  "On Sale",
  "partisan",
  "Palestine",
  "Pandemic",
  "Pelosi",
  "pharmaceutical",
  "police",
  "poor",
  "power",
  "President",
  "Press Secretary",
  "prison",
  "Primaries",
  "Primary Election",
  "probation",
  "parole",
  "POTUS",
  "purchase",
  "refugee",
  "Republic",
  "Republican",
  "Republicans",
  "rich",
  "right to bear arms",
  "rights",
  "right wing",
  "RollCall",
  "Russia",
  "Second Amendment",
  "stimulus",
  "Social Security",
  "Senate",
  "sex",
  "semiconductor",
  "Speaker of the House",
  "substance abuse",
  "sustainable",
  "Supreme Court",
  "SCOTUS",
  "STFU",
  "stocks",
  "Stock Market",
  "Taiwan",
  "Tax",
  "Taxes",
  "Tech",
  "Technology",
  "Trump",
  "Trade",
  "trading",
  "trafficking",
  "trans",
  "United States",
  "USA",
  "Ukraine",
  "Unemployment",
  "US Border",
  "Veteran",
  "Veterans",
  "Veterans Day",
  "Vice President",
  "VPOTUS",
  "Vote",
  "White House",
  "War",
  "women",
  "World",
  "World War"
];

/// YOUTUBE
const String playlistId = 'PLhVgsjve2unNn2NgCKW0uMjgde8L20Hnb';

/// ADSENSE CONSTANTS
const String adSenseClientId = 'ca-pub-9188084311019420';

/// ADMOB DATAApp Open	ca-app-pub-3940256099942544/3419835294
const int adChanceToShowThreshold = 3000;
const String appId = 'ca-app-pub-3834929667159972~4799960334';
const String defaultBannerId = 'ca-app-pub-3834929667159972/8034011226';
const String rewardedAdId = 'ca-app-pub-3834929667159972/5759618902';
const String interstitialAdId = 'ca-app-pub-3834929667159972/9786327541';

const List<String> adMobKeyWords = [
  'united states',
  'government',
  'voting',
  'law',
  'bills',
  'independent',
  'republican',
  'democrat',
  'congress',
  'white house',
  'judiciary',
  'supreme court',
  'president',
  'vice president',
  'speaker of the house',
  'international',
  'world',
  'potus',
  'capitol hill'
];

/// FREE PREMIUM DAYS CONSTANTS
int freePremiumDaysStartDay = 1;
int freePremiumDaysEndDay = 6;
bool freePremiumDaysActive =
    DateTime.now().day >= freePremiumDaysStartDay && DateTime.now().day < freePremiumDaysEndDay;
// &&  DateTime.now().month % 3 == 0;
int freeTrialPromoDurationDays = 5;

String oldUserIdPrefix = 'user<|:|>';
String oldUserIDTag =
    "$oldUserIdPrefix${DateTime.now().year.toString().padLeft(2, '0')}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}${DateTime.now().hour.toString().padLeft(2, '0')}${DateTime.now().minute.toString().padLeft(2, '0')}${DateTime.now().second.toString().padLeft(2, '0')}<|:|>${DateTime.now().toString()}";
String newUserIdPrefix = 'newUser<|:|>';
Map<String, dynamic> initialUserData = {
  "userIdList": [
    "$newUserIdPrefix${DateTime.now().year.toString().padLeft(2, '0')}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}${DateTime.now().hour.toString().padLeft(2, '0')}${DateTime.now().minute.toString().padLeft(2, '0')}${DateTime.now().second.toString().padLeft(2, '0')}<|:|>${DateTime.now().toString()}"
  ],
  "appUpdatesList": [
    //   "Premium Days<|:|>Get 5 days of free premium status during \'Premium Days\' with all features activated!<|:|>high",
    "Data Security<|:|>Updates to app code to further protect user data and security<|:|>high",
    // "App Merch Shop Is Open!<|:|>All users can now begin using their points to shop for cool app merchandise. We'll be adding many more products and streamlining the process as we go! (Currently only available in the US and US Territories)\nA few quick ways to accrue points?\n- Share the app with friends, family and colleagues\n- Rating the app from the 'Support' menu\n- Or just purchase them directly when prompted!<|:|>normal",
    // "Top News<|:|>Now users can keep track of the latest US Congress news from around the world.<|:|>medium",
    "App Security<|:|>Minor updates for continued data security<|:|>normal",
    "User Interface<|:|>Minor user interface adjustments<|:|>normal",
    "Miscellaneous<|:|>Minor code upgrades and bug fixes. Earn credits for pointing them out to us!<|:|>normal",
  ],
  "userEmailList": [],
  "userIsPremium": false,
  "userIsSubscribed": false,
  "devLegacyCode": "DLC${random.nextInt(900000) + 100000}",
  "devPremiumCode": "DPC${random.nextInt(900000) + 100000}",
  "devUpgraded": false,
  "freeTrialStartDate": "${DateTime.now()}",
  "freeTrialUsed": false,
  "freeTrialDismissed": false,
  "freeTrialCode": "FTC${random.nextInt(900000) + 100000}",
  "usageInfo": false,
  "usageInfoSelected": false,
  "appRated": false,
  "interstitialAdId": "",
  "interstitialAdIsNew": false,
  "interstitialAdCount": 0,
  "rewardedAdId": "",
  "rewardedAdIsNew": false,
  "rewardedAdCount": 0,
  "adShowAttempts":0,
  "credits": 0,
  "permCredits": 100,
  "purchCredits": 0,
  "appOpens": 0,
  "backgroundFetches": 0,
  "lastPromoNotification": "${DateTime.now()}",
  "githubData": {},
  "lastGithubPromoNotificationsRefresh": "${DateTime.now()}",
  "lastRefresh": "${DateTime.now()}",
  "capitolBabbleNotificationsList": [],
  "lastCapitolBabble": "${DateTime.now()}",
  "darkTheme": false,
  "onboarding": true,
  "packageInfo": {},
  "deviceInfo": {},
  "locationData": {},
  "currentAddress": {"street": "", "city": "", "state": "", "country": "", "zip": ""},
  "representativesMap": {},
  "representativesLocation": {"city": "", "state": "", "country": "", "zip": ""},
  "congress": 117,
  "houseMembersList": {},
  "senateMembersList": {},
  "memberAlerts": false,
  "memberResponse": {},
  "lastMembersRefresh": "${DateTime.now()}",
  // "notificationsList": [],
  "subscriptionAlertsList": [],
  "subscriptionAlertsListBackup": [],
  "lobbyingAlerts": false,
  "lobbyingEventsList": {},
  "lastLobby": "",
  "lastLobbyingRefresh": "${DateTime.now()}",
  "newLobbies": false,
  "privateFundedTripsAlerts": false,
  "privateFundedTripsList": {},
  "lastPrivateFundedTrip": "",
  "lastPrivateFundedTripsRefresh": "${DateTime.now()}",
  "newTrips": false,
  "stockWatchAlerts": false,
  "houseStockWatchList": [],
  "lastHouseStockWatchItem": "",
  "lastHouseStockWatchListRefresh": "${DateTime.now()}",
  "newHouseStock": false,
  "senateStockWatchList": [],
  "lastSenateStockWatchItem": "",
  "lastSenateStockWatchListRefresh": "${DateTime.now()}",
  "newSenateStock": false,
  "houseStockMarketActivityList": [],
  "senateStockMarketActivityList": [],
  "marketActivityOverview": {},
  "newMarketOverview": true,
  "lastMarketOverviewRefresh": "${DateTime.now()}",
  "floorAlerts": true,
  "houseFloorActions": {},
  "senateFloorActions": {},
  "lastHouseFloorRefresh": "${DateTime.now()}",
  "lastSenateFloorRefresh": "${DateTime.now()}",
  "newHouseFloor": false,
  "newSenateFloor": false,
  "billAlerts": true,
  "recentBills": {},
  "lastBill": "",
  "lastBillsRefresh": "${DateTime.now()}",
  "newBills": false,
  "voteAlerts": true,
  "recentVotes": {},
  "lastVote": "",
  "lastVotesRefresh": "${DateTime.now()}",
  "newVotes": false,
  "statementAlerts": true,
  "statementsResponse": {},
  "lastStatement": "",
  "lastStatementsRefresh": "${DateTime.now()}",
  "newStatements": false,
  "newsAlerts": true,
  "newsArticles": {},
  "lastNewsArticlesRefresh": "${DateTime.now()}",
  "newNewsArticles": false,
  "videoAlerts": true,
  // "youTubePlaylist": {},
  // "youtubeVideoIds": [],
  "youtubeVideosList":{},
  "lastVideosRefresh": "${DateTime.now()}",
  "newVideos": false,
  "ecwidProducts": {},
  "newProductAlerts": true,
  "newEcwidProducts": false,
  "lastEcwidProductsRefresh": "${DateTime.now()}",
  "ecwidProductOrdersList": {},
};

Map<String, String> statesMap = {
  "AL": "Alabama",
  "AK": "Alaska",
  "AS": "American Samoa",
  "AZ": "Arizona",
  "AR": "Arkansas",
  "CA": "California",
  "CO": "Colorado",
  "CT": "Connecticut",
  "DE": "Delaware",
  "DC": "District Of Columbia",
  "FM": "Federated States Of Micronesia",
  "FL": "Florida",
  "GA": "Georgia",
  "GU": "Guam",
  "HI": "Hawaii",
  "ID": "Idaho",
  "IL": "Illinois",
  "IN": "Indiana",
  "IA": "Iowa",
  "KS": "Kansas",
  "KY": "Kentucky",
  "LA": "Louisiana",
  "ME": "Maine",
  "MH": "Marshall Islands",
  "MD": "Maryland",
  "MA": "Massachusetts",
  "MI": "Michigan",
  "MN": "Minnesota",
  "MS": "Mississippi",
  "MO": "Missouri",
  "MT": "Montana",
  "NE": "Nebraska",
  "NV": "Nevada",
  "NH": "New Hampshire",
  "NJ": "New Jersey",
  "NM": "New Mexico",
  "NY": "New York",
  "NC": "North Carolina",
  "ND": "North Dakota",
  "MP": "Northern Mariana Islands",
  "OH": "Ohio",
  "OK": "Oklahoma",
  "OR": "Oregon",
  "PW": "Palau",
  "PA": "Pennsylvania",
  "PR": "Puerto Rico",
  "RI": "Rhode Island",
  "SC": "South Carolina",
  "SD": "South Dakota",
  "TN": "Tennessee",
  "TX": "Texas",
  "UT": "Utah",
  "VT": "Vermont",
  "VI": "Virgin Islands",
  "VA": "Virginia",
  "WA": "Washington",
  "WV": "West Virginia",
  "WI": "Wisconsin",
  "WY": "Wyoming"
};

// List<PlaylistItem> youTubePlaylistPlaceholder = [
//   PlaylistItem.fromJson({
//     "kind": "youtube#playlistItem",
//     "etag": "yijyoLB5klBdgU9hbCX9lancO8Y",
//     "id": "UExoVmdzanZlMnVuTm4yTmdDS1cwdU1qZ2RlOEwyMEhuYi41Mzk2QTAxMTkzNDk4MDhF",
//     "snippet": {
//       "publishedAt": "2021-11-20T00:45:32Z",
//       "channelId": "UCUrW7YMZDBaVMjP7V3XnpVw",
//       "title": "Wages Must Rise to Fight Inflation says U.S. Labor Chief",
//       "description":
//           "U.S. Labor Secretary Marty Walsh tells David Westin that higher-paying jobs are the key to fighting inflation. He also talks about his upcoming trip to Los Angeles, where he's going to speak to truck drivers in an effort to resolve the supply-chain crisis. \n --------\nFollow Bloomberg for business news & analysis, up-to-the-minute market data, features, profiles and more: http://www.bloomberg.com\nConnect with us on...\nTwitter: https://twitter.com/business\nFacebook: https://www.facebook.com/bloombergbusiness\nInstagram: https://www.instagram.com/bloombergbusiness/",
//       "thumbnails": {
//         "default": {
//           "url": "https://i.ytimg.com/vi/Zlc-Sg5ql_A/default.jpg",
//           "width": 120,
//           "height": 90
//         },
//         "medium": {
//           "url": "https://i.ytimg.com/vi/Zlc-Sg5ql_A/mqdefault.jpg",
//           "width": 320,
//           "height": 180
//         },
//         "high": {
//           "url": "https://i.ytimg.com/vi/Zlc-Sg5ql_A/hqdefault.jpg",
//           "width": 480,
//           "height": 360
//         },
//         "standard": {
//           "url": "https://i.ytimg.com/vi/Zlc-Sg5ql_A/sddefault.jpg",
//           "width": 640,
//           "height": 480
//         },
//         "maxres": {
//           "url": "https://i.ytimg.com/vi/Zlc-Sg5ql_A/maxresdefault.jpg",
//           "width": 1280,
//           "height": 720
//         }
//       },
//       "channelTitle": "MettaCode Developers",
//       "playlistId": "PLhVgsjve2unNn2NgCKW0uMjgde8L20Hnb",
//       "position": 4,
//       "resourceId": {"kind": "youtube#video", "videoId": "Zlc-Sg5ql_A"},
//       "videoOwnerChannelTitle": "Bloomberg Politics",
//       "videoOwnerChannelId": "UCV61VqLMr2eIhH4f51PV0gA"
//     }
//   })
// ];

// List<GithubNotifications> githubNotificationsPlaceholder = [
//   GithubNotifications(
//       startDate: DateTime.now(),
//       expirationDate: DateTime.now().add(const Duration(minutes: 30)),
//       title: 'ERROR: No Notifications To List',
//       message: 'There are no notifications to list at this time',
//       priority: 0,
//       userLevels: ["developer", "premium", "legacy", "free"],
//       url: "",
//       icon: "",
//       supportOption: false,
//       additionalData: "place-holder")
// ];

// FloorActions initialFloorActions = FloorActions.fromJson({
//   "status": "OK",
//   "copyright": " Copyright (c) 2017 ProPublica Inc. All Rights Reserved.",
//   "results": [
//     {
//       "chamber": "Senate",
//       "num_results": 19,
//       "offset": 0,
//       "floor_actions": [
//         {
//           "congress": "115",
//           "chamber": "Senate",
//           "timestamp": "2017-05-02 14:06:19 -0400",
//           "date": "2017-05-02",
//           "action_id": "",
//           "description": "The Senate adjourned at 5:59 PM.",
//           "bill_ids": []
//         },
//         {
//           "congress": "115",
//           "chamber": "Senate",
//           "timestamp": "2017-05-02 05:54:21 -0400",
//           "date": "2017-05-02",
//           "action_id": "",
//           "description":
//               "The Senate will convene at 10:00 AM. Following Leader remarks, the Senate will proceed to Executive Session to resume consideration of Cal. #36, Jay Clayton, of New York, to be a Member of the Securities and Exchange Commission. The Senate will recess from 12:30 PM until 2:15 PM for the weekly party caucus luncheons.",
//           "bill_ids": []
//         }
//       ]
//     }
//   ]
// });
