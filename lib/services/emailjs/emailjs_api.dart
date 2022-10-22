import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:us_congress_vote_tracker/functions/functions.dart';

class EmailjsApi {
  /// SEND USER COMMENT EMAIL
  static Future<void> sendCommentEmail(
      String subject, String message, String toEmail,
      {String fromEmail = 'themettaman@gmail.com',
      String fromName = 'US Congress App (User Comment Email)',
      String toName = 'MettaCode Dev',
      String additionalData1 = 'No Additional Data',
      String additionalData2 = 'No Additional Data',
      String additionalData3 = 'No Additional Data',
      String additionalData4 = 'No Additional Data',
      String additionalData5 = 'No Additional Data'}) async {
    logger.d('SENDING EMAIL FROM $fromEmail TO $toEmail');

    final serviceId = dotenv.env['MCSERVICEID'];
    final templateId = dotenv.env['MCTEMPLATEID'];
    final publicKey = dotenv.env['MCPUBLICKEY'];
    // final privateKey = dotenv.env['MCPRIVATEKEY'];

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'subject': '[USC APP USER COMMENT] $subject',
            'message': message,
            'to_name': toName,
            'from_name': fromName,
            'to_email': toEmail,
            'from_email': fromEmail,
            'additional_data_1': additionalData1,
            'additional_data_2': additionalData2,
            'additional_data_3': additionalData3,
            'additional_data_4': additionalData4,
            'additional_data_5': additionalData5,
          }
        }));

    logger.i(response.statusCode);
  }

  /// SEND CAPITOL BABBLE TWEET EMAIL
  static Future<void> sendCapitolBabbleSocialEmail(
      {String messageBody = '', String subject = ''}) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    List<bool> userLevels = await Functions.getUserLevels();
    bool userIsDev = userLevels[0];
    // bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];

    List<String> capitolBabbleNotificationsList =
        List<String>.from(userDatabase.get('capitolBabbleNotificationsList'));

    if (userIsDev &&
        capitolBabbleNotificationsList.isNotEmpty &&
        ((isPeakCapitolBabblePostHours &&
                DateTime.parse(userDatabase.get('lastCapitolBabble')).isBefore(DateTime.now()
                    .subtract(Duration(minutes: capitolBabbleDelayMinutes)))) ||
            (capitolBabbleNotificationsList.any((element) =>
                    element.split('<|:|>')[3].toLowerCase() == 'high') &&
                DateTime.parse(userDatabase.get('lastCapitolBabble')).isBefore(
                    DateTime.now().subtract(
                        Duration(minutes: capitolBabbleDelayMinutes ~/ 4)))) ||
            (capitolBabbleNotificationsList.any((element) =>
                    element.split('<|:|>')[3].toLowerCase() == 'medium') &&
                DateTime.parse(userDatabase.get('lastCapitolBabble')).isBefore(
                    DateTime.now().subtract(Duration(minutes: capitolBabbleDelayMinutes ~/ 2)))))) {
      capitolBabbleNotificationsList
          .sort((a, b) => a.split('<|:|>')[3].compareTo(b.split('<|:|>')[3]));

      if (capitolBabbleNotificationsList.length > 20)
        capitolBabbleNotificationsList.removeRange(
            20, capitolBabbleNotificationsList.length);

      final serviceId = dotenv.env['CBSERVICEID'];
      final templateId = dotenv.env['CBTEMPLATEID'];
      final publicKey = dotenv.env['MCPUBLICKEY'];

      String _nextBabble = capitolBabbleNotificationsList.first;
      // DateTime _nextBabbleDateTime =
      //     DateTime.parse(_nextBabble.split('<|:|>')[0]);
      String _nextBabbleSubject = _nextBabble.split('<|:|>')[1];
      String _nextBabbleBody = _nextBabble.split('<|:|>')[2];
      // String _nextBabblePriority = _nextBabble.split('<|:|>')[3];
      String _nextBabbleUrl = '';
      if (_nextBabble.split('<|:|>').length > 4) {
        _nextBabbleUrl = _nextBabble.split('<|:|>')[4];
      }

      String _rawMessage = subject.isNotEmpty && messageBody.isNotEmpty
          ? messageBody
          : _nextBabbleBody;
      debugPrint('SENDING EMAIL TO CAPITOL BABBLE SOCIALS: $_rawMessage');

      String _finalMessage = '';
      await Functions.addHashTags(_rawMessage)
          .then((str) => _finalMessage = '$str $_nextBabbleUrl');

      try {
        final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
        final response = await http.post(url,
            headers: {
              'origin': 'http://localhost',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'service_id': serviceId,
              'template_id': templateId,
              'user_id': publicKey,
              'template_params': {
                'subject': subject.isNotEmpty && messageBody.isNotEmpty
                    ? subject + '#capitolbabble'
                    : _nextBabbleSubject + '#capitolbabble',
                'message': _finalMessage,
              }
            }));
        debugPrint(response.statusCode.toString());

        if (response.statusCode == 200) {
          capitolBabbleNotificationsList.removeAt(0);
          userDatabase.put(
              'capitolBabbleNotificationsList', capitolBabbleNotificationsList);
          userDatabase.put('lastCapitolBabble', '${DateTime.now()}');
        }
      } catch (error) {
        debugPrint('ERROR SENDING EMAILJS TO CAPITOL BABBLE: $error');
      }
    } else
      debugPrint(
          'CAPITOL BABBLE SOCIALS EMAIL NOT SENT. PEAK HOURS IS ${isPeakCapitolBabblePostHours.toString().toUpperCase()} AND LAST BABBLE SENT WAS ${dateWithTimeFormatter.format(DateTime.parse(userDatabase.get('lastCapitolBabble')))}');
  }

  /// SEND FREE TRIAL STARTED EMAIL
  static Future<void> sendFreeTrialEmail(String subject, String message,
      {String fromEmail = 'themettaman@gmail.com',
      String fromName = 'US Congress App (Free Trial Notification)',
      String toEmail = 'mettacode@gmail.com',
      String toName = 'MettaCode Dev',
      String additionalData1 = 'No Additional Data',
      String additionalData2 = 'No Additional Data',
      String additionalData3 = 'No Additional Data',
      String additionalData4 = 'No Additional Data',
      String additionalData5 = 'No Additional Data'}) async {
    logger.d('SENDING FREE TRIAL STARTED EMAIL');

    final serviceId = dotenv.env['MCSERVICEID'];
    final publicKey = dotenv.env['MCPUBLICKEY'];
    // final privateKey = dotenv.env['MCPRIVATEKEY'];
    final templateId = dotenv.env['FTTEMPLATEID'];

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'subject': '[USC APP FREE TRIAL STARTED] $subject',
            'message': message,
            'to_name': toName,
            'from_name': fromName,
            'to_email': toEmail,
            'from_email': fromEmail,
            'additional_data_1': additionalData1,
            'additional_data_2': additionalData2,
            'additional_data_3': additionalData3,
            'additional_data_4': additionalData4,
            'additional_data_5': additionalData5,
          }
        }));

    logger.i(response.statusCode);
  }

  /// SEND ECWID ORDER WITH CREDITS EMAIL
  static Future<void> sendEcwidOrderWithCreditsEmail(
      String subject, String message, String customerEmail, String customerName,
      {String customerPhone = 'No Phone Data',
      String customerAddress = 'No Address Data',
      String orderId = 'No Order ID Data',
      String orderIdExtended = 'No Extended Order ID Data',
      String orderDate = 'No Order Date Data',
      String creditsUsed = 'No Credits Used Data',
      String productName = 'No Product Name Data',
      String productOptions = 'No Product Options Data',
      String productImageUrl = 'No Product Image Data',
      String otherProductInfo = 'No Other Product Info Data',
      String allProductInfo = 'No Product Data',
      String appUserId = 'No User ID Data',
      String appUserStatus = 'No User Status Data',
      String appUserLocation = 'No User Location Data'}) async {
    logger.d('SENDING NEW ECWID ORDER EMAIL');

    final serviceId = dotenv.env['MCSERVICEID'];
    final publicKey = dotenv.env['MCPUBLICKEY'];
    // final privateKey = dotenv.env['MCPRIVATEKEY'];
    final templateId = dotenv.env['EPOTEMPLATEID'];

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'subject': '[PRODUCT ORDER] $subject',
            'message': message,
            'store_name': 'US Congress App',
            'store_email': 'mettacode@gmail.com',
            'customer_name': customerName,
            'customer_email': customerEmail,
            'customer_phone': customerPhone,
            'customer_address': customerAddress,
            'order_id': orderId,
            'order_id_extended': orderIdExtended,
            'order_date': orderDate,
            'credits_used': creditsUsed,
            'product_name': productName,
            'product_options': productOptions,
            'product_image_url': productImageUrl,
            'other_product_info': otherProductInfo,
            'all_product_info': allProductInfo,
            'app_user_id': appUserId,
            'app_user_status': appUserStatus,
            'app_user_location': appUserLocation,
          }
        }));

    logger.i(response.statusCode);
  }
}
