import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pictionnary/gameSession/models/game_model.dart';
import 'package:pictionnary/gameSession/models/game_round_model.dart';
import 'package:provider/provider.dart';
import 'package:pictionnary/drawingScreen/views/viewing_screen.dart';
import 'package:pictionnary/gameSession/viewModels/game_session_view_model.dart';


class LooserWaitingRoom extends StatefulWidget {
  // final String gameId;
  final Game game;

  // LooserWaitingRoom({required this.gameId});
  LooserWaitingRoom({required this.game});


  @override
  _LooserWaitingRoomState createState() => _LooserWaitingRoomState();
}

class _LooserWaitingRoomState extends State<LooserWaitingRoom> {
  late Stream<DocumentSnapshot> gameStream;
  late Game game;

  @override
  void initState() {
    super.initState();
    game = widget.game;

    gameStream = FirebaseFirestore.instance
        .collection('games')
        .doc(game.id)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final gameSessionViewModel = Provider.of<GameSessionViewModel>(context, listen: true);

    return StreamBuilder<DocumentSnapshot>(
      stream: gameStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.blueGrey[900],
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        var gameData = snapshot.data!.data() as Map<String, dynamic>;
        
        // Si la session passe en "ongoing", redirection vers l'écran de la manche
        String gameStatus = gameData['gameStatus'];
        if (gameStatus == 'ongoing') {
          String currentGameRoundId = gameData['currentGameRoundId'];
          
          // Ici, récupérer l'objet gameRound depuis firebase : 
          FirebaseFirestore.instance
            .collection('games')
            .doc(game.id)
            .collection('rounds')
            .doc(currentGameRoundId)
            .get()
            .then((snapshot) {
          if (snapshot.exists) {
            var gameRoundData = snapshot.data() as Map<String, dynamic>;
            print("GameRound Data: $gameRoundData");

            // GameRound currentGameRound = GameRound.fromMap(gameRoundData);
            GameRound currentGameRound = GameRound.fromFirestore(gameRoundData, currentGameRoundId);

            print("GameRound récupéré : $currentGameRound");

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.popAndPushNamed(
                context,
                '/gameSession',
                arguments: {
                  'game': game,
                  'gameRound': currentGameRound,
                  'drawingWidget': ViewingScreen(gameRoundId: currentGameRound.id),
                },
              );
            });
          } else {
            print("Game round not found!");
          }});
        }

      return PopScope(
        onPopInvokedWithResult: (popDisposition, result) async {
          gameSessionViewModel.refreshGameAndRound();
          // Redirect toward home page
          // Navigator.popAndPushNamed(context, '/home'); //todo: doesnt work
        },
        child: Scaffold(
            backgroundColor: Colors.blueGrey[900],
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "En attente du mot à deviner...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent),
                    strokeWidth: 6.0,
                  ),
                ],
              ),
            ),
          ),
      );
      },
    );
  }
}