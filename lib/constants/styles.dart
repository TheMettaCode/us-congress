import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Styles {
  static final regularStyle = TextStyle(
    // textStyle: TextStyle(
    // color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    // ),
    fontStyle: FontStyle.normal,
    // shadows: [
    //   Shadow(
    //       color: Colors.black.withOpacity(0.5),
    //       offset: Offset(5, 5),
    //       blurRadius: 5),
    // ],
  );

  static final googleStyle = GoogleFonts.bangers(
    textStyle: TextStyle(
        // color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.normal),
    fontStyle: FontStyle.normal,
    // shadows: [
    //   Shadow(
    //       color: Colors.black.withOpacity(0.5),
    //       offset: Offset(5, 5),
    //       blurRadius: 5),
    // ],
  );

  static final TextStyle voteTileTextStyle = new TextStyle(fontSize: 12.0);

  static final List<BoxShadow> containerShadow = [
    // BoxShadow(
    //     // bottomLeft
    //     offset: Offset(-2, -2),
    //     blurRadius: 1,
    //     color: Color(0xff424242)),
    // BoxShadow(
    //     // topRight
    //     offset: Offset(2, -2),
    //     blurRadius: 1,
    //     color: Color(0xff424242)),
    BoxShadow(
        // bottomRight
        offset: Offset(2, 2),
        blurRadius: 3,
        color: Color(0xff424242)),
    // BoxShadow(
    //   // topLeft
    //   offset: Offset(-2, 2),
    //   blurRadius: 1,
    //   color: Color(0xff424242),
    // )
  ];

  static final List<Shadow> shadowStrokeTextGrey = [
    Shadow(
        // bottomLeft
        offset: Offset(-1, -1),
        blurRadius: 1,
        color: Color(0xff424242).withOpacity(0.5)),
    Shadow(
        // bottomRight
        offset: Offset(1, -1),
        blurRadius: 1,
        color: Color(0xff424242).withOpacity(0.5)),
    Shadow(
        // topRight
        offset: Offset(1, 1),
        blurRadius: 1,
        color: Color(0xff424242).withOpacity(0.5)),
    Shadow(
      // topLeft
      offset: Offset(-1, 1),
      blurRadius: 1,
      color: Color(0xff424242).withOpacity(0.5),
    )
  ];

  static final List<Shadow> shadowStrokeTextWhite = [
    Shadow(
        // bottomLeft
        offset: Offset(-1, -1),
        blurRadius: 1,
        color: Color(0xffffffff)),
    Shadow(
        // bottomRight
        offset: Offset(1, -1),
        blurRadius: 1,
        color: Color(0xffffffff)),
    Shadow(
        // topRight
        offset: Offset(1, 1),
        blurRadius: 1,
        color: Color(0xffffffff)),
    Shadow(
      // topLeft
      offset: Offset(-1, 1),
      blurRadius: 1,
      color: Color(0xffffffff),
    )
  ];
}
