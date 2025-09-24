import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:pictionnary/drawingScreen/tools/color_picker_tool.dart';

class DrawingScreen extends StatefulWidget {
  final String gameRoundId;

  const DrawingScreen({super.key, required this.gameRoundId});

  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final DrawingController _drawingController = DrawingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String gameRoundId;

  Color currentColor = Colors.black;

  @override
  void initState() {
    super.initState();
    gameRoundId = widget.gameRoundId;

    _drawingController.addListener(() {
      _sendDrawingToFirebase();
    });
  }


  @override
  void dispose() {
    _drawingController.removeListener(_sendDrawingToFirebase); 
    super.dispose();
  }


  void _sendDrawingToFirebase() async {
    // Récupére le contenu actuel en JSON
    final jsonContent = _drawingController.getJsonList();

    // Envoie les données à Firebase // todo : put the function into the service 
    await _firestore.collection('drawings').add({
      'drawing': jsonContent,
      'timestamp': FieldValue.serverTimestamp(),
      'gameRoundId': gameRoundId,
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        width: 800,
        height: 800,
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: Colors.blueGrey, width: 1),
        ),
        child: DrawingBoard(
          showDefaultActions: true,
          showDefaultTools: true,
          controller: _drawingController,
          background:
              Container(width: 800, height: 800, color: Colors.yellow[100]),
          defaultToolsBuilder: (Type currType, DrawingController controller) {
            
            return DrawingBoard.defaultTools(currType, controller)
              ..insert(
                1,
                DefToolItem(
                  icon: Icons.color_lens,
                  isActive: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Sélectionnez une couleur'),
                          content: SingleChildScrollView(
                            child: MyColorPickerWidget(
                              currentColor: currentColor,
                              onColorSelected: (color) {
                                currentColor = color;
                                _drawingController.setStyle(color: color);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Fermer'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
          },
        ),
      );
  }
}