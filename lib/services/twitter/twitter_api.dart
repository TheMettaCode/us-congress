import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart' as v2;

class TwitterServiceApi {
  /// You need to get keys and tokens at https://developer.twitter.com

  /// CAPITOLBABBLE TWITTER ACCOUNT KEYS
  static final String capitolBabbleConsumerKey = dotenv.env['CAPITOLBABBLE_TWITTER_API_KEY'];
  static final String capitolBabbleConsumerSecret = dotenv.env['CAPITOLBABBLE_TWITTER_SECRET_KEY'];
  static final String capitolBabbleBearerToken = dotenv.env['CAPITOLBABBLE_TWITTER_BEARER_TOKEN'];
  static final String capitolBabbleAccessToken =
      dotenv.env['CAPITOLBABBLE_TWITTER_OAUTH_ACCESS_TOKEN'];
  static final String capitolBabbleAccessTokenSecret =
      dotenv.env['CAPITOLBABBLE_TWITTER_OAUTH_ACCESS_TOKEN_SECRET'];
  static final String capitolBabbleClientId = dotenv.env['CAPITOLBABBLE_TWITTER_CLIENT_ID'];
  static final String capitolBabbleClientSecret = dotenv.env['CAPITOLBABBLE_TWITTER_CLIENT_SECRET'];

  static Future<void> postTweet(String message, {String assetImageUrl}) async {
    debugPrint('[TWITTER API] BEGINNING TWEET POST PROCESS');
    //! You need to get keys and tokens at https://developer.twitter.com
    final twitter = v2.TwitterApi(
      //! Authentication with OAuth2.0 is the default.
      //!
      //! Note that to use endpoints that require certain user permissions,
      //! such as Tweets and Likes, you need a token issued by OAuth2.0 PKCE.
      //!
      //! The easiest way to achieve authentication with OAuth 2.0 PKCE is
      //! to use [twitter_oauth2_pkce](https://pub.dev/packages/twitter_oauth2_pkce)!
      bearerToken: capitolBabbleBearerToken,

      //! Or perhaps you would prefer to use the good old OAuth1.0a method
      //! over the OAuth2.0 PKCE method. Then you can use the following code
      //! to set the OAuth1.0a tokens.
      //!
      //! However, note that some endpoints cannot be used for OAuth 1.0a method
      //! authentication.
      oauthTokens: v2.OAuthTokens(
        consumerKey: capitolBabbleConsumerKey,
        consumerSecret: capitolBabbleConsumerSecret,
        accessToken: capitolBabbleAccessToken,
        accessTokenSecret: capitolBabbleAccessTokenSecret,
      ),

      //! Automatic retry is available when a TimeoutException occurs when
      //! communicating with the API.
      retryConfig: v2.RetryConfig.ofExponentialBackOffAndJitter(
        maxAttempts: 5,
        onExecute: (event) => logger.d(
          '[TWITTER API] '
          'Retry after ${event.intervalInSeconds} seconds... '
          '[${event.retryCount} times]',
        ),
      ),

      //! The default timeout is 10 seconds.
      timeout: const Duration(seconds: 20),
    );

    try {
      // //! Get the authenticated user's profile.
      // final me = await twitter.users.lookupMe();
      // debugPrint('[TWITTER API] I AM ${me.data.username} [${me.data.name}]');

      if (assetImageUrl != null) {
        //! You can upload media such as image, gif and video.
        final uploadedMedia = await twitter.media.uploadMedia(
          file: File.fromUri(Uri.file(assetImageUrl)),
          altText: 'Uploaded Image',

          //! You can check the upload progress.
          onProgress: (event) {
            switch (event.state) {
              case v2.UploadState.preparing:
                logger.d('Upload is preparing...');
                break;
              case v2.UploadState.inProgress:
                logger.d('${event.progress}% completed...');
                break;
              case v2.UploadState.completed:
                logger.d('Upload has completed!');
                break;
            }
          },
          onFailed: (error) => logger.d('Upload failed due to "${error.message}"'),
        );

        //! You can easily post a tweet with uploaded media.
        await twitter.tweets.createTweet(
            text: message, media: v2.TweetMediaParam(mediaIds: [uploadedMedia.data.id]));
      } else {
        //! You can easily post a tweet.
        await twitter.tweets.createTweet(
          text: message,
        );
      }
    } on TimeoutException catch (e) {
      logger.d(e);
    } on v2.UnauthorizedException catch (e) {
      logger.d(e);
    } on v2.RateLimitExceededException catch (e) {
      logger.d(e);
    } on v2.DataNotFoundException catch (e) {
      logger.d(e);
    } on v2.TwitterUploadException catch (e) {
      logger.d(e);
    } on v2.TwitterException catch (e) {
      logger.d(e.response.headers);
      logger.d(e.body);
      logger.d(e);
    }
    debugPrint('[TWITTER API] POST TWEET PROCESS ENDED');
  }

  // Future<void> exampleFunctionsDONOTUSE(String message) async {
  //   debugPrint('[TWITTER API] BEGINNING TWITTER API PROCESS');
  //   //! You need to get keys and tokens at https://developer.twitter.com
  //   final twitter = v2.TwitterApi(
  //     //! Authentication with OAuth2.0 is the default.
  //     //!
  //     //! Note that to use endpoints that require certain user permissions,
  //     //! such as Tweets and Likes, you need a token issued by OAuth2.0 PKCE.
  //     //!
  //     //! The easiest way to achieve authentication with OAuth 2.0 PKCE is
  //     //! to use [twitter_oauth2_pkce](https://pub.dev/packages/twitter_oauth2_pkce)!
  //     bearerToken: capitolBabbleBearerToken,
  //
  //     //! Or perhaps you would prefer to use the good old OAuth1.0a method
  //     //! over the OAuth2.0 PKCE method. Then you can use the following code
  //     //! to set the OAuth1.0a tokens.
  //     //!
  //     //! However, note that some endpoints cannot be used for OAuth 1.0a method
  //     //! authentication.
  //     oauthTokens: v2.OAuthTokens(
  //       consumerKey: capitolBabbleConsumerKey,
  //       consumerSecret: capitolBabbleConsumerSecret,
  //       accessToken: capitolBabbleAccessToken,
  //       accessTokenSecret: capitolBabbleAccessTokenSecret,
  //     ),
  //
  //     //! Automatic retry is available when a TimeoutException occurs when
  //     //! communicating with the API.
  //     retryConfig: v2.RetryConfig.ofExponentialBackOffAndJitter(
  //       maxAttempts: 5,
  //       onExecute: (event) => logger.d(
  //         '[TWITTER API] '
  //         'Retry after ${event.intervalInSeconds} seconds... '
  //         '[${event.retryCount} times]',
  //       ),
  //     ),
  //
  //     //! The default timeout is 10 seconds.
  //     timeout: const Duration(seconds: 20),
  //   );
  //
  //   try {
  //     //! Get the authenticated user's profile.
  //     final me = await twitter.users.lookupMe();
  //     debugPrint('[TWITTER API] I AM ${me.data.username} [${me.data.name}]');
  //
  //     //! Get the tweets associated with the search query.
  //     final tweets = await twitter.tweets.searchRecent(
  //       query: '#ElonMusk',
  //       maxResults: 20,
  //       // You can expand the search result.
  //       expansions: [
  //         v2.TweetExpansion.authorId,
  //         v2.TweetExpansion.inReplyToUserId,
  //       ],
  //       tweetFields: [
  //         v2.TweetField.conversationId,
  //         v2.TweetField.publicMetrics,
  //         v2.TweetField.editControls,
  //       ],
  //       userFields: [
  //         v2.UserField.location,
  //         v2.UserField.verified,
  //         v2.UserField.entities,
  //         v2.UserField.publicMetrics,
  //       ],
  //
  //       //! Safe paging is easy to implement.
  //       paging: (event) {
  //         logger.d(event.response);
  //
  //         if (event.count == 3) {
  //           return v2.ForwardPaginationControl.stop();
  //         }
  //
  //         return v2.ForwardPaginationControl.next();
  //       },
  //     );
  //
  //     //! You can serialize & deserialize JSON from response object
  //     //! and model object.
  //     final tweetJson = tweets.data.first.toJson();
  //     final tweet = v2.TweetData.fromJson(tweetJson);
  //     logger.d(tweet);
  //
  //     await twitter.tweets.createLike(
  //       userId: me.data.id,
  //       tweetId: tweets.data.first.id,
  //     );
  //
  //     //! You can upload media such as image, gif and video.
  //     final uploadedMedia = await twitter.media.uploadMedia(
  //       file: File.fromUri(Uri.file('FILE_PATH')),
  //       altText: 'This is alt text.',
  //
  //       //! You can check the upload progress.
  //       onProgress: (event) {
  //         switch (event.state) {
  //           case v2.UploadState.preparing:
  //             logger.d('Upload is preparing...');
  //             break;
  //           case v2.UploadState.inProgress:
  //             logger.d('${event.progress}% completed...');
  //             break;
  //           case v2.UploadState.completed:
  //             logger.d('Upload has completed!');
  //             break;
  //         }
  //       },
  //       onFailed: (error) => logger.d('Upload failed due to "${error.message}"'),
  //     );
  //
  //     //! You can easily post a tweet with the uploaded media.
  //     await twitter.tweets.createTweet(
  //       text: 'Tweet with uploaded media',
  //       media: v2.TweetMediaParam(
  //         mediaIds: [uploadedMedia.data.id],
  //       ),
  //     );
  //
  //     //! You can easily post a tweet.
  //     await twitter.tweets.createTweet(
  //       text: 'Hello World!',
  //     );
  //
  //     //! High-performance Volume Stream endpoint is available.
  //     final sampleStream = await twitter.tweets.connectSampleStream();
  //     await for (final response in sampleStream.stream.handleError(print)) {
  //       logger.d(response);
  //     }
  //
  //     //! Also high-performance Filtered Stream endpoint is available.
  //     await twitter.tweets.createFilteringRules(
  //       rules: [
  //         const v2.FilteringRuleParam(value: '#ElonMusk'),
  //
  //         //! You can easily build filtering rule using by "FilteringRule" object.
  //         v2.FilteringRuleParam(
  //           //! => #Tesla has:media
  //           value:
  //               v2.FilteringRule.of().matchHashtag('Tesla').and().matchTweetContainsMedia().build(),
  //         ),
  //         v2.FilteringRuleParam(
  //           //! => (#SpaceX has:media) OR (#SpaceX has:hashtags) sample:50
  //           value: v2.FilteringRule.ofSample(percent: 50)
  //               .group(
  //                 v2.FilteringRule.of().matchHashtag('SpaceX').and().matchTweetContainsMedia(),
  //               )
  //               .or()
  //               .group(
  //                 v2.FilteringRule.of().matchHashtag('SpaceX').and().matchTweetContainsHashtags(),
  //               )
  //               .build(),
  //         ),
  //       ],
  //     );
  //
  //     final filteredStream = await twitter.tweets.connectFilteredStream();
  //     await for (final response in filteredStream.stream.handleError(print)) {
  //       logger.d(response.data);
  //       logger.d(response.matchingRules);
  //     }
  //   } on TimeoutException catch (e) {
  //     logger.d(e);
  //   } on v2.UnauthorizedException catch (e) {
  //     logger.d(e);
  //   } on v2.RateLimitExceededException catch (e) {
  //     logger.d(e);
  //   } on v2.DataNotFoundException catch (e) {
  //     logger.d(e);
  //   } on v2.TwitterUploadException catch (e) {
  //     logger.d(e);
  //   } on v2.TwitterException catch (e) {
  //     logger.d(e.response.headers);
  //     logger.d(e.body);
  //     logger.d(e);
  //   }
  //   logger.d('[TWITTER API] TWITTER API PROCESS ENDED');
  // }
}
