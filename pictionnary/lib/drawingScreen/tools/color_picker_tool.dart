import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class MyColorPickerWidget extends StatefulWidget {
  final Function(Color) onColorSelected;
  final Color currentColor; // Ajout de la couleur actuelle

  MyColorPickerWidget({required this.onColorSelected, required this.currentColor});

  @override
  _ColorPickerWidgetState createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<MyColorPickerWidget> {
  late Color currentColor;

  @override
  void initState() {
    super.initState();
    currentColor = widget.currentColor; 
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Affiche la couleur actuelle
        Container(
          height: 50,
          width: 50,
          color: currentColor,
        ),
        ElevatedButton(
          child: const Text('Choisissez une couleur'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Sélectionnez une couleur'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        ColorPicker(
                          pickerColor: currentColor,
                          onColorChanged: (color) {
                            setState(() {
                              currentColor = color;
                              widget.onColorSelected(color); // Notifie le changement de couleur
                            });
                          },
                          pickerAreaHeightPercent: 0.7,
                        ),
                      ],
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
      ],
    );
  }
}
