import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pictionnary/gameSession/viewModels/player_view_model.dart';


class PlayerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    
    return Consumer<PlayerViewModel>(
      builder: (context, playerViewModel, child) {
        if (playerViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (playerViewModel.users.isEmpty) {
          return const Center(child: Text('Aucun joueur trouvé.'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Joueurs connectés :',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Container(
              height: 100, 
              child: ListView.builder(
                scrollDirection: Axis.horizontal, 
                itemCount: playerViewModel.users.length,
                itemBuilder: (context, index) {
                  final user = playerViewModel.users[index];
                  return Container(
                    width: 80,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          child: Text(user.email![0]),
                        ),
                      ],
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
