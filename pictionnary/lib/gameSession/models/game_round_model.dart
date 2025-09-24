import 'package:cloud_firestore/cloud_firestore.dart';

class GameRound {
  final String id; 
  final String wordToGuess; 
  final bool guessedCorrectly; 
  String? guessedByPlayerId;
  final DateTime startedAt; 


  GameRound({
    required this.id,
    required this.wordToGuess,
    this.guessedCorrectly = false,
    this.guessedByPlayerId,
    required this.startedAt, 
  });

  int get wordToGuessLength => wordToGuess.length;

  // Méthode pour créer un objet GameRoundModel à partir d'un document Firestore
  factory GameRound.fromFirestore(Map<String, dynamic> data, String id) {
    return GameRound(
      id: id,
      wordToGuess: data['wordToGuess'],
      guessedCorrectly: data['guessedCorrectly'] ?? false,
      guessedByPlayerId: data['guessedByPlayerId'] ?? '',
      startedAt: (data['startedAt'] as Timestamp).toDate(),
    );
  }

  factory GameRound.fromMap(Map<String, dynamic> data) {
    return GameRound(
      id: data['id'], // Si tu ID est également stocké dans le map, sinon prends-le de la source appelante.
      wordToGuess: data['wordToGuess'],
      guessedCorrectly: data['guessedCorrectly'] ?? false,
      guessedByPlayerId: data['guessedByPlayerId'] ?? '',
      startedAt: (data['startedAt'] as Timestamp).toDate(),
    );
  }

  // Méthode pour convertir l'objet en un Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'wordToGuess': wordToGuess,
      'guessedCorrectly': guessedCorrectly,
      'guessedByPlayerId': guessedByPlayerId,
      'startedAt': Timestamp.fromDate(startedAt),
    };
  }

  @override
  String toString() {
    return 'GameRound { '
           'id: $id, '
           'wordToGuess: $wordToGuess, '
           'guessedCorrectly: $guessedCorrectly, '
           'guessedByPlayerId: ${guessedByPlayerId ?? 'none'}, '
           'startedAt: $startedAt '
           '}';
  }
}
