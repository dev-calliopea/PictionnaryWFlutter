import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';

class ViewingScreen extends StatefulWidget {
  final String gameRoundId;

  const ViewingScreen({super.key, required this.gameRoundId});

  @override
  _ViewingScreenState createState() => _ViewingScreenState();
}

class _ViewingScreenState extends State<ViewingScreen> {
  late DrawingController drawingController;
  late String gameRoundId;

  @override
  void initState() {
    super.initState();

    gameRoundId = widget.gameRoundId;
    drawingController = DrawingController();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('drawings').orderBy('timestamp').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucun dessin disponible.'));
          }

          var drawingData = snapshot.data!.docs.last.data() as Map<String, dynamic>;
          var drawingJson = drawingData['drawing'] as List;

          // Ajoute le contenu de dessin depuis le JSON
          drawingController.clear();
          for (var json in drawingJson) {
            var type = json['type'];
            var content = createContentFromJson(type, json);
            if (content != null) {
              drawingController.addContent(content);
            }
          }

          return AbsorbPointer(
            absorbing: true, // IMPORTANT : Bloque toutes les interactions
            child: Center(
              child: Container(
                width: 800,
                height: 800,
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.blueGrey, width: 1),
                ),
                child: DrawingBoard(
                  background: Container(
                    width: 800,
                    height: 800,
                    color: Colors.yellow[100],
                  ),
                  showDefaultActions: false,
                  showDefaultTools: false,
                  controller: drawingController,
                ),
              ),
            ),
          );
        },
      );
  }


  PaintContent? createContentFromJson(String type, Map<String, dynamic> json) { // todo : put the function into a service
    switch (type) {
      case 'SimpleLine':
        return SimpleLine.fromJson(json);
      case 'SmoothLine':
        return SmoothLine.fromJson(json);
      case 'StraightLine':
        return StraightLine.fromJson(json);
      case 'Rectangle':
        return Rectangle.fromJson(json);
      case 'Circle':
        return Circle.fromJson(json);
      case 'Eraser':
        return Eraser.fromJson(json);
      default:
        return null; // Type inconnu
    }
  }
}