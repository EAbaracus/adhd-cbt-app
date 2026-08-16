import 'app_locale.dart';

/// Dependency-free UI string layer. en/tr maps; missing key falls back to en
/// (G3: never crashes). Screens not yet migrated are documented follow-ups.
class AppStrings {
  static const _en = <String, String>{
    'home_title': 'Program',
    'nav_tasks': 'Tasks',
    'nav_timer': 'Focus timer',
    'nav_progress': 'Progress',
    'nav_settings': 'Settings',
    'settings_title': 'Settings',
    'settings_language': 'Language',
    'settings_account': 'Account',
    'settings_logout': 'Log out',
    'settings_delete': 'Delete account',
    'settings_delete_hint': 'Type delete to confirm',
    'settings_delete_error': 'Could not delete the account. Try again later.',
    'settings_email': 'Signed in as',
    'crisis_title': 'If you are in crisis',
    'crisis_body': 'Call or text 988 (US). You matter.',
    'logout_confirm': 'Log out?',
    'logout_confirm_body': 'Your progress stays on this device.',
  };

  static const _tr = <String, String>{
    'home_title': 'Program',
    'nav_tasks': 'Görevler',
    'nav_timer': 'Odak zamanlayıcı',
    'nav_progress': 'İlerleme',
    'nav_settings': 'Ayarlar',
    'settings_title': 'Ayarlar',
    'settings_language': 'Dil',
    'settings_account': 'Hesap',
    'settings_logout': 'Çıkış yap',
    'settings_delete': 'Hesabı sil',
    'settings_delete_hint': 'Onaylamak için delete yazın',
    'settings_delete_error': 'Hesap silinemedi. Daha sonra tekrar deneyin.',
    'settings_email': 'Oturum açıldı:',
    'crisis_title': 'Krizdeyseniz',
    'crisis_body': '112’yi arayın. Önemsiz değilsiniz.',
    'logout_confirm': 'Çıkış yapılsın mı?',
    'logout_confirm_body': 'İlerlemeniz bu cihazda kalır.',
  };

  static String tr(AppLocaleCode code, String key) {
    if (code == AppLocaleCode.tr && _tr.containsKey(key)) {
      return _tr[key]!;
    }
    return _en[key] ?? key;
  }
}
