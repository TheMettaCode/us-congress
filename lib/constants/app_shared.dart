import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'package:purchases_flutter/models/store_product_wrapper.dart';

import '../app_user/user_profile.dart';
import '../models/bill_recent_payload_model.dart';
import '../models/floor_action_model.dart';
import '../models/lobby_event_model.dart';
import '../models/member_payload_model.dart';
import '../models/news_article_model.dart';
import '../models/statements_model.dart';
import '../models/vote_payload_model.dart';
import '../models/private_funded_trips_model.dart';
import '../services/congress_stock_watch/house_stock_watch_model.dart';
import '../services/congress_stock_watch/market_activity_model.dart';
import '../services/congress_stock_watch/senate_stock_watch_model.dart';
import '../services/ecwid/ecwid_store_model.dart';
import '../services/github/usc_app_data_model.dart';
import '../services/stripe/stripe_models/charge.dart';
import '../services/stripe/stripe_models/customer.dart';
import '../services/stripe/stripe_models/invoice.dart';
import '../services/stripe/stripe_models/product.dart';
import '../services/youtube/top_congressional_videos.dart';
import 'constants.dart';
import '../models/order_detail.dart';

class SharedFunctions {
  /// CONVERTS STRIPE METADATA PRICE STRING TO DOUBLE WITH 2 SIGNIFICANT PLACES
  static String stripeAmountToDouble(String stripeAmountString) {
    double stripeAmountWithDecimal =
        double.parse(stripeAmountString.trim()) / 100;
    return stripeAmountWithDecimal.toStringAsFixed(2);
  }
}

/// USER DATABASE MODEL
class UserDatabase {
  UserDatabase({
    @required this.userIdList,
    @required this.appUpdatesList,
    @required this.lastRefresh,
    @required this.userProfile,
    @required this.userEmailList,
    @required this.userIsPremium,
    @required this.devLegacyCode,
    @required this.devPremiumCode,
    @required this.devUpgraded,
    @required this.stripeTestMode,
    @required this.googleTestMode,
    @required this.amazonTestMode,
    @required this.freeTrialStartDate,
    @required this.freeTrialUsed,
    @required this.freeTrialDismissed,
    @required this.freeTrialCode,
    @required this.usageInfo,
    @required this.usageInfoSelected,
    @required this.appRated,
    @required this.interstitialAdId,
    @required this.interstitialAdIsNew,
    @required this.interstitialAdCount,
    @required this.rewardedAdId,
    @required this.rewardedAdIsNew,
    @required this.rewardedAdCount,
    @required this.adShowAttempts,
    @required this.temporaryCredits,
    @required this.supportCredits,
    @required this.purchasedCredits,
    @required this.appOpens,
    @required this.backgroundFetches,
    @required this.lastPromoNotification,
    @required this.githubData,
    @required this.lastGithubPromoNotificationsRefresh,
    @required this.capitolBabbleNotificationsList,
    @required this.lastCapitolBabble,
    @required this.darkTheme,
    @required this.onboarding,
    @required this.installerStore,
    @required this.rcIapAvailable,
    @required this.revenueCatCustomer,
    @required this.lastRevenueCatCustomerRefresh,
    @required this.stripeCustomer,
    @required this.lastStripeCustomerRefresh,
    @required this.stripeProductsList,
    @required this.lastStripeProductsRefresh,
    @required this.lastStripeSearchInvoicesList,
    @required this.stripeChargesList,
    @required this.packageInfo,
    @required this.deviceInfo,
    @required this.locationInfo,
    @required this.currentLocation,
    @required this.userAddress,
    @required this.representativesMap,
    @required this.representativesLocation,
    @required this.congress,
    @required this.houseMembersList,
    @required this.senateMembersList,
    @required this.memberAlerts,
    // @required this.memberResponse,
    @required this.lastMembersRefresh,
    @required this.subscriptionAlertsList,
    @required this.subscriptionAlertsListBackup,
    @required this.lobbyingAlerts,
    @required this.lobbyingEventsList,
    @required this.lastLobbyingRefresh,
    @required this.newLobbies,
    @required this.privateFundedTripsAlerts,
    @required this.privateFundedTripsList,
    @required this.lastPrivateFundedTrip,
    @required this.lastPrivateFundedTripsRefresh,
    @required this.newTrips,
    @required this.stockWatchAlerts,
    @required this.houseStockWatchList,
    @required this.lastHouseStockWatchItem,
    @required this.lastHouseStockWatchListRefresh,
    @required this.newHouseStock,
    @required this.senateStockWatchList,
    @required this.lastSenateStockWatchItem,
    @required this.lastSenateStockWatchListRefresh,
    @required this.newSenateStock,
    @required this.houseStockMarketActivityList,
    @required this.senateStockMarketActivityList,
    @required this.marketActivityOverview,
    @required this.newMarketOverview,
    @required this.lastMarketOverviewRefresh,
    @required this.floorAlerts,
    @required this.houseFloorActions,
    @required this.senateFloorActions,
    @required this.lastHouseFloorRefresh,
    @required this.lastSenateFloorRefresh,
    @required this.newHouseFloor,
    @required this.newSenateFloor,
    @required this.billAlerts,
    @required this.recentBills,
    @required this.lastBill,
    @required this.lastBillsRefresh,
    @required this.newBills,
    @required this.voteAlerts,
    @required this.recentVotes,
    @required this.lastVote,
    @required this.lastVotesRefresh,
    @required this.newVotes,
    @required this.statementAlerts,
    @required this.statementsResponse,
    @required this.lastStatement,
    @required this.lastStatementsRefresh,
    @required this.newStatements,
    @required this.newsAlerts,
    @required this.newsArticles,
    @required this.lastNewsArticlesRefresh,
    @required this.newNewsArticles,
    @required this.videoAlerts,
    @required this.youtubeVideosList,
    @required this.lastVideosRefresh,
    @required this.newVideos,
    @required this.ecwidProducts,
    @required this.newProductAlerts,
    @required this.newEcwidProducts,
    @required this.lastEcwidProductsRefresh,
    @required this.ecwidProductOrdersList,
  });

  final List<String> userIdList;
  final List<String> appUpdatesList;
  final String lastRefresh;
  final UserProfile userProfile;
  final List<String> userEmailList;
  final bool userIsPremium;
  final String devLegacyCode;
  final String devPremiumCode;
  final bool devUpgraded;
  final bool stripeTestMode;
  final bool googleTestMode;
  final bool amazonTestMode;
  final String freeTrialStartDate;
  final bool freeTrialUsed;
  final bool freeTrialDismissed;
  final String freeTrialCode;
  final bool usageInfo;
  final bool usageInfoSelected;
  final bool appRated;
  final String interstitialAdId;
  final bool interstitialAdIsNew;
  final int interstitialAdCount;
  final String rewardedAdId;
  final bool rewardedAdIsNew;
  final int rewardedAdCount;
  final int adShowAttempts;
  final int temporaryCredits;
  final int supportCredits;
  final int purchasedCredits;
  final int appOpens;
  final int backgroundFetches;
  final String lastPromoNotification;
  final GithubData githubData;
  final String lastGithubPromoNotificationsRefresh;
  final List<String> capitolBabbleNotificationsList;
  final String lastCapitolBabble;
  final bool darkTheme;
  final bool onboarding;
  final String installerStore;
  final bool rcIapAvailable;
  final CustomerInfo revenueCatCustomer;
  final String lastRevenueCatCustomerRefresh;
  final StripeCustomer stripeCustomer;
  final String lastStripeCustomerRefresh;
  final StripeProductsList stripeProductsList;
  final String lastStripeProductsRefresh;
  final StripeInvoiceSearch lastStripeSearchInvoicesList;
  final StripeCharge stripeChargesList;
  final UserPackageInfo packageInfo;
  final UserDeviceInfo deviceInfo;
  final UserLocationInfo locationInfo;
  final UserAddress currentLocation;
  final UserAddress userAddress;
  final Map<String, dynamic> representativesMap;
  final UserAddress representativesLocation;
  final int congress;
  final MemberPayload houseMembersList;
  final MemberPayload senateMembersList;
  final bool memberAlerts;
  // final Response memberResponse;
  final String lastMembersRefresh;
  final List<String> subscriptionAlertsList;
  final List<String> subscriptionAlertsListBackup;
  final bool lobbyingAlerts;
  final LobbyEvent lobbyingEventsList;
  final String lastLobbyingRefresh;
  final bool newLobbies;
  final bool privateFundedTripsAlerts;
  final PrivateFundedTrip privateFundedTripsList;
  final String lastPrivateFundedTrip;
  final String lastPrivateFundedTripsRefresh;
  final bool newTrips;
  final bool stockWatchAlerts;
  final List<HouseStockWatch> houseStockWatchList;
  final String lastHouseStockWatchItem;
  final String lastHouseStockWatchListRefresh;
  final bool newHouseStock;
  final List<SenateStockWatch> senateStockWatchList;
  final String lastSenateStockWatchItem;
  final String lastSenateStockWatchListRefresh;
  final bool newSenateStock;
  final List<MarketActivity> houseStockMarketActivityList;
  final List<MarketActivity> senateStockMarketActivityList;
  final MarketActivity marketActivityOverview;
  final bool newMarketOverview;
  final String lastMarketOverviewRefresh;
  final bool floorAlerts;
  final CongressFloorAction houseFloorActions;
  final CongressFloorAction senateFloorActions;
  final String lastHouseFloorRefresh;
  final String lastSenateFloorRefresh;
  final bool newHouseFloor;
  final bool newSenateFloor;
  final bool billAlerts;
  final RecentBills recentBills;
  final String lastBill;
  final String lastBillsRefresh;
  final bool newBills;
  final bool voteAlerts;
  final RecentVotes recentVotes;
  final String lastVote;
  final String lastVotesRefresh;
  final bool newVotes;
  final bool statementAlerts;
  final Statements statementsResponse;
  final String lastStatement;
  final String lastStatementsRefresh;
  final bool newStatements;
  final bool newsAlerts;
  final List<NewsArticle> newsArticles;
  final String lastNewsArticlesRefresh;
  final bool newNewsArticles;
  final bool videoAlerts;
  final TopCongressionalVideos youtubeVideosList;
  final String lastVideosRefresh;
  final bool newVideos;
  final EcwidStore ecwidProducts;
  final bool newProductAlerts;
  final bool newEcwidProducts;
  final String lastEcwidProductsRefresh;
  final List<Order> ecwidProductOrdersList;

  // factory UserDatabase.fromJson(Map<String, dynamic> json) => UserDatabase();
  //
  // Map<String, dynamic> toJson() => {
  //   "street": street,
  //   "city": city,
  //   "state": state,
  //   "country": country,
  //   "zip": zip,
  //   "latitude": latitude.toString(),
  //   "longitude": longitude.toString(),
  // };
}
