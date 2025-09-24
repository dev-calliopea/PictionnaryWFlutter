import 'package:flutter/material.dart';
import 'package:pictionnary/gameSession/models/game_model.dart';
import 'package:pictionnary/gameSession/models/game_round_model.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pictionnary/gameSession/viewModels/game_session_view_model.dart';

class GameSession extends StatefulWidget {
  // final String gameId;
  // final String gameRoundId;
  final Widget drawingWidget;
  final Game game;
  final GameRound gameRound;

  // GameSession({required this.gameId, required this.gameRoundId, required this.drawingWidget});
  GameSession({required this.game, required this.gameRound, required this.drawingWidget});

  @override
  _GameSessionState createState() => _GameSessionState();
}


class _GameSessionState extends State<GameSession> {
  final TextEditingController _messageController = TextEditingController();
  // late String gameId;
  // late String gameRoundId;
  late Game game;
  late GameRound gameRound;
  late Widget drawingWidget;
  Completer<void>? _navigationCompleter;

  @override
  void initState() {
    super.initState();
    // gameId = widget.gameId;
    // gameRoundId = widget.gameRoundId;
    // gameId = widget.game.id;
    // gameRoundId = widget.gameRound.id;
    game = widget.game; 
    gameRound = widget.gameRound;
    drawingWidget = widget.drawingWidget;
  }

  Future<void> _navigateTo(String routeName, Map<String, dynamic> arguments) async {
    if (_navigationCompleter == null || _navigationCompleter!.isCompleted) {
      _navigationCompleter = Completer<void>();
      await Navigator.pushNamed(context, routeName, arguments: arguments);
      _navigationCompleter!.complete();
    }
  }


  @override
  Widget build(BuildContext context) {
    final gameSessionViewModel = Provider.of<GameSessionViewModel>(context, listen: false);

    return PopScope(
      onPopInvokedWithResult: (popDisposition, result) async {
        gameSessionViewModel.refreshGameAndRound();
        // Redirect toward home page //todo doesnt work
      },

      child: Scaffold(
        appBar: AppBar(
          title: Text('Game session'),
        ),

        body: Column(
          children: [
            // Draw input 
            Expanded(
              child: Center(
                child: widget.drawingWidget,
              ),
            ),
            


            // Chat container
            Container(
              height: 200,
              color: Colors.grey[200],
              child: Column(
                children: [
                  Expanded(
                    // Stream to listen and display new messages 
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('games')
                          .doc(game.id)
                          .collection('rounds')
                          .doc(gameRound.id)
                          .collection('messages')
                          .orderBy('timestamp')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return CircularProgressIndicator();
                        List<DocumentSnapshot> docs = snapshot.data!.docs;

                        return ListView(
                          children: docs.map((doc) {
                            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                            String messageText = data['text'] ?? '';
                            String senderId = data['senderId'] ?? '';

                            if (gameSessionViewModel.currentGameRound != null) {
                              // Log pour vérifier si le mot est deviné
                              print('Vérification du mot deviné: ${gameSessionViewModel.currentGameRound!.wordToGuess} == $messageText');

                              // If the word is guessed 
                              if (gameSessionViewModel.isTheWordGuessed(messageText.toLowerCase())) {
                                Future.microtask(() async { 
                                  await gameSessionViewModel.endGameRound(game.id, gameRound.id, senderId);

                                  if (senderId == gameSessionViewModel.userId) {
                                    await _navigateTo('/chooseWordScreen', {'game': game});
                                  } else {
                                    await _navigateTo('/looserWaitingRoom', {'game': game});
                                  }
                                });
                              }
                            } else {
                              print('currentGameRound est nul');
                            }
                            return ListTile(
                              title: Text(data['text']),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  


                  // Barre d'envoi de message
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: "Écrivez votre réponse dans le chat...",
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () {
                            bool isMessageSent = gameSessionViewModel.sendMessage(_messageController.text, game.id, gameRound.id);
                            if (isMessageSent) {
                              _messageController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

