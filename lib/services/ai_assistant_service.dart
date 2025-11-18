import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/chore_model.dart';
import '../utils/logger.dart';

// AI 어시스턴트 "영희" 서비스
class AIAssistantService {
  static final AIAssistantService _instance = AIAssistantService._internal();
  factory AIAssistantService() => _instance;
  AIAssistantService._internal();

  // OpenAI API 키 (환경 변수 또는 Firebase Remote Config에서 로드)
  String? _apiKey;
  static const String _apiEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _visionEndpoint = 'https://api.openai.com/v1/chat/completions';

  // API 키 설정
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  // GPT-4를 사용한 일반 대화
  Future<String> chat(String userMessage, {String? context}) async {
    if (_apiKey == null) {
      throw Exception('OpenAI API key not set');
    }

    try {
      final messages = [
        {
          'role': 'system',
          'content': _getSystemPrompt(context),
        },
        {
          'role': 'user',
          'content': userMessage,
        },
      ];

      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-4',
          'messages': messages,
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final message = data['choices'][0]['message']['content'];
        logger.i('AI response: $message');
        return message;
      } else {
        logger.e('OpenAI API error: ${response.statusCode} ${response.body}');
        throw Exception('Failed to get AI response');
      }
    } catch (e) {
      logger.e('AI chat error: $e');
      rethrow;
    }
  }

  // 냉장고 사진 분석 (GPT-4 Vision)
  Future<FridgeAnalysisResult> analyzeFridgeImage(File imageFile) async {
    if (_apiKey == null) {
      throw Exception('OpenAI API key not set');
    }

    try {
      // 이미지를 Base64로 인코딩
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final messages = [
        {
          'role': 'system',
          'content': '''당신은 냉장고 속 식재료를 분석하는 전문가입니다.
사진을 보고 다음을 분석해주세요:
1. 식재료 목록 (신선도 포함)
2. 곧 상할 것 같은 재료
3. 추천 레시피 (오늘 만들면 좋은 요리)
4. 장보기 추천 (부족한 재료)

한국 가정의 냉장고이므로 한국 음식 위주로 추천하되, 응답은 JSON 형식으로 해주세요.'''
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': '이 냉장고 사진을 분석해주세요.',
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
              },
            },
          ],
        },
      ];

      final response = await http.post(
        Uri.parse(_visionEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-4-vision-preview',
          'messages': messages,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];

        // JSON 파싱 (AI가 JSON으로 응답했다고 가정)
        try {
          final analysisData = json.decode(content);
          return FridgeAnalysisResult.fromJson(analysisData);
        } catch (e) {
          // JSON 파싱 실패 시 텍스트 그대로 사용
          return FridgeAnalysisResult(
            ingredients: [],
            expiringSoon: [],
            recommendedRecipes: [content],
            shoppingList: [],
          );
        }
      } else {
        logger.e('Vision API error: ${response.statusCode}');
        throw Exception('Failed to analyze fridge');
      }
    } catch (e) {
      logger.e('Fridge analysis error: $e');
      rethrow;
    }
  }

  // 집 사진 분석 (청결도 평가)
  Future<HomeAnalysisResult> analyzeHomeImage(File imageFile, String roomName) async {
    if (_apiKey == null) {
      throw Exception('OpenAI API key not set');
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final messages = [
        {
          'role': 'system',
          'content': '''당신은 집 청결도를 평가하는 전문가입니다.
사진을 보고 다음을 분석해주세요:
1. 청결도 점수 (0-100점)
2. 문제점 (정리가 필요한 부분)
3. 추천 집안일 (우선순위 순)
4. 예상 소요 시간

응답은 JSON 형식으로 해주세요.'''
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': '$roomName 사진을 분석해주세요.',
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
              },
            },
          ],
        },
      ];

      final response = await http.post(
        Uri.parse(_visionEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-4-vision-preview',
          'messages': messages,
          'max_tokens': 800,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];

        try {
          final analysisData = json.decode(content);
          return HomeAnalysisResult.fromJson(analysisData);
        } catch (e) {
          return HomeAnalysisResult(
            cleanliness: 50,
            issues: ['분석 실패'],
            recommendedChores: [],
            estimatedMinutes: 0,
          );
        }
      } else {
        throw Exception('Failed to analyze home');
      }
    } catch (e) {
      logger.e('Home analysis error: $e');
      rethrow;
    }
  }

  // 레시피 추천
  Future<List<Recipe>> recommendRecipes({
    required List<String> ingredients,
    String? mealType, // breakfast, lunch, dinner
    String? dietaryRestriction, // vegetarian, vegan, etc.
  }) async {
    try {
      final prompt = '''다음 재료로 만들 수 있는 레시피를 3개 추천해주세요:
재료: ${ingredients.join(', ')}
${mealType != null ? '식사 유형: $mealType' : ''}
${dietaryRestriction != null ? '식이 제한: $dietaryRestriction' : ''}

한국 가정 요리 위주로 추천해주시고, 각 레시피는 다음 정보를 포함해주세요:
1. 요리 이름
2. 필요한 추가 재료
3. 간단한 조리법 (5단계 이내)
4. 예상 조리 시간

JSON 배열 형식으로 응답해주세요.''';

      final response = await chat(prompt);

      try {
        final List<dynamic> recipesData = json.decode(response);
        return recipesData.map((data) => Recipe.fromJson(data)).toList();
      } catch (e) {
        // JSON 파싱 실패 시 텍스트로 변환
        return [
          Recipe(
            name: '추천 레시피',
            ingredients: ingredients,
            steps: [response],
            estimatedMinutes: 30,
          ),
        ];
      }
    } catch (e) {
      logger.e('Recipe recommendation error: $e');
      rethrow;
    }
  }

  // AI 기반 집안일 자동 생성
  Future<List<ChoreModel>> suggestChores({
    required String householdType, // newlywed, family, roommate
    required List<String> recentChores,
    required int householdSize,
  }) async {
    try {
      final prompt = '''가구 유형: $householdType
구성원 수: $householdSize명
최근 한 집안일: ${recentChores.join(', ')}

위 정보를 바탕으로 오늘 해야 할 집안일을 5개 추천해주세요.
각 집안일은 다음 정보를 포함해주세요:
1. 제목
2. 설명
3. 난이도 (easy/medium/hard)
4. 예상 소요 시간 (분)
5. 카테고리

JSON 배열 형식으로 응답해주세요.''';

      final response = await chat(prompt);

      try {
        final List<dynamic> choresData = json.decode(response);
        return choresData.map((data) {
          return ChoreModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            householdId: '', // 나중에 할당
            title: data['title'] ?? '',
            description: data['description'],
            difficulty: _parseDifficulty(data['difficulty']),
            status: ChoreStatus.pending,
          );
        }).toList();
      } catch (e) {
        logger.e('Failed to parse AI chore suggestions: $e');
        return [];
      }
    } catch (e) {
      logger.e('AI chore suggestion error: $e');
      rethrow;
    }
  }

  // 시스템 프롬프트 생성
  String _getSystemPrompt(String? context) {
    return '''당신은 "영희"라는 이름의 친절한 AI 가사 도우미입니다.
한국 가정의 집안일을 돕고, 레시피를 추천하며, 가족 간의 협력을 돕습니다.

특징:
- 친근하고 따뜻한 말투
- 한국 문화와 음식에 대한 깊은 이해
- 실용적이고 구체적인 조언
- 가족 간의 공정한 분담을 중시

${context != null ? '현재 상황: $context' : ''}

항상 한국어로 응답하며, 이모지를 적절히 사용하여 친근감을 줍니다.''';
  }

  // 난이도 파싱
  ChoreDifficulty _parseDifficulty(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return ChoreDifficulty.easy;
      case 'hard':
        return ChoreDifficulty.hard;
      default:
        return ChoreDifficulty.medium;
    }
  }
}

// 냉장고 분석 결과
class FridgeAnalysisResult {
  final List<FridgeIngredient> ingredients;
  final List<String> expiringSoon;
  final List<String> recommendedRecipes;
  final List<String> shoppingList;

  FridgeAnalysisResult({
    required this.ingredients,
    required this.expiringSoon,
    required this.recommendedRecipes,
    required this.shoppingList,
  });

  factory FridgeAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FridgeAnalysisResult(
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((i) => FridgeIngredient.fromJson(i))
              .toList() ??
          [],
      expiringSoon: (json['expiringSoon'] as List<dynamic>?)?.cast<String>() ?? [],
      recommendedRecipes: (json['recommendedRecipes'] as List<dynamic>?)?.cast<String>() ?? [],
      shoppingList: (json['shoppingList'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

class FridgeIngredient {
  final String name;
  final String freshness; // fresh, expiring, expired
  final int? daysUntilExpiration;

  FridgeIngredient({
    required this.name,
    required this.freshness,
    this.daysUntilExpiration,
  });

  factory FridgeIngredient.fromJson(Map<String, dynamic> json) {
    return FridgeIngredient(
      name: json['name'] ?? '',
      freshness: json['freshness'] ?? 'fresh',
      daysUntilExpiration: json['daysUntilExpiration'],
    );
  }
}

// 집 분석 결과
class HomeAnalysisResult {
  final int cleanliness; // 0-100
  final List<String> issues;
  final List<String> recommendedChores;
  final int estimatedMinutes;

  HomeAnalysisResult({
    required this.cleanliness,
    required this.issues,
    required this.recommendedChores,
    required this.estimatedMinutes,
  });

  factory HomeAnalysisResult.fromJson(Map<String, dynamic> json) {
    return HomeAnalysisResult(
      cleanliness: json['cleanliness'] ?? 50,
      issues: (json['issues'] as List<dynamic>?)?.cast<String>() ?? [],
      recommendedChores: (json['recommendedChores'] as List<dynamic>?)?.cast<String>() ?? [],
      estimatedMinutes: json['estimatedMinutes'] ?? 0,
    );
  }
}

// 레시피 모델
class Recipe {
  final String name;
  final List<String> ingredients;
  final List<String> steps;
  final int estimatedMinutes;
  final String? imageUrl;

  Recipe({
    required this.name,
    required this.ingredients,
    required this.steps,
    required this.estimatedMinutes,
    this.imageUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'] ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)?.cast<String>() ?? [],
      steps: (json['steps'] as List<dynamic>?)?.cast<String>() ?? [],
      estimatedMinutes: json['estimatedMinutes'] ?? 30,
      imageUrl: json['imageUrl'],
    );
  }
}
