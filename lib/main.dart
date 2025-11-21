import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Config
import 'package:flutter_app/config/firebase_config.dart';

// Models
import 'package:flutter_app/models/user_model.dart';
import 'package:flutter_app/models/household_model.dart';
import 'package:flutter_app/models/chore_model.dart';

// Services
import 'package:flutter_app/services/firebase_auth_service.dart';
import 'package:flutter_app/services/firestore_service.dart';
// import 'package:flutter_app/services/notification_service.dart';

// Repositories
import 'package:flutter_app/repositories/user_repository.dart';
import 'package:flutter_app/repositories/household_repository.dart';
import 'package:flutter_app/repositories/chore_repository.dart';

// Providers
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/household_provider.dart';
import 'package:flutter_app/providers/chore_provider.dart';

// Screens
import 'package:flutter_app/screens/splash_screen.dart';
import 'package:flutter_app/screens/auth/login_screen.dart';
import 'package:flutter_app/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await FirebaseConfig.initialize();

  // Hive 초기화
  await Hive.initFlutter();

  // TypeAdapter 등록
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(HouseholdModelAdapter());
  Hive.registerAdapter(ChoreModelAdapter());
  Hive.registerAdapter(ChoreStatusAdapter());
  Hive.registerAdapter(ChoreDifficultyAdapter());

  // Hive Box 열기
  final userBox = await Hive.openBox<UserModel>('users');
  final householdBox = await Hive.openBox<HouseholdModel>('households');
  final choreBox = await Hive.openBox<ChoreModel>('chores');

  // Services 초기화
  final firestoreService = FirestoreService();
  final authService = FirebaseAuthService();
  // await NotificationService().initialize();

  // Repositories 초기화
  final userRepository = UserRepository(
    firestoreService,
    userBox,
  );
  final householdRepository = HouseholdRepository(
    firestoreService: firestoreService,
    localCache: householdBox,
  );
  final choreRepository = ChoreRepository(
    firestoreService: firestoreService,
    localCache: choreBox,
  );

  // Initialize locale data for date formatting
  await initializeDateFormatting('ko_KR', null);

  runApp(MyApp(
    userRepository: userRepository,
    householdRepository: householdRepository,
    choreRepository: choreRepository,
    authService: authService,
  ));
}

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  final HouseholdRepository householdRepository;
  final ChoreRepository choreRepository;
  final FirebaseAuthService authService;

  const MyApp({
    super.key,
    required this.userRepository,
    required this.householdRepository,
    required this.choreRepository,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide repositories and services for future use
        // Step 2-4에서 Provider들이 이를 사용하도록 업데이트 예정
        Provider<UserRepository>.value(value: userRepository),
        Provider<HouseholdRepository>.value(value: householdRepository),
        Provider<ChoreRepository>.value(value: choreRepository),
        Provider<FirebaseAuthService>.value(value: authService),

        // Provide state management providers
        // Step 2: AuthProvider - Firebase + Repository 통합 완료
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: authService,
            userRepository: userRepository,
          ),
        ),
        // Step 3: HouseholdProvider - Repository + 실시간 동기화 완료
        ChangeNotifierProvider(
          create: (_) => HouseholdProvider(
            householdRepository: householdRepository,
            userRepository: userRepository,
          ),
        ),
        // Step 4: ChoreProvider - Repository 주입 완료
        ChangeNotifierProvider(
          create: (_) => ChoreProvider(
            choreRepository: choreRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'ChoreQuest',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
