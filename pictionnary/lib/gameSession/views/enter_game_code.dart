import 'package:flutter/material.dart';
import 'package:pictionnary/gameSession/models/game_model.dart';
import 'package:pictionnary/gameSession/viewModels/game_session_view_model.dart';
import 'package:provider/provider.dart';

class EnterGameCode extends StatefulWidget {
  @override
  _EnterGameCodeState createState() => _EnterGameCodeState();
}


class _EnterGameCodeState extends State<EnterGameCode> {
  final TextEditingController _codeController = TextEditingController();

  Future<void> _submitGameCode(ongoingGameSession) async {
    final gameCode = _codeController.text.trim();
    final gameSessionViewModel = Provider.of<GameSessionViewModel>(context, listen: false);
    
    await gameSessionViewModel.handleGameCodeSubmission(context, gameCode, ongoingGameSession);
  }


  @override
  Widget build(BuildContext context) {
    final gameSessionViewModel = Provider.of<GameSessionViewModel>(context, listen: false);
    final Game ongoingGameSession = ModalRoute.of(context)!.settings.arguments as Game;

    return PopScope(
      onPopInvokedWithResult: (popDisposition, result) async {
        gameSessionViewModel.refreshGameAndRound();
        // Redirect toward home page
        Navigator.popAndPushNamed(context, '/home');
      },
      child: Scaffold(
        appBar: AppBar(title: Text('La partie est privée')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _codeController,
                decoration: InputDecoration(labelText: 'Entrer le code privé de la partie'),
                maxLength: 6
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _submitGameCode(ongoingGameSession);
                },
                child: Text('Valider'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
