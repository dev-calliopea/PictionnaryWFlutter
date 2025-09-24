import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pictionnary/gameSession/models/game_round_model.dart';

class Game {
  final String id; 
  final String title;
  final String adminPlayerId;
  List<String> guestPlayerIds; 
  String turnPlayerId;
  String currentGameRoundId;

  List<GameRound> rounds;
  int roundNb;

  String gameStatus; // ongoing, waiting or completed 
  final String? gameCode; 
  final bool isPrivate;
  int playerNb;
  final DateTime createdAt; 


  GameRound? get currentRound {
    return rounds.isNotEmpty ? rounds.last : null;
  }


  Game({
    required this.id,
    required this.title,
    required this.adminPlayerId,
    this.guestPlayerIds = const [],
    required this.turnPlayerId,
    required this.currentGameRoundId,
    required this.rounds,
    required this.roundNb,
    required this.gameStatus,
    this.gameCode, // optional 
    required this.isPrivate,
    required this.playerNb,
    required this.createdAt,
  });


  factory Game.fromFirestore(Map<String, dynamic> data, String id) {
    return Game(
      id: id,
      title: data['tite'],
      adminPlayerId: data['adminPlayerId'],
      guestPlayerIds: List<String>.from(data['guestPlayerIds'] ?? []),
      turnPlayerId: data['turnPlayerId'],
      currentGameRoundId: data['currentGameRoundId'],
      rounds: List<GameRound>.from(data['rounds'] ?? []),
      roundNb: data['roundNb'],
      gameStatus: data['gameStatus'],
      gameCode: data['gameCode'],
      isPrivate: data['isPrivate'],
      playerNb: data['playerNb'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
  

  factory Game.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Game(
      id: doc.id, // ID du document Firestore
      title: data['title'],
      adminPlayerId: data['adminPlayerId'] ?? '',
      guestPlayerIds: List<String>.from(data['guestPlayerIds'] ?? []),
      turnPlayerId: data['turnPlayerId'] ?? '',
      currentGameRoundId: data['currentGameRoundId'] ?? '',
      rounds: List<GameRound>.from(data['rounds'] ?? []),
      roundNb: data['roundNb'],
      gameStatus: data['gameStatus'],
      gameCode: data['gameCode'],
      isPrivate: data['isPrivate'],
      playerNb: data['playerNb'],
      createdAt: (data['createdAt'] as Timestamp?)!.toDate(), 
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'adminPlayerId': adminPlayerId,
      'guestPlayerId': guestPlayerIds,
      'turnPlayerId': turnPlayerId,
      'currentGameRoundId': currentGameRoundId,
      'rounds' : rounds,
      'roundNb': roundNb,
      'gameStatus': gameStatus,
      'gameCode': gameCode,
      'isPrivate': isPrivate,
      'playerNb' : playerNb,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }


  @override
  String toString() {
    return 'Game(id: $id, title: $title, adminPlayerId: $adminPlayerId, '
           'guestPlayerIds: ${guestPlayerIds.isEmpty ? "[]" : guestPlayerIds.toString()}, '
           'turnPlayerId: $turnPlayerId, '
           'currentGameRoundId: $currentGameRoundId, '
           'rounds: ${rounds.isEmpty ? "[]" : rounds.map((r) => r.toString()).toList()}, '
           'roundNb: $roundNb, '
           'gameStatus: $gameStatus, gameCode: ${gameCode ?? "N/A"}, isPrivate: $isPrivate, '
           'playerNb: $playerNb, createdAt: $createdAt, '
           'currentRound: ${currentRound.toString()})';
  }
}
