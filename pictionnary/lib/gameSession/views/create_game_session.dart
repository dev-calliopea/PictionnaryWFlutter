import 'package:flutter/material.dart';
import 'package:pictionnary/drawingScreen/views/drawing_screen.dart';
import 'package:pictionnary/gameSession/models/game_model.dart';
import 'package:provider/provider.dart';
import 'package:pictionnary/gameSession/models/game_round_model.dart';
import 'package:pictionnary/gameSession/viewModels/game_session_view_model.dart';

class CreateGameSession extends StatefulWidget {
  @override
  _CreateGameSessionState createState() => _CreateGameSessionState();
}


class _CreateGameSessionState extends State<CreateGameSession> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();


  Future<void> _submitGameSessionCreation() async {
    final wordToGuess = _wordController.text.trim();
    final gameCode = _codeController.text;
    final gameTitle = _titleController.text.trim();

    if (wordToGuess.isNotEmpty && gameTitle.isNotEmpty) {
      final gameSessionViewModel = Provider.of<GameSessionViewModel>(context, listen: false);
      // GameRound? newGameRound = await gameSessionViewModel.createGameSessionAndFirstRound(gameTitle, gameCode, wordToGuess);
      List<dynamic>? gameSessionData = await gameSessionViewModel.createGameSessionAndFirstRound(gameTitle, gameCode, wordToGuess);

      if (gameSessionData != null && gameSessionData.length == 2) {
        Game game = gameSessionData[0] as Game;
        GameRound gameRound = gameSessionData[1] as GameRound;
        // Go to gameSession screen
        Navigator.pushNamed(
          context,
          '/gameSession',
          arguments: {
            'game': game,
            'gameRound': gameRound,
            'drawingWidget': DrawingScreen(gameRoundId: gameRound.id),
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Il semble y avoir eu un problème durant la création de votre partie et de votre première manche. Veuillez ré-essayer plus tard!')),
        );
      }
      // if (newGameRound != null) {
      //   // Go to gameSession screen
      //   Navigator.pushNamed(
      //     context,
      //     '/gameSession',
      //     arguments: {
      //       'game': gameSessionViewModel.currentGame!, 
      //       'gameRound': newGameRound,
      //       'drawingWidget': DrawingScreen(gameRoundId: newGameRound.id)
      //     },
      //   );
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Il semble y avoir eu un problème durant la création de votre partie et de votre première manche. Veuillez ré-essayer plus tard!')),
      //   );
      // }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez définir un titre et un mot à faire deviner aux joueurs !')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameSessionViewModel = Provider.of<GameSessionViewModel>(context, listen: false);

    return PopScope(
      onPopInvokedWithResult: (popDisposition, result) async {
        gameSessionViewModel.refreshGameAndRound();
        // Redirect toward home page
        Navigator.popAndPushNamed(context, '/home');
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Création de la partie')),

        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(  
            children: [
              SizedBox(height: 50),
              Text(
                "Choisissez un titre pour votre partie",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Titre de la partie (20 caractères)',
                  border: OutlineInputBorder(),
                ),
                maxLength: 20,
              ),
              SizedBox(height: 50),

              Text(
                "Choisissez un code pour rendre votre partie privée. Laissez le champ vide et votre partie sera publique.",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Code de la partie (6 caractères)',
                  border: OutlineInputBorder(),
                ),
                maxLength: 6,
              ),
              SizedBox(height: 50),

              TextField(
                controller: _wordController,
                decoration: InputDecoration(labelText: 'Mot à faire deviner', border: OutlineInputBorder()),
                maxLength: 10,
              ),
              SizedBox(height: 50),

              ElevatedButton(
                onPressed: () async {
                  await _submitGameSessionCreation();
                },
                child: Text('Créer la partie'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}