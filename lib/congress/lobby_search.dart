import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:us_congress_vote_tracker/congress/lobby_event_detail.dart';
import 'package:us_congress_vote_tracker/constants/animated_widgets.dart';
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:us_congress_vote_tracker/constants/themes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:us_congress_vote_tracker/models/lobby_search_model.dart';
import 'package:us_congress_vote_tracker/services/propublica/propublica_api.dart';

class LobbyingSearchList extends StatefulWidget {
  final String lobbyingSearchString;
  LobbyingSearchList(this.lobbyingSearchString);

  @override
  _LobbySearchListState createState() => new _LobbySearchListState();
}

class _LobbySearchListState extends State<LobbyingSearchList> {
  bool _isLoading = true;
  List<LobbyingSearchRepresentation> lobbyingSearchList = [];
  // Container bannerAdContainer = Container();
  // bool showBannerAd = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getLobbyingSearchList();
    });
  }

  // Future<List<LobbyingSearchRepresentation>> fetchLobbying(queryString) async {
  //   final String queryString = widget.lobbyingSearchString.toLowerCase().trim();

  //   logger.d('***** Query String: $queryString *****');

  //   final url = ApiLinks().lobbyingSearchApi;
  //   final queryParameters = {
  //     'query': queryString,
  //     // 'param2': 'two',
  //   };
  //   final headers = ApiLinks().apiHeaders;
  //   final authority = ApiLinks().authority;
  //   final response = await http.get(Uri.https(authority, url, queryParameters),
  //       headers: headers);

  //   if (response.statusCode == 200) {
  //     logger.d('***** Lobbying Query String: $queryString *****');
  //     LobbyingSearch lobbyingSearch = lobbyingSearchFromJson(response.body);
  //     if (lobbyingSearch.status == 'OK') {
  //       logger.d('Search ' + lobbyingSearch.status);
  //       logger.d(lobbyingSearch.results.first.lobbyingRepresentations.length
  //           .toString());
  //       List<LobbyingSearchRepresentation> lobbyingSearchRepresentation =
  //           lobbyingSearch.results.first.lobbyingRepresentations;
  //       logger.d(
  //           '***** Lobbying: ${lobbyingSearchRepresentation.map((e) => e.id)} *****');

  //       lobbyingSearchRepresentation
  //           .sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));

  //       // lobbyingSearchList = lobbyingSearchRepresentation;

  //       return lobbyingSearchRepresentation;
  //     } else {
  //       return null;
  //     }
  //   } else {
  //     // logger.d(response.statusCode);
  //     throw Exception('Failed to load Data');
  //   }
  // }

  Future<void> getLobbyingSearchList() async {
    await PropublicaApi.fetchLobbying(
            widget.lobbyingSearchString.toLowerCase().trim())
        .then((value) {
      setState(() => lobbyingSearchList = value);
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    String lobbyingSearchString = widget.lobbyingSearchString;

    return new Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: alertIndicatorColorDarkGreen,
        title: new Text(
            lobbyingSearchString.isEmpty
                ? 'Lobbying Search'
                : 'Search for $lobbyingSearchString',
            style: GoogleFonts.bangers(fontSize: 25)),
        // systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  // backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) => Container(
                    color: Colors.transparent,
                    margin: const EdgeInsets.only(top: 5, left: 15, right: 15),
                    height: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 50,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                              color: alertIndicatorColorDarkGreen
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.center,
                            autocorrect: true,
                            autofocus: true,
                            enableSuggestions: true,
                            decoration: InputDecoration.collapsed(
                              hintText: lobbyingSearchString != null
                                  ? lobbyingSearchString
                                  : 'Enter your search',
                            ),
                            onChanged: (val) {
                              lobbyingSearchString = val;
                            },
                          ),
                        ),
                        new ElevatedButton.icon(
                          style: ButtonStyle(
                              backgroundColor: alertIndicatorMSPColorDarkGreen),
                          icon: Icon(Icons.search),
                          onPressed: () {
                            Navigator.pop(context);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LobbyingSearchList(lobbyingSearchString),
                              ),
                            );
                          },
                          label: Text(
                            'Search',
                            // style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
        ],
      ),
      body: _isLoading
          ? AnimatedWidgets.circularProgressWatchtower(context,
              isLobby: true, isFullScreen: true)
          : lobbyingSearchList.length > 0
              ? RefreshIndicator(
                  child: new Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      image: DecorationImage(
                          opacity: 0.15,
                          image: AssetImage(
                              'assets/congress_pic_${random.nextInt(4)}.png'),
                          // fit: BoxFit.fitWidth,
                          repeat: ImageRepeat.repeat,
                          colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.background,
                              BlendMode.color)),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                    alignment: Alignment.center,
                    child: new ListView.separated(
                      physics: BouncingScrollPhysics(),
                      separatorBuilder: (context, index) {
                        return Divider(height: 0, color: Colors.transparent);
                      },
                      itemCount: lobbyingSearchList.length,
                      // scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        return _getLobbyingSearchTile(index);
                      },
                    ),
                  ),
                  onRefresh: getLobbyingSearchList,
                )
              : Center(
                  child: Text('No Search Results',
                      style: GoogleFonts.bangers(fontSize: 30)),
                ),
    );
  }

  Widget _getLobbyingSearchTile(int index) {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    List<String> _subscriptions =
        List.from(userDatabase.get('subscriptionAlertsList'));
    var lobby = lobbyingSearchList[index];
    return Container(
      // color: Colors.grey,
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      child: new Card(
        color: Theme.of(context).colorScheme.background,
        elevation: 0.0,
        child: new Column(
          children: <Widget>[
            InkWell(
              splashColor: Colors.grey,
              enableFeedback: true,
              onTap: lobby.id == null
                  ? () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Details'),
                            content: Text('Details not available.'),
                            actions: [
                              TextButton(
                                child: Text('Close'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LobbyEventDetail(
                              /*null,*/
                              thisLobbyEventId: lobby.id),
                        ),
                      );
                    },
              child: new Column(
                children: [
                  new Container(
                    alignment: Alignment.topLeft,
                    margin: new EdgeInsets.all(5.0),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  new Text(
                                    'ID: ${lobby.id}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: new TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 3),
                                  AnimatedWidgets.flashingEye(
                                      context,
                                      _subscriptions.any((element) => element
                                          .toLowerCase()
                                          .startsWith(
                                              'lobby_${lobby.id.toLowerCase()}')),
                                      false,
                                      size: 10),
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 3,
                              child: new Text(
                                '${lobby.lobbyingClient.name}'.toUpperCase(),
                                textAlign: TextAlign.right,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: new TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            // new Text(
                            //   lobby.active.toString() == 'true'
                            //       ? 'ACTIVE'
                            //       : 'INACTIVE',
                            //   style: new TextStyle(
                            //       color: lobby.active.toString() == 'true'
                            //           ? Colors.green
                            //           : Colors.grey,
                            //       fontSize: 12.0,
                            //       fontWeight: FontWeight.bold),
                            // ),
                          ],
                        ),
                        new SizedBox(height: 2),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: lobby.specificIssues
                              .map(
                                (e) => Text(
                                  '• $e',
                                  style: new TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.normal),
                                ),
                              )
                              .toList(),
                        ),
                        new SizedBox(height: 5),
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            lobby.signedDate == null || lobby.signedDate.isEmpty
                                ? new Text('')
                                : new Text(
                                    'Signed > ' +
                                        formatter.format(
                                            DateTime.parse(lobby.signedDate)),
                                    style: new TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.normal),
                                  ),
                            lobby.effectiveDate == null ||
                                    lobby.effectiveDate.isEmpty
                                ? new Text('')
                                : new Text(
                                    'Effective > ' +
                                        formatter.format(DateTime.parse(
                                            lobby.effectiveDate)),
                                    style: new TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.normal),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
