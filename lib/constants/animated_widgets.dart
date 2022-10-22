import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:us_congress_vote_tracker/constants/styles.dart';
import 'package:us_congress_vote_tracker/constants/themes.dart';

import '../services/github/promo_message/github-promo-message-model.dart';

class AnimatedWidgets {
  static Widget starryNight(
    BuildContext context,
    bool isActiveWhen,
    bool visibleWhenOff, {
    bool animate = true,
    bool infinite = true,
    double size = 20,
    double spins = 1,
    Color color = const Color.fromARGB(255, 51, 255, 0),
    Color disabledColor = Colors.grey,
    bool reverseContrast = false,
    bool sameColorBright = false,
    bool sameColorDark = false,
  }) {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    return isActiveWhen
        ? Stack(
            alignment: Alignment.topRight,
            children: [
              ZoomIn(
                child: Flash(
                  animate: animate,
                  infinite: infinite,
                  // delay: Duration(milliseconds: 1000),
                  duration: Duration(milliseconds: 5000),
                  // spins: spins,
                  child: Icon(Icons.auto_awesome_outlined, size: size / 1.5, color: Colors.white),
                ),
              ),
              ZoomIn(
                  animate: animate,
                  // infinite: infinite,
                  // delay: Duration(milliseconds: 1000),
                  duration: Duration(milliseconds: 500),
                  child: Swing(
                    infinite: true,
                    duration: Duration(seconds: 10),
                    child: FaIcon(FontAwesomeIcons.solidMoon,
                        size: size,
                        color: sameColorBright
                            ? color
                            : sameColorDark
                                ? alertIndicatorColorDarkGreen
                                : reverseContrast
                                    ? userDatabase.get('darkTheme')
                                        ? alertIndicatorColorDarkGreen
                                        : color
                                    : color),
                  ))
            ],
          )
        : visibleWhenOff
            ? FaIcon(FontAwesomeIcons.solidSun, size: size, color: Colors.white)
            : SizedBox.shrink();
  }

  static Widget jumpingingPremium(
    BuildContext context,
    bool isActiveWhen,
    bool visibleWhenOff, {
    bool animate = true,
    bool infinite = true,
    double size = 20,
    Color color = const Color.fromRGBO(255, 170, 0, 1),
    Color disabledColor = Colors.grey,
  }) {
    return isActiveWhen
        ? Swing(
            animate: animate,
            infinite: infinite,
            delay: Duration(milliseconds: 1000),
            duration: Duration(milliseconds: 10000),
            child: Bounce(
              from: 5,
              animate: animate,
              infinite: infinite,
              // delay: Duration(milliseconds: 1000),
              duration: Duration(milliseconds: 3000),
              child: Icon(Icons.workspace_premium, size: size, color: color),
            ),
          )
        : visibleWhenOff
            ? Icon(Icons.workspace_premium, size: size, color: disabledColor)
            : SizedBox.shrink();
  }

  static Widget flashingEye(BuildContext context, bool isActiveWhen, bool visibleWhenOff,
      {bool animate = true,
      bool infinite = true,
      double size = 15,
      Color color = const Color.fromARGB(255, 51, 255, 0),
      Color disabledColor = Colors.grey,
      bool reverseContrast = false,
      bool sameColorBright = false,
      bool sameColorDark = false}) {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    return isActiveWhen
        ? Flash(
            animate: animate,
            infinite: infinite,
            delay: Duration(milliseconds: 1000),
            duration: Duration(milliseconds: 5000),
            child: FaIcon(FontAwesomeIcons.solidEye,
                size: size,
                color: sameColorBright
                    ? color
                    : sameColorDark
                        ? alertIndicatorColorDarkGreen
                        : reverseContrast
                            ? userDatabase.get('darkTheme')
                                ? alertIndicatorColorDarkGreen
                                : color
                            : userDatabase.get('darkTheme')
                                ? color
                                : alertIndicatorColorDarkGreen),
          )
        : visibleWhenOff
            ? FaIcon(FontAwesomeIcons.solidEye,
                size: size, color: Theme.of(context).primaryColorLight)
            : SizedBox.shrink();
  }

  static Widget flashingText(
      BuildContext context, String textToFlash, bool isActiveWhen, bool visibleWhenOff,
      {bool animate = true,
      bool infinite = true,
      double size = 20,
      Color color = Colors.white,
      Color disabledColor = Colors.grey,
      bool reverseContrast = false,
      bool sameColor = false,
      bool sameColorDark = false,
      bool removeShadow = false}) {
    // Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    return isActiveWhen
        ? Flash(
            animate: animate,
            infinite: infinite,
            delay: Duration(milliseconds: 2000),
            duration: Duration(milliseconds: 5000),
            child: Padding(
              padding: const EdgeInsets.only(left: 3.0),
              child: Text(textToFlash,
                  style: Styles.googleStyle.copyWith(
                      shadows: removeShadow ? null : Styles.shadowStrokeTextGrey,
                      fontSize: size,
                      color: color)),
            ),
          )
        : visibleWhenOff
            ? Text(textToFlash,
                style: Styles.googleStyle.copyWith(
                    shadows: Styles.shadowStrokeTextGrey,
                    fontSize: size,
                    color: Theme.of(context).disabledColor))
            : SizedBox.shrink();
  }

  static Widget spinningLocation(BuildContext context, bool isActive, visibleWhenOff,
      {bool animate = true,
      bool infinite = true,
      double size = 20,
      Color color = const Color.fromARGB(255, 51, 255, 0),
      Color disabledColor = Colors.grey, // Theme.of(context).disabledColor,
      bool reverseContrast = false,
      bool sameColorBright = false,
      bool sameColorDark = false}) {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    return isActive
        ? Spin(
            animate: animate,
            infinite: infinite,
            // delay: Duration(milliseconds: 1000),
            duration: Duration(milliseconds: 1000),
            child: FaIcon(FontAwesomeIcons.locationCrosshairs,
                size: size,
                color: sameColorBright
                    ? color
                    : sameColorDark
                        ? alertIndicatorColorDarkGreen
                        : reverseContrast
                            ? userDatabase.get('darkTheme')
                                ? alertIndicatorColorDarkGreen
                                : color
                            : userDatabase.get('darkTheme')
                                ? color
                                : alertIndicatorColorDarkGreen),
          )
        : visibleWhenOff
            ? FaIcon(FontAwesomeIcons.locationCrosshairs, size: size, color: disabledColor)
            : SizedBox.shrink();
  }

  static Widget flashingInfo(BuildContext context, bool isActive, visibleWhenOff,
      {bool animate = true,
      bool infinite = true,
      double size = 20,
      Color color = const Color.fromARGB(255, 255, 255, 255),
      Color disabledColor = Colors.grey, // Theme.of(context).disabledColor,
      bool reverseContrast = false,
      bool sameColorBright = false,
      bool sameColorDark = false}) {
    // Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    return isActive
        ? Flash(
            animate: animate,
            infinite: infinite,
            // delay: Duration(milliseconds: 1000),
            duration: Duration(seconds: 5),
            child: FaIcon(FontAwesomeIcons.circleInfo, size: size, color: color),
          )
        : visibleWhenOff
            ? FaIcon(FontAwesomeIcons.locationCrosshairs, size: size, color: disabledColor)
            : SizedBox.shrink();
  }

  static Widget circularProgressWatchtower(
    BuildContext context, {
    double widthAndHeight = 48,
    double strokeWidth = 5,
    bool isMarket = false,
    bool isLobby = false,
    bool isFullScreen = false,
    bool isHomePage = false,
    String thisGithubNotification = '',
    String backgroundImage = '',
    // Color color = const Color.fromARGB(255, 51, 255, 0),
  }) {
    final int randomImageIndex = random.nextInt(isMarket
        ? 3
        : isLobby
            ? 2
            : 4);
    return Center(
      child: Stack(
        children: [
          isFullScreen
              ? FadeIn(
                  duration: Duration(milliseconds: 1000),
                  child: Pulse(
                    delay: Duration(milliseconds: 250),
                    duration: Duration(milliseconds: 250),
                    // infinite: true,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        image: DecorationImage(
                            alignment: Alignment.center,
                            scale: 0.65,
                            opacity: 0.15,
                            image: backgroundImage.isNotEmpty
                                ? AssetImage(backgroundImage)
                                : AssetImage(isMarket
                                    ? 'assets/stock$randomImageIndex.png'
                                    : isLobby
                                        ? 'assets/lobbying$randomImageIndex.png'
                                        : 'assets/congress_pic_$randomImageIndex.png'),
                            repeat: ImageRepeat.repeat,
                            // fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.background, BlendMode.color)),
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ZoomIn(
                  child: Container(
                      width: widthAndHeight,
                      height: widthAndHeight,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: strokeWidth,
                            color: isLobby
                                ? alertIndicatorColorDarkGreen
                                : isMarket
                                    ? Colors.white
                                    : republicanColor,
                            backgroundColor: isLobby
                                ? Color.fromARGB(255, 51, 255, 0)
                                : isMarket
                                    ? Colors.transparent
                                    : democratColor,
                          ),
                          SpinPerfect(
                              animate: true,
                              spins: 3,
                              infinite: true,
                              child: Image.asset('assets/watchtower.png')),
                        ],
                      )),
                ),
                isHomePage && thisGithubNotification.isNotEmpty
                    ? SlideInUp(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Text(thisGithubNotification,
                                textAlign: TextAlign.center,
                                style: Styles.googleStyle
                                    .copyWith(fontSize: 20 /*, color: darkThemeTextColor*/))),
                      )
                    : SizedBox.shrink()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
