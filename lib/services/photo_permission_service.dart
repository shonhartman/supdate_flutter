import 'package:permission_handler/permission_handler.dart';

/// Service for requesting and checking photo library permission.
/// Used to prompt the user for access and to show evidence of permission status.
class PhotoPermissionService {
  PhotoPermissionService._();
  static final PhotoPermissionService instance = PhotoPermissionService._();

  /// Permission used for photo library access.
  /// On iOS: .photos; on Android: mapped by permission_handler (e.g. READ_MEDIA_IMAGES).
  Permission get _photosPermission => Permission.photos;

  /// Returns the current photo library permission status.
  Future<PermissionStatus> getPhotoPermissionStatus() async {
    return _photosPermission.status;
  }

  /// Requests photo library permission. Shows the system dialog if not yet determined.
  /// Returns the status after the user responds (or current status if already granted/denied).
  Future<PermissionStatus> requestPhotoAccess() async {
    return _photosPermission.request();
  }

  /// Opens the app's system settings page so the user can change the permission
  /// when it is permanently denied.
  Future<bool> openSettings() => openAppSettings();
}
