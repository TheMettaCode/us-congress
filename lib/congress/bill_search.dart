import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:us_congress_vote_tracker/constants/animated_widgets.dart';
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:us_congress_vote_tracker/models/bill_search_model.dart';
import 'package:us_congress_vote_tracker/congress/bill_details.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/house_stock_watch_model.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/senate_stock_watch_model.dart';
import 'package:us_congress_vote_tracker/services/propublica/propublica_api.dart';

class BillSearch extends StatefulWidget {
  // QuerySearch({Key key}) : super(key: key);

  final String queryString;
  final List<HouseStockWatch> houseStockWatchList;
  final List<SenateStockWatch> senateStockWatchList;
  BillSearch(
      this.queryString, this.houseStockWatchList, this.senateStockWatchList);

  @override
  _BillSearchState createState() => new _BillSearchState();
}

class _BillSearchState extends State<BillSearch> {
  Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
  bool _isLoading = true;
  bool userIsPremium = false;
  bool userIsLegacy = false;
  List<HouseStockWatch> houseStockWatchList;
  List<SenateStockWatch> senateStockWatchList;
  List<Bill> billQueryList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await setVariables();
      await getBillQueryList();
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

  Future<void> getBillQueryList() async {
    await PropublicaApi.fetchBills(widget.queryString.toLowerCase().trim())
        .then((value) {
      setState(() => billQueryList = value);
      setState(() => _isLoading = false);

      // Future.delayed(Duration(seconds: 2), () async {
      //   // Do something
      //   if (ModalRoute.of(context).isCurrent) {
      //     await AdMobLibrary().defaultRewarded();
      //   }
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    String queryString = widget.queryString;

    return new Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: new Text(
            queryString.isEmpty ? 'Bill Search' : 'Search for $queryString',
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
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.center,
                            autocorrect: true,
                            autofocus: true,
                            enableSuggestions: true,
                            decoration: InputDecoration.collapsed(
                              hintText: queryString != null
                                  ? queryString
                                  : 'Enter your search',
                            ),
                            onChanged: (val) {
                              queryString = val;
                            },
                          ),
                        ),
                        new ElevatedButton.icon(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            Navigator.pop(context);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BillSearch(queryString,
                                    houseStockWatchList, senateStockWatchList),
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
              isFullScreen: true)
          : billQueryList.length > 0
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
                        return Divider(
                          height: 0,
                          color: Colors.transparent,
                        );
                      },
                      itemCount: billQueryList.length,
                      // scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        return _getQueryTile(index);
                      },
                    ),
                  ),
                  onRefresh: getBillQueryList,
                )
              : Center(
                  child: Text('No Search Results',
                      style: GoogleFonts.bangers(fontSize: 30)),
                ),
    );
  }

  Widget _getQueryTile(int index) {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    var thisBillQuery = billQueryList[index];
    List<String> _subscriptions =
        List.from(userDatabase.get('subscriptionAlertsList'));
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
              onTap: thisBillQuery.billUri == null
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
                          builder: (context) => BillDetail(
                              thisBillQuery.billUri,
                              houseStockWatchList,
                              senateStockWatchList),
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
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                new Text(
                                  thisBillQuery.number,
                                  style: new TextStyle(
                                      // color: Colors.black,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 3),
                                AnimatedWidgets.flashingEye(
                                    context,
                                    _subscriptions.any((element) => element
                                        .toLowerCase()
                                        .startsWith(
                                            'bill_${thisBillQuery.billId.toLowerCase()}')),
                                    false,
                                    size: 10),
                              ],
                            ),
                            new Text(
                              thisBillQuery.active.toString() == 'true'
                                  ? 'ACTIVE'
                                  : 'INACTIVE',
                              style: new TextStyle(
                                  color:
                                      thisBillQuery.active.toString() == 'true'
                                          ? Colors.green
                                          : Colors.grey,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        new SizedBox(height: 2),
                        new Text(
                          thisBillQuery.title,
                          style: new TextStyle(
                              // color: Colors.black,
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal),
                        ),
                        new SizedBox(height: 5),
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            thisBillQuery.introducedDate == null
                                ? new Text('')
                                : new Text(
                                    'Intr > ' +
                                        formatter.format(
                                            thisBillQuery.introducedDate),
                                    style: new TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.normal),
                                  ),
                            thisBillQuery.latestMajorActionDate == null
                                ? new Text('')
                                : new Text(
                                    'Last > ' +
                                        formatter.format(thisBillQuery
                                            .latestMajorActionDate),
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
