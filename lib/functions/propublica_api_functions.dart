import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:congress_watcher/constants/constants.dart';
import 'package:congress_watcher/models/bill_payload_model.dart';
import 'package:congress_watcher/models/bill_search_model.dart';
import 'package:congress_watcher/models/lobby_event_specific_model.dart';
import 'package:congress_watcher/models/lobby_search_model.dart';
import 'package:congress_watcher/models/members_model.dart';
import 'package:congress_watcher/models/office_expenses_member.dart';
import 'package:congress_watcher/models/private_funded_trips_by_member_model.dart';

class PropublicaApi {
  var apiHeaders = <String, String>{
    'X-API-Key': dotenv.env["PropublicaApiKey"]
  };
  String authority = 'api.propublica.org';
  String memberStatementsApi = 'congress/v1/statements/latest.json';
  String recentChamberVotesApi = 'congress/v/both/votes/recent.json';
  String senateFloorUpdatesApi = 'congress/v1/senate/floor_updates.json';
  String houseFloorUpdatesApi = 'congress/v1/house/floor_updates.json';
  String billSearchApi = 'congress/v1/bills/search.json';
  String memberDetailsApi = 'congress/v1/members/';
  String memberImageRootUrl = 'https://www.congress.gov/img/member/';
  String lobbyingSearchApi = 'congress/v1/lobbying/search.json';
  String latestLobbyingApi = 'congress/v1/lobbying/latest.json';

  static Future<List<MemberResult>> fetchMember(memberId) async {
    if (memberId != null && memberId != '') {
      final authority = PropublicaApi().authority;
      final url = '${PropublicaApi().memberDetailsApi + memberId}.json';
      final headers = PropublicaApi().apiHeaders;

      final response =
          await http.get(Uri.https(authority, url), headers: headers);

      if (response.statusCode == 200) {
        Members members = membersFromJson(response.body);
        if (members.status == 'OK') {
          logger.d('Member Details ${members.status}');
          return members.results;
        } else {
          return [];
        }
      } else {
        logger.d('${response.statusCode}');
        throw Exception('Failed to load Data');
      }
    } else {
      throw Exception('URI is null');
    }
  }

  static Future<List<LobbyingSearchRepresentation>> fetchLobbying(
      queryString) async {
    // final String queryString = widget.lobbyingSearchString.toLowerCase().trim();

    logger.d('***** Query String: $queryString *****');

    final url = PropublicaApi().lobbyingSearchApi;
    final queryParameters = {
      'query': queryString,
      // 'param2': 'two',
    };
    final headers = PropublicaApi().apiHeaders;
    final authority = PropublicaApi().authority;
    final response = await http.get(Uri.https(authority, url, queryParameters),
        headers: headers);

    if (response.statusCode == 200) {
      logger.d('***** Lobbying Query String: $queryString *****');
      LobbyingSearch lobbyingSearch = lobbyingSearchFromJson(response.body);
      if (lobbyingSearch.status == 'OK') {
        logger.d('Search ${lobbyingSearch.status}');
        logger.d(lobbyingSearch.results.first.lobbyingRepresentations.length
            .toString());
        List<LobbyingSearchRepresentation> lobbyingSearchRepresentation =
            lobbyingSearch.results.first.lobbyingRepresentations;
        logger.d(
            '***** Lobbying: ${lobbyingSearchRepresentation.map((e) => e.id)} *****');

        lobbyingSearchRepresentation
            .sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));

        // lobbyingSearchList = lobbyingSearchRepresentation;

        return lobbyingSearchRepresentation;
      } else {
        return [];
      }
    } else {
      // logger.d(response.statusCode);
      throw Exception('Failed to load Data');
    }
  }

  static Future<SpecificLobbyResult> fetchSingleLobbyEvent(
      String lobbyId) async {
    logger.d('^^^^^ FETCHING LOBBY DATA... ^^^^^');

    SpecificLobbyResult localThisSpecificLobbyEvent;

    final localUrl = 'congress/v1/lobbying/$lobbyId.json';
    final localHeaders = PropublicaApi().apiHeaders;
    final authority = PropublicaApi().authority;
    final response =
        await http.get(Uri.https(authority, localUrl), headers: localHeaders);

    logger.d(
        '^^^^^ LOBBY DATA RESPONSE STATUS CODE: ${response.statusCode} ^^^^^');

    if (response.statusCode == 200) {
      SpecificLobbyingEvent specificLobbyingEvent =
          specificLobbyingEventFromJson(response.body);

      if (specificLobbyingEvent.status == 'OK') {
        logger.d(
            '^^^^^ LOBBY DATA RESPONSE STATUS: ${specificLobbyingEvent.status} ^^^^^');
        localThisSpecificLobbyEvent = specificLobbyingEvent.results.first;

        return localThisSpecificLobbyEvent;
      } else {
        logger.w(
            'ERROR: API RETURNED STATUS CODE ${specificLobbyingEvent.status}');
        return null;
      }
    } else {
      logger.w(
          'ERROR: API RETURNED RESPONSE CODE ${response.statusCode} ${response.reasonPhrase}');
      return null;
    }
  }

  static Future<List<Bill>> fetchBills(queryString) async {
    final url = PropublicaApi().billSearchApi;
    final queryParameters = {
      'query': queryString,
    };
    final headers = PropublicaApi().apiHeaders;
    final authority = PropublicaApi().authority;
    final response = await http.get(Uri.https(authority, url, queryParameters),
        headers: headers);

    if (response.statusCode == 200) {
      logger.d('***** Query String: $queryString *****');
      Query query = queryFromJson(response.body);
      if (query.status == 'OK') {
        logger.d('Search ${query.status}');
        logger.d(query.results.first.bills.length.toString());
        List<Bill> bills = query.results.first.bills;
        logger.d('***** Bills: ${bills.map((e) => e.title)} *****');

        bills.sort((a, b) =>
            a.active.toString().length.compareTo(b.active.toString().length));

        return bills;
      } else {
        return null;
      }
    } else {
      logger.d(response.statusCode);
      throw Exception('Failed to load Data');
    }
  }

  static Future<List<Result>> fetchSingleBill(String rawUrlString) async {
    if (rawUrlString != null && rawUrlString != '') {
      final String authority = PropublicaApi().authority;
      final String url = rawUrlString.split(authority)[1];
      final Map<String, String> headers = PropublicaApi().apiHeaders;

      final response =
          await http.get(Uri.https(authority, url), headers: headers);

      if (response.statusCode == 200) {
        Bills bill = billsFromJson(response.body);
        if (bill.status == 'OK') {
          return bill.results;
        } else {
          return [];
        }
      } else {
        logger.d(response.statusCode.toString());
        throw Exception('Failed to load Data');
      }
    } else {
      throw Exception('URI is null');
    }
  }

  static Future<List<MemberTripsResult>> fetchPrivateFundedTravelByMember(
      BuildContext context, String memberId,
      {bool userIsPremium = false, bool userIsLegacy = false}) async {
    logger.d('[Begin] Private Funded Travel By Member Retrieval');

    final localUrl = 'congress/v1/members/$memberId/private-trips.json';
    final localHeaders = PropublicaApi().apiHeaders;
    final authority = PropublicaApi().authority;
    final response =
        await http.get(Uri.https(authority, localUrl), headers: localHeaders);
    logger.d(
        '***** PRIVATE TRIPS BY MEMBER API RESPONSE CODE: ${response.statusCode} *****');

    if (response.statusCode == 200) {
      logger.d('***** PRIVATE TRIPS BY MEMBER RETRIEVAL SUCCESS! *****');
      PrivateTripsByMember privateTripsByMember =
          privateTripsByMemberFromJson(response.body);
      if (privateTripsByMember.status == 'OK') {
        return privateTripsByMember.results;
      } else {
        logger.d(
            'ERROR RETRIEVING PRIVATE TRIPS BY MEMBER (STATUS RESPONSE) CODE: ${privateTripsByMember.status}');
        return [];
      }
    } else {
      logger.d(
          'ERROR RETRIEVING PRIVATE TRIPS BY MEMBER (API RESPONSE) CODE: ${response.statusCode}');
      return [];
    }
  }

  static Future<List<MemberExpensesResult>> fetchMemberOfficeExpenses(
      String memberId, int thisYear, int thisQuarter) async {
    // final int thisMonth = DateTime.now().month;
    // final int thisQuarter = thisMonth >= 1 && thisMonth < 4
    //     ? 1
    //     : thisMonth >= 4 && thisMonth < 7
    //         ? 2
    //         : thisMonth >= 7 && thisMonth < 10
    //             ? 3
    //             : 4;
    // final effectiveQuarter = thisQuarter - 2 < 1 ? 4 : thisQuarter - 2;
    // final int effectiveYear =
    //     thisQuarter - 2 < 1 ? DateTime.now().year - 1 : DateTime.now().year;

    final String authority = PropublicaApi().authority;
    final String url =
        'congress/v1/members/$memberId/office_expenses/$thisYear/$thisQuarter.json';
    final Map<String, String> headers = PropublicaApi().apiHeaders;

    final response =
        await http.get(Uri.https(authority, url), headers: headers);

    if (response.statusCode == 200) {
      MemberOfficeExpenses memberOfficeExpenses =
          memberOfficeExpensesFromJson(response.body);
      if (memberOfficeExpenses.status == 'OK') {
        return memberOfficeExpenses.results;
      } else {
        return [];
      }
    } else {
      logger.d(response.statusCode.toString());
      return [];
    }
  }
}
