#!/usr/bin/env python3
"""
ChoreQuest Auto Translation Script
자동으로 100개 언어 번역 파일 생성

사용법:
python auto_translate.py

필요 패키지:
pip install googletrans==4.0.0-rc1
또는
pip install deep-translator
"""

import json
import os
from pathlib import Path

try:
    from googletrans import Translator
    USE_GOOGLE = True
except ImportError:
    print("googletrans not found. Install: pip install googletrans==4.0.0-rc1")
    try:
        from deep_translator import GoogleTranslator
        USE_GOOGLE = False
    except ImportError:
        print("deep_translator not found. Install: pip install deep-translator")
        exit(1)

# 언어 코드 매핑 (Flutter locale code -> Google Translate code)
LANGUAGE_CODES = {
    'ko': 'ko',  # 한국어 (기준)
    'en': 'en',  # 영어
    'ja': 'ja',  # 일본어
    'zh': 'zh-cn',  # 중국어 간체
    'zh-TW': 'zh-tw',  # 중국어 번체
    'vi': 'vi',  # 베트남어
    'th': 'th',  # 태국어
    'id': 'id',  # 인도네시아어
    'ms': 'ms',  # 말레이어
    'fil': 'tl',  # 필리핀어 (타갈로그어)
    'hi': 'hi',  # 힌디어
    'bn': 'bn',  # 벵골어
    'ur': 'ur',  # 우르두어
    'ta': 'ta',  # 타밀어
    'te': 'te',  # 텔루구어
    'mr': 'mr',  # 마라티어
    'kn': 'kn',  # 칸나다어
    'gu': 'gu',  # 구자라트어
    'ml': 'ml',  # 말라얄람어
    'si': 'si',  # 싱할라어
    'ne': 'ne',  # 네팔어
    'my': 'my',  # 버마어
    'km': 'km',  # 크메르어
    'lo': 'lo',  # 라오어
    'mn': 'mn',  # 몽골어
    'kk': 'kk',  # 카자흐어
    'uz': 'uz',  # 우즈베크어
    'az': 'az',  # 아제르바이잔어
    'hy': 'hy',  # 아르메니아어
    'ka': 'ka',  # 조지아어
    'es': 'es',  # 스페인어
    'fr': 'fr',  # 프랑스어
    'de': 'de',  # 독일어
    'it': 'it',  # 이탈리아어
    'pt': 'pt',  # 포르투갈어
    'pt-BR': 'pt',  # 포르투갈어 (브라질)
    'ru': 'ru',  # 러시아어
    'pl': 'pl',  # 폴란드어
    'uk': 'uk',  # 우크라이나어
    'nl': 'nl',  # 네덜란드어
    'sv': 'sv',  # 스웨덴어
    'no': 'no',  # 노르웨이어
    'da': 'da',  # 덴마크어
    'fi': 'fi',  # 핀란드어
    'cs': 'cs',  # 체코어
    'sk': 'sk',  # 슬로바키아어
    'hu': 'hu',  # 헝가리어
    'ro': 'ro',  # 루마니아어
    'bg': 'bg',  # 불가리아어
    'el': 'el',  # 그리스어
    'tr': 'tr',  # 터키어
    'hr': 'hr',  # 크로아티아어
    'sr': 'sr',  # 세르비아어
    'sl': 'sl',  # 슬로베니아어
    'lt': 'lt',  # 리투아니아어
    'lv': 'lv',  # 라트비아어
    'et': 'et',  # 에스토니아어
    'sq': 'sq',  # 알바니아어
    'mk': 'mk',  # 마케도니아어
    'bs': 'bs',  # 보스니아어
    'is': 'is',  # 아이슬란드어
    'ga': 'ga',  # 아일랜드어
    'cy': 'cy',  # 웨일스어
    'mt': 'mt',  # 몰타어
    'be': 'be',  # 벨라루스어
    'gl': 'gl',  # 갈리시아어
    'eu': 'eu',  # 바스크어
    'ca': 'ca',  # 카탈루냐어
    'ar': 'ar',  # 아랍어
    'he': 'iw',  # 히브리어
    'fa': 'fa',  # 페르시아어
    'sw': 'sw',  # 스와힐리어
    'am': 'am',  # 암하라어
    'ha': 'ha',  # 하우사어
    'yo': 'yo',  # 요루바어
    'ig': 'ig',  # 이그보어
    'zu': 'zu',  # 줄루어
    'xh': 'xh',  # 코사어
    'af': 'af',  # 아프리칸스어
    'so': 'so',  # 소말리어
    'mg': 'mg',  # 말라가시어
    'sn': 'sn',  # 쇼나어
    'ny': 'ny',  # 치체와어
    'st': 'st',  # 세소토어
    'ps': 'ps',  # 파슈토어
    'ku': 'ku',  # 쿠르드어
    'en-US': 'en',
    'en-GB': 'en',
    'en-AU': 'en',
    'en-CA': 'en',
    'es-MX': 'es',
    'es-AR': 'es',
    'fr-CA': 'fr',
    'ht': 'ht',  # 아이티 크레올어
}


def translate_text(text, target_lang, translator):
    """텍스트 번역"""
    try:
        if USE_GOOGLE:
            result = translator.translate(text, dest=target_lang, src='ko')
            return result.text
        else:
            result = GoogleTranslator(source='ko', target=target_lang).translate(text)
            return result
    except Exception as e:
        print(f"  ⚠️  Translation error for '{text}' to {target_lang}: {e}")
        return text  # 실패 시 원문 반환


def translate_json_file(source_file, target_lang_code, target_lang_name):
    """JSON 파일 번역"""
    print(f"\n🔄 Translating to {target_lang_name} ({target_lang_code})...")

    # 소스 파일 로드
    with open(source_file, 'r', encoding='utf-8') as f:
        source_data = json.load(f)

    # 번역 초기화
    if USE_GOOGLE:
        translator = Translator()
    else:
        translator = None

    # Google Translate 언어 코드
    google_lang = LANGUAGE_CODES.get(target_lang_code, target_lang_code)

    # 번역 수행
    translated_data = {}
    total = len(source_data)
    for idx, (key, value) in enumerate(source_data.items(), 1):
        # 변수 플레이스홀더 보호 (예: {name}, {xp})
        protected_value = value
        placeholders = []

        import re
        pattern = r'\{[^}]+\}'
        matches = re.findall(pattern, value)
        for i, match in enumerate(matches):
            placeholder = f"__PLACEHOLDER_{i}__"
            placeholders.append((placeholder, match))
            protected_value = protected_value.replace(match, placeholder)

        # 번역
        if protected_value.strip():  # 빈 문자열이 아닌 경우만
            translated = translate_text(protected_value, google_lang, translator)

            # 플레이스홀더 복원
            for placeholder, original in placeholders:
                translated = translated.replace(placeholder, original)

            translated_data[key] = translated
        else:
            translated_data[key] = value

        # 진행률 표시
        if idx % 10 == 0:
            print(f"  Progress: {idx}/{total} ({idx*100//total}%)")

    return translated_data


def main():
    """메인 함수"""
    print("🌍 ChoreQuest Auto Translation Script")
    print("=" * 50)

    # 경로 설정
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    i18n_dir = project_root / 'assets' / 'i18n'
    source_file = i18n_dir / 'ko.json'

    # 소스 파일 확인
    if not source_file.exists():
        print(f"❌ Source file not found: {source_file}")
        return

    print(f"✅ Source file: {source_file}")
    print(f"📁 Output directory: {i18n_dir}")

    # 번역할 언어 선택
    print("\n번역할 언어를 선택하세요:")
    print("1. 주요 10개 언어만")
    print("2. 모든 100개 언어 (시간 오래 걸림)")
    print("3. 특정 언어만")

    choice = input("\n선택 (1/2/3): ").strip()

    if choice == '1':
        # 주요 언어만
        target_langs = {
            'en': 'English',
            'ja': 'Japanese',
            'zh': 'Chinese (Simplified)',
            'es': 'Spanish',
            'fr': 'French',
            'de': 'German',
            'pt': 'Portuguese',
            'ru': 'Russian',
            'ar': 'Arabic',
            'hi': 'Hindi',
        }
    elif choice == '2':
        # 모든 언어
        target_langs = {code: f'Language-{code}' for code in LANGUAGE_CODES.keys() if code != 'ko'}
    elif choice == '3':
        # 특정 언어
        lang_code = input("언어 코드 입력 (예: ja, zh, es): ").strip()
        if lang_code in LANGUAGE_CODES:
            target_langs = {lang_code: f'Language-{lang_code}'}
        else:
            print(f"❌ 지원하지 않는 언어 코드: {lang_code}")
            return
    else:
        print("❌ 잘못된 선택")
        return

    # 번역 시작
    print(f"\n🚀 Starting translation for {len(target_langs)} languages...")

    for lang_code, lang_name in target_langs.items():
        try:
            translated_data = translate_json_file(source_file, lang_code, lang_name)

            # 파일 저장
            output_file = i18n_dir / f'{lang_code}.json'
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(translated_data, f, ensure_ascii=False, indent=2)

            print(f"✅ Saved: {output_file}")

        except Exception as e:
            print(f"❌ Failed to translate {lang_code}: {e}")

    print("\n🎉 Translation complete!")


if __name__ == '__main__':
    main()
