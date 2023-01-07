import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color mettaCodeOrange = Color(0xffff9000);
const Color mettaCodeOrangeDark = Color(0xFF996000);

const Color capitolBabbleDark = Color(0xFF4D0046);

final MaterialStateProperty<double> zeroMSPDouble =
    MaterialStateProperty.all<double>(0);

final MaterialStateProperty<Color> transparentMSPColor =
    MaterialStateProperty.all<Color>(const Color.fromARGB(0, 0, 0, 0));

final MaterialStateProperty<Color> republicanMSPColor =
    MaterialStateProperty.all<Color>(const Color(0xffff0000));
const Color republicanColor = Color(0xffff0000);

final MaterialStateProperty<Color> democratMSPColor =
    MaterialStateProperty.all<Color>(const Color(0xff0000ff));

final MaterialStateProperty<Color> errorMSPColor =
    MaterialStateProperty.all<Color>(const Color.fromRGBO(183, 28, 28, 1));

const Color democratColor = Color(0xff0000ff);

const Color independentColor = Color(0xff000000);

const Color darkThemeTextColor = Color(0xffffffff);

const Color stockWatchColor = Color.fromARGB(255, 76, 85, 0);

final MaterialStateProperty<Color> darkThemeTextMSPColor =
    MaterialStateProperty.all<Color>(const Color.fromARGB(255, 255, 255, 255));

final MaterialStateProperty<Color> altHighlightMSPColor =
    MaterialStateProperty.all<Color>(const Color(0xffffaa00));

final MaterialStateProperty<Color> primaryMSPColorLight =
    MaterialStateProperty.all<Color>(const Color(0xffff00ff));

final MaterialStateProperty<Color> primaryMSPColorDark =
    MaterialStateProperty.all<Color>(Colors.black);

final MaterialStateProperty<Color> disabledMSPColorGray =
    MaterialStateProperty.all<Color>(const Color.fromARGB(255, 125, 125, 125));

const Color alertIndicatorColorBrightGreen = Color.fromARGB(255, 51, 255, 0);

final MaterialStateProperty<Color> alertIndicatorMSPColorBrightGreen =
    MaterialStateProperty.all<Color>(const Color.fromARGB(255, 51, 255, 0));

const Color alertIndicatorColorDarkGreen = Color.fromARGB(255, 30, 150, 0);

final MaterialStateProperty<Color> alertIndicatorMSPColorDarkGreen =
    MaterialStateProperty.all<Color>(const Color.fromARGB(255, 30, 150, 0));

const Color altIndicatorColorPurple = Color.fromARGB(255, 100, 0, 100);

final MaterialStateProperty<Color> altIndicatorMSPColorPurple =
    MaterialStateProperty.all<Color>(const Color.fromARGB(255, 100, 0, 100));

const Color altHighlightColor = Color(0xFFFFAA00);

final MaterialStateProperty<Color> altHighlightAccentMSPColorDark =
    MaterialStateProperty.all<Color>(const Color(0xff660066));

const Color altHighlightAccentColorDark = Color(0xff660066);
// final MaterialStateProperty<Color> altDarkHighlightMSPAccentColor =
//     MaterialStateProperty.all<Color>(Color(0xccffaa00));

final ThemeData defaultThemeData = ThemeData(
    primaryColor: const Color(0xFF0055AA),
    primaryColorDark: const Color(0xFF004080),
    colorScheme: const ColorScheme.light(
        tertiary: Colors.black,
        background: Color.fromARGB(255, 226, 226, 226),
        error: Color.fromRGBO(183, 28, 28, 1),
        brightness: Brightness.light,
        primary: Color(0xff0055aa),
        secondary: Color(0xFF004080)),
    highlightColor: const Color.fromARGB(255, 77, 77, 77),
    appBarTheme:
        const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: MaterialStateProperty.all<Color>(const Color(0xff707070)),
    ),
    // iconTheme: IconThemeData(color: Color(0xffffffff)),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(
                const TextStyle(color: Color(0xffffffff))))),
    switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all<Color>(const Color(0xffffffff)),
        trackColor: MaterialStateProperty.all<Color>(const Color(0xffa0a0a0))),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        enableFeedback: true,
        foregroundColor:
            MaterialStateProperty.all<Color>(const Color(0xffffffff)),
        backgroundColor:
            MaterialStateProperty.all<Color>(const Color(0xFF004080)),
        // overlayColor: MaterialStateProperty.all<Color>(Color(0xff363636)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        enableFeedback: true,
        foregroundColor:
            MaterialStateProperty.all<Color>(const Color(0xffffffff)),
        backgroundColor:
            MaterialStateProperty.all<Color>(const Color(0xFF004080)),
        // overlayColor: MaterialStateProperty.all<Color>(Color(0xff363636)),
      ),
    ));

final ThemeData grapeThemeData = ThemeData(
    primaryColor: const Color(0xff770077),
    primaryColorDark: const Color(0xff660066),
    colorScheme: const ColorScheme.light(
        tertiary: Colors.black,
        background: Color.fromARGB(255, 226, 226, 226),
        error: Color.fromRGBO(183, 28, 28, 1),
        brightness: Brightness.light,
        primary: Color(0xff770077),
        secondary: Color(0xFF660066)),
    highlightColor: const Color.fromARGB(255, 77, 77, 77),
    appBarTheme:
        const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: MaterialStateProperty.all<Color>(const Color(0xff707070)),
    ),
    // iconTheme: IconThemeData(color: Color(0xffffffff)),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(
                const TextStyle(color: Color(0xffffffff))))),
    switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all<Color>(const Color(0xffffffff)),
        trackColor: MaterialStateProperty.all<Color>(const Color(0xffa0a0a0))),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        enableFeedback: true,
        foregroundColor:
            MaterialStateProperty.all<Color>(const Color(0xffffffff)),
        backgroundColor:
            MaterialStateProperty.all<Color>(const Color(0xff660066)),
        // overlayColor: MaterialStateProperty.all<Color>(Color(0xff363636)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        enableFeedback: true,
        foregroundColor:
            MaterialStateProperty.all<Color>(const Color(0xffffffff)),
        backgroundColor:
            MaterialStateProperty.all<Color>(const Color(0xff660066)),
        // overlayColor: MaterialStateProperty.all<Color>(Color(0xff363636)),
      ),
    ));

final ThemeData darkThemeData = ThemeData(
    // primarySwatch: Colors.grey,
    primaryColor: const Color(0xff696969),
    primaryColorDark: const Color(0xFF000000),
    colorScheme: ColorScheme.dark(
        tertiary: Colors.white,
        background: const Color.fromARGB(255, 51, 51, 51),
        error: Colors.red[900],
        brightness: Brightness.dark,
        primary: const Color(0xFF696969),
        secondary: const Color.fromRGBO(54, 54, 54, 1)),
    highlightColor: const Color(0xFF000000),
    appBarTheme:
        const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: MaterialStateProperty.all<Color>(const Color(0xff707070)),
    ),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(
                const TextStyle(color: Color(0xffffffff))))),
    switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all<Color>(const Color(0xffb0b0b0)),
        trackColor: MaterialStateProperty.all<Color>(const Color(0xff707070))),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xff000000), //  <-- dark color
      textTheme:
          ButtonTextTheme.primary, //  <-- this auto selects the right color
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        enableFeedback: true,
        foregroundColor:
            MaterialStateProperty.all<Color>(const Color(0xffffffff)),
        backgroundColor:
            MaterialStateProperty.all<Color>(const Color(0xff000000)),
        // overlayColor: MaterialStateProperty.all<Color>(Color(0xff363636)),
      ),
    ));
