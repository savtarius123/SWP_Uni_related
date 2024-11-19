import 'package:backend/middleware/jwt_base_manager.dart';

class GroupInvitationManager extends JwtBaseManager {
  GroupInvitationManager(super.config);

  String generateToken(int groupId, int userId) {
    final Duration duration = Duration(days: config.INVITATION_EXPIRATION_DAYS);

    return super.getToken({'groupId': groupId, 'userId': userId},
        expiresAfter: duration);
  }

  Future<Map<String, dynamic>> parseInvitation(String token) async {
    return super.getClaim(token).then((claim) {
      return claim;
    });
  }

  @override
  String get tokenType => 'invitation';
}
