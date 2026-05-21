import 'package:flutter/widgets.dart';

/// Hand-rolled string table. Two locales (en, ar), no codegen, no ARB files.
///
/// Lookup happens through `Localizations.localeOf(context)`, so when
/// `MaterialApp.locale` changes the whole tree rebuilds with the new value
/// — no need for callers to listen to anything manually.
class AppStrings {
  AppStrings._();

  static const Map<String, String> _en = {
    'app_name': 'Janna October Services',

    // Bottom nav
    'home': 'Home',
    'categories': 'Categories',
    'favorites': 'Favorites',
    'numbers': 'Numbers',

    // Section headers
    'important_numbers': 'Important numbers',
    'featured_providers': 'Featured providers',
    'browse_categories': 'Browse categories',
    'about': 'About',
    'gallery': 'Gallery',
    'menu': 'Menu',
    'products': 'Products',
    'related_providers': 'Related providers',

    // Actions
    'search': 'Search',
    'search_hint': 'Search providers, services...',
    'see_all': 'See all',
    'view_all': 'View all',
    'call': 'Call',
    'whatsapp': 'WhatsApp',
    'location': 'Location',
    'retry': 'Retry',
    'view_details': 'View details',
    'filter': 'Filter',

    // Provider details
    'working_hours': 'Working hours',
    'address': 'Address',
    'phone': 'Phone',

    // Badges
    'featured': 'Featured',
    'inside_compound': 'Inside compound',
    'near_compound': 'Near compound',

    // Filters
    'all_categories': 'All categories',
    'featured_only': 'Featured only',
    'any_area': 'Any area',

    // Empty / error / loading states
    'no_results': 'No results found',
    'no_results_for': 'Nothing matched "{q}".',
    'no_providers_match': 'No providers match',
    'try_removing_filters': 'Try removing some filters.',
    'no_providers_yet': 'No providers yet',
    'no_providers_in_category': 'This category will be populated soon.',
    'no_categories_yet': 'No categories yet',
    'no_categories_message': 'New categories will appear here.',
    'no_numbers_yet': 'No numbers yet',
    'no_favorites': 'No favorites yet',
    'tap_heart_to_save': 'Tap the heart on any provider to save it here.',
    'find_something': 'Find something',
    'find_something_hint': 'Type a service name, restaurant, pharmacy, or anything else.',
    'something_went_wrong': 'Something went wrong.',
    'no_internet': 'No internet connection. Please check your network.',
    'server_timeout': 'The server took too long to respond.',
    'invalid_response': 'Received an invalid response from the server.',

    // Language switcher
    'language': 'Language',
    'language_english': 'English',
    'language_arabic': 'العربية',

    // Counters (very basic — one form only)
    'n_providers': '{n} providers',

    // Standalone noun
    'providers': 'Providers',
    'more': 'More',
    'all': 'All',
  };

  static const Map<String, String> _ar = {
    'app_name': 'خدمات جنة أكتوبر',

    // Bottom nav
    'home': 'الرئيسية',
    'categories': 'الأقسام',
    'favorites': 'المفضلة',
    'numbers': 'الأرقام',

    // Section headers
    'important_numbers': 'أرقام مهمة',
    'featured_providers': 'مزودو خدمات مميزون',
    'browse_categories': 'تصفح الأقسام',
    'about': 'نبذة',
    'gallery': 'معرض الصور',
    'menu': 'المنيو',
    'products': 'المنتجات',
    'related_providers': 'مزودون مشابهون',

    // Actions
    'search': 'بحث',
    'search_hint': 'ابحث عن خدمات أو مزودين...',
    'see_all': 'عرض الكل',
    'view_all': 'عرض الكل',
    'call': 'اتصال',
    'whatsapp': 'واتساب',
    'location': 'الموقع',
    'retry': 'إعادة المحاولة',
    'view_details': 'عرض التفاصيل',
    'filter': 'تصفية',

    // Provider details
    'working_hours': 'مواعيد العمل',
    'address': 'العنوان',
    'phone': 'الهاتف',

    // Badges
    'featured': 'مميز',
    'inside_compound': 'داخل الكمبوند',
    'near_compound': 'قريب من الكمبوند',

    // Filters
    'all_categories': 'كل الأقسام',
    'featured_only': 'المميزون فقط',
    'any_area': 'أي منطقة',

    // Empty / error / loading states
    'no_results': 'لا توجد نتائج',
    'no_results_for': 'لا توجد نتائج لـ "{q}".',
    'no_providers_match': 'لا يوجد مزودو خدمات مطابقون',
    'try_removing_filters': 'جرّب إزالة بعض عوامل التصفية.',
    'no_providers_yet': 'لا يوجد مزودو خدمات بعد',
    'no_providers_in_category': 'سيتم إضافة مزودي خدمات قريبًا.',
    'no_categories_yet': 'لا توجد أقسام بعد',
    'no_categories_message': 'ستظهر الأقسام الجديدة هنا.',
    'no_numbers_yet': 'لا توجد أرقام بعد',
    'no_favorites': 'لا توجد مفضلة بعد',
    'tap_heart_to_save': 'اضغط على القلب لحفظ أي مزود خدمة هنا.',
    'find_something': 'ابحث عن شيء',
    'find_something_hint': 'اكتب اسم خدمة أو مطعم أو صيدلية أو أي شيء آخر.',
    'something_went_wrong': 'حدث خطأ ما.',
    'no_internet': 'لا يوجد اتصال بالإنترنت. يُرجى التحقق من الشبكة.',
    'server_timeout': 'الخادم استغرق وقتًا طويلًا في الاستجابة.',
    'invalid_response': 'تم استلام استجابة غير صالحة من الخادم.',

    // Language switcher
    'language': 'اللغة',
    'language_english': 'English',
    'language_arabic': 'العربية',

    // Counters (very basic — one form only)
    'n_providers': '{n} من مزودي الخدمة',

    // Standalone noun
    'providers': 'مزودو الخدمات',
    'more': 'المزيد',
    'all': 'الكل',
  };

  static String of(BuildContext context, String key) {
    final code = Localizations.localeOf(context).languageCode;
    final dict = code == 'ar' ? _ar : _en;
    return dict[key] ?? _en[key] ?? key;
  }
}

/// Sugar so callers can write `context.tr('home')` instead of
/// `AppStrings.of(context, 'home')`.
extension AppStringsContext on BuildContext {
  String tr(String key) => AppStrings.of(this, key);

  /// String with a single `{q}`-style replacement.
  String trf(String key, Map<String, String> params) {
    var s = AppStrings.of(this, key);
    params.forEach((k, v) => s = s.replaceAll('{$k}', v));
    return s;
  }
}
