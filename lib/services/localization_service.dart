import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../utils/logger.dart';

// 다국어 지원 서비스
class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Map<String, String> _localizedStrings = {};
  String _currentLocale = 'ko'; // 기본 한국어

  // 지원 언어 목록 (100개)
  static const List<SupportedLanguage> supportedLanguages = [
    // 아시아 (30개)
    SupportedLanguage('ko', '한국어', 'Korean', '🇰🇷'),
    SupportedLanguage('ja', '日本語', 'Japanese', '🇯🇵'),
    SupportedLanguage('zh', '中文', 'Chinese (Simplified)', '🇨🇳'),
    SupportedLanguage('zh-TW', '繁體中文', 'Chinese (Traditional)', '🇹🇼'),
    SupportedLanguage('en', 'English', 'English', '🇺🇸'),
    SupportedLanguage('vi', 'Tiếng Việt', 'Vietnamese', '🇻🇳'),
    SupportedLanguage('th', 'ไทย', 'Thai', '🇹🇭'),
    SupportedLanguage('id', 'Bahasa Indonesia', 'Indonesian', '🇮🇩'),
    SupportedLanguage('ms', 'Bahasa Melayu', 'Malay', '🇲🇾'),
    SupportedLanguage('fil', 'Filipino', 'Filipino', '🇵🇭'),
    SupportedLanguage('hi', 'हिन्दी', 'Hindi', '🇮🇳'),
    SupportedLanguage('bn', 'বাংলা', 'Bengali', '🇧🇩'),
    SupportedLanguage('ur', 'اردو', 'Urdu', '🇵🇰'),
    SupportedLanguage('ta', 'தமிழ்', 'Tamil', '🇱🇰'),
    SupportedLanguage('te', 'తెలుగు', 'Telugu', '🇮🇳'),
    SupportedLanguage('mr', 'मराठी', 'Marathi', '🇮🇳'),
    SupportedLanguage('kn', 'ಕನ್ನಡ', 'Kannada', '🇮🇳'),
    SupportedLanguage('gu', 'ગુજરાતી', 'Gujarati', '🇮🇳'),
    SupportedLanguage('ml', 'മലയാളം', 'Malayalam', '🇮🇳'),
    SupportedLanguage('si', 'සිංහල', 'Sinhala', '🇱🇰'),
    SupportedLanguage('ne', 'नेपाली', 'Nepali', '🇳🇵'),
    SupportedLanguage('my', 'မြန်မာ', 'Burmese', '🇲🇲'),
    SupportedLanguage('km', 'ខ្មែរ', 'Khmer', '🇰🇭'),
    SupportedLanguage('lo', 'ລາວ', 'Lao', '🇱🇦'),
    SupportedLanguage('mn', 'Монгол', 'Mongolian', '🇲🇳'),
    SupportedLanguage('kk', 'Қазақ', 'Kazakh', '🇰🇿'),
    SupportedLanguage('uz', 'Oʻzbek', 'Uzbek', '🇺🇿'),
    SupportedLanguage('az', 'Azərbaycan', 'Azerbaijani', '🇦🇿'),
    SupportedLanguage('hy', 'Հայերեն', 'Armenian', '🇦🇲'),
    SupportedLanguage('ka', 'ქართული', 'Georgian', '🇬🇪'),

    // 유럽 (40개)
    SupportedLanguage('es', 'Español', 'Spanish', '🇪🇸'),
    SupportedLanguage('fr', 'Français', 'French', '🇫🇷'),
    SupportedLanguage('de', 'Deutsch', 'German', '🇩🇪'),
    SupportedLanguage('it', 'Italiano', 'Italian', '🇮🇹'),
    SupportedLanguage('pt', 'Português', 'Portuguese', '🇵🇹'),
    SupportedLanguage('pt-BR', 'Português (Brasil)', 'Portuguese (Brazil)', '🇧🇷'),
    SupportedLanguage('ru', 'Русский', 'Russian', '🇷🇺'),
    SupportedLanguage('pl', 'Polski', 'Polish', '🇵🇱'),
    SupportedLanguage('uk', 'Українська', 'Ukrainian', '🇺🇦'),
    SupportedLanguage('nl', 'Nederlands', 'Dutch', '🇳🇱'),
    SupportedLanguage('sv', 'Svenska', 'Swedish', '🇸🇪'),
    SupportedLanguage('no', 'Norsk', 'Norwegian', '🇳🇴'),
    SupportedLanguage('da', 'Dansk', 'Danish', '🇩🇰'),
    SupportedLanguage('fi', 'Suomi', 'Finnish', '🇫🇮'),
    SupportedLanguage('cs', 'Čeština', 'Czech', '🇨🇿'),
    SupportedLanguage('sk', 'Slovenčina', 'Slovak', '🇸🇰'),
    SupportedLanguage('hu', 'Magyar', 'Hungarian', '🇭🇺'),
    SupportedLanguage('ro', 'Română', 'Romanian', '🇷🇴'),
    SupportedLanguage('bg', 'Български', 'Bulgarian', '🇧🇬'),
    SupportedLanguage('el', 'Ελληνικά', 'Greek', '🇬🇷'),
    SupportedLanguage('tr', 'Türkçe', 'Turkish', '🇹🇷'),
    SupportedLanguage('hr', 'Hrvatski', 'Croatian', '🇭🇷'),
    SupportedLanguage('sr', 'Српски', 'Serbian', '🇷🇸'),
    SupportedLanguage('sl', 'Slovenščina', 'Slovenian', '🇸🇮'),
    SupportedLanguage('lt', 'Lietuvių', 'Lithuanian', '🇱🇹'),
    SupportedLanguage('lv', 'Latviešu', 'Latvian', '🇱🇻'),
    SupportedLanguage('et', 'Eesti', 'Estonian', '🇪🇪'),
    SupportedLanguage('sq', 'Shqip', 'Albanian', '🇦🇱'),
    SupportedLanguage('mk', 'Македонски', 'Macedonian', '🇲🇰'),
    SupportedLanguage('bs', 'Bosanski', 'Bosnian', '🇧🇦'),
    SupportedLanguage('is', 'Íslenska', 'Icelandic', '🇮🇸'),
    SupportedLanguage('ga', 'Gaeilge', 'Irish', '🇮🇪'),
    SupportedLanguage('cy', 'Cymraeg', 'Welsh', '🏴'),
    SupportedLanguage('mt', 'Malti', 'Maltese', '🇲🇹'),
    SupportedLanguage('lb', 'Lëtzebuergesch', 'Luxembourgish', '🇱🇺'),
    SupportedLanguage('be', 'Беларуская', 'Belarusian', '🇧🇾'),
    SupportedLanguage('gl', 'Galego', 'Galician', '🇪🇸'),
    SupportedLanguage('eu', 'Euskara', 'Basque', '🇪🇸'),
    SupportedLanguage('ca', 'Català', 'Catalan', '🇪🇸'),
    SupportedLanguage('fy', 'Frysk', 'Frisian', '🇳🇱'),

    // 중동 & 아프리카 (20개)
    SupportedLanguage('ar', 'العربية', 'Arabic', '🇸🇦'),
    SupportedLanguage('he', 'עברית', 'Hebrew', '🇮🇱'),
    SupportedLanguage('fa', 'فارسی', 'Persian', '🇮🇷'),
    SupportedLanguage('sw', 'Kiswahili', 'Swahili', '🇰🇪'),
    SupportedLanguage('am', 'አማርኛ', 'Amharic', '🇪🇹'),
    SupportedLanguage('ha', 'Hausa', 'Hausa', '🇳🇬'),
    SupportedLanguage('yo', 'Yorùbá', 'Yoruba', '🇳🇬'),
    SupportedLanguage('ig', 'Igbo', 'Igbo', '🇳🇬'),
    SupportedLanguage('zu', 'isiZulu', 'Zulu', '🇿🇦'),
    SupportedLanguage('xh', 'isiXhosa', 'Xhosa', '🇿🇦'),
    SupportedLanguage('af', 'Afrikaans', 'Afrikaans', '🇿🇦'),
    SupportedLanguage('so', 'Soomaali', 'Somali', '🇸🇴'),
    SupportedLanguage('rw', 'Kinyarwanda', 'Kinyarwanda', '🇷🇼'),
    SupportedLanguage('mg', 'Malagasy', 'Malagasy', '🇲🇬'),
    SupportedLanguage('sn', 'chiShona', 'Shona', '🇿🇼'),
    SupportedLanguage('ny', 'Chichewa', 'Chichewa', '🇲🇼'),
    SupportedLanguage('st', 'Sesotho', 'Sesotho', '🇱🇸'),
    SupportedLanguage('tn', 'Setswana', 'Tswana', '🇧🇼'),
    SupportedLanguage('ps', 'پښتو', 'Pashto', '🇦🇫'),
    SupportedLanguage('ku', 'Kurdî', 'Kurdish', '🇮🇶'),

    // 아메리카 & 오세아니아 (10개)
    SupportedLanguage('en-US', 'English (US)', 'English (US)', '🇺🇸'),
    SupportedLanguage('en-GB', 'English (UK)', 'English (UK)', '🇬🇧'),
    SupportedLanguage('en-AU', 'English (Australia)', 'English (Australia)', '🇦🇺'),
    SupportedLanguage('en-CA', 'English (Canada)', 'English (Canada)', '🇨🇦'),
    SupportedLanguage('es-MX', 'Español (México)', 'Spanish (Mexico)', '🇲🇽'),
    SupportedLanguage('es-AR', 'Español (Argentina)', 'Spanish (Argentina)', '🇦🇷'),
    SupportedLanguage('fr-CA', 'Français (Canada)', 'French (Canada)', '🇨🇦'),
    SupportedLanguage('ht', 'Kreyòl ayisyen', 'Haitian Creole', '🇭🇹'),
    SupportedLanguage('gn', 'Guaraní', 'Guarani', '🇵🇾'),
    SupportedLanguage('qu', 'Runa Simi', 'Quechua', '🇵🇪'),
  ];

  // 언어 파일 로드
  Future<void> loadLanguage(String languageCode) async {
    try {
      _currentLocale = languageCode;

      final jsonString = await rootBundle.loadString(
        'assets/i18n/$languageCode.json',
      );

      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      logger.i('Loaded language: $languageCode');
    } catch (e) {
      logger.e('Error loading language $languageCode: $e');

      // 폴백: 한국어 또는 영어
      if (languageCode != 'ko' && languageCode != 'en') {
        await loadLanguage('en');
      }
    }
  }

  // 번역 문자열 가져오기
  String translate(String key, {Map<String, String>? args}) {
    String value = _localizedStrings[key] ?? key;

    // 변수 치환 (예: {name} → 실제 이름)
    if (args != null) {
      args.forEach((argKey, argValue) {
        value = value.replaceAll('{$argKey}', argValue);
      });
    }

    return value;
  }

  // 현재 로케일
  String get currentLocale => _currentLocale;

  // 언어 검색
  static SupportedLanguage? findLanguage(String code) {
    try {
      return supportedLanguages.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }

  // 지역별 언어 그룹
  static Map<String, List<SupportedLanguage>> getLanguagesByRegion() {
    return {
      'Asia': supportedLanguages.where((l) => _isAsian(l.code)).toList(),
      'Europe': supportedLanguages.where((l) => _isEuropean(l.code)).toList(),
      'Middle East & Africa': supportedLanguages.where((l) => _isMiddleEastOrAfrican(l.code)).toList(),
      'Americas': supportedLanguages.where((l) => _isAmerican(l.code)).toList(),
    };
  }

  static bool _isAsian(String code) {
    return ['ko', 'ja', 'zh', 'zh-TW', 'vi', 'th', 'id', 'ms', 'fil', 'hi', 'bn', 'ur', 'ta', 'te', 'mr', 'kn', 'gu', 'ml', 'si', 'ne', 'my', 'km', 'lo', 'mn', 'kk', 'uz', 'az', 'hy', 'ka'].contains(code);
  }

  static bool _isEuropean(String code) {
    return ['en', 'es', 'fr', 'de', 'it', 'pt', 'pt-BR', 'ru', 'pl', 'uk', 'nl', 'sv', 'no', 'da', 'fi', 'cs', 'sk', 'hu', 'ro', 'bg', 'el', 'tr', 'hr', 'sr', 'sl', 'lt', 'lv', 'et', 'sq', 'mk', 'bs', 'is', 'ga', 'cy', 'mt', 'lb', 'be', 'gl', 'eu', 'ca', 'fy'].contains(code);
  }

  static bool _isMiddleEastOrAfrican(String code) {
    return ['ar', 'he', 'fa', 'sw', 'am', 'ha', 'yo', 'ig', 'zu', 'xh', 'af', 'so', 'rw', 'mg', 'sn', 'ny', 'st', 'tn', 'ps', 'ku'].contains(code);
  }

  static bool _isAmerican(String code) {
    return ['en-US', 'en-GB', 'en-AU', 'en-CA', 'es-MX', 'es-AR', 'fr-CA', 'ht', 'gn', 'qu'].contains(code);
  }
}

// 지원 언어 모델
class SupportedLanguage {
  final String code; // 언어 코드 (ISO 639-1)
  final String nativeName; // 원어명
  final String englishName; // 영어명
  final String flag; // 국기 이모지

  const SupportedLanguage(
    this.code,
    this.nativeName,
    this.englishName,
    this.flag,
  );
}

// Extension for easy access
extension LocalizationExtension on String {
  String tr({Map<String, String>? args}) {
    return LocalizationService().translate(this, args: args);
  }
}
