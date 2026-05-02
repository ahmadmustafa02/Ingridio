import 'package:ingridio/models/user_preferences.dart';

class UserPreferencesStore {
  static UserPreferences? current;
  static bool notificationsEnabled = true;
  static String selectedLanguage = 'English (US)';

  static void save(UserPreferences preferences) {
    current = preferences;
  }

  static void reset() {
    current = null;
    notificationsEnabled = true;
    selectedLanguage = 'English (US)';
  }
}
