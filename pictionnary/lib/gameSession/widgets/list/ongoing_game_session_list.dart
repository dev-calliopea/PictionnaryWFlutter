import 'package:flutter/material.dart';
import 'package:pictionnary/authentication/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:pictionnary/gameSession/viewModels/game_session_view_model.dart';

class OngoingGameSessionList extends StatefulWidget {
  @override
  _OngoingGameSessionListState createState() => _OngoingGameSessionListState();
}


class _OngoingGameSessionListState extends State<OngoingGameSessionList> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final gameSessionViewModel = Provider.of<GameSessionViewModel>(context, listen: false);
    if (gameSessionViewModel.userId == null) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      gameSessionViewModel.initializeUser(authViewModel.user?.uid);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<GameSessionViewModel>(
      builder: (context, gameSessionViewModel, child) {
        if (gameSessionViewModel.userId == null || gameSessionViewModel.userId!.isEmpty) {
          return const Center(
            child: Text('Problème de récupération de votre identifiant de joueur.'),
          );
        }

        if (gameSessionViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (gameSessionViewModel.allOngoingGameSessions.isEmpty) {
          return const Center(child: Text('Aucune partie en cours.'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Toutes les parties en cours :',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Container(
              height: 100, 
              child: ListView.builder(
                scrollDirection: Axis.horizontal, 
                itemCount: gameSessionViewModel.allOngoingGameSessions.length,
                itemBuilder: (context, index) {
                  final ongoingGameSession = gameSessionViewModel.allOngoingGameSessions[index];

                  return GestureDetector(
                    onTap: () => gameSessionViewModel.handleOnGoingGameSessionTap(context, ongoingGameSession),
                    child: Container(
                      width: 80, 
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30, 
                            backgroundColor: Colors.lightGreen.shade400,
                          ),

                          
                          Text(
                            gameSessionViewModel.isUserTurnToDraw(ongoingGameSession.turnPlayerId)
                                ? 'À vous de dessiner'
                                : 'À vous de deviner',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
