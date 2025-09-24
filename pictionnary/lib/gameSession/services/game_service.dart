import 'package:cloud_firestore/cloud_firestore.dart';

class Gameservice { 
  final String gameStatusOnGoing = 'ongoing';
  final String gameStatusWaiting = 'waiting';
  final String gameStatusCompleted = 'completed';

  Future<QuerySnapshot> getOngoingGameSessions() async {
    QuerySnapshot ongoingGameSessions = await FirebaseFirestore.instance
        .collection('games')
        .where('gameStatus', isEqualTo: gameStatusOnGoing)
        .get();

    return ongoingGameSessions;
  }

  Future<QuerySnapshot> getOngoingGameSessionsWhereUserIsAdmin(String userId) async {
    QuerySnapshot ongoingGameSessionsWhereUserIsAdmin = await FirebaseFirestore.instance
          .collection('games')
          .where('gameStatus', isEqualTo: gameStatusOnGoing)
          .where('adminPlayerId', isEqualTo: userId)
          .get();
    
    return ongoingGameSessionsWhereUserIsAdmin;
  }


  Future<QuerySnapshot> getOngoingGameSessionsWhereUserIsGuest(String userId) async {
    QuerySnapshot ongoingGameSessionsWhereUserIsGuest = await FirebaseFirestore.instance
        .collection('games')
        .where('gameStatus', isEqualTo: gameStatusOnGoing)
        .where('guestPlayerId', isEqualTo: userId)
        .get();

    return ongoingGameSessionsWhereUserIsGuest;
  }


  Future<DocumentSnapshot> getGameSessionById(String gameId) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('games').doc(gameId).get();

    return docSnapshot;
  }


  Future<String> createGameSession(String title, String adminPlayerId, String? gameCode) async {
    DocumentReference docRef = await FirebaseFirestore.instance.collection('games').add({
      'title': title, 
      'adminPlayerId': adminPlayerId,
      'guestPlayerIds': [], 
      'turnPlayerId': adminPlayerId, // the one who creates the session is the one who starts to play
      'currentGameRoundId': '',
      'roundNb' : 0,
      'gameStatus': gameStatusOnGoing, 
      'gameCode': gameCode,
      'isPrivate': gameCode != '', // the session is private if a code is provided 
      'playerNb': 1,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }


  Future<bool> updateGameSessionCurrentGameRoundId(String gameId, String currentGameRoundId) async {
    try {
      await FirebaseFirestore.instance.collection('games').doc(gameId).update({
        'currentGameRoundId': currentGameRoundId,
      });
      return true;
    } catch (e) {
      return false;
    }
  }


  Future<bool> updateGuestPlayerId(String gameId, String guestPlayerId) async {
    try {
      await FirebaseFirestore.instance.collection('games').doc(gameId).update({
        'guestPlayerIds': FieldValue.arrayUnion([guestPlayerId]),
      });
      return true;
    } catch (e) {
      return false;
    }
  }


  Future<String> updateGameTurnPlayerId(String gameId, String winnerPlayerId) async {
    String nextTurnPlayerId = winnerPlayerId;

    await FirebaseFirestore.instance.collection('games').doc(gameId).update({
      'turnPlayerId': nextTurnPlayerId,
    });

    return nextTurnPlayerId;
  }


  Future<void> updateGameStatus(String gameId, String gameStatus) async {
    await FirebaseFirestore.instance.collection('games').doc(gameId).update({
      'gameStatus': gameStatus,
    });
  }


  Future<void> endGameSession(String gameId) async {
    await FirebaseFirestore.instance.collection('games').doc(gameId).update({
      'gameStatus': gameStatusCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }


  Future<String> createGameRound(String gameId, String wordToGuess) async {
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('games')
        .doc(gameId)
        .collection('rounds')
        .add({
      'wordToGuess': wordToGuess,
      'guessedCorrectly': false,
      'guessedByPlayerId': '',
      'startedAt': FieldValue.serverTimestamp(),
    });

    // Increment gameRoundNb 
    await FirebaseFirestore.instance.collection('games').doc(gameId).update({
      'roundNb': FieldValue.increment(1), 
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }


  Future<void> endGameRound(String gameId, String roundId, String winnerPlayerId) async {
    await FirebaseFirestore.instance
        .collection('games')
        .doc(gameId)
        .collection('rounds')
        .doc(roundId)
        .update({
      'guessedCorrectly': true,
      'guessedByPlayerId': winnerPlayerId,
      'endedAt': FieldValue.serverTimestamp(),
    });

    // Update game turnPlayerId
    await updateGameTurnPlayerId(gameId, winnerPlayerId);
  }
}