import 'package:flutter/material.dart';
import 'package:pictionnary/gameSession/viewModels/game_session_view_model.dart';
import 'package:pictionnary/gameSession/viewModels/player_view_model.dart';
import 'package:pictionnary/gameSession/widgets/list/ongoing_game_session_list.dart';
import 'package:pictionnary/gameSession/widgets/list/player_list.dart';
import 'package:provider/provider.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Récupérer les joueurs et les parties en cours
      Provider.of<PlayerViewModel>(context, listen: false).fetchUsers();
      Provider.of<GameSessionViewModel>(context, listen: false).listenToAllOngoingGameSessions(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pictionis'),
      ),

      body: SingleChildScrollView( 
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),

                // GamSession creation button
                ElevatedButton.icon(
                  onPressed: () async  {
                    Navigator.pushNamed(context, '/createGameSession');
                  },
                  icon: Icon(Icons.add),
                  label: Text("Créer une partie"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  ),
                ),
                SizedBox(height: 50),

                // OngoingGameSession list 
                SizedBox(
                  height: 200,
                  child: OngoingGameSessionList(),
                ),

                // Player list
                SizedBox(
                  height: 200,
                  child: PlayerList(),
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }
}

