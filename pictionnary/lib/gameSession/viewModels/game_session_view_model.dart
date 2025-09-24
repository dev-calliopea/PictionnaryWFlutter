import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pictionnary/drawingScreen/views/drawing_screen.dart';
import 'package:pictionnary/drawingScreen/views/viewing_screen.dart';
import 'package:pictionnary/gameSession/services/game_service.dart';
import 'package:pictionnary/gameSession/models/game_model.dart';
import 'package:pictionnary/gameSession/models/game_round_model.dart';

class GameSessionViewModel extends ChangeNotifier {
  String? _userId;
  bool isLoading = false;
  final int maxPlayerNb = 8;

  Game? _currentGame;
  GameRound? _currentGameRound;

  List<Game> allOngoingGameSessions = [];
  List<Game> userOngoingGameSessions = [];

  final Gameservice _gameService = Gameservice();

  Game? get currentGame => _currentGame;
  GameRound? get currentGameRound => _currentGameRound;
  String? get userId => _userId;


  void initializeUser(String? userId) {
    if (userId != null && userId.isNotEmpty) {
      _userId = userId;
      listenToAllOngoingGameSessions();
    }
  }


  void setCurrentGame(Game game) {
    _currentGame = game;
    notifyListeners();
  }

  
  void setCurrentGameRound(GameRound gameRound) {
    _currentGameRound = gameRound;
    notifyListeners();
  }


  bool isUserTurnToDraw(gameTurnPlayerId) {
    return gameTurnPlayerId == userId;
  }


  bool isUserAdminOfGameSession(Game gameSession) { 
    if (gameSession.adminPlayerId == userId) {
      return true;
    } else { 
      return false;
    }
  }


  bool isGameSessionPrivate(Game gameSession) {
    if (gameSession.isPrivate) {
      return true;
    } else {
      return false;
    }
  }


  bool isGameSessionCodeValid(String gameCode, Game gameSession) {
    if (gameCode == gameSession.gameCode) {
      return true;
    } else {
      return false;
    }
  }


  bool isGameSessionFull(Game gameSession) {
    if (gameSession.playerNb == maxPlayerNb) {
      return true; 
    } else { 
      return false;
    }
  }


  bool isTheWordGuessed(String guessedWord) {
    if (_currentGameRound != null) {
      return guessedWord == _currentGameRound!.wordToGuess;
    }
    return false;
  }


  void refreshGameAndRound() {
    _currentGame = null;
    _currentGameRound = null;
    notifyListeners(); 
  }


  void listenToAllOngoingGameSessions() {
    if (_userId == null) return;

    isLoading = true;
    notifyListeners();

    FirebaseFirestore.instance
        .collection('games')
        .where('gameStatus', isEqualTo: 'ongoing')
        .snapshots()
        .listen((snapshot) async {
      List<Game> gamesList = []; //todo: into function

      try {
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

          // Récupérer les rounds de la sous-collection
          QuerySnapshot roundsSnapshot = await FirebaseFirestore.instance
              .collection('games')
              .doc(doc.id)
              .collection('rounds')
              .get();

          List<GameRound> roundsList = roundsSnapshot.docs.map((roundDoc) {
            final roundData = roundDoc.data() as Map<String, dynamic>;
            return GameRound(
              id: roundDoc.id,
              wordToGuess: roundData['wordToGuess'],
              guessedCorrectly: roundData['guessedCorrectly'],
              guessedByPlayerId: roundData['guessedByPlayerId'],
              startedAt: (roundData['startedAt'] as Timestamp).toDate(),
            );
          }).toList();

          Game game = Game(
            id: doc.id,
            title: data['title'],
            adminPlayerId: data['adminPlayerId'],
            guestPlayerIds: List<String>.from(data['guestPlayerIds'] ?? []),
            turnPlayerId: data['turnPlayerId'],
            currentGameRoundId: data['currentGameRoundId'],
            rounds: roundsList,
            roundNb: data['roundNb'],
            gameStatus: data['gameStatus'],
            gameCode: data['gameCode'],
            isPrivate: data['isPrivate'],
            playerNb: data['playerNb'],
            createdAt: (data['createdAt'] as Timestamp).toDate(),
          );

          gamesList.add(game);
        }

        allOngoingGameSessions = gamesList;
      } catch (e) {
        print('Error fetching ongoing game sessions: $e');
      } finally {
        isLoading = false;
        notifyListeners();
      }
    });
  }


  Future<List<dynamic>?> createGameSessionAndFirstRound(String gameTitle, String? gameCode, String wordToGuess) async {
    try {      
      String newGameSessionId = await _gameService.createGameSession(gameTitle, userId!, gameCode);

      // Set current game 
      Game currentGame = Game(
        id: newGameSessionId,
        title: gameTitle,
        adminPlayerId: userId!, // the one who creates the game is the admin 
        guestPlayerIds: [], // the game session is created without any others players at first  
        turnPlayerId: userId!, // The one who creates the game session starts to draw 
        currentGameRoundId: '', // the first round hasnt been created yet 
        rounds: [],
        roundNb: 0, // when the game session is created, there is not round created yet 
        gameStatus: _gameService.gameStatusOnGoing,
        gameCode: gameCode,
        isPrivate: gameCode != '',
        playerNb: 1,
        createdAt: DateTime.now(),
      );
      setCurrentGame(currentGame);

      // Create first round 
      GameRound? currentGameRound = await openNewGameRound(newGameSessionId, wordToGuess);
      
      
      if (currentGameRound != null) {        
        // Link the first gameRound to the gameSession
        currentGame.rounds.add(currentGameRound); 
        currentGame.roundNb++;

        // Update gameSession currentGameRoundId on Firebase 
        await _gameService.updateGameSessionCurrentGameRoundId(newGameSessionId, currentGameRound.id);
        // Update on model
        currentGame.currentGameRoundId = currentGameRound.id;

        // Set current game round 
        setCurrentGameRound(currentGameRound);

      } else {
        print('Failed to create the first round');
      }

      // return _currentGameRound;
      return [currentGame, currentGameRound];

    } catch (e) {
      print('Error creating game session: $e');
      return null; 

    } finally {
      notifyListeners();
    }
  }


  Future<Game?> joinOnGoingGameSession(Game gameSession) async {
    try {
      DocumentSnapshot gameSessionToBeJoined = await _gameService.getGameSessionById(gameSession.id);

      if (gameSessionToBeJoined.exists) {
        bool isUserAdmin = isUserAdminOfGameSession(gameSession);

        // If user is not admin, add him as a guest player 
        if (!isUserAdmin) {
          await _gameService.updateGuestPlayerId(gameSession.id, userId!);
        }

        final data = gameSessionToBeJoined.data() as Map<String, dynamic>;
        // Get linked game rounds
        QuerySnapshot roundsSnapshot = await FirebaseFirestore.instance
            .collection('games')
            .doc(gameSessionToBeJoined.id)
            .collection('rounds')
            .get();

        List<GameRound> roundsList = roundsSnapshot.docs.map((roundDoc) {
          final roundData = roundDoc.data() as Map<String, dynamic>;
          return GameRound(
            id: roundDoc.id,
            wordToGuess: roundData['wordToGuess'],
            guessedCorrectly: roundData['guessedCorrectly'],
            guessedByPlayerId: roundData['guessedByPlayerId'],
            startedAt: (roundData['startedAt'] as Timestamp).toDate()
          );
        }).toList();

        // Set current game 
        Game currentGame = Game(
          id: gameSessionToBeJoined.id,
          title: data['title'],
          adminPlayerId: data['adminPlayerId'],
          guestPlayerIds: List<String>.from(data['guestPlayerIds'] ?? []),
          turnPlayerId: data['turnPlayerId'],
          currentGameRoundId: data['currentGameRoundId'],
          rounds: roundsList, 
          roundNb: data['roundNb'],
          gameStatus: data['gameStatus'],
          gameCode: data['gameCode'],
          isPrivate: data['isPrivate'],
          playerNb: data['playerNb'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
        setCurrentGame(currentGame);

        return _currentGame;

      } else {
        print('Aucune session de jeu trouvée avec l\'ID: ${gameSession.id}');
        return null;
      }

    } catch (e) {
      print('Erreur lors de la tentative de rejoindre la session de jeu: $e');
      return null;

    } finally {
      notifyListeners();
    }
  }


  Future<GameRound?> openNewGameRound(String gameId, String wordToGuess) async {
    try {
      String newGameRoundId = await _gameService.createGameRound(gameId, wordToGuess);

      GameRound currentGameRound = GameRound(
        id: newGameRoundId,
        wordToGuess: wordToGuess,
        startedAt: DateTime.now(),
      );
      setCurrentGameRound(currentGameRound); 

      // Set the gameSession status as ongoing (so the gameSession can start again)
      await _gameService.updateGameStatus(gameId, _gameService.gameStatusOnGoing);

      // Set the currentGameRoundId 
      await _gameService.updateGameSessionCurrentGameRoundId(gameId, newGameRoundId);

      return _currentGameRound;

    } catch (e) {
      print('Error opening new round: $e');
      return null; 

    } finally {
      notifyListeners();
    }
  }


  Future<void> endGameRound(String gameId, String gameRoundId, String winnerPlayerId) async {
    try {
      // Set the gameSession status as waiting (so the winner can choose another word to guess)
      await _gameService.updateGameStatus(gameId, _gameService.gameStatusWaiting);

      await _gameService.endGameRound(gameId, gameRoundId, winnerPlayerId);

    } catch (e) {
      print('Error ending round: $e');

    } finally {
      notifyListeners();
    }
  }


  Future<void> handleOnGoingGameSessionTap(BuildContext context, Game ongoingGameSession) async {
    try {
      // Set current game 
      setCurrentGame(ongoingGameSession);

      // Set current game round 
      GameRound? _currentGameRound = _currentGame!.currentRound;
      setCurrentGameRound(_currentGameRound!);

      bool isMaxPlayerNbReached = await isGameSessionFull(ongoingGameSession);
      bool isOngoingGameSessionPrivate = await isGameSessionPrivate(ongoingGameSession);
      bool isUserAdmin = await isUserAdminOfGameSession(ongoingGameSession);

      if (isMaxPlayerNbReached) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Le nombre maximum de joueur a été atteint. Tentez de rejoindre une autre partie !')),
        );
      }

      if (isOngoingGameSessionPrivate && !isUserAdmin) {
        Navigator.pushNamed(context, '/enterGameCode', arguments: ongoingGameSession);
        return;
      }
       
      // If user is not admin, add him as a guest player 
      if (!isUserAdmin) {
        await _gameService.updateGuestPlayerId(ongoingGameSession.id, userId!);
      }
      bool userTurnToDraw = await isUserTurnToDraw(ongoingGameSession);

      // Go to gameSession screen 
      Navigator.pushNamed(
        context,
        '/gameSession',
        arguments: {
          'game': _currentGame!,
          'gameRound': _currentGameRound,
          'drawingWidget': userTurnToDraw ? DrawingScreen(gameRoundId: _currentGameRound.id) : ViewingScreen(gameRoundId: _currentGameRound.id), 
        },
      );
    } catch(e) {
      print('Erreur lors du traitement de la session de jeu : $e');
    }
  }


  Future<void> handleGameCodeSubmission(BuildContext context, String gameCode, Game ongoingGameSession) async {
    if (gameCode.isNotEmpty) {
      bool isGameCodeValid = await isGameSessionCodeValid(gameCode, ongoingGameSession);
      
      if (isGameCodeValid) {
        Game? joinedGameSession = await joinOnGoingGameSession(ongoingGameSession);

        if (joinedGameSession != null) {
          bool userTurnToDraw = await isUserTurnToDraw(joinedGameSession);
          
          // Go to gameSession screen 
          Navigator.pushNamed(
            context,
            '/gameSession',
            arguments: {
              'game': currentGame!,
              'gameRound': currentGameRound!,
              'drawingWidget':  userTurnToDraw ? DrawingScreen(gameRoundId: _currentGameRound!.id) : ViewingScreen(gameRoundId: _currentGameRound!.id),
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Il semble y avoir eu un problème durant l\'ouverture de votre partie. Veuillez ré-essayer plus tard!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Le code est invalide. Veuillez réessayer !')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer un code.')),
      );
    }
  }


  bool sendMessage(String message, String gameId, String gameRoundId) {
    if (message.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('games')
          .doc(gameId)
          .collection('rounds')
          .doc(gameRoundId)
          .collection('messages')
          .add({
        'text': message,
        'senderId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    return true;
  }
}