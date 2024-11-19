import 'package:backend/config/config.dart';
import 'package:backend/util/logger_provider.dart';
import 'package:logger/logger.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class Mailer {
  late final Config config;
  late final SmtpServer _smtpServer;
  late final Logger _log;

  Mailer(this.config) {
    _log = LoggerProvider.instance;

    if (!config.SMTP_SECURE_CONNECTION) {
      _log.w('Using unencrypted connection to SMTP server');
    }

    _smtpServer = SmtpServer(config.SMTP_HOST,
        port: config.SMTP_PORT,
        username: config.SMTP_USERNAME,
        password: config.SMTP_PASSWORD,
        ssl: config.SMTP_SECURE_CONNECTION,
        allowInsecure: !config.SMTP_SECURE_CONNECTION,
        ignoreBadCertificate: !config.SMTP_SECURE_CONNECTION);
  }

  /// Sends an email to the recipient with the given subject and text. Returns
  /// true if the email was sent successfully, otherwise false. Can be safely
  /// called from any context as it handles exceptions internally and logs them.
  ///
  /// @param recipient The email address of the recipient.
  ///
  /// @param subject The subject of the email.
  ///
  /// @param text The text of the email.
  ///
  /// @return True if the email was sent successfully, otherwise false.
  Future<bool> sendEmail(String recipient, String subject, String text) async {
    final message = Message()
      ..from = Address(config.SMTP_FROM, config.SMTP_USERNAME)
      ..envelopeFrom = config.SMTP_FROM
      ..recipients.add(recipient)
      ..subject = subject
      ..text = text;

    try {
      final sendReport = await send(message, _smtpServer);
      _log.i('Message sent: ${sendReport.toString()}');

      return true;
    } on Exception catch (e) {
      _log.e('Message not sent: $e');

      return false;
    }
  }
}
