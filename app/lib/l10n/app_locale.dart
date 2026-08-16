import 'package:flutter/widgets.dart';

import '../store/app_database.dart';

enum AppLocaleCode { en, tr }

/// App-wide locale: persisted in user_settings ('locale'), default en.
/// The ancestor (main) owns a ValueNotifier of [AppLocaleCode] and rebuilds the
/// tree; AppLocale.set persists + notifies via onChanged.
class AppLocale extends InheritedWidget {
  final AppLocaleCode code;
  final AppDatabase? db;
  final void Function(AppLocaleCode)? onChanged;
  const AppLocale(
      {super.key,
      required this.code,
      required this.db,
      required this.onChanged,
      required super.child});

  static AppLocale? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppLocale>();

  Future<void> set(AppLocaleCode value) async {
    final db = this.db;
    if (db != null) {
      await db.into(db.userSettings).insertOnConflictUpdate(
          UserSettingsCompanion.insert(key: 'locale', value: value.name));
    }
    onChanged?.call(value);
  }

  static Future<AppLocaleCode> load(AppDatabase db) async {
    final rows = await (db.select(db.userSettings)
          ..where((u) => u.key.equals('locale')))
        .get();
    if (rows.isEmpty) return AppLocaleCode.en;
    return rows.single.value == 'tr' ? AppLocaleCode.tr : AppLocaleCode.en;
  }

  @override
  bool updateShouldNotify(AppLocale old) => code != old.code;
}
