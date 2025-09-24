import 'package:flutter/material.dart';
import 'package:pictionnary/drawingScreen/views/drawing_screen.dart';
import 'package:pictionnary/gameSession/models/game_model.dart';
import 'package:provider/provider.dart';
import 'package:pictionnary/gameSession/models/game_round_model.dart';
import 'package:pictionnary/gameSession/viewModels/game_session_view_model.dart';

class ChooseWordScreen extends StatefulWidget { 
  // final String gameId;
  final Game game; 


  ChooseWordScreen({required this.game});
  // ChooseWordScreen({required this.gameId});


  @override
  _ChooseWordScreenState createState() => _ChooseWordScreenState();
}


class _ChooseWordScreenState extends State<ChooseWordScreen> {
  final TextEditingController _wordController = TextEditingController();

  Future<void> _submitWordToGuess() async {
    final wordToGuess = _wordController.text.trim();

    if (wordToGuess.isNotEmpty) {
      final gameSessionViewModel = Provider.of<GameSessionViewModel>(context, listen: false);
      GameRound? newGameRound = await gameSessionViewModel.openNewGameRound(widget.game.id, wordToGuess);
      
      if (newGameRound != null) {
        Navigator.popAndPushNamed( //todo: here was id
          context,
          '/gameSession',
          arguments: {
            'game': widget.game, 
            'gameRound': newGameRound,
            'drawingWidget': DrawingScreen(gameRoundId: newGameRound.id,)
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Il semble y avoir eu un problème durant la création de votre manche. Veuillez ré-essayer plus tard!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer un mot.')),
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
        appBar: AppBar(title: Text('Choisissez un mot')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _wordController,
                decoration: InputDecoration(labelText: 'Mot à faire deviner'),
                maxLength: 10
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _submitWordToGuess();
                },
                child: Text('Soumettre le mot'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
