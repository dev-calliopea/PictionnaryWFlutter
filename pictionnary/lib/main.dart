import 'package:flutter/material.dart';
import 'package:pictionnary/authentication/models/user_model.dart';
import 'package:pictionnary/authentication/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:pictionnary/views/home_page.dart';
import 'package:pictionnary/authentication/viewmodels/auth_viewmodel.dart';
import 'package:pictionnary/authentication/views/login_view.dart';
import 'package:pictionnary/authentication/views/register_view.dart';
import 'package:pictionnary/gameSession/viewModels/player_view_model.dart';
import 'package:pictionnary/gameSession/viewModels/game_session_view_model.dart';
import 'package:pictionnary/gameSession/views/choose_word_screen.dart';
import 'package:pictionnary/gameSession/views/create_game_session.dart';
import 'package:pictionnary/gameSession/views/enter_game_code.dart';
import 'package:pictionnary/gameSession/views/game_session.dart';
import 'package:pictionnary/gameSession/views/looser_waiting_room.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authService = AuthService();
  UserModel? persistentUser = await authService.loadPersistentUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) {
          final gameSessionViewModel = GameSessionViewModel();
          gameSessionViewModel.initializeUser(persistentUser?.uid);
          return gameSessionViewModel;
        }),
        ChangeNotifierProvider(create: (_) => PlayerViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pictionis',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      routes: {
        '/home': (context) => HomePage(),
        '/register': (context) => RegisterView(),
        '/login': (context) => LoginView(title: 'Login',),
        '/createGameSession' : (context) => CreateGameSession(),
        '/enterGameCode' : (context) => EnterGameCode(),
        
        // Dynamic routes
        '/gameSession': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return GameSession(
            game: args['game'],
            gameRound: args['gameRound'],
            drawingWidget: args['drawingWidget'],
          );
        },

        '/chooseWordScreen': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ChooseWordScreen(
            game: args['game']
          );
        },

        '/looserWaitingRoom': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return LooserWaitingRoom(
            game: args['game'],
          );
        },
      },
      initialRoute: '/login',
    );
  }
}