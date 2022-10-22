import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final MaterialStateProperty<double> zeroMSPDouble =
    MaterialStateProperty.all<double>(0);

final MaterialStateProperty<Color> transparentMSPColor =
    MaterialStateProperty.all<Color>(Color.fromARGB(0, 0, 0, 0));

final MaterialStateProperty<Color> republicanMSPColor =
    MaterialStateProperty.all<Color>(Color(0xffff0000));
final Color republicanColor = Color(0xffff0000);

final MaterialStateProperty<Color> democratMSPColor =
    MaterialStateProperty.all<Color>(Color(0xff0000ff));

final MaterialStateProperty<Color> errorMSPColor =
    MaterialStateProperty.all<Color>(Color.fromRGBO(183, 28, 28, 1));

final Color democratColor = Color(0xff0000ff);

final Color independentColor = Color(0xff000000);

final Color darkThemeTextColor = Color(0xffffffff);

final Color stockWatchColor = Color.fromARGB(255, 76, 85, 0);

final MaterialStateProperty<Color> darkThemeTextMSPColor =
    MaterialStateProperty.all<Color>(Color.fromARGB(255, 255, 255, 255));

final MaterialStateProperty<Color> altHighlightMSPColor =
    MaterialStateProperty.all<Color>(Color(0xffffaa00));

final MaterialStateProperty<Color> primaryMSPColorLight =
    MaterialStateProperty.all<Color>(Color.fromARGB(255, 33, 150, 243));

final MaterialStateProperty<Color> primaryMSPColorDark =
    MaterialStateProperty.all<Color>(Colors.black);

final MaterialStateProperty<Color> disabledMSPColorGray =
    MaterialStateProperty.all<Color>(Color.fromARGB(255, 125, 125, 125));

final Color alertIndicatorColorBrightGreen = Color.fromARGB(255, 51, 255, 0);

final MaterialStateProperty<Color> alertIndicatorMSPColorBrightGreen =
    MaterialStateProperty.all<Color>(Color.fromARGB(255, 51, 255, 0));

final Color alertIndicatorColorDarkGreen = Color.fromARGB(255, 30, 150, 0);

final MaterialStateProperty<Color> alertIndicatorMSPColorDarkGreen =
    MaterialStateProperty.all<Color>(Color.fromARGB(255, 30, 150, 0));

final Color altIndicatorColorPurple = Color.fromARGB(255, 100, 0, 100);

final MaterialStateProperty<Color> altIndicatorMSPColorPurple =
    MaterialStateProperty.all<Color>(Color.fromARGB(255, 100, 0, 100));

final Color altHighlightColor = Color.fromRGBO(255, 170, 0, 1);

final MaterialStateProperty<Color> altHighlightAccentMSPColorDarkRed =
    MaterialStateProperty.all<Color>(Color(0xff800000));

final Color altHighlightAccentColorDarkRed = Color(0xff800000);
// final MaterialStateProperty<Color> altDarkHighlightMSPAccentColor =
//     MaterialStateProperty.all<Color>(Color(0xccffaa00));

final ThemeData defaultThemeData = new ThemeData(
    // brightness: Brightness.light,
    // primarySwatch: Colors.blue,
    colorScheme: ColorScheme.light(
        tertiary: Colors.black,
        background: Color.fromARGB(255, 226, 226, 226),
        error: Color.fromRGBO(183, 28, 28, 1),
        brightness: Brightness.light,
        primary: Colors.blue,
        secondary: Color.fromARGB(255, 0, 100, 255)),
    highlightColor: Color.fromARGB(255, 77, 77, 77),
    appBarTheme: AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: MaterialStateProperty.all<Color>(Color(0xff707070)),
    ),
    // iconTheme: IconThemeData(color: Color(0xffffffff)),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(
                TextStyle(color: Color(0xffffffff))))),
    switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all<Color>(Color(0xffffffff)),
        trackColor: MaterialStateProperty.all<Color>(Color(0xffa0a0a0))),
    outlinedButtonTheme: OutlinedButtonThemeData(
        // style: ButtonStyle(
        //   enableFeedback: true,
        //   foregroundColor: MaterialStateProperty.all<Color>(Color(0xffffffff)),
        //   backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
        //   overlayColor:
        //       MaterialStateProperty.all<Color>(Color.fromARGB(255, 9, 255, 1)),
        // ),
        ));

final ThemeData darkThemeData = new ThemeData(
    // primarySwatch: Colors.grey,
    colorScheme: ColorScheme.dark(
        tertiary: Colors.white,
        background: Color.fromARGB(255, 51, 51, 51),
        error: Colors.red[900],
        brightness: Brightness.dark,
        primary: Color.fromARGB(255, 120, 120, 120),
        secondary: Color.fromRGBO(54, 54, 54, 1)),
    highlightColor: Color.fromARGB(255, 0, 0, 0),
    appBarTheme: AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: MaterialStateProperty.all<Color>(Color(0xff707070)),
    ),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(
                TextStyle(color: Color(0xffffffff))))),
    switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all<Color>(Color(0xffb0b0b0)),
        trackColor: MaterialStateProperty.all<Color>(Color(0xff707070))),
    buttonTheme: ButtonThemeData(
      buttonColor: Color(0xff000000), //  <-- dark color
      textTheme:
          ButtonTextTheme.primary, //  <-- this auto selects the right color
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        enableFeedback: true,
        foregroundColor: MaterialStateProperty.all<Color>(Color(0xffffffff)),
        backgroundColor: MaterialStateProperty.all<Color>(Color(0xff000000)),
        // overlayColor: MaterialStateProperty.all<Color>(Color(0xff363636)),
      ),
    ));
