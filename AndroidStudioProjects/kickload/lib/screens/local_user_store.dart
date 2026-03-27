/// Simple in-memory user store.
/// Replace this with Firebase / REST API / SharedPreferences later.
class LocalUserStore {
  LocalUserStore._();

  static Map<String, String>? _user;

  /// Save a registered user's details.
  static void saveUser(Map<String, String> data) {
    _user = Map<String, String>.from(data);
  }

  /// Retrieve the registered user. Returns null if no user registered yet.
  static Map<String, String>? getUser() => _user;

  /// Clear stored user (e.g. on logout).
  static void clear() => _user = null;
}
