import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:us_congress_vote_tracker/main.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({Key key}) : super(key: key);

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<OnBoardingPage> {
  // final introKey = GlobalKey<IntroductionScreenState>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (userDatabase.get('darkTheme') == true) {
        await userDatabase.put('darkTheme', false);
      }
    });
    super.initState();
  }

  Box userDatabase = Hive.box<dynamic>(appDatabase);

  void _onIntroEnd(context) async {
    await userDatabase.put('onboarding', false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MyApp()),
    );
  }

  // void _onIntroSkip(context) async {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(builder: (_) => MyApp()),
  //   );
  // }

  Widget _buildFullScreenImage() {
    return Image.asset(
      'assets/intro_background.png',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      // key: introKey,
      // globalBackgroundColor: Colors.white,
      initialPage: 0,
      globalHeader: Align(
        alignment: Alignment.topRight,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
            child: _buildImage('watchtower_icon.png', 75),
          ),
        ),
      ),
      globalFooter: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          child: const Text(
            'Cancel Intro',
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
          onPressed: () => _onIntroEnd(context),
        ),
      ),
      pages: [
        PageViewModel(
          // title: "US Congress",
          titleWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('US Congress',
                    style:
                        GoogleFonts.bangers(fontSize: 30, color: Theme.of(context).primaryColor)),
                const SizedBox(height: 5),
                const Text(
                    'Keep watch over US Congressional member activities. Including bills, chamber voting and roll calls.',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
          bodyWidget: Container(
              height: 125,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/congress_pic_${random.nextInt(4)}.png'),
                      fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(5))),
          image: _buildFullScreenImage(),
          decoration: pageDecoration.copyWith(
            contentMargin: const EdgeInsets.symmetric(horizontal: 16),
            fullScreen: true,
            bodyFlex: 2,
            // imageFlex: 3,
          ),
        ),
        PageViewModel(
          // title: "US Congress",
          titleWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Stay Informed',
                    style:
                        GoogleFonts.bangers(fontSize: 30, color: Theme.of(context).primaryColor)),
                const SizedBox(height: 5),
                const Text(
                    'Activate alerts from the Senate and House chambers floor while in session as well as specific congressional members, bills, lobby events and privately funded travel.',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
          // body:
          //     "Instead of having to buy an entire share, invest any amount yo am Nunc id euismod lectus, nou want.",
          bodyWidget: Container(
              height: 125,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/lobbying${random.nextInt(2)}.png'),
                      fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(5))),
          image: _buildFullScreenImage(),
          decoration: pageDecoration.copyWith(
            contentMargin: const EdgeInsets.symmetric(horizontal: 16),
            fullScreen: true,
            bodyFlex: 2,
            // imageFlex: 3,
          ),
        ),
        PageViewModel(
          // title: "US Congress",
          titleWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Follow The Market',
                    style:
                        GoogleFonts.bangers(fontSize: 30, color: Theme.of(context).primaryColor)),
                const SizedBox(height: 5),
                const Text(
                    'Premium subscribers are able to keep up to date on commodity and stock market trades executed by congressional members.',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
          // body:
          //     "Instead of having to buy an entire share, invest any amount yo am Nunc id euismod lectus, nou want.",
          bodyWidget: Container(
              height: 125,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/stock${random.nextInt(3)}.png'), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(5))),
          image: _buildFullScreenImage(),
          decoration: pageDecoration.copyWith(
            contentMargin: const EdgeInsets.symmetric(horizontal: 16),
            fullScreen: true,
            bodyFlex: 2,
            // imageFlex: 3,
          ),
        ),
        // PageViewModel(
        //   title: "Full Screen Page",
        //   body:
        //       "Pages can be full screen as well.\n\nLorem ipsum dolor sit amet. Nunc id euismod lectus, non tempor felis.",
        //   image: _buildFullScreenImage(),
        //   decoration: pageDecoration.copyWith(
        //     contentMargin: const EdgeInsets.symmetric(horizontal: 16),
        //     fullScreen: true,
        //     bodyFlex: 2,
        //     imageFlex: 3,
        //   ),
        // ),
        // PageViewModel(
        //   title: "Title page",
        //   body: "A beautiful body text for this example onboarding",
        //   image: _buildFullScreenImage(),
        //   footer: ElevatedButton(
        //     onPressed: () {
        //       // introKey.currentState?.animateScroll(0);
        //     },
        //     child: const Text(
        //       'FooButton',
        //       style: TextStyle(color: Colors.white),
        //     ),
        //     style: ElevatedButton.styleFrom(
        //       primary: Colors.lightBlue,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //       ),
        //     ),
        //   ),
        //   decoration: pageDecoration,
        // ),
        // PageViewModel(
        //   title: "Title page",
        //   body: "A beautiful body text for this example onboarding",
        //   image: _buildImage('usflag.jpg'),
        //   footer: ElevatedButton(
        //     onPressed: () {
        //       // introKey.currentState?.animateScroll(0);
        //     },
        //     child: const Text(
        //       'FooButton',
        //       style: TextStyle(color: Colors.white),
        //     ),
        //     style: ElevatedButton.styleFrom(
        //       primary: Colors.lightBlue,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //       ),
        //     ),
        //   ),
        //   decoration: pageDecoration,
        // ),
        // PageViewModel(
        //   title: "Title of last page - reversed",
        //   bodyWidget: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: const [
        //       Text("Click on ", style: bodyStyle),
        //       Icon(Icons.edit),
        //       Text(" to edit a post", style: bodyStyle),
        //     ],
        //   ),
        //   decoration: pageDecoration.copyWith(
        //     bodyFlex: 2,
        //     imageFlex: 4,
        //     bodyAlignment: Alignment.bottomCenter,
        //     imageAlignment: Alignment.topCenter,
        //   ),
        //   image: _buildImage('usflag.jpg'),
        //   reverse: true,
        // ),
      ],
      onDone: () => _onIntroEnd(context),
      // onSkip: () => _onIntroSkip(context), // You can override onSkip callback
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      //rtl: true, // Display as right-to-left
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding:
          kIsWeb ? const EdgeInsets.all(12.0) : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Color(0xffffffff),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
      ),
    );
  }
}
